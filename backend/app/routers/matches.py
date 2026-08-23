from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Query
from sqlalchemy import and_, or_
from sqlalchemy.orm import Session, joinedload

from ..auth.deps import get_current_user
from ..database import get_db
from ..errors import ApiError
from ..models import Match, MatchPlayer, MatchSetting, MatchTeam, User
from ..schemas.match import (
    CurrentTeamUpdateRequest,
    MatchOut,
    MatchSettingOut,
    MatchStatusUpdateRequest,
    MatchUpsertRequest,
    OwnerChangeRequest,
    RevisedTargetRequest,
    SquadUpdateRequest,
    TossUpdateRequest,
)

router = APIRouter(prefix="/matches", tags=["matches"])

_LOAD = (joinedload(Match.teams).joinedload(MatchTeam.squad),)


def _get_match_or_404(db: Session, match_id: str) -> Match:
    match = db.query(Match).options(*_LOAD).filter(Match.id == match_id).one_or_none()
    if match is None:
        raise ApiError(404, "something-went-wrong", "Match not found")
    return match


def _replace_teams(db: Session, match_id: str, teams_in) -> None:
    db.query(MatchTeam).filter(MatchTeam.match_id == match_id).delete()
    db.flush()
    for team_in in teams_in:
        match_team = MatchTeam(
            match_id=match_id,
            team_id=team_in.team_id,
            captain_id=team_in.captain_id,
            admin_id=team_in.admin_id,
            over=team_in.over,
            run=team_in.run,
            wicket=team_in.wicket,
        )
        db.add(match_team)
        db.flush()
        for player_in in team_in.squad:
            db.add(
                MatchPlayer(
                    match_team_id=match_team.id,
                    user_id=player_in.id,
                    status=player_in.status,
                )
            )


@router.get("", response_model=list[MatchOut])
def get_matches_by_ids(ids: list[str] = Query(...), db: Session = Depends(get_db)) -> list[MatchOut]:
    matches = db.query(Match).options(*_LOAD).filter(Match.id.in_(ids)).all()
    return [MatchOut.from_model(m) for m in matches]


@router.get("/by-team/{team_id}", response_model=list[MatchOut])
def get_matches_by_team(
    team_id: str, limit: int = 10, db: Session = Depends(get_db)
) -> list[MatchOut]:
    matches = (
        db.query(Match)
        .options(*_LOAD)
        .join(MatchTeam, MatchTeam.match_id == Match.id)
        .filter(MatchTeam.team_id == team_id)
        .order_by(Match.id)
        .limit(limit)
        .all()
    )
    return [MatchOut.from_model(m) for m in matches]


@router.get("/by-user/{user_id}", response_model=list[MatchOut])
def get_matches_by_user(
    user_id: str, limit: int = 10, db: Session = Depends(get_db)
) -> list[MatchOut]:
    """Covers MatchService.streamUserRelatedMatches/streamUserMatches: matches
    the user created, plays in, or created a participating team for.
    """
    matches = (
        db.query(Match)
        .options(*_LOAD)
        .outerjoin(MatchTeam, MatchTeam.match_id == Match.id)
        .outerjoin(MatchPlayer, MatchPlayer.match_team_id == MatchTeam.id)
        .filter(
            or_(
                Match.created_by == user_id,
                MatchPlayer.user_id == user_id,
                Match.team_creator_ids.any(user_id),
            )
        )
        .order_by(Match.id)
        .limit(limit)
        .distinct()
        .all()
    )
    return [MatchOut.from_model(m) for m in matches]


@router.get("/owned-count", response_model=int)
def get_owned_match_count(user_id: str, db: Session = Depends(get_db)) -> int:
    return db.query(Match).filter(Match.created_by == user_id).count()


@router.get("/active", response_model=list[MatchOut])
def get_active_matches(limit: int = 10, db: Session = Depends(get_db)) -> list[MatchOut]:
    cutoff = datetime.now(timezone.utc) - timedelta(hours=1, minutes=30)
    matches = (
        db.query(Match)
        .options(*_LOAD)
        .filter(and_(Match.match_status == 2, Match.updated_at > cutoff))
        .limit(limit)
        .all()
    )
    return [MatchOut.from_model(m) for m in matches]


