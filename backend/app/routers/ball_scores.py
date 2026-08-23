from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..errors import ApiError
from ..models import BallScore, Inning, MatchPlayer, MatchTeam
from ..schemas.scoring import AddBallScoreRequest, BallScoreOut, DeleteBallScoreRequest

router = APIRouter(prefix="/ball-scores", tags=["ball-scores"])


def _apply_team_and_inning_updates(
    db: Session,
    *,
    match_id: str,
    batting_team_id: str,
    batting_team_inning_id: str,
    total_runs: int,
    bowling_team_id: str,
    bowling_team_inning_id: str,
    total_wicket_taken: int,
    total_bowling_team_runs: int | None,
    over: float | None,
) -> None:
    batting_team = (
        db.query(MatchTeam).filter(MatchTeam.match_id == match_id, MatchTeam.team_id == batting_team_id).one_or_none()
    )
    bowling_team = (
        db.query(MatchTeam).filter(MatchTeam.match_id == match_id, MatchTeam.team_id == bowling_team_id).one_or_none()
    )
    if batting_team is None or bowling_team is None:
        raise ApiError(404, "something-went-wrong", "Match team not found")

    batting_team.run = total_runs
    if over is not None:
        batting_team.over = over
    bowling_team.wicket = total_wicket_taken
    if total_bowling_team_runs is not None:
        bowling_team.run = total_bowling_team_runs

    batting_inning = db.query(Inning).filter(Inning.id == batting_team_inning_id).one_or_none()
    bowling_inning = db.query(Inning).filter(Inning.id == bowling_team_inning_id).one_or_none()
    if batting_inning is None or bowling_inning is None:
        raise ApiError(404, "something-went-wrong", "Inning not found")

    batting_inning.total_runs = total_runs
    if over is not None:
        batting_inning.overs = over
    bowling_inning.total_wickets = total_wicket_taken
    if total_bowling_team_runs is not None:
        bowling_inning.total_runs = total_bowling_team_runs


@router.post("", response_model=BallScoreOut, status_code=201)
def add_ball_score(payload: AddBallScoreRequest, db: Session = Depends(get_db)) -> BallScoreOut:
    """Postgres equivalent of BallScoreService.addBallScoreAndUpdateTeamDetails.
    Everything (ball insert, match-team score, inning totals, squad status) now
    lives in Postgres, so this is a single real DB transaction - stronger than
    the old Firestore version, which could only cover ball_score+innings+match
    atomically because all three happened to be Firestore too at the time.
    """
    _apply_team_and_inning_updates(
        db,
        match_id=payload.match_id,
        batting_team_id=payload.batting_team_id,
        batting_team_inning_id=payload.batting_team_inning_id,
        total_runs=payload.total_runs,
        bowling_team_id=payload.bowling_team_id,
        bowling_team_inning_id=payload.bowling_team_inning_id,
        total_wicket_taken=payload.total_wicket_taken,
        total_bowling_team_runs=payload.total_bowling_team_runs,
        over=payload.over,
    )

    if payload.updated_player is not None:
        match_team = (
            db.query(MatchTeam)
            .filter(MatchTeam.match_id == payload.match_id, MatchTeam.team_id == payload.batting_team_id)
            .one()
        )
        player = (
            db.query(MatchPlayer)
            .filter(MatchPlayer.match_team_id == match_team.id, MatchPlayer.user_id == payload.updated_player.id)
            .one_or_none()
        )
        if player is None:
            db.add(
                MatchPlayer(
                    match_team_id=match_team.id,
                    user_id=payload.updated_player.id,
                    status=payload.updated_player.status,
                )
            )
        else:
            player.status = payload.updated_player.status

    ball = db.query(BallScore).filter(BallScore.id == payload.id).one_or_none()
    if ball is None:
        ball = BallScore(id=payload.id)
        db.add(ball)

    ball.inning_id = payload.inning_id
    ball.match_id = payload.match_id
    ball.over_number = payload.over_number
    ball.ball_number = payload.ball_number
    ball.bowler_id = payload.bowler_id
    ball.batsman_id = payload.batsman_id
    ball.non_striker_id = payload.non_striker_id
    ball.runs_scored = payload.runs_scored
    ball.extras_type = payload.extras_type
    ball.extras_awarded = payload.extras_awarded
    ball.wicket_type = payload.wicket_type
    ball.fielding_position = payload.fielding_position
    ball.player_out_id = payload.player_out_id
    ball.wicket_taker_id = payload.wicket_taker_id
    ball.is_four = payload.is_four
    ball.is_six = payload.is_six
    ball.time = payload.time

    db.commit()
    db.refresh(ball)
    return BallScoreOut.from_model(ball)


@router.get("", response_model=list[BallScoreOut])
def get_ball_scores_by_match_ids(match_ids: list[str] = Query(...), db: Session = Depends(get_db)) -> list[BallScoreOut]:
    if not match_ids:
        return []
    balls = db.query(BallScore).filter(BallScore.match_id.in_(match_ids)).all()
    return [BallScoreOut.from_model(b) for b in balls]


@router.get("/by-innings", response_model=list[BallScoreOut])
def get_ball_scores_by_inning_ids(
    inning_ids: list[str] = Query(...), limit: int | None = None, db: Session = Depends(get_db)
) -> list[BallScoreOut]:
    if not inning_ids:
        return []
    query = db.query(BallScore).filter(BallScore.inning_id.in_(inning_ids)).order_by(BallScore.score_time.desc())
    if limit is not None:
        query = query.limit(limit)
    return [BallScoreOut.from_model(b) for b in query.all()]


@router.post("/{ball_id}/delete-and-update", status_code=204)
def delete_ball_score(ball_id: str, payload: DeleteBallScoreRequest, db: Session = Depends(get_db)) -> None:
    ball = db.query(BallScore).filter(BallScore.id == ball_id).one_or_none()
    if ball is None:
        raise ApiError(404, "something-went-wrong", "Ball score not found")

    _apply_team_and_inning_updates(
        db,
        match_id=ball.match_id,
        batting_team_id=payload.batting_team_id,
        batting_team_inning_id=payload.batting_team_inning_id,
        total_runs=payload.total_runs,
        bowling_team_id=payload.bowling_team_id,
        bowling_team_inning_id=payload.bowling_team_inning_id,
        total_wicket_taken=payload.total_wicket_taken,
        total_bowling_team_runs=payload.total_bowling_team_runs,
        over=payload.over,
    )

    if payload.updated_players:
        match_team = (
            db.query(MatchTeam)
            .filter(MatchTeam.match_id == ball.match_id, MatchTeam.team_id == payload.batting_team_id)
            .one()
        )
        for updated in payload.updated_players:
            player = (
                db.query(MatchPlayer)
                .filter(MatchPlayer.match_team_id == match_team.id, MatchPlayer.user_id == updated.id)
                .one_or_none()
            )
            if player is not None:
                player.status = updated.status

    db.delete(ball)
    db.commit()
