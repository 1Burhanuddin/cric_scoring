from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse


class ApiError(Exception):
    """Raised for any expected client-facing failure.

    error_code reuses the exact strings already defined in the Flutter app's
    AppErrorL10nCodes (data/lib/errors/app_error_l10n_codes.dart) wherever one fits,
    so the client can map error_code -> AppError(l10nCode: ...) with no new table.
    """

    def __init__(self, status_code: int, error_code: str, message: str):
        self.status_code = status_code
        self.error_code = error_code
        self.message = message


def register_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(ApiError)
    async def handle_api_error(request: Request, exc: ApiError) -> JSONResponse:
        return JSONResponse(
            status_code=exc.status_code,
            content={"error_code": exc.error_code, "message": exc.message},
        )
