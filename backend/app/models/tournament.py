from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, Numeric, SmallInteger, String, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base, new_id


class Tournament(Base):
    __tablename__ = "tournaments"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    name: Mapped[str] = mapped_column(String(255))
    profile_img_url: Mapped[str | None] = mapped_column(String(1024))
    banner_img_url: Mapped[str | None] = mapped_column(String(1024))
    type: Mapped[int] = mapped_column(SmallInteger)
    created_by: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    start_date: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    end_date: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class TournamentMember(Base):
    __tablename__ = "tournament_members"
    __table_args__ = (
        UniqueConstraint("tournament_id", "user_id", name="uq_tournament_members_tournament_user"),
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    tournament_id: Mapped[str] = mapped_column(ForeignKey("tournaments.id", ondelete="CASCADE"), index=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    role: Mapped[str] = mapped_column(String(16), default="admin")  # "organizer" | "admin"


class TournamentTeam(Base):
    """Replaces the `team_ids` array on the Firestore tournament document."""

    __tablename__ = "tournament_teams"
    __table_args__ = (
        UniqueConstraint("tournament_id", "team_id", name="uq_tournament_teams_tournament_team"),
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    tournament_id: Mapped[str] = mapped_column(ForeignKey("tournaments.id", ondelete="CASCADE"), index=True)
    team_id: Mapped[str] = mapped_column(ForeignKey("teams.id", ondelete="CASCADE"), index=True)


class TournamentTeamStat(Base):
    __tablename__ = "tournament_team_stats"
    __table_args__ = (
        UniqueConstraint("tournament_id", "team_id", name="uq_tournament_team_stats_tournament_team"),
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    tournament_id: Mapped[str] = mapped_column(ForeignKey("tournaments.id", ondelete="CASCADE"), index=True)
    team_id: Mapped[str] = mapped_column(ForeignKey("teams.id", ondelete="CASCADE"), index=True)
    points: Mapped[int] = mapped_column(Integer, default=0)
    wins: Mapped[int] = mapped_column(Integer, default=0)
    losses: Mapped[int] = mapped_column(Integer, default=0)
    nrr: Mapped[float] = mapped_column(Numeric(6, 3), default=0)
    played_matches: Mapped[int] = mapped_column(Integer, default=0)


class TournamentPlayerKeyStat(Base):
    __tablename__ = "tournament_player_key_stats"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    tournament_id: Mapped[str] = mapped_column(ForeignKey("tournaments.id", ondelete="CASCADE"), index=True)
    player_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    team_name: Mapped[str] = mapped_column(String(255))
    stats: Mapped[dict] = mapped_column(JSONB, default=dict)
    tag: Mapped[str | None] = mapped_column(String(32))
    value: Mapped[int | None] = mapped_column(Integer)
