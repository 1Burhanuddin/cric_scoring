import hashlib
import hmac
import secrets
from datetime import datetime, timedelta, timezone

import jwt

from ..config import get_settings

settings = get_settings()


def generate_otp() -> str:
    return f"{secrets.randbelow(1_000_000):06d}"


def hash_otp(phone: str, otp: str) -> str:
    # HMAC keyed with the server secret so a leaked DB row alone can't be brute-forced offline.
    return hmac.new(settings.jwt_secret.encode(), f"{phone}:{otp}".encode(), hashlib.sha256).hexdigest()


def create_access_token(user_id: str, session_id: str) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": user_id,
        "sid": session_id,
        "iat": now,
        "exp": now + timedelta(minutes=settings.jwt_access_token_minutes),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def decode_access_token(token: str) -> dict:
    return jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
