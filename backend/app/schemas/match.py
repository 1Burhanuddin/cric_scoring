from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


def _ts(value: datetime | None) -> dict | None:
    """Matches data/lib/converter/timestamp_json_converter.dart's expected shape
    for @TimeStampJsonConverter() fields when decoded from plain JSON (not a
    live Firestore SDK Timestamp): {"_seconds": int, "_nanoseconds": int}.
    """
    if value is None:
        return None
    return {"_seconds": int(value.timestamp()), "_nanoseconds": value.microsecond * 1000}


class MatchPlayerOut(BaseModel):
    id: str
    status: int = 3  # PlayerStatus.played
    performance: list = Field(default_factory=list)

    @classmethod
    def from_model(cls, player: Any) -> "MatchPlayerOut":
        return cls(id=player.user_id, status=player.status, performance=player.performance)


class MatchTeamOut(BaseModel):
    team_id: str
    captain_id: str | None = None
    admin_id: str | None = None
    over: float = 0
    run: int = 0
    wicket: int = 0
    squad: list[MatchPlayerOut] = Field(default_factory=list)

    @classmethod
    def from_model(cls, match_team: Any) -> "MatchTeamOut":
        return cls(
            team_id=match_team.team_id,
            captain_id=match_team.captain_id,
            admin_id=match_team.admin_id,
            over=float(match_team.over),
            run=match_team.run,
            wicket=match_team.wicket,
            squad=[MatchPlayerOut.from_model(p) for p in match_team.squad],
        )


class MatchOut(BaseModel):
    """Mirrors data/lib/api/match/match_model.dart MatchModel. `teams[].team`,
    `umpires`/`scorers`/`commentators`/`referee` are excluded from JSON there
    too (hydrated client-side from the *_ids fields), matching MatchService's
    existing hydration pattern.
    """

    model_config = {"json_encoders": {}}

    id: str
    teams: list[MatchTeamOut] = Field(default_factory=list)
    tournament_id: str | None = None
    match_group: int | None = None
    match_group_number: int | None = None
    match_type: int
    number_of_over: int
    over_per_bowler: int
    players: list[str] = Field(default_factory=list)
    team_ids: list[str] = Field(default_factory=list)
    team_creator_ids: list[str] = Field(default_factory=list)
    power_play_overs1: list[int] = Field(default_factory=list)
    power_play_overs2: list[int] = Field(default_factory=list)
    power_play_overs3: list[int] = Field(default_factory=list)
    city: str
    ground: str
    start_time: datetime | None = None
    start_at: dict | None = None
    ball_type: int
    pitch_type: int
    created_by: str
    umpire_ids: list[str] | None = None
    scorer_ids: list[str] | None = None
    commentator_ids: list[str] | None = None
    referee_id: str | None = None
    match_status: int
    toss_decision: int | None = None
    toss_winner_id: str | None = None
    current_playing_team_id: str | None = None
    revised_target: dict | None = None
    updated_at: dict | None = None

    @classmethod
    def from_model(cls, match: Any) -> "MatchOut":
        revised_target = None
        if match.revised_target:
            revised_target = dict(match.revised_target)
            if revised_target.get("time"):
                pass  # plain DateTime field on RevisedTarget, stored as ISO string already
            if revised_target.get("revised_time"):
                revised_target["revised_time"] = _ts(
                    datetime.fromisoformat(revised_target["revised_time"])
                    if isinstance(revised_target["revised_time"], str)
                    else revised_target["revised_time"]
                )

        team_ids = [t.team_id for t in match.teams]
        players = [p.user_id for t in match.teams for p in t.squad]

        return cls(
            id=match.id,
            teams=[MatchTeamOut.from_model(t) for t in match.teams],
            tournament_id=match.tournament_id,
            match_group=match.match_group,
            match_group_number=match.match_group_number,
            match_type=match.match_type,
            number_of_over=match.number_of_over,
            over_per_bowler=match.over_per_bowler,
            players=players,
            team_ids=team_ids,
            team_creator_ids=match.team_creator_ids or [],
            power_play_overs1=match.power_play_overs1 or [],
            power_play_overs2=match.power_play_overs2 or [],
            power_play_overs3=match.power_play_overs3 or [],
            city=match.city,
            ground=match.ground,
            start_time=match.start_time,
            start_at=_ts(match.start_at),
            ball_type=match.ball_type,
            pitch_type=match.pitch_type,
            created_by=match.created_by,
            umpire_ids=match.umpire_ids or [],
            scorer_ids=match.scorer_ids or [],
            commentator_ids=match.commentator_ids or [],
            referee_id=match.referee_id,
            match_status=match.match_status,
            toss_decision=match.toss_decision,
            toss_winner_id=match.toss_winner_id,
            current_playing_team_id=match.current_playing_team_id,
            revised_target=revised_target,
            updated_at=_ts(match.updated_at),
        )


class MatchSettingOut(BaseModel):
    continue_with_injured_player: bool = True
    show_wagon_wheel_for_less_run: bool = True
    show_wagon_wheel_for_dot_ball: bool = True

    @classmethod
    def from_model(cls, setting: Any | None) -> "MatchSettingOut":
        if setting is None:
            return cls()
        return cls(
            continue_with_injured_player=setting.continue_with_injured_player,
            show_wagon_wheel_for_less_run=setting.show_wagon_wheel_for_less_run,
            show_wagon_wheel_for_dot_ball=setting.show_wagon_wheel_for_dot_ball,
        )


class MatchPlayerIn(BaseModel):
    id: str
    status: int = 3


class MatchTeamIn(BaseModel):
    team_id: str
    captain_id: str | None = None
    admin_id: str | None = None
    over: float = 0
    run: int = 0
    wicket: int = 0
    squad: list[MatchPlayerIn] = Field(default_factory=list)


class MatchUpsertRequest(BaseModel):
    teams: list[MatchTeamIn]
    tournament_id: str | None = None
    match_group: int | None = None
    match_group_number: int | None = None
    match_type: int
    number_of_over: int
    over_per_bowler: int
    team_creator_ids: list[str] = Field(default_factory=list)
    power_play_overs1: list[int] = Field(default_factory=list)
    power_play_overs2: list[int] = Field(default_factory=list)
    power_play_overs3: list[int] = Field(default_factory=list)
    city: str
    ground: str
    start_time: datetime | None = None
    start_at: datetime | None = None
    ball_type: int
    pitch_type: int
    created_by: str
    umpire_ids: list[str] = Field(default_factory=list)
    scorer_ids: list[str] = Field(default_factory=list)
    commentator_ids: list[str] = Field(default_factory=list)
    referee_id: str | None = None
    match_status: int


class TossUpdateRequest(BaseModel):
    toss_winner_id: str
    toss_decision: int
    current_playing_team_id: str


class MatchStatusUpdateRequest(BaseModel):
    match_status: int


class CurrentTeamUpdateRequest(BaseModel):
    team_id: str


class RevisedTargetRequest(BaseModel):
    runs: int = 0
    overs: float = 0


class OwnerChangeRequest(BaseModel):
    owner_id: str


class SquadUpdateRequest(BaseModel):
    squad: list[MatchPlayerIn]


