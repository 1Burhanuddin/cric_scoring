from datetime import date, datetime

from sqlalchemy import (
    Boolean,
    Date,
    DateTime,
    ForeignKey,
    Integer,
    SmallInteger,
    String,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, new_id


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    phone: Mapped[str] = mapped_column(String(32), unique=True, index=True)
    name: Mapped[str | None] = mapped_column(String(255))
    name_lowercase: Mapped[str | None] = mapped_column(String(255), index=True)
    location: Mapped[str | None] = mapped_column(String(255))
    dob: Mapped[date | None] = mapped_column(Date)
    email: Mapped[str | None] = mapped_column(String(255))
    profile_img_url: Mapped[str | None] = mapped_column(String(1024))
    gender: Mapped[int | None] = mapped_column(SmallInteger)
    player_role: Mapped[int | None] = mapped_column(SmallInteger)
    batting_style: Mapped[int | None] = mapped_column(SmallInteger)
    bowling_style: Mapped[int | None] = mapped_column(SmallInteger)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    notifications: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    sessions: Mapped[list["UserSession"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    stats: Mapped[list["UserStat"]] = relationship(back_populates="user", cascade="all, delete-orphan")


class UserSession(Base):
    __tablename__ = "user_sessions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    device_type: Mapped[int] = mapped_column(SmallInteger)
    device_id: Mapped[str] = mapped_column(String(255))
    device_name: Mapped[str] = mapped_column(String(255))
    device_fcm_token: Mapped[str | None] = mapped_column(String(512))
    app_version: Mapped[int] = mapped_column(Integer)
    os_version: Mapped[str] = mapped_column(String(64))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    user: Mapped["User"] = relationship(back_populates="sessions")


class UserOtp(Base):
    """OTP challenges. Firebase Auth used to own this entirely; now we do."""

    __tablename__ = "user_otps"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    phone: Mapped[str] = mapped_column(String(32), index=True)
    otp_hash: Mapped[str] = mapped_column(String(128))
    attempts: Mapped[int] = mapped_column(Integer, default=0)
    consumed: Mapped[bool] = mapped_column(Boolean, default=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class UserStat(Base):
    __tablename__ = "user_stats"
    __table_args__ = (UniqueConstraint("user_id", "type", name="uq_user_stats_user_type"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    type: Mapped[str] = mapped_column(String(32))
    matches: Mapped[int] = mapped_column(Integer, default=0)
    batting: Mapped[dict] = mapped_column(JSONB, default=dict)
    bowling: Mapped[dict] = mapped_column(JSONB, default=dict)
    fielding: Mapped[dict] = mapped_column(JSONB, default=dict)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    user: Mapped["User"] = relationship(back_populates="stats")
