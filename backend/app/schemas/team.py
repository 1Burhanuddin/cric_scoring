from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


class TeamPlayerOut(BaseModel):
    id: str
    role: str = "player"

    @classmethod
    def from_model(cls, player: Any) -> "TeamPlayerOut":
        return cls(id=player.user_id, role=player.role)


class TeamOut(BaseModel):
    """Mirrors data/lib/api/team/team_model.dart TeamModel. `stat` and
    `created_by_user` are excluded from JSON there too (fetched separately),
    matching TeamService.fetchDetailsOfTeam's two-step hydration.
    """

    id: str
    name: str
    name_lowercase: str
    city: str | None = None
    name_initial: str | None = None
    profile_img_url: str | None = None
    created_by: str | None = None
    created_at: datetime | None = None
    team_players: list[TeamPlayerOut] = Field(default_factory=list)

    @classmethod
    def from_model(cls, team: Any) -> "TeamOut":
        return cls(
            id=team.id,
            name=team.name,
            name_lowercase=team.name_lowercase,
            city=team.city,
            name_initial=team.name_initial,
            profile_img_url=team.profile_img_url,
            created_by=team.created_by,
            created_at=team.created_at,
            team_players=[TeamPlayerOut.from_model(p) for p in team.players],
        )


class TeamUpdate(BaseModel):
    name: str | None = None
    city: str | None = None
    profile_img_url: str | None = None


class TeamMatchStatusOut(BaseModel):
    win: int = 0
    tie: int = 0
    lost: int = 0


class TeamStatOut(BaseModel):
    played: int = 0
    status: TeamMatchStatusOut = TeamMatchStatusOut()
    runs: int = 0
    wickets: int = 0
    batting_average: float = 0
    bowling_average: float = 0
    highest_runs: int = 0
    lowest_runs: int = 0
    run_rate: float = 0

    @classmethod
    def from_model(cls, stat: Any | None) -> "TeamStatOut":
        if stat is None:
            return cls()
        return cls(
            played=stat.played,
            status=TeamMatchStatusOut(win=stat.win, tie=stat.tie, lost=stat.lost),
            runs=stat.runs,
            wickets=stat.wickets,
            batting_average=float(stat.batting_average),
            bowling_average=float(stat.bowling_average),
            highest_runs=stat.highest_runs,
            lowest_runs=stat.lowest_runs,
            run_rate=float(stat.run_rate),
        )


class TeamStatIn(BaseModel):
    played: int = 0
    status: TeamMatchStatusOut = TeamMatchStatusOut()
    runs: int = 0
    wickets: int = 0
    batting_average: float = 0
    bowling_average: float = 0
    highest_runs: int = 0
    lowest_runs: int = 0
    run_rate: float = 0


class TeamPlayerIn(BaseModel):
    id: str
    role: str = "player"


class TeamPlayersRequest(BaseModel):
    players: list[TeamPlayerIn]


class TeamOwnerChangeRequest(BaseModel):
    owner_id: str
    players: list[TeamPlayerIn]


class TeamUpsertRequest(BaseModel):
    name: str
    city: str | None = None
    name_initial: str | None = None
    profile_img_url: str | None = None
    created_by: str | None = None
    team_players: list[TeamPlayerIn] = Field(default_factory=list)
