from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session, joinedload

from ..auth.deps import get_current_user
from ..database import get_db
from ..errors import ApiError
from ..models import Team, TeamPlayer, TeamStat, User
from ..schemas.team import (
    TeamOut,
    TeamOwnerChangeRequest,
    TeamPlayersRequest,
    TeamStatIn,
    TeamStatOut,
    TeamUpdate,
    TeamUpsertRequest,
)

router = APIRouter(prefix="/teams", tags=["teams"])


def _get_team_or_404(db: Session, team_id: str) -> Team:
    team = (
        db.query(Team).options(joinedload(Team.players)).filter(Team.id == team_id).one_or_none()
    )
    if team is None:
        raise ApiError(404, "something-went-wrong", "Team not found")
    return team


def _require_team_admin(team: Team, user: User) -> None:
    is_admin = team.created_by == user.id or any(
        p.user_id == user.id and p.role == "admin" for p in team.players
    )
    if not is_admin:
        raise ApiError(403, "something-went-wrong", "Only team admins can perform this action")


@router.get("/name-available", response_model=bool)
def is_team_name_available(name: str, db: Session = Depends(get_db)) -> bool:
    exists = db.query(Team).filter(Team.name_lowercase == name.lower()).first()
    return exists is None


@router.get("/search", response_model=list[TeamOut])
def search_teams(q: str, limit: int = 20, db: Session = Depends(get_db)) -> list[TeamOut]:
    teams = (
        db.query(Team)
        .options(joinedload(Team.players))
        .filter(Team.name_lowercase.like(f"{q.lower()}%"))
        .order_by(Team.id)
        .limit(limit)
        .all()
    )
    return [TeamOut.from_model(t) for t in teams]


@router.get("/by-member/{user_id}", response_model=list[TeamOut])
def get_teams_by_member(user_id: str, db: Session = Depends(get_db)) -> list[TeamOut]:
    """Teams where user_id is a player (any role) or the creator. Covers
    TeamService.streamUserRelatedTeams/streamUserOwnedTeams/
    streamUserRelatedTeamsByUserId on the Flutter side - those differ only in
    client-side filtering (e.g. admin-only for "owned"), not in the query.
    """
    teams = (
        db.query(Team)
        .options(joinedload(Team.players))
        .join(TeamPlayer, TeamPlayer.team_id == Team.id)
        .filter(TeamPlayer.user_id == user_id)
        .order_by(Team.id)
        .all()
    )
    return [TeamOut.from_model(t) for t in teams]


@router.get("", response_model=list[TeamOut])
def get_teams_by_ids(ids: list[str] = Query(...), db: Session = Depends(get_db)) -> list[TeamOut]:
    teams = db.query(Team).options(joinedload(Team.players)).filter(Team.id.in_(ids)).all()
    return [TeamOut.from_model(t) for t in teams]


@router.get("/{team_id}", response_model=TeamOut)
def get_team(team_id: str, db: Session = Depends(get_db)) -> TeamOut:
    return TeamOut.from_model(_get_team_or_404(db, team_id))


@router.get("/{team_id}/stat", response_model=TeamStatOut)
def get_team_stat(team_id: str, db: Session = Depends(get_db)) -> TeamStatOut:
    stat = db.query(TeamStat).filter(TeamStat.team_id == team_id).one_or_none()
    return TeamStatOut.from_model(stat)


@router.put("/{team_id}/stat", response_model=TeamStatOut)
def upsert_team_stat(team_id: str, payload: TeamStatIn, db: Session = Depends(get_db)) -> TeamStatOut:
    # As with user stats, computation still happens client-side from
    # Firestore-sourced match data (pending Stage 2); this just persists it.
    stat = db.query(TeamStat).filter(TeamStat.team_id == team_id).one_or_none()
    if stat is None:
        stat = TeamStat(team_id=team_id)
        db.add(stat)

    stat.played = payload.played
    stat.win = payload.status.win
    stat.tie = payload.status.tie
    stat.lost = payload.status.lost
    stat.runs = payload.runs
    stat.wickets = payload.wickets
    stat.batting_average = payload.batting_average
    stat.bowling_average = payload.bowling_average
    stat.highest_runs = payload.highest_runs
    stat.lowest_runs = payload.lowest_runs
    stat.run_rate = payload.run_rate
    db.commit()
    db.refresh(stat)
    return TeamStatOut.from_model(stat)


