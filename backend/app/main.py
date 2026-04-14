from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

from .routes import scan, recommend, plans
from .services.db_service import init_db

# Initialize database
init_db()

app = FastAPI(
    title="MenuMate API",
    description="Backend for the AI-powered MenuMate application",
    version="1.0.0"
)

# Allow CORS for mobile clients connecting from the same network
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(scan.router)
app.include_router(recommend.router)
app.include_router(plans.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to the MenuMate API!"}
