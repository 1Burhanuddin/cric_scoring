from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import get_settings
from .errors import register_error_handlers
from .routers import (
    auth,
    ball_scores,
    innings,
    leaderboard,
    match_events,
    matches,
    partnerships,
    teams,
    tournaments,
    uploads,
    users,
)

settings = get_settings()

app = FastAPI(title="CricHeros API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

register_error_handlers(app)

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(teams.router)
app.include_router(matches.router)
app.include_router(innings.router)
app.include_router(ball_scores.router)
app.include_router(partnerships.router)
app.include_router(match_events.router)
app.include_router(tournaments.router)
app.include_router(leaderboard.router)
app.include_router(uploads.router)


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}
