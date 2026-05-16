# CLAUDE.md

## Project Overview

**Career OS** — a personal career tracking database. This project provides the backend data infrastructure for storing and managing career information: personal profile, employment history, roles held, and a timestamped audit log of career events and achievements.

Current state: early-stage scaffold. All active code is SQL migrations and GitHub Actions CI. No application server or ORM yet.

## Tech Stack

| Layer | Technology |
|---|---|
| Database | PostgreSQL (hosted on [Neon](https://neon.tech) — serverless Postgres) |
| Migrations | Plain SQL files, applied via `psql` |
| CI/CD | GitHub Actions (`.github/workflows/migrate.yml`) |
| Auth/Config | GitHub Environments + Secrets |

No Node.js, Python, or other runtime is present yet.

## Directory Structure

```
worcester/
├── .github/
│   └── workflows/
│       └── migrate.yml       # Auto-runs migrations on push to main
├── migrations/
│   ├── README.md             # Migration conventions (important — read this)
│   ├── 0001_initial.sql      # Creates person, employer, role, activity_event tables
│   └── .gitkeep
├── SETUP.md                  # One-time Neon + GitHub setup steps
└── CLAUDE.md                 # This file
```

## How to Run / Deploy

Migrations run automatically via GitHub Actions when a PR is merged to `main`. There is no local dev runner yet.

**Manual run (if needed):**
```bash
psql "$DATABASE_URL" -f migrations/0001_initial.sql
```

**CI workflow steps (migrate.yml):**
1. Installs `postgresql-client`
2. Creates `schema_migrations` tracking table (idempotent)
3. Runs each `migrations/*.sql` file in alphabetical order
4. Skips files already recorded in `schema_migrations`
5. Records the filename on success

## One-Time Setup Prerequisites

See `SETUP.md` for full details. Summary:

1. Create a Neon project at neon.tech
2. Create a GitHub environment named `prod`
3. Add secret `DATABASE_URL` to the `prod` environment (use the **direct** connection string, not the pooler URL)
4. Enable branch protection on `main` (require PR review before merge)
5. Set GitHub Actions permissions to "Read and write"

## Database Schema

Four tables defined in `0001_initial.sql`:

| Table | Purpose | Notes |
|---|---|---|
| `person` | Singleton — one row describing the user | No hard constraint; application must enforce |
| `employer` | Companies worked at | Soft-delete via `deleted_at` |
| `role` | Positions held | FK → `employer.id` with `ON DELETE RESTRICT` |
| `activity_event` | Append-only event log | No `updated_at`/`deleted_at` — corrections are new events |

**`schema_migrations`** — created by the CI workflow, not in the migrations folder. Tracks which `.sql` files have been applied (`filename TEXT PRIMARY KEY`, `applied_at TIMESTAMPTZ`).

## Coding Conventions

### SQL Migrations

- File naming: `NNNN_description.sql` (sequential, zero-padded to 4 digits)
- **Never edit a migration file after it has been merged.** Always add a new file.
- All `CREATE TABLE` statements use `IF NOT EXISTS` — migrations must be idempotent
- Primary keys: `UUID` with `gen_random_uuid()` default
- Timestamps: `TIMESTAMPTZ` with `now()` default
- Soft-delete pattern: nullable `deleted_at TIMESTAMPTZ` column
- Foreign keys: `ON DELETE RESTRICT` (no cascades)
- **No `GRANT` statements** — Neon free tier only has `neondb_owner`

### `activity_event` table

Intentionally has no `updated_at` or `deleted_at`. It is an immutable audit log. If something was recorded incorrectly, insert a corrective event — do not update or delete the original row.

## Common Commands

```bash
# Apply a specific migration manually
psql "$DATABASE_URL" -f migrations/0002_your_migration.sql

# Check which migrations have been applied
psql "$DATABASE_URL" -c "SELECT filename, applied_at FROM schema_migrations ORDER BY applied_at;"

# Connect interactively
psql "$DATABASE_URL"

# List tables
psql "$DATABASE_URL" -c "\dt"
```

## Gotchas / Things to Avoid

1. **No pooler URL** — always use the Neon direct connection string (without `-pooler` in the hostname) for `psql` and migrations.

2. **Sequential migration numbers are critical** — the workflow applies files in alphabetical order. Gaps or out-of-order numbers will cause unexpected behavior.

3. **Idempotency is required** — every statement must be safe to re-run. Use `IF NOT EXISTS`, `ON CONFLICT DO NOTHING`, etc.

4. **No GRANT / CREATE ROLE** — Neon's free tier does not support custom roles. These statements will fail.

5. **`activity_event` is append-only** — do not add `updated_at` or `deleted_at` to this table. Any schema change that implies mutability breaks the audit-log design intent.

6. **`person` is a singleton** — there is no `UNIQUE` constraint enforcing this yet; application logic must ensure only one row exists.

7. **Branch protection must be on** — the PR-based workflow only works if `main` requires PRs. Pushing directly to `main` skips the review step but still triggers migrations.

8. **This is a git worktree** — the repo root is `/Users/olenamelnyk/conductor/repos/ai_stack`; this workspace lives at `.git/worktrees/worcester`. Standard git commands work normally.
