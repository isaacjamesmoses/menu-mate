import base64
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from ..schemas.menu import MenuItem
from ..services.ai_service import MenuScannerAI

class ImagePayload(BaseModel):
    image_base64: str

router = APIRouter()
ai_service = MenuScannerAI()

@router.post("/scan-menu", response_model=List[MenuItem])
async def scan_menu(payload: ImagePayload):
    """
    Accepts a base64 encoded image string (the restaurant menu) and uses AI
    to extract and classify all menu items into a structured format.
    """
    if not payload.image_base64:
        raise HTTPException(status_code=400, detail="Base64 image data is missing.")

    try:
        # Decode the base64 string securely back into raw bytes
        # Strip potential data URI web headers before decoding
        b64_data = payload.image_base64
        if "," in b64_data:
            b64_data = b64_data.split(",", 1)[1]
            
        image_bytes = base64.b64decode(b64_data)
        
        # Process the image with the AI service
        extracted_items = ai_service.extract_menu_items(image_bytes)
        
        return extracted_items
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to process menu image: {str(e)}")
