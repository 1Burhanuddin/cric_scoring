import os
import re

os.environ.setdefault("DATABASE_URL", "postgresql+psycopg://cricheros:cricheros@localhost:5434/cricheros")
os.environ.setdefault("ENV", "test")
os.environ.setdefault("JWT_SECRET", "test-secret")
os.environ.setdefault("OTP_DEV_BYPASS_CODE", "000000")

import psycopg
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.config import get_settings
from app.database import get_db
from app.main import app
from app.models import Base

_dev_settings = get_settings()

# Tests must never run against the dev/prod database - the fixtures below
# create and drop tables freely. Derive a dedicated "<db>_test" database from
# DATABASE_URL instead (e.g. cricheros -> cricheros_test), auto-created if
# it doesn't exist yet.
_match = re.match(r"^(.*)/([^/?]+)(\?.*)?$", _dev_settings.database_url)
if not _match:
    raise RuntimeError(f"Could not parse DATABASE_URL to derive a test database: {_dev_settings.database_url}")
_base_url, _dev_db_name, _query = _match.groups()
_test_db_name = f"{_dev_db_name}_test"
_test_database_url = f"{_base_url}/{_test_db_name}{_query or ''}"

os.environ["DATABASE_URL"] = _test_database_url
get_settings.cache_clear()
settings = get_settings()


def _ensure_test_database_exists() -> None:
    admin_url = f"{_base_url}/postgres".replace("postgresql+psycopg://", "")
    with psycopg.connect(f"postgresql://{admin_url}", autocommit=True) as conn:
        exists = conn.execute(
            "SELECT 1 FROM pg_database WHERE datname = %s", (_test_db_name,)
        ).fetchone()
        if not exists:
            conn.execute(f'CREATE DATABASE "{_test_db_name}"')


_ensure_test_database_exists()

engine = create_engine(settings.database_url)
TestingSessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


@pytest.fixture(scope="session", autouse=True)
def _setup_database():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture()
def db_session():
    connection = engine.connect()
    transaction = connection.begin()
    session = TestingSessionLocal(bind=connection)

    yield session

    session.close()
    transaction.rollback()
    connection.close()


@pytest.fixture()
def client(db_session):
    def _override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = _override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()
