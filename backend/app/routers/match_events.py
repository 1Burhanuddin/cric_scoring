from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..errors import ApiError
from ..models import MatchEvent
from ..schemas.scoring import MatchEventOut, MatchEventUpsertRequest

router = APIRouter(prefix="/match-events", tags=["match-events"])


@router.put("/{event_id}", response_model=MatchEventOut)
def upsert_match_event(
    event_id: str, payload: MatchEventUpsertRequest, db: Session = Depends(get_db)
) -> MatchEventOut:
    event = db.query(MatchEvent).filter(MatchEvent.id == event_id).one_or_none()
    if event is None:
        event = MatchEvent(id=event_id)
        db.add(event)

    event.match_id = payload.match_id
    event.inning_id = payload.inning_id
    event.type = payload.type
    event.time = payload.time
    event.bowler_id = payload.bowler_id
    event.batsman_id = payload.batsman_id
    event.fielding_position = payload.fielding_position
    event.over = payload.over
    event.ball_ids = payload.ball_ids
    event.wickets = payload.wickets
    event.milestone = payload.milestone

    db.commit()
    db.refresh(event)
    return MatchEventOut.from_model(event)


@router.get("/by-match/{match_id}", response_model=list[MatchEventOut])
def get_events_by_match(match_id: str, db: Session = Depends(get_db)) -> list[MatchEventOut]:
    events = db.query(MatchEvent).filter(MatchEvent.match_id == match_id).all()
    return [MatchEventOut.from_model(e) for e in events]


@router.delete("/{event_id}", status_code=204)
def delete_match_event(event_id: str, db: Session = Depends(get_db)) -> None:
    event = db.query(MatchEvent).filter(MatchEvent.id == event_id).one_or_none()
    if event is None:
        raise ApiError(404, "something-went-wrong", "Match event not found")
    db.delete(event)
    db.commit()
