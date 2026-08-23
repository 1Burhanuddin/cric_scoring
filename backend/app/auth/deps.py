import jwt
from fastapi import Depends, Header
from sqlalchemy.orm import Session

from ..database import get_db
from ..errors import ApiError
from ..models import User, UserSession
from .security import decode_access_token


def get_current_session(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> UserSession:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise ApiError(401, "unauthenticated", "Missing or invalid Authorization header")

    token = authorization.split(" ", 1)[1]
    try:
        payload = decode_access_token(token)
    except jwt.PyJWTError as error:
        raise ApiError(401, "session-expired", "Session expired, please sign in again") from error

    session = db.get(UserSession, payload.get("sid"))
    if session is None or not session.is_active:
        raise ApiError(401, "session-expired", "Session expired, please sign in again")
    return session


def get_current_user(
    session: UserSession = Depends(get_current_session),
    db: Session = Depends(get_db),
) -> User:
    user = db.get(User, session.user_id)
    if user is None or not user.is_active:
        raise ApiError(401, "user-not-found", "Account not found")
    return user
