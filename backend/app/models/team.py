from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, Numeric, String, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, new_id


class Team(Base):
    __tablename__ = "teams"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    name: Mapped[str] = mapped_column(String(255))
    name_lowercase: Mapped[str] = mapped_column(String(255), index=True)
    city: Mapped[str | None] = mapped_column(String(255))
    name_initial: Mapped[str | None] = mapped_column(String(8))
    profile_img_url: Mapped[str | None] = mapped_column(String(1024))
    created_by: Mapped[str | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    players: Mapped[list["TeamPlayer"]] = relationship(back_populates="team", cascade="all, delete-orphan")
    stat: Mapped["TeamStat | None"] = relationship(
        back_populates="team", cascade="all, delete-orphan", uselist=False
    )


class TeamPlayer(Base):
    """Replaces the embedded `team_players` array on the Firestore team document."""

    __tablename__ = "team_players"
    __table_args__ = (UniqueConstraint("team_id", "user_id", name="uq_team_players_team_user"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    team_id: Mapped[str] = mapped_column(ForeignKey("teams.id", ondelete="CASCADE"), index=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    role: Mapped[str] = mapped_column(String(16), default="player")  # "admin" | "player"

    team: Mapped["Team"] = relationship(back_populates="players")


class TeamStat(Base):
    __tablename__ = "team_stats"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    team_id: Mapped[str] = mapped_column(ForeignKey("teams.id", ondelete="CASCADE"), unique=True)
    played: Mapped[int] = mapped_column(Integer, default=0)
    win: Mapped[int] = mapped_column(Integer, default=0)
    tie: Mapped[int] = mapped_column(Integer, default=0)
    lost: Mapped[int] = mapped_column(Integer, default=0)
    runs: Mapped[int] = mapped_column(Integer, default=0)
    wickets: Mapped[int] = mapped_column(Integer, default=0)
    batting_average: Mapped[float] = mapped_column(Numeric(8, 2), default=0)
    bowling_average: Mapped[float] = mapped_column(Numeric(8, 2), default=0)
    highest_runs: Mapped[int] = mapped_column(Integer, default=0)
    lowest_runs: Mapped[int] = mapped_column(Integer, default=0)
    run_rate: Mapped[float] = mapped_column(Numeric(8, 2), default=0)

    team: Mapped["Team"] = relationship(back_populates="stat")
