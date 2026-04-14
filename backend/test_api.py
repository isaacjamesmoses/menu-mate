import requests

BASE_URL = 'http://127.0.0.1:8000'

def test_api_workflow():
    print("--- 1. Testing POST /scan-menu ---")
    files = {'file': ('dummy.jpg', b'dummy_content', 'image/jpeg')}
    resp = requests.post(f"{BASE_URL}/scan-menu", files=files)
    if resp.status_code != 200:
        print(f"FAILED /scan-menu: {resp.text}")
        return
    menu_items = resp.json()
    print("Extracted Items:")
    for item in menu_items:
        print(f" - {item['name']} (${item['price']}) [{item['category']}]")

    print("\n--- 2. Testing POST /recommend-meal ---")
    payload = {
        "people_count": 4,
        "budget": 50.0,
        "preferred_foods": "pizza",
        "foods_to_avoid": "",
        "dietary_toggles": {
            "vegetarian": False,
            "vegan": False,
            "halal": False,
            "spicy": False,
            "non_spicy": False
        },
        "menu_items": menu_items
    }
    
    resp2 = requests.post(f"{BASE_URL}/recommend-meal", json=payload)
    if resp2.status_code != 200:
        print(f"FAILED /recommend-meal: {resp2.text}")
        return
    recommendations = resp2.json()
    best_plan = recommendations['best_plan']
    print(f"Best Plan Details:")
    print(f"Total Cost: ${best_plan['total_cost']}")
    print(f"Explanation: {best_plan['explanation']}")

    print("\n--- 3. Testing POST /save-plan ---")
    save_payload = {
        "plan": best_plan,
        "preferences": payload
    }
    resp3 = requests.post(f"{BASE_URL}/save-plan", json=save_payload)
    if resp3.status_code != 200:
        print(f"FAILED /save-plan: {resp3.text}")
        return
    print(f"Plan saved! Database ID: {resp3.json()['id']}")

    print("\n--- 4. Testing GET /plans ---")
    resp4 = requests.get(f"{BASE_URL}/plans")
    if resp4.status_code != 200:
        print(f"FAILED /plans: {resp4.text}")
        return
    plans = resp4.json()
    print(f"Total saved plans in database: {len(plans)}")

if __name__ == '__main__':
    test_api_workflow()
