from fastapi import APIRouter, HTTPException
from typing import List
import uuid
from datetime import datetime, timezone
from ..schemas.plans import SavedPlanRequest, SavedPlanResponse
from ..services.db_service import save_plan_to_db, get_all_plans_from_db

router = APIRouter()

@router.post("/save-plan", response_model=SavedPlanResponse)
def save_plan(request: SavedPlanRequest):
    """
    Saves a chosen meal plan with the associated preferences into the database.
    """
    try:
        new_plan = SavedPlanResponse(
            id=str(uuid.uuid4()),
            plan=request.plan,
            preferences=request.preferences,
            created_at=datetime.now(timezone.utc)
        )
        save_plan_to_db(new_plan)
        return new_plan
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save plan: {str(e)}")

@router.get("/plans", response_model=List[SavedPlanResponse])
def get_plans():
    """
    Retrieves all previously saved meal plans.
    """
    try:
        return get_all_plans_from_db()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve plans: {str(e)}")