@router.get("/upcoming", response_model=list[MatchOut])
def get_upcoming_matches(limit: int = 10, db: Session = Depends(get_db)) -> list[MatchOut]:
    now = datetime.now(timezone.utc)
    start_of_day = datetime(now.year, now.month, now.day, tzinfo=timezone.utc)
    a_month_after = start_of_day + timedelta(days=30)
    matches = (
        db.query(Match)
        .options(*_LOAD)
        .filter(
            and_(
                Match.match_status == 1,
                Match.start_at >= start_of_day,
                Match.start_at <= a_month_after,
            )
        )
        .limit(limit)
        .all()
    )
    return [MatchOut.from_model(m) for m in matches]


@router.get("/finished", response_model=list[MatchOut])
def get_finished_matches(db: Session = Depends(get_db)) -> list[MatchOut]:
    now = datetime.now(timezone.utc)
    cutoff = datetime(now.year, now.month, now.day, tzinfo=timezone.utc) - timedelta(days=15)
    matches = (
        db.query(Match)
        .options(*_LOAD)
        .filter(and_(Match.match_status == 3, Match.updated_at > cutoff))
        .all()
    )
    return [MatchOut.from_model(m) for m in matches]


@router.get("/by-status", response_model=list[MatchOut])
def get_matches_by_status(
    status: list[int] = Query(...), limit: int = 10, db: Session = Depends(get_db)
) -> list[MatchOut]:
    matches = (
        db.query(Match)
        .options(*_LOAD)
        .filter(Match.match_status.in_(status))
        .order_by(Match.id)
        .limit(limit)
        .all()
    )
    return [MatchOut.from_model(m) for m in matches]


@router.get("/{match_id}", response_model=MatchOut)
def get_match(match_id: str, db: Session = Depends(get_db)) -> MatchOut:
    return MatchOut.from_model(_get_match_or_404(db, match_id))


@router.get("/{match_id}/setting", response_model=MatchSettingOut)
def get_match_setting(match_id: str, db: Session = Depends(get_db)) -> MatchSettingOut:
    setting = db.query(MatchSetting).filter(MatchSetting.match_id == match_id).one_or_none()
    return MatchSettingOut.from_model(setting)


@router.put("/{match_id}/setting", response_model=MatchSettingOut)
def upsert_match_setting(
    match_id: str, payload: MatchSettingOut, db: Session = Depends(get_db)
) -> MatchSettingOut:
    setting = db.query(MatchSetting).filter(MatchSetting.match_id == match_id).one_or_none()
    if setting is None:
        setting = MatchSetting(match_id=match_id)
        db.add(setting)
    setting.continue_with_injured_player = payload.continue_with_injured_player
    setting.show_wagon_wheel_for_less_run = payload.show_wagon_wheel_for_less_run
    setting.show_wagon_wheel_for_dot_ball = payload.show_wagon_wheel_for_dot_ball
    db.commit()
    db.refresh(setting)
    return MatchSettingOut.from_model(setting)


