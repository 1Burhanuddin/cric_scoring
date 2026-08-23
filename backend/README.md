# CricHeros backend (FastAPI + PostgreSQL)

Stage 0/1 of the Firebase → Postgres migration: auth (phone OTP via MSG91),
users, and teams. Matches, live scoring, tournaments, and leaderboard stay on
Firestore until Stage 2/3 (see the migration plan for the full roadmap).

## Run locally

```bash
cd backend
cp .env.example .env   # already has dev-safe defaults; edit if you have real MSG91/R2 keys
docker compose up --build
```

This starts Postgres (host port 5434 - 5432/5433 were already taken by other
local projects) and serves the API on `http://localhost:8001` (interactive
docs at `/docs`; also not 8000, same reason). The Flutter app's
`API_BASE_URL` defaults to `http://10.0.2.2:8001` (Android emulator → host
machine); pass `--dart-define=API_BASE_URL=...` to point at something else
(a physical device, a staging deployment, etc). If your machine doesn't have
those ports taken, feel free to change them back to 5432/8000 in
`docker-compose.yml` (and the matching default in `khelo/lib/main.dart`).

**First run only** — no migration exists yet. Generate it once the containers
are up:

```bash
docker compose run --rm api alembic revision --autogenerate -m "initial schema"
docker compose run --rm api alembic upgrade head
```

(after that, `docker compose up` applies it automatically via the command in
`docker-compose.yml`).

## Run tests

```bash
docker compose up -d db
docker compose run --rm api pytest
```

Tests run against the same `cricheros` database as dev (not a separate test
DB) — fine for local iteration, but wire up a dedicated test database before
this runs in CI.

## What's stubbed for local dev

- **OTP delivery**: with no `MSG91_AUTH_KEY`/`MSG91_TEMPLATE_ID` set, the OTP
  is logged instead of sent, and `OTP_DEV_BYPASS_CODE` (default `000000`)
  always works in non-production. Set real MSG91 credentials before any real
  device testing beyond the emulator/bypass flow.
- **File storage**: `/uploads/presign` returns a 503 until `R2_ACCOUNT_ID` /
  `R2_ACCESS_KEY_ID` / `R2_SECRET_ACCESS_KEY` are set. Create an R2 bucket and
  API token to test profile/team image uploads end-to-end.

