from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..auth.deps import get_current_session, get_current_user
from ..auth.otp import send_otp_sms
from ..auth.security import create_access_token, generate_otp, hash_otp
from ..config import get_settings
from ..database import get_db
from ..errors import ApiError
from ..models import User, UserOtp, UserSession
from ..schemas.auth import OtpSendRequest, OtpVerifyRequest, RegisterDeviceRequest, TokenResponse
from ..schemas.user import SessionOut, UserOut

router = APIRouter(prefix="/auth", tags=["auth"])
settings = get_settings()


def _normalize_phone(country_code: str, phone_number: str) -> str:
    return f"{country_code.strip()} {phone_number.strip()}"


@router.post("/otp/send", status_code=204)
async def send_otp(payload: OtpSendRequest, db: Session = Depends(get_db)) -> None:
    phone = _normalize_phone(payload.country_code, payload.phone_number)

    recent_count = (
        db.query(UserOtp)
        .filter(
            UserOtp.phone == phone,
            UserOtp.created_at > datetime.now(timezone.utc) - timedelta(minutes=10),
        )
        .count()
    )
    if recent_count >= 5:
        raise ApiError(429, "too-many-requests", "Too many OTP requests. Please try again later.")

    otp = generate_otp()
    db.add(
        UserOtp(
            phone=phone,
            otp_hash=hash_otp(phone, otp),
            expires_at=datetime.now(timezone.utc) + timedelta(seconds=settings.otp_ttl_seconds),
        )
    )
    db.commit()

    await send_otp_sms(phone, otp)


@router.post("/otp/verify", response_model=TokenResponse)
def verify_otp(payload: OtpVerifyRequest, db: Session = Depends(get_db)) -> TokenResponse:
    phone = _normalize_phone(payload.country_code, payload.phone_number)

    is_dev_bypass = (
        not settings.is_production
        and settings.otp_dev_bypass_code is not None
        and payload.otp == settings.otp_dev_bypass_code
    )

    if not is_dev_bypass:
        record = (
            db.query(UserOtp)
            .filter(UserOtp.phone == phone, UserOtp.consumed.is_(False))
            .order_by(UserOtp.created_at.desc())
            .first()
        )
        if record is None or record.expires_at < datetime.now(timezone.utc):
            raise ApiError(400, "invalid-verification-code", "This code has expired. Please request a new one.")
        if record.attempts >= settings.otp_max_attempts:
            raise ApiError(429, "too-many-requests", "Too many attempts. Please request a new code.")

        record.attempts += 1
        if record.otp_hash != hash_otp(phone, payload.otp):
            db.commit()
            raise ApiError(400, "invalid-verification-code", "Incorrect verification code.")

        record.consumed = True
        db.commit()

    user = db.query(User).filter(User.phone == phone).one_or_none()
    if user is None:
        user = User(phone=phone, name=payload.name, name_lowercase=payload.name.lower() if payload.name else None)
        db.add(user)
        db.flush()

    session = UserSession(
        user_id=user.id,
        device_type=payload.device_type,
        device_id=payload.device_id,
        device_name=payload.device_name,
        app_version=payload.app_version,
        os_version=payload.os_version,
    )
    db.add(session)
    db.commit()
    db.refresh(user)
    db.refresh(session)

    token = create_access_token(user.id, session.id)
    return TokenResponse(
        access_token=token,
        user=UserOut.from_model(user),
        session=SessionOut.from_model(session),
    )


@router.post("/logout", status_code=204)
def logout(session: UserSession = Depends(get_current_session), db: Session = Depends(get_db)) -> None:
    session.is_active = False
    db.commit()


@router.post("/device", status_code=204)
def register_device(
    payload: RegisterDeviceRequest,
    session: UserSession = Depends(get_current_session),
    db: Session = Depends(get_db),
) -> None:
    if session.device_fcm_token == payload.device_fcm_token:
        return
    session.device_fcm_token = payload.device_fcm_token
    db.commit()


@router.delete("/account", status_code=204)
def delete_account(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)) -> None:
    db.delete(current_user)
    db.commit()
