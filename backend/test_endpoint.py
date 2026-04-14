import requests
import json

url = "http://127.0.0.1:8000/scan-menu"
payload = {"image_base64": "dGVzdA=="}

try:
    resp = requests.post(url, json=payload)
    print(f"Status: {resp.status_code}")
    print(f"Body: {resp.text[:500]}")
except Exception as e:
    print(f"Error: {e}")
