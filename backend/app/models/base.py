import uuid

from ..database import Base

__all__ = ["Base", "new_id"]


def new_id() -> str:
    return uuid.uuid4().hex
