import sqlite3
import json
import os
from typing import List, Optional
from datetime import datetime
from ..schemas.plans import SavedPlanResponse
from ..schemas.recommendation import MealPlan, RecommendationRequest

# Use /tmp on cloud (Render), local path for development
if os.getenv("RENDER"):
    DB_PATH = '/tmp/menumate.db'
else:
    DB_PATH = os.path.join(os.path.dirname(__file__), '..', '..', 'menumate.db')

def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('''
        CREATE TABLE IF NOT EXISTS saved_plans (
            id TEXT PRIMARY KEY,
            plan_json TEXT NOT NULL,
            preferences_json TEXT NOT NULL,
            created_at TEXT NOT NULL
        )
    ''')
    conn.commit()
    conn.close()

def save_plan_to_db(plan_response: SavedPlanResponse) -> None:
    conn = get_db_connection()
    c = conn.cursor()
    c.execute(
        'INSERT INTO saved_plans (id, plan_json, preferences_json, created_at) VALUES (?, ?, ?, ?)',
        (
            plan_response.id,
            plan_response.plan.model_dump_json(),
            plan_response.preferences.model_dump_json(),
            plan_response.created_at.isoformat()
        )
    )
    conn.commit()
    conn.close()

def get_all_plans_from_db() -> List[SavedPlanResponse]:
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('SELECT * FROM saved_plans ORDER BY created_at DESC')
    rows = c.fetchall()
    conn.close()

    plans = []
    for row in rows:
        plan_data = json.loads(row['plan_json'])
        preferences_data = json.loads(row['preferences_json'])
        
        # Build pydantic models
        plan = MealPlan(**plan_data)
        preferences = RecommendationRequest(**preferences_data)
        
        plans.append(SavedPlanResponse(
            id=row['id'],
            plan=plan,
            preferences=preferences,
            created_at=datetime.fromisoformat(row['created_at'])
        ))
        
    return plans
