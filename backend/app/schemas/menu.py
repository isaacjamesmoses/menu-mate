from pydantic import BaseModel
from typing import List, Optional

class MenuItem(BaseModel):
    id: str
    name: str
    price: float
    category: str

class MenuScanResponse(BaseModel):
    items: List[MenuItem]
