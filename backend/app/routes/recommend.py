from fastapi import APIRouter, HTTPException
from ..schemas.recommendation import RecommendationRequest, RecommendationResponse
from ..services.recommender import RecommendationService

router = APIRouter()
recommender_service = RecommendationService()

@router.post("/recommend-meal", response_model=RecommendationResponse)
def recommend_meal(request: RecommendationRequest):
    """
    Evaluates the list of menu items against the user's group size, 
    budget, and stringent dietary preferences.
    Uses algorithms to evaluate combinatorics and rank by value and variety.
    """
    try:
        response = recommender_service.generate_recommendations(request)
        return response
    except ValueError as val_err:
        raise HTTPException(status_code=400, detail=str(val_err))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate recommendations: {str(e)}")
