from fastapi import APIRouter, Depends
from pydantic import BaseModel

from ..auth.deps import get_current_user
from ..errors import ApiError
from ..models import User
from ..storage.r2 import (
    build_object_key,
    create_presigned_upload,
    delete_object_by_url,
    public_url_for_key,
    sanitize_object_path,
)

router = APIRouter(prefix="/uploads", tags=["uploads"])


class PresignRequest(BaseModel):
    # Object key prefix, e.g. "images/<user_id>/profile" - matches the Flutter
    # side's StorageConst.*UploadPath() helpers. Always namespaced under the
    # uploading user's own id, checked below.
    path: str
    filename: str
    content_type: str = "image/jpeg"


class PresignResponse(BaseModel):
    upload_url: str
    public_url: str


class DeleteRequest(BaseModel):
    url: str


@router.post("/presign", response_model=PresignResponse)
def presign_upload(payload: PresignRequest, current_user: User = Depends(get_current_user)) -> PresignResponse:
    try:
        sanitized_path = sanitize_object_path(payload.path)
    except ValueError as error:
        raise ApiError(400, "something-went-wrong", str(error)) from error

    if not sanitized_path.startswith(f"images/{current_user.id}/"):
        raise ApiError(403, "something-went-wrong", "You can only upload to your own path")

    key = build_object_key(sanitized_path, payload.filename)
    try:
        upload_url = create_presigned_upload(key, payload.content_type)
    except RuntimeError as error:
        raise ApiError(503, "something-went-wrong", str(error)) from error

    return PresignResponse(upload_url=upload_url, public_url=public_url_for_key(key))


@router.post("/delete", status_code=204)
def delete_upload(payload: DeleteRequest, current_user: User = Depends(get_current_user)) -> None:
    delete_object_by_url(payload.url)
