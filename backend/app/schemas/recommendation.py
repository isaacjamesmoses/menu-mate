from pydantic import BaseModel
from typing import List, Dict, Optional
from .menu import MenuItem

class DietaryToggles(BaseModel):
    vegetarian: bool = False
    vegan: bool = False
    halal: bool = False
    spicy: bool = False
    non_spicy: bool = False

class RecommendationRequest(BaseModel):
    people_count: int
    budget: float
    preferred_foods: str = ""
    foods_to_avoid: str = ""
    dietary_toggles: DietaryToggles
    menu_items: List[MenuItem]

class MealPlan(BaseModel):
    plan_id: str
    dishes: List[MenuItem]
    total_cost: float
    cost_per_person: float
    explanation: str

class RecommendationResponse(BaseModel):
    best_plan: MealPlan
    alternative_plan_1: MealPlan
    alternative_plan_2: MealPlan
