import uuid
import os
import json
from typing import List
from ..schemas.menu import MenuItem
from google import genai
from google.genai import types

class MenuScannerAI:
    def __init__(self):
        self.api_key = os.getenv("GEMINI_API_KEY")
        if self.api_key:
            self.client = genai.Client(api_key=self.api_key)
        else:
            self.client = None

    def extract_menu_items(self, image_bytes: bytes) -> List[MenuItem]:
        """
        Takes an image and extracts menu items using Gemini Vision model.
        Falls back to mock data if no API key is provided.
        """
        if not self.client:
            print("WARNING: No GEMINI_API_KEY found, using mock data for menu extraction.")
            return self._mock_data()

        try:
            # Prepare image part
            image_part = types.Part.from_bytes(data=image_bytes, mime_type="image/jpeg")
            
            # The prompt requests JSON format array
            prompt = """
            You are a menu parsing assistant. Look at this menu image.
            Extract all distinct food/drink items. 
            Return the output STRICTLY as a JSON array where each object has:
            - "name": string (name of the item)
            - "price": float (the price value, e.g. 14.5)
            - "category": string (e.g., "Starter", "Main", "Side", "Dessert", "Drink")
            Do not include markdown blocks or any other text, just the raw JSON array.
            """
            
            response = self.client.models.generate_content(
                model='gemini-2.5-flash',
                contents=[image_part, prompt],
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                )
            )

            results = json.loads(response.text)
            
            parsed_items = []
            for item in results:
                parsed_items.append(
                    MenuItem(
                        id=str(uuid.uuid4()),
                        name=item.get("name", "Unknown Item"),
                        price=float(item.get("price", 0.0)),
                        category=item.get("category", "Uncategorized"),
                    )
                )
            return parsed_items
        except Exception as e:
            print(f"Error during Gemini processing: {e}")
            print("Falling back to mock data.")
            return self._mock_data()

    def _mock_data(self) -> List[MenuItem]:
        simulated_data = [
            {"name": "Margherita Pizza", "price": 14.50, "category": "Main"},
            {"name": "Truffle Fries", "price": 8.00, "category": "Side"},
            {"name": "Caesar Salad", "price": 11.00, "category": "Starter"},
            {"name": "Sparkling Water", "price": 3.50, "category": "Drink"},
            {"name": "Tiramisu", "price": 9.00, "category": "Dessert"},
        ]
        parsed_items = []
        for item in simulated_data:
            parsed_items.append(MenuItem(id=str(uuid.uuid4()), name=item["name"], price=item["price"], category=item["category"]))
        return parsed_items
