# MenuMate - AI Meal Planner

MenuMate is a full-stack, AI-powered mobile application designed to seamlessly extract text from restaurant menus and output algorithmically generated meal plans based on your constraints (budget, dietary restrictions, party size).

## Architecture

- **Frontend**: Flutter (Android-first) utilizing modern routing, state tracking, and multipart file transportation.
- **Backend**: Python FastAPI with built-in combinatorics recommendation engines simulating strict LLM Vision outputs and intelligent math matching.
- **Database**: Extensible in-memory persistence layer, built flawlessly to mount PostgreSQL or Supabase in the `routes/plans.py` module.

---

## 🚀 Running Locally

### Backend (Python)
1. Ensure Python 3.9+ is installed globally or locally.
2. Navigate into the backend directory:
   ```bash
   cd backend
   ```
3. Install dependencies:
   ```bash
   python -m pip install -r requirements.txt
   ```
4. Start the server (runs on `http://127.0.0.1:8000`):
   ```bash
   python -m uvicorn app.main:app --reload
   ```

### Frontend (Flutter)
1. Ensure the Flutter SDK is installed completely and that you have configured an Android Emulator or local debugging device.
2. Open a separate terminal and navigate into the frontend directory:
   ```bash
   cd frontend
   ```
3. Sync dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

---

## 📦 Building for Production (Android APK / AAB)

To release the Android application for device side-loading or Google Play Store distribution, you will use the Flutter CLI. 

> Note: Ensure your `android/app/build.gradle` has exactly matching Android SDK versions. Run `flutter doctor` before building to secure against local Android Studio errors.

**Build an APK (For Side-Loading, Testing, or QA)**
```bash
flutter build apk --release
```
*Your file will map out to `frontend/build/app/outputs/flutter-apk/app-release.apk`*

**Build an App Bundle / AAB (For Google Play Store Submit)**
```bash
flutter build appbundle --release
```
*Your file will map out to `frontend/build/app/outputs/bundle/release/app-release.aab`*

---

## 🔌 API Endpoints
All endpoints are available natively under your localhost schema:

| Method | Route | Description |
|---|---|---|
| `POST` | `/scan-menu` | Consumes a `multipart/form-data` image to read text and extract distinct items via Vision. |
| `POST` | `/recommend-meal` | Ingests variables mapped inside `RecommendationRequest` to evaluate permutations of optimal food selections. Returns `<RecommendationResponse>` |
| `POST` | `/save-plan` | Passes chosen `MealPlan` dictionaries safely over to the mock Postgres/Supabase module mapped into `MOCK_DB`. |
| `GET` | `/plans` | Yields an optimized JSON array containing all historical saves for global referencing. |

## Project Status

This project is currently in prototype stage. The core workflow demonstrates menu upload, backend processing, meal recommendation logic, and saved meal plan retrieval.

The current version is designed as a proof-of-concept and can be extended with real OCR or LLM Vision integration, cloud database storage, authentication, and deployment.

## Future Improvements

- Integrate real OCR or LLM Vision for menu text extraction
- Connect the backend to PostgreSQL or Supabase
- Add user authentication and saved user profiles
- Improve recommendation logic using nutrition data and real menu datasets
- Add dietary filters such as vegetarian, vegan, diabetic-friendly, and high-protein options
- Deploy the backend and mobile app for live testing
- Add screenshots, demo video, and sample user flow
