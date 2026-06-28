# Water Camper Delivery Management System

Mobile-first water camper delivery management for water suppliers.

## Tech Stack

- **Frontend:** Flutter (Android-first, Material 3)
- **Backend:** Node.js + Express (REST API, JWT, RBAC)
- **Database:** MongoDB + Mongoose

## Project Structure

```
Water Camper App/
├── backend/          # Express REST API
├── frontend/         # Flutter mobile app
└── docker-compose.yml
```

## Prerequisites

- Node.js 18+
- MongoDB (local or Docker)
- Flutter SDK 3.2+ (for mobile app)

## Quick Start

### 1. Start MongoDB

```bash
docker compose up -d
```

Or use a local/Atlas MongoDB instance and update `backend/.env`.

### 2. Backend Setup

```bash
cd backend
npm install
npm run seed    # Creates demo owner, labour, and 8 customers
npm run dev     # Starts API on http://localhost:5000
```

API docs: http://localhost:5000/api/docs

### 3. Flutter App Setup

```bash
cd frontend
flutter create . --org com.watercamper   # First time only - generates android/ios folders
flutter pub get
flutter run
```

**API URL:** Edit `frontend/lib/core/constants.dart`:
- Android emulator: `http://10.0.2.2:5000/api` (default)
- Physical device: use your PC's LAN IP, e.g. `http://192.168.1.5:5000/api`

## Demo Accounts

| Role   | Mobile       | Password  |
|--------|--------------|-----------|
| Owner  | 9876543210   | owner123  |
| Labour | 9876543211   | labour123 |

## Features

### Owner
- Customer management (CRUD, search)
- Labour account management
- Dashboard with 8 summary cards
- Delivery and revenue charts (7-day)

### Labour
- Daily workflow wizard:
  1. Filled out count
  2. Mark deliveries
  3. Mark undelivered (with reason)
  4. Extra campers (+1/-1)
  5. Not received campers (+1/-1)
  6. Empty campers received (+1/-1)
  7. Payment collection (Cash/UPI/Bank)
  8. Submit daily report

## API Endpoints

| Method | Endpoint | Role |
|--------|----------|------|
| POST | `/api/auth/login` | Public |
| GET | `/api/auth/me` | Auth |
| CRUD | `/api/customers` | Owner |
| GET | `/api/customers/assigned` | Labour |
| POST/GET | `/api/users/labour` | Owner |
| GET | `/api/daily-reports/today` | Labour |
| PATCH | `/api/daily-reports/:id/filled-out` | Labour |
| POST | `/api/daily-reports/:id/deliveries` | Labour |
| PATCH | `/api/daily-reports/:id/empty-in` | Labour |
| PATCH | `/api/daily-reports/:id/extra` | Labour |
| PATCH | `/api/daily-reports/:id/not-received` | Labour |
| POST | `/api/daily-reports/:id/payments` | Labour |
| POST | `/api/daily-reports/:id/submit` | Labour |
| GET | `/api/dashboard/summary` | Owner |
| GET | `/api/dashboard/analytics` | Owner |

## Architecture

**Backend:** MVC + Service Layer + Repository Pattern

```
controllers/ → services/ → repositories/ → models/
```

**Frontend:** Provider state management

```
screens/ → providers/ → services/ → API
```