@router.put("/{match_id}", response_model=MatchOut)
def upsert_match(
    match_id: str,
    payload: MatchUpsertRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> MatchOut:
    match = db.query(Match).filter(Match.id == match_id).one_or_none()
    if match is None:
        match = Match(id=match_id)
        db.add(match)

    match.tournament_id = payload.tournament_id
    match.match_group = payload.match_group
    match.match_group_number = payload.match_group_number
    match.match_type = payload.match_type
    match.number_of_over = payload.number_of_over
    match.over_per_bowler = payload.over_per_bowler
    match.team_creator_ids = payload.team_creator_ids
    match.power_play_overs1 = payload.power_play_overs1
    match.power_play_overs2 = payload.power_play_overs2
    match.power_play_overs3 = payload.power_play_overs3
    match.city = payload.city
    match.ground = payload.ground
    match.start_time = payload.start_time
    match.start_at = payload.start_at
    match.ball_type = payload.ball_type
    match.pitch_type = payload.pitch_type
    match.created_by = payload.created_by
    match.umpire_ids = payload.umpire_ids
    match.scorer_ids = payload.scorer_ids
    match.commentator_ids = payload.commentator_ids
    match.referee_id = payload.referee_id
    match.match_status = payload.match_status
    db.flush()

    _replace_teams(db, match_id, payload.teams)

    db.commit()
    return MatchOut.from_model(_get_match_or_404(db, match_id))


@router.patch("/{match_id}/toss", response_model=MatchOut)
def update_toss(
    match_id: str,
    payload: TossUpdateRequest,
    db: Session = Depends(get_db),
) -> MatchOut:
    match = _get_match_or_404(db, match_id)
    match.toss_winner_id = payload.toss_winner_id
    match.toss_decision = payload.toss_decision
    match.current_playing_team_id = payload.current_playing_team_id
    db.commit()
    return MatchOut.from_model(_get_match_or_404(db, match_id))


@router.patch("/{match_id}/status", response_model=MatchOut)
def update_status(
    match_id: str, payload: MatchStatusUpdateRequest, db: Session = Depends(get_db)
) -> MatchOut:
    match = _get_match_or_404(db, match_id)
    match.match_status = payload.match_status
    db.commit()
    return MatchOut.from_model(_get_match_or_404(db, match_id))


@router.patch("/{match_id}/current-team", response_model=MatchOut)
def update_current_team(
    match_id: str, payload: CurrentTeamUpdateRequest, db: Session = Depends(get_db)
) -> MatchOut:
    match = _get_match_or_404(db, match_id)
    match.current_playing_team_id = payload.team_id
    db.commit()
    return MatchOut.from_model(_get_match_or_404(db, match_id))


@router.patch("/{match_id}/revised-target", response_model=MatchOut)
def update_revised_target(
    match_id: str, payload: RevisedTargetRequest, db: Session = Depends(get_db)
) -> MatchOut:
    match = _get_match_or_404(db, match_id)
    now = datetime.now(timezone.utc)
    match.revised_target = {
        "runs": payload.runs,
        "overs": payload.overs,
        "time": now.isoformat(),
        "revised_time": now.isoformat(),
    }
    db.commit()
    return MatchOut.from_model(_get_match_or_404(db, match_id))


@router.patch("/{match_id}/owner", response_model=MatchOut)
def change_owner(
    match_id: str, payload: OwnerChangeRequest, db: Session = Depends(get_db)
) -> MatchOut:
    match = _get_match_or_404(db, match_id)
    match.created_by = payload.owner_id
    db.commit()
    return MatchOut.from_model(_get_match_or_404(db, match_id))


@router.put("/{match_id}/teams/{team_id}/squad", response_model=MatchOut)
def update_team_squad(
    match_id: str,
    team_id: str,
    payload: SquadUpdateRequest,
    db: Session = Depends(get_db),
) -> MatchOut:
    match_team = (
        db.query(MatchTeam)
        .filter(MatchTeam.match_id == match_id, MatchTeam.team_id == team_id)
        .one_or_none()
    )
    if match_team is None:
        raise ApiError(404, "something-went-wrong", "Match team not found")

    existing = {p.user_id: p for p in db.query(MatchPlayer).filter(MatchPlayer.match_team_id == match_team.id)}
    for player_in in payload.squad:
        if player_in.id in existing:
            existing[player_in.id].status = player_in.status
        else:
            db.add(MatchPlayer(match_team_id=match_team.id, user_id=player_in.id, status=player_in.status))

    db.commit()
    return MatchOut.from_model(_get_match_or_404(db, match_id))


@router.delete("/{match_id}", status_code=204)
def delete_match(match_id: str, db: Session = Depends(get_db)) -> None:
    match = _get_match_or_404(db, match_id)
    db.delete(match)
    db.commit()
