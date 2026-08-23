from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, Numeric, SmallInteger, String, func
from sqlalchemy.dialects.postgresql import ARRAY, JSONB
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base, new_id


class Inning(Base):
    __tablename__ = "innings"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    match_id: Mapped[str] = mapped_column(ForeignKey("matches.id", ondelete="CASCADE"), index=True)
    team_id: Mapped[str] = mapped_column(ForeignKey("teams.id", ondelete="CASCADE"))
    overs: Mapped[float] = mapped_column(Numeric(6, 2), default=0)
    index: Mapped[int] = mapped_column(Integer, default=0)
    total_runs: Mapped[int] = mapped_column(Integer, default=0)
    total_wickets: Mapped[int] = mapped_column(Integer, default=0)
    innings_status: Mapped[int | None] = mapped_column(SmallInteger)


class BallScore(Base):
    __tablename__ = "ball_scores"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    inning_id: Mapped[str] = mapped_column(ForeignKey("innings.id", ondelete="CASCADE"), index=True)
    match_id: Mapped[str] = mapped_column(ForeignKey("matches.id", ondelete="CASCADE"), index=True)
    over_number: Mapped[int] = mapped_column(Integer)
    ball_number: Mapped[int] = mapped_column(Integer)
    bowler_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
    batsman_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
    non_striker_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
    runs_scored: Mapped[int] = mapped_column(Integer, default=0)
    extras_type: Mapped[int | None] = mapped_column(SmallInteger)
    extras_awarded: Mapped[int | None] = mapped_column(Integer)
    wicket_type: Mapped[int | None] = mapped_column(SmallInteger)
    fielding_position: Mapped[int | None] = mapped_column(SmallInteger)
    player_out_id: Mapped[str | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    wicket_taker_id: Mapped[str | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    is_four: Mapped[bool] = mapped_column(Boolean, default=False)
    is_six: Mapped[bool] = mapped_column(Boolean, default=False)
    time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    score_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), server_default=func.now())


class Partnership(Base):
    __tablename__ = "partnerships"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    match_id: Mapped[str] = mapped_column(ForeignKey("matches.id", ondelete="CASCADE"), index=True)
    inning_id: Mapped[str] = mapped_column(ForeignKey("innings.id", ondelete="CASCADE"), index=True)
    player_ids: Mapped[list[str]] = mapped_column(ARRAY(String(36)), default=list)
    players: Mapped[list] = mapped_column(JSONB, default=list)
    runs: Mapped[int] = mapped_column(Integer, default=0)
    extras: Mapped[int] = mapped_column(Integer, default=0)
    ball_faced: Mapped[int] = mapped_column(Integer, default=0)
    start_over: Mapped[float] = mapped_column(Numeric(6, 2), default=0)
    end_over: Mapped[float] = mapped_column(Numeric(6, 2), default=0)


class MatchEvent(Base):
    __tablename__ = "match_events"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    match_id: Mapped[str] = mapped_column(ForeignKey("matches.id", ondelete="CASCADE"), index=True)
    inning_id: Mapped[str] = mapped_column(ForeignKey("innings.id", ondelete="CASCADE"), index=True)
    type: Mapped[int] = mapped_column(SmallInteger)
    time: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    bowler_id: Mapped[str | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    batsman_id: Mapped[str | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    fielding_position: Mapped[int | None] = mapped_column(SmallInteger)
    over: Mapped[float] = mapped_column(Numeric(6, 2), default=0)
    ball_ids: Mapped[list[str]] = mapped_column(ARRAY(String(36)), default=list)
    wickets: Mapped[list] = mapped_column(JSONB, default=list)
    milestone: Mapped[list] = mapped_column(JSONB, default=list)
