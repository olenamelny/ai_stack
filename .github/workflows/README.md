# .github/workflows/

## migrate.yml

Runs SQL migrations against the Neon production database on every push to `main`
that touches `migrations/**`.

### Trigger

```
on:
  push:
    branches: [main]
    paths: ["migrations/**"]
```

### How it works

1. Installs `psql` (postgresql-client)
2. Creates a `schema_migrations` table on first run (idempotent)
3. Iterates over `migrations/*.sql` in alphabetical order
4. Skips files already recorded in `schema_migrations`
5. Applies new files with `psql -f`, then records them

### Required setup

| What | Where |
|---|---|
| GitHub environment | `prod` (Settings → Environments) |
| Secret name | `DATABASE_URL` (in the `prod` environment, not a repo secret) |
| Connection string | Neon direct URL — **without** `-pooler` suffix |

### Why the `prod` environment gate?

GitHub environment secrets require a reviewer approval step before the job
can read the secret. This means no migration runs without a human merging a PR
and (optionally) approving the environment deployment.
