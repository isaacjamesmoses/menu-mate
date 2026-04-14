from pydantic import BaseModel
from typing import List, Dict, Any
from datetime import datetime
from .recommendation import MealPlan

class SavedPlanRequest(BaseModel):
    plan: MealPlan
    preferences: Dict[str, Any]

class SavedPlanResponse(BaseModel):
    id: str
    plan: MealPlan
    preferences: Dict[str, Any]
    created_at: datetime
