from datetime import datetime

from sqlalchemy import (
    Boolean,
    DateTime,
    ForeignKey,
    Integer,
    Numeric,
    SmallInteger,
    String,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import ARRAY, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, new_id


class Match(Base):
    __tablename__ = "matches"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    tournament_id: Mapped[str | None] = mapped_column(
        ForeignKey("tournaments.id", ondelete="SET NULL"), index=True
    )
    match_group: Mapped[int | None] = mapped_column(SmallInteger)
    match_group_number: Mapped[int | None] = mapped_column(Integer)
    match_type: Mapped[int] = mapped_column(SmallInteger)
    number_of_over: Mapped[int] = mapped_column(Integer)
    over_per_bowler: Mapped[int] = mapped_column(Integer)
    power_play_overs1: Mapped[list[int]] = mapped_column(ARRAY(Integer), default=list)
    power_play_overs2: Mapped[list[int]] = mapped_column(ARRAY(Integer), default=list)
    power_play_overs3: Mapped[list[int]] = mapped_column(ARRAY(Integer), default=list)
    city: Mapped[str] = mapped_column(String(255))
    ground: Mapped[str] = mapped_column(String(255))
    start_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    start_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), index=True)
    ball_type: Mapped[int] = mapped_column(SmallInteger)
    pitch_type: Mapped[int] = mapped_column(SmallInteger)
    created_by: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    team_creator_ids: Mapped[list[str]] = mapped_column(ARRAY(String(36)), default=list)
    umpire_ids: Mapped[list[str]] = mapped_column(ARRAY(String(36)), default=list)
    scorer_ids: Mapped[list[str]] = mapped_column(ARRAY(String(36)), default=list)
    commentator_ids: Mapped[list[str]] = mapped_column(ARRAY(String(36)), default=list)
    referee_id: Mapped[str | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    match_status: Mapped[int] = mapped_column(SmallInteger, index=True)
    toss_decision: Mapped[int | None] = mapped_column(SmallInteger)
    toss_winner_id: Mapped[str | None] = mapped_column(ForeignKey("teams.id", ondelete="SET NULL"))
    current_playing_team_id: Mapped[str | None] = mapped_column(ForeignKey("teams.id", ondelete="SET NULL"))
    revised_target: Mapped[dict | None] = mapped_column(JSONB)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    teams: Mapped[list["MatchTeam"]] = relationship(back_populates="match", cascade="all, delete-orphan")
    setting: Mapped["MatchSetting | None"] = relationship(
        back_populates="match", cascade="all, delete-orphan", uselist=False
    )


class MatchTeam(Base):
    """Replaces the embedded `teams` array on the Firestore match document."""

    __tablename__ = "match_teams"
    __table_args__ = (UniqueConstraint("match_id", "team_id", name="uq_match_teams_match_team"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    match_id: Mapped[str] = mapped_column(ForeignKey("matches.id", ondelete="CASCADE"), index=True)
    team_id: Mapped[str] = mapped_column(ForeignKey("teams.id", ondelete="CASCADE"), index=True)
    captain_id: Mapped[str | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    admin_id: Mapped[str | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    over: Mapped[float] = mapped_column(Numeric(6, 2), default=0)
    run: Mapped[int] = mapped_column(Integer, default=0)
    wicket: Mapped[int] = mapped_column(Integer, default=0)

    match: Mapped["Match"] = relationship(back_populates="teams")
    squad: Mapped[list["MatchPlayer"]] = relationship(back_populates="match_team", cascade="all, delete-orphan")


class MatchPlayer(Base):
    """Replaces the embedded `squad` array on each Firestore MatchTeamModel."""

    __tablename__ = "match_players"
    __table_args__ = (UniqueConstraint("match_team_id", "user_id", name="uq_match_players_team_user"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    match_team_id: Mapped[str] = mapped_column(ForeignKey("match_teams.id", ondelete="CASCADE"), index=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    status: Mapped[int] = mapped_column(SmallInteger, default=3)  # PlayerStatus.played
    performance: Mapped[list] = mapped_column(JSONB, default=list)

    match_team: Mapped["MatchTeam"] = relationship(back_populates="squad")


class MatchSetting(Base):
    """Was matches/{id}/match_settings/setting subcollection document."""

    __tablename__ = "match_settings"

    match_id: Mapped[str] = mapped_column(ForeignKey("matches.id", ondelete="CASCADE"), primary_key=True)
    continue_with_injured_player: Mapped[bool] = mapped_column(Boolean, default=True)
    show_wagon_wheel_for_less_run: Mapped[bool] = mapped_column(Boolean, default=True)
    show_wagon_wheel_for_dot_ball: Mapped[bool] = mapped_column(Boolean, default=True)

    match: Mapped["Match"] = relationship(back_populates="setting")
