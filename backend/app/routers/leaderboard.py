from fastapi import APIRouter, Query

router = APIRouter(prefix="/leaderboard", tags=["leaderboard"])


@router.get("", response_model=list[dict])
def get_leaderboard(limit: int = 4) -> list[dict]:
    # No leaderboard computation built yet (out of scope for the matches
    # migration pass) - empty is accurate: there's no stat data to rank yet.
    return []
