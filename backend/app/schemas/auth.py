from pydantic import BaseModel

from .user import SessionOut, UserOut


class OtpSendRequest(BaseModel):
    country_code: str
    phone_number: str


class OtpVerifyRequest(BaseModel):
    country_code: str
    phone_number: str
    otp: str
    device_id: str
    device_name: str
    device_type: int
    app_version: int
    os_version: str
    # Used to seed the profile name on first sign-in only; ignored for existing users.
    name: str | None = None


class TokenResponse(BaseModel):
    access_token: str
    user: UserOut
    session: SessionOut


class RegisterDeviceRequest(BaseModel):
    device_fcm_token: str
