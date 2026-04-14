import itertools
import uuid
import random
from typing import List, Dict
from ..schemas.recommendation import RecommendationRequest, MealPlan, RecommendationResponse
from ..schemas.menu import MenuItem

class RecommendationService:
    def _is_forbidden(self, item: MenuItem, req: RecommendationRequest) -> bool:
        # Basic dietary mock checks
        # In a real scenario, LLM classifiers evaluate if item name contains avoiding terms
        avoid_terms = [t.strip().lower() for t in req.foods_to_avoid.split(",") if t.strip()]
        item_lower = item.name.lower()
        
        for term in avoid_terms:
            if term in item_lower:
                return True
                
        # Mocking dietary: let's pretend "burger" or "steak" fails vegetarian check
        if req.dietary_toggles.vegetarian or req.dietary_toggles.vegan:
            non_veg_keywords = ['steak', 'chicken', 'pork', 'beef', 'fish', 'meat']
            if any(k in item_lower for k in non_veg_keywords):
                return True
                
        return False

    def _score_combination(self, combo: List[MenuItem], req: RecommendationRequest) -> float:
        score = 0.0
        total_price = sum(item.price for item in combo)
        
        # 1. Budget Efficiency (closer to budget but definitely under it is better value)
        budget_ratio = total_price / req.budget
        score += budget_ratio * 10 
        
        # 2. Variety (unique categories)
        categories = set(item.category for item in combo)
        score += len(categories) * 5

        # 3. Preference Hits
        pref_terms = [t.strip().lower() for t in req.preferred_foods.split(",") if t.strip()]
        for item in combo:
            if any(term in item.name.lower() for term in pref_terms):
                score += 10 # Big score bump for preference hits
                
        return score

    def generate_recommendations(self, req: RecommendationRequest) -> RecommendationResponse:
        # Step 1: Filter forbidden items
        valid_items = [item for item in req.menu_items if not self._is_forbidden(item, req)]
        
        # Check quantities
        min_dishes = 2
        max_dishes = 4
        if req.people_count == 4:
            min_dishes = 4
            max_dishes = 6
        elif req.people_count == 5:
            min_dishes = 5
            max_dishes = 7
            
        # Ensure we have enough valid items
        if len(valid_items) < min_dishes:
            # Fallback: ignore min_dishes if the menu itself is super small, just use all valid
            max_dishes = len(valid_items)
            min_dishes = max_dishes if max_dishes > 0 else 0

        if min_dishes == 0:
            raise ValueError("No valid menu items remaining after filtering constraints.")

        valid_combos = []
        
        # Generate all combinations within size limits
        for size in range(min_dishes, max_dishes + 1):
            for combo in itertools.combinations(valid_items, size):
                total_cost = sum(item.price for item in combo)
                if total_cost <= req.budget:
                    valid_combos.append(list(combo))
                    
        if not valid_combos:
            raise ValueError(f"No valid meal combinations found under the strict budget of ${req.budget}.")

        # Score combinations
        combo_scores = []
        for combo in valid_combos:
            score = self._score_combination(combo, req)
            combo_scores.append((score, combo))
            
        # Rank by score descending
        combo_scores.sort(key=lambda x: x[0], reverse=True)
        
        # Extract top 3 (or repeat top if less than 3 available)
        top_combos = [c[1] for c in combo_scores[:3]]
        
        while len(top_combos) < 3 and len(top_combos) > 0:
            top_combos.append(top_combos[0]) # duplicate to satisfy 3 returns gracefully
            
        return RecommendationResponse(
            best_plan=self._build_plan(top_combos[0], req, "Based on exceptional value, variety, and matching your exact dietary preferences."),
            alternative_plan_1=self._build_plan(top_combos[1], req, "A great alternative with a slightly different flavor profile."),
            alternative_plan_2=self._build_plan(top_combos[2], req, "The most budget-friendly option while satisfying all constraints.")
        )
        
    def _build_plan(self, dishes: List[MenuItem], req: RecommendationRequest, explanation: str) -> MealPlan:
        total_cost = sum(item.price for item in dishes)
        cost_per_person = total_cost / req.people_count
        
        return MealPlan(
            plan_id=str(uuid.uuid4()),
            dishes=dishes,
            total_cost=round(total_cost, 2),
            cost_per_person=round(cost_per_person, 2),
            explanation=explanation
        )
