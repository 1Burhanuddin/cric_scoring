from datetime import date, datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class UserOut(BaseModel):
    """Mirrors data/lib/api/user/user_models.dart UserModel field-for-field
    (including the camelCase `isActive` key) so UserModel.fromJson keeps working
    unmodified on the Flutter side.
    """

    model_config = ConfigDict(populate_by_name=True)

    id: str
    name: str | None = None
    name_lowercase: str | None = None
    location: str | None = None
    phone: str | None = None
    dob: date | None = None
    email: str | None = None
    profile_img_url: str | None = None
    gender: int | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None
    player_role: int | None = None
    batting_style: int | None = None
    bowling_style: int | None = None
    is_active: bool = Field(default=True, alias="isActive")
    notifications: bool = True

    @classmethod
    def from_model(cls, user: Any) -> "UserOut":
        return cls(
            id=user.id,
            name=user.name,
            name_lowercase=user.name_lowercase,
            location=user.location,
            phone=user.phone,
            dob=user.dob,
            email=user.email,
            profile_img_url=user.profile_img_url,
            gender=user.gender,
            created_at=user.created_at,
            updated_at=user.updated_at,
            player_role=user.player_role,
            batting_style=user.batting_style,
            bowling_style=user.bowling_style,
            isActive=user.is_active,
            notifications=user.notifications,
        )


class UserUpdate(BaseModel):
    name: str | None = None
    location: str | None = None
    dob: date | None = None
    email: str | None = None
    profile_img_url: str | None = None
    gender: int | None = None
    player_role: int | None = None
    batting_style: int | None = None
    bowling_style: int | None = None


class SessionOut(BaseModel):
    id: str
    user_id: str
    device_type: int
    device_id: str
    device_name: str
    device_fcm_token: str | None = None
    app_version: int
    os_version: str
    created_at: datetime | None = None
    is_active: bool = True

    @classmethod
    def from_model(cls, session: Any) -> "SessionOut":
        return cls(
            id=session.id,
            user_id=session.user_id,
            device_type=session.device_type,
            device_id=session.device_id,
            device_name=session.device_name,
            device_fcm_token=session.device_fcm_token,
            app_version=session.app_version,
            os_version=session.os_version,
            created_at=session.created_at,
            is_active=session.is_active,
        )


class UserStatIn(BaseModel):
    matches: int = 0
    type: str = "other"
    batting: dict = Field(default_factory=dict)
    bowling: dict = Field(default_factory=dict)
    fielding: dict = Field(default_factory=dict)


class UserStatOut(BaseModel):
    matches: int = 0
    type: str | None = None
    batting: dict = Field(default_factory=dict)
    bowling: dict = Field(default_factory=dict)
    fielding: dict = Field(default_factory=dict)

    @classmethod
    def from_model(cls, stat: Any) -> "UserStatOut":
        return cls(
            matches=stat.matches,
            type=stat.type,
            batting=stat.batting,
            bowling=stat.bowling,
            fielding=stat.fielding,
        )
