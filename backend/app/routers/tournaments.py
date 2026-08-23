from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Tournament

router = APIRouter(prefix="/tournaments", tags=["tournaments"])


@router.get("/active", response_model=list[dict])
def get_active_tournaments(db: Session = Depends(get_db)) -> list[dict]:
    # No tournament CRUD built yet (out of scope for the matches migration
    # pass) - this just needs to not throw so the home screen's combined
    # stream (matches + tournaments + leaderboard) can resolve. Empty is
    # accurate: there's no tournament data anywhere yet.
    db.query(Tournament).limit(0).all()
    return []
