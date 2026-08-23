from datetime import date as date_type

from sqlalchemy import Date, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base, new_id


class LeaderboardEntry(Base):
    """Replaces leaderboard/{period}/data/{userId} in Firestore."""

    __tablename__ = "leaderboard_entries"
    __table_args__ = (UniqueConstraint("period", "field", "user_id", name="uq_leaderboard_period_field_user"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    period: Mapped[str] = mapped_column(String(16), index=True)  # weekly | monthly | all_time
    field: Mapped[str] = mapped_column(String(16), index=True)  # batting | bowling | fielding
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    date: Mapped[date_type] = mapped_column(Date)
    runs: Mapped[int] = mapped_column(Integer, default=0)
    wickets: Mapped[int] = mapped_column(Integer, default=0)
    catches: Mapped[int] = mapped_column(Integer, default=0)
