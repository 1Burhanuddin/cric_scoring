import re
import uuid

import boto3
from botocore.client import Config

from ..config import get_settings

settings = get_settings()

_SAFE_SEGMENT = re.compile(r"^[A-Za-z0-9_\-. ]+$")


def sanitize_object_path(path: str) -> str:
    """Collapses a client-supplied path prefix (e.g. "images/<uid>/profile") down to
    safe segments, rejecting traversal attempts. Raises ValueError if nothing usable
    is left.
    """
    segments = [segment for segment in path.strip("/").split("/") if segment not in ("", ".", "..")]
    if not segments or not all(_SAFE_SEGMENT.match(segment) for segment in segments):
        raise ValueError("Invalid upload path")
    return "/".join(segments)


def _client():
    if not (settings.r2_account_id and settings.r2_access_key_id and settings.r2_secret_access_key):
        raise RuntimeError("R2 storage is not configured")

    return boto3.client(
        "s3",
        endpoint_url=f"https://{settings.r2_account_id}.r2.cloudflarestorage.com",
        aws_access_key_id=settings.r2_access_key_id,
        aws_secret_access_key=settings.r2_secret_access_key,
        config=Config(signature_version="s3v4"),
        region_name="auto",
    )


def build_object_key(path_prefix: str, filename: str) -> str:
    extension = filename.rsplit(".", 1)[-1] if "." in filename else "jpg"
    return f"{path_prefix}/{uuid.uuid4().hex}.{extension}"


def create_presigned_upload(object_key: str, content_type: str, expires_in: int = 300) -> str:
    return _client().generate_presigned_url(
        "put_object",
        Params={"Bucket": settings.r2_bucket_name, "Key": object_key, "ContentType": content_type},
        ExpiresIn=expires_in,
    )


def public_url_for_key(object_key: str) -> str:
    base = settings.r2_public_base_url or f"https://{settings.r2_bucket_name}.r2.dev"
    return f"{base.rstrip('/')}/{object_key}"


def delete_object_by_url(url: str) -> None:
    if not settings.r2_public_base_url:
        return
    prefix = settings.r2_public_base_url.rstrip("/") + "/"
    if not url.startswith(prefix):
        return
    key = url[len(prefix) :]
    _client().delete_object(Bucket=settings.r2_bucket_name, Key=key)
