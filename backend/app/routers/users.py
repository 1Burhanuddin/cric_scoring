from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..auth.deps import get_current_user
from ..database import get_db
from ..errors import ApiError
from ..models import User, UserStat
from ..schemas.user import UserOut, UserStatIn, UserStatOut, UserUpdate

router = APIRouter(prefix="/users", tags=["users"])


class NotificationSettingsRequest(BaseModel):
    notifications: bool


@router.get("/me", response_model=UserOut)
def get_me(current_user: User = Depends(get_current_user)) -> UserOut:
    return UserOut.from_model(current_user)


@router.patch("/me", response_model=UserOut)
def update_me(
    payload: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserOut:
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(current_user, field, value)
    if payload.name is not None:
        current_user.name_lowercase = payload.name.lower()
    db.commit()
    db.refresh(current_user)
    return UserOut.from_model(current_user)


@router.patch("/me/notifications", status_code=204)
def update_notification_settings(
    payload: NotificationSettingsRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> None:
    current_user.notifications = payload.notifications
    db.commit()


@router.get("/search/by-name", response_model=list[UserOut])
def search_users(q: str, limit: int = 20, db: Session = Depends(get_db)) -> list[UserOut]:
    users = (
        db.query(User)
        .filter(User.name_lowercase.like(f"{q.lower()}%"))
        .order_by(User.id)
        .limit(limit)
        .all()
    )
    return [UserOut.from_model(u) for u in users]


@router.get("", response_model=list[UserOut])
def get_users_by_ids(ids: list[str] = Query(...), db: Session = Depends(get_db)) -> list[UserOut]:
    users = db.query(User).filter(User.id.in_(ids)).all()
    return [UserOut.from_model(u) for u in users]


@router.get("/{user_id}", response_model=UserOut)
def get_user(user_id: str, db: Session = Depends(get_db)) -> UserOut:
    user = db.get(User, user_id)
    if user is None:
        raise ApiError(404, "user-not-found", "User not found")
    return UserOut.from_model(user)


@router.get("/{user_id}/stats", response_model=list[UserStatOut])
def get_user_stats(user_id: str, db: Session = Depends(get_db)) -> list[UserStatOut]:
    stats = db.query(UserStat).filter(UserStat.user_id == user_id).all()
    return [UserStatOut.from_model(s) for s in stats]


@router.put("/{user_id}/stats", response_model=UserStatOut)
def upsert_user_stat(user_id: str, payload: UserStatIn, db: Session = Depends(get_db)) -> UserStatOut:
    # Note: stat *computation* still happens client-side from ball-by-ball data
    # (still on Firestore pending Stage 2). This just persists the result here
    # so UserService can fully retire Firestore in this stage.
    stat = (
        db.query(UserStat)
        .filter(UserStat.user_id == user_id, UserStat.type == payload.type)
        .one_or_none()
    )
    if stat is None:
        stat = UserStat(user_id=user_id, type=payload.type)
        db.add(stat)

    stat.matches = payload.matches
    stat.batting = payload.batting
    stat.bowling = payload.bowling
    stat.fielding = payload.fielding
    db.commit()
    db.refresh(stat)
    return UserStatOut.from_model(stat)
