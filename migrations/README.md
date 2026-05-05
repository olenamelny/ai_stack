# migrations/

SQL migration files for the Career OS database (Postgres on Neon).

## Conventions

- Files are named `NNNN_description.sql` (e.g. `0001_initial.sql`)
- Sequential numbering — never edit a file after it has been merged
- Every `CREATE TABLE` uses `IF NOT EXISTS` for idempotency
- No `GRANT` statements — only `neondb_owner` role exists on Neon

## How migrations run

GitHub Actions (`.github/workflows/migrate.yml`) runs every `.sql` file
in alphabetical order against `$DATABASE_URL` (stored in the `prod`
GitHub environment secret) on every push to `main` that touches this folder.

A `schema_migrations` table tracks which files have already run so
re-runs are safe.

## Planned tables (first migration)

| Table | Purpose |
|---|---|
| `person` | Singleton — one row describing you |
| `employer` | Companies you've worked at |
| `role` | Positions held, FK → employer |
| `activity_event` | Append-only log of career events |

> Migration SQL files will be added here once the schema is finalised.
