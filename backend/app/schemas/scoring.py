from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


def _ts(value: datetime | None) -> dict | None:
    """Matches data/lib/converter/timestamp_json_converter.dart's expected
    shape for @TimeStampJsonConverter() fields: {"_seconds": int, "_nanoseconds": int}.
    """
    if value is None:
        return None
    return {"_seconds": int(value.timestamp()), "_nanoseconds": value.microsecond * 1000}


def _ts_in_dict(d: dict, key: str) -> dict:
    """Wraps an ISO-string timestamp inside a JSONB-stored dict (e.g. one
    wicket/milestone entry) into the same _seconds/_nanoseconds shape.
    """
    value = d.get(key)
    if value is None:
        return d
    if isinstance(value, str):
        value = datetime.fromisoformat(value)
    return {**d, key: _ts(value)}


# ---- innings -----------------------------------------------------------


class InningOut(BaseModel):
    id: str
    match_id: str
    team_id: str
    overs: float = 0
    index: int = 0
    total_runs: int = 0
    total_wickets: int = 0
    innings_status: int | None = None

    @classmethod
    def from_model(cls, inning: Any) -> "InningOut":
        return cls(
            id=inning.id,
            match_id=inning.match_id,
            team_id=inning.team_id,
            overs=float(inning.overs),
            index=inning.index,
            total_runs=inning.total_runs,
            total_wickets=inning.total_wickets,
            innings_status=inning.innings_status,
        )


class InningIn(BaseModel):
    id: str
    match_id: str
    team_id: str
    overs: float = 0
    index: int = 0
    total_runs: int = 0
    total_wickets: int = 0
    innings_status: int | None = None


class InningsBatchCreateRequest(BaseModel):
    innings: list[InningIn]


class InningStatusUpdate(BaseModel):
    innings_status: int


class InningsStatusBatchUpdate(BaseModel):
    statuses: dict[str, int]  # inning_id -> InningStatus.value


# ---- ball scores ---------------------------------------------------------


class BallScoreOut(BaseModel):
    id: str
    inning_id: str
    match_id: str
    over_number: int
    ball_number: int
    bowler_id: str
    batsman_id: str
    non_striker_id: str
    runs_scored: int = 0
    extras_type: int | None = None
    extras_awarded: int | None = None
    wicket_type: int | None = None
    fielding_position: int | None = None
    player_out_id: str | None = None
    wicket_taker_id: str | None = None
    is_four: bool = False
    is_six: bool = False
    time: datetime | None = None
    score_time: dict | None = None

    @classmethod
    def from_model(cls, ball: Any) -> "BallScoreOut":
        return cls(
            id=ball.id,
            inning_id=ball.inning_id,
            match_id=ball.match_id,
            over_number=ball.over_number,
            ball_number=ball.ball_number,
            bowler_id=ball.bowler_id,
            batsman_id=ball.batsman_id,
            non_striker_id=ball.non_striker_id,
            runs_scored=ball.runs_scored,
            extras_type=ball.extras_type,
            extras_awarded=ball.extras_awarded,
            wicket_type=ball.wicket_type,
            fielding_position=ball.fielding_position,
            player_out_id=ball.player_out_id,
            wicket_taker_id=ball.wicket_taker_id,
            is_four=ball.is_four,
            is_six=ball.is_six,
            time=ball.time,
            score_time=_ts(ball.score_time),
        )


class UpdatedPlayerIn(BaseModel):
    id: str
    status: int = 3


class AddBallScoreRequest(BaseModel):
    id: str
    inning_id: str
    match_id: str
    over_number: int
    ball_number: int
    bowler_id: str
    batsman_id: str
    non_striker_id: str
    runs_scored: int = 0
    extras_type: int | None = None
    extras_awarded: int | None = None
    wicket_type: int | None = None
    fielding_position: int | None = None
    player_out_id: str | None = None
    wicket_taker_id: str | None = None
    is_four: bool = False
    is_six: bool = False
    time: datetime | None = None

    # compound update fields (was: MatchService.updateTeamScoreAndSquadViaTransaction
    # + InningsService.updateInningScoreDetailViaTransaction, done atomically
    # alongside the ball insert since everything is Postgres now)
    batting_team_id: str
    batting_team_inning_id: str
    total_runs: int
    bowling_team_id: str
    bowling_team_inning_id: str
    total_wicket_taken: int
    total_bowling_team_runs: int | None = None
    over: float | None = None
    updated_player: UpdatedPlayerIn | None = None


class DeleteBallScoreRequest(BaseModel):
    batting_team_id: str
    batting_team_inning_id: str
    total_runs: int
    bowling_team_id: str
    bowling_team_inning_id: str
    total_wicket_taken: int
    total_bowling_team_runs: int | None = None
    over: float | None = None
    updated_players: list[UpdatedPlayerIn] = Field(default_factory=list)


# ---- partnerships ----------------------------------------------------------


class PartnershipPlayerOut(BaseModel):
    player_id: str
    runs: int = 0
    ball_faced: int = 0
    fours: int = 0
    sixes: int = 0


class PartnershipOut(BaseModel):
    id: str
    match_id: str
    inning_id: str
    player_ids: list[str] = Field(default_factory=list)
    players: list[PartnershipPlayerOut] = Field(default_factory=list)
    runs: int = 0
    extras: int = 0
    ball_faced: int = 0
    start_over: float = 0
    end_over: float = 0

    @classmethod
    def from_model(cls, p: Any) -> "PartnershipOut":
        return cls(
            id=p.id,
            match_id=p.match_id,
            inning_id=p.inning_id,
            player_ids=p.player_ids or [],
            players=p.players or [],
            runs=p.runs,
            extras=p.extras,
            ball_faced=p.ball_faced,
            start_over=float(p.start_over),
            end_over=float(p.end_over),
        )


class PartnershipUpsertRequest(BaseModel):
    match_id: str
    inning_id: str
    player_ids: list[str] = Field(default_factory=list)
    players: list[PartnershipPlayerOut] = Field(default_factory=list)
    runs: int = 0
    extras: int = 0
    ball_faced: int = 0
    start_over: float = 0
    end_over: float = 0


# ---- match events ------------------------------------------------------


class MatchEventOut(BaseModel):
    id: str
    match_id: str
    inning_id: str
    type: int
    time: dict | None = None
    bowler_id: str | None = None
    batsman_id: str | None = None
    fielding_position: int | None = None
    over: float = 0
    ball_ids: list[str] = Field(default_factory=list)
    wickets: list[dict] = Field(default_factory=list)
    milestone: list[dict] = Field(default_factory=list)

    @classmethod
    def from_model(cls, e: Any) -> "MatchEventOut":
        return cls(
            id=e.id,
            match_id=e.match_id,
            inning_id=e.inning_id,
            type=e.type,
            time=_ts(e.time),
            bowler_id=e.bowler_id,
            batsman_id=e.batsman_id,
            fielding_position=e.fielding_position,
            over=float(e.over),
            ball_ids=e.ball_ids or [],
            wickets=[_ts_in_dict(w, "time") for w in (e.wickets or [])],
            milestone=[_ts_in_dict(m, "time") for m in (e.milestone or [])],
        )


class MatchEventUpsertRequest(BaseModel):
    match_id: str
    inning_id: str
    type: int
    time: datetime
    bowler_id: str | None = None
    batsman_id: str | None = None
    fielding_position: int | None = None
    over: float = 0
    ball_ids: list[str] = Field(default_factory=list)
    wickets: list[dict] = Field(default_factory=list)
    milestone: list[dict] = Field(default_factory=list)
