from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..errors import ApiError
from ..models import Inning
from ..schemas.scoring import (
    InningOut,
    InningsBatchCreateRequest,
    InningsStatusBatchUpdate,
    InningStatusUpdate,
)

router = APIRouter(prefix="/innings", tags=["innings"])


@router.post("/batch", response_model=list[InningOut], status_code=201)
def create_innings(payload: InningsBatchCreateRequest, db: Session = Depends(get_db)) -> list[InningOut]:
    created = []
    for inning_in in payload.innings:
        inning = db.query(Inning).filter(Inning.id == inning_in.id).one_or_none()
        if inning is None:
            inning = Inning(id=inning_in.id)
            db.add(inning)
        inning.match_id = inning_in.match_id
        inning.team_id = inning_in.team_id
        inning.overs = inning_in.overs
        inning.index = inning_in.index
        inning.total_runs = inning_in.total_runs
        inning.total_wickets = inning_in.total_wickets
        inning.innings_status = inning_in.innings_status
        created.append(inning)
    db.commit()
    return [InningOut.from_model(i) for i in created]


@router.get("/by-match/{match_id}", response_model=list[InningOut])
def get_innings_by_match(match_id: str, db: Session = Depends(get_db)) -> list[InningOut]:
    innings = db.query(Inning).filter(Inning.match_id == match_id).all()
    return [InningOut.from_model(i) for i in innings]


@router.patch("/{inning_id}/status", response_model=InningOut)
def update_inning_status(
    inning_id: str, payload: InningStatusUpdate, db: Session = Depends(get_db)
) -> InningOut:
    inning = db.query(Inning).filter(Inning.id == inning_id).one_or_none()
    if inning is None:
        raise ApiError(404, "something-went-wrong", "Inning not found")
    inning.innings_status = payload.innings_status
    db.commit()
    return InningOut.from_model(inning)


@router.patch("/status-batch", status_code=204)
def update_inning_statuses_batch(payload: InningsStatusBatchUpdate, db: Session = Depends(get_db)) -> None:
    for inning_id, status in payload.statuses.items():
        db.query(Inning).filter(Inning.id == inning_id).update({"innings_status": status})
    db.commit()
