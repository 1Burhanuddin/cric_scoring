import logging

import httpx

from ..config import get_settings

logger = logging.getLogger("cricheros.otp")
settings = get_settings()


class OtpDeliveryError(Exception):
    pass


async def send_otp_sms(phone: str, otp: str) -> None:
    """Send the OTP over SMS via MSG91.

    In development/test (no MSG91 credentials configured), this just logs the OTP
    instead of failing, so local work doesn't require a live SMS provider account.
    Production requires MSG91_AUTH_KEY/MSG91_TEMPLATE_ID to be set.
    """
    if not settings.msg91_auth_key or not settings.msg91_template_id:
        if settings.is_production:
            raise OtpDeliveryError("MSG91 credentials are not configured")
        logger.warning("MSG91 not configured; OTP for %s is %s (dev only)", phone, otp)
        return

    async with httpx.AsyncClient(timeout=10) as client:
        response = await client.post(
            f"{settings.msg91_base_url}/otp",
            params={
                "template_id": settings.msg91_template_id,
                "mobile": phone.lstrip("+").replace(" ", ""),
                "authkey": settings.msg91_auth_key,
                "otp": otp,
            },
        )
        if response.status_code >= 400:
            raise OtpDeliveryError(f"MSG91 send failed: {response.status_code} {response.text}")