@router.put("/{team_id}", response_model=TeamOut)
def upsert_team(
    team_id: str,
    payload: TeamUpsertRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TeamOut:
    """Create-or-replace, matching the client's Firestore-era `.set(merge:true)`
    flow: the Flutter app pre-generates a team id (see TeamService.generateTeamId)
    and always sends the complete team representation, so this fully replaces
    the roster on every call rather than doing a partial merge.
    """
    team = (
        db.query(Team).options(joinedload(Team.players)).filter(Team.id == team_id).one_or_none()
    )

    if team is not None:
        _require_team_admin(team, current_user)
        team.name = payload.name
        team.name_lowercase = payload.name.lower()
        team.city = payload.city
        team.name_initial = payload.name_initial or (payload.name[:1].upper() if payload.name else None)
        team.profile_img_url = payload.profile_img_url
        if payload.created_by:
            team.created_by = payload.created_by
        db.query(TeamPlayer).filter(TeamPlayer.team_id == team_id).delete()
    else:
        team = Team(
            id=team_id,
            name=payload.name,
            name_lowercase=payload.name.lower(),
            city=payload.city,
            name_initial=payload.name_initial or (payload.name[:1].upper() if payload.name else None),
            profile_img_url=payload.profile_img_url,
            created_by=payload.created_by or current_user.id,
        )
        db.add(team)
        db.add(TeamStat(team_id=team_id))

    for player in payload.team_players:
        db.add(TeamPlayer(team_id=team_id, user_id=player.id, role=player.role))

    db.commit()
    db.refresh(team)
    return TeamOut.from_model(team)


@router.patch("/{team_id}", response_model=TeamOut)
def update_team(
    team_id: str,
    payload: TeamUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TeamOut:
    team = _get_team_or_404(db, team_id)
    _require_team_admin(team, current_user)

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(team, field, value)
    if payload.name is not None:
        team.name_lowercase = payload.name.lower()
        team.name_initial = payload.name[:1].upper()
    db.commit()
    db.refresh(team)
    return TeamOut.from_model(team)


@router.post("/{team_id}/players", response_model=TeamOut)
def add_players(
    team_id: str,
    payload: TeamPlayersRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TeamOut:
    team = _get_team_or_404(db, team_id)
    existing_user_ids = {p.user_id for p in team.players}
    for player in payload.players:
        if player.id not in existing_user_ids:
            db.add(TeamPlayer(team_id=team_id, user_id=player.id, role=player.role))
    db.commit()
    db.refresh(team)
    return TeamOut.from_model(team)


@router.put("/{team_id}/players", response_model=TeamOut)
def replace_players(
    team_id: str,
    payload: TeamOwnerChangeRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TeamOut:
    team = _get_team_or_404(db, team_id)
    _require_team_admin(team, current_user)

    db.query(TeamPlayer).filter(TeamPlayer.team_id == team_id).delete()
    for player in payload.players:
        db.add(TeamPlayer(team_id=team_id, user_id=player.id, role=player.role))
    team.created_by = payload.owner_id
    db.commit()
    db.refresh(team)
    return TeamOut.from_model(team)


@router.delete("/{team_id}/players", response_model=TeamOut)
def remove_players(
    team_id: str,
    payload: TeamPlayersRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TeamOut:
    team = _get_team_or_404(db, team_id)
    _require_team_admin(team, current_user)

    user_ids = {p.id for p in payload.players}
    db.query(TeamPlayer).filter(TeamPlayer.team_id == team_id, TeamPlayer.user_id.in_(user_ids)).delete(
        synchronize_session=False
    )
    db.commit()
    db.refresh(team)
    return TeamOut.from_model(team)


@router.delete("/{team_id}", status_code=204)
def delete_team(
    team_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> None:
    team = _get_team_or_404(db, team_id)
    _require_team_admin(team, current_user)
    db.delete(team)
    db.commit()
