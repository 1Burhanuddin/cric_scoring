from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..errors import ApiError
from ..models import Partnership
from ..schemas.scoring import PartnershipOut, PartnershipUpsertRequest

router = APIRouter(prefix="/partnerships", tags=["partnerships"])


@router.put("/{partnership_id}", response_model=PartnershipOut)
def upsert_partnership(
    partnership_id: str, payload: PartnershipUpsertRequest, db: Session = Depends(get_db)
) -> PartnershipOut:
    partnership = db.query(Partnership).filter(Partnership.id == partnership_id).one_or_none()
    if partnership is None:
        partnership = Partnership(id=partnership_id)
        db.add(partnership)

    partnership.match_id = payload.match_id
    partnership.inning_id = payload.inning_id
    partnership.player_ids = payload.player_ids
    partnership.players = [p.model_dump() for p in payload.players]
    partnership.runs = payload.runs
    partnership.extras = payload.extras
    partnership.ball_faced = payload.ball_faced
    partnership.start_over = payload.start_over
    partnership.end_over = payload.end_over

    db.commit()
    db.refresh(partnership)
    return PartnershipOut.from_model(partnership)


@router.get("/by-match/{match_id}", response_model=list[PartnershipOut])
def get_partnerships_by_match(match_id: str, db: Session = Depends(get_db)) -> list[PartnershipOut]:
    partnerships = db.query(Partnership).filter(Partnership.match_id == match_id).all()
    return [PartnershipOut.from_model(p) for p in partnerships]


@router.delete("/{partnership_id}", status_code=204)
def delete_partnership(partnership_id: str, db: Session = Depends(get_db)) -> None:
    partnership = db.query(Partnership).filter(Partnership.id == partnership_id).one_or_none()
    if partnership is None:
        raise ApiError(404, "something-went-wrong", "Partnership not found")
    db.delete(partnership)
    db.commit()
