from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    env: str = "development"
    database_url: str = "postgresql+psycopg://cricheros:cricheros@localhost:5432/cricheros"

    jwt_secret: str = "change-me-in-production"
    jwt_algorithm: str = "HS256"
    # Mobile sessions are long-lived by design (mirrors the previous Firebase Auth session model).
    jwt_access_token_minutes: int = 60 * 24 * 30

    otp_ttl_seconds: int = 300
    otp_max_attempts: int = 5
    # Only honored when env != "production" - lets local/dev/test sign in without a real SMS provider.
    otp_dev_bypass_code: str | None = "000000"

    msg91_auth_key: str | None = None
    msg91_template_id: str | None = None
    msg91_base_url: str = "https://control.msg91.com/api/v5"

    r2_account_id: str | None = None
    r2_access_key_id: str | None = None
    r2_secret_access_key: str | None = None
    r2_bucket_name: str = "cricheros-uploads"
    r2_public_base_url: str | None = None

    cors_origins: list[str] = ["*"]

    @property
    def is_production(self) -> bool:
        return self.env == "production"


@lru_cache
def get_settings() -> Settings:
    return Settings()
