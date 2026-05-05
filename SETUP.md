# ai_stack — Setup Guide

## Prerequisites

Before the migration workflow can run, complete these one-time steps.

### 1. Neon database

- Create a Neon project at [neon.tech](https://neon.tech)
- Database name: `neondb` (Neon default)
- Copy the **direct** connection string (no `-pooler` suffix) — you'll need it below

### 2. GitHub environment

1. Go to **Settings → Environments → New environment**
2. Name it exactly `prod`
3. (Optional) Add required reviewers for an extra approval gate
4. Add a secret inside that environment:
   - Name: `DATABASE_URL`
   - Value: your Neon direct connection string

### 3. Branch protection

Protect `main` so migrations only run after a reviewed PR:

1. **Settings → Branches → Add rule**
2. Branch name pattern: `main`
3. Enable: *Require a pull request before merging*

### 4. Workflow permissions

**Settings → Actions → General → Workflow permissions**  
Set to: *Read and write permissions*

---

## How to add a migration

1. Create a new branch: `git checkout -b feat/your-migration-name`
2. Add a file: `migrations/NNNN_description.sql`
   - Use the next sequential number
   - Write idempotent SQL (`CREATE TABLE IF NOT EXISTS`, etc.)
   - No `GRANT` statements — only `neondb_owner` exists on Neon
3. Open a PR → review → merge
4. GitHub Actions applies the migration automatically via `migrate.yml`

---

## Repository structure

```
ai_stack/
├── .github/
│   └── workflows/
│       ├── migrate.yml       # Runs SQL migrations on push to main
│       └── README.md         # Workflow documentation
├── migrations/
│   ├── README.md             # Migration conventions and schema plan
│   └── NNNN_*.sql            # Migration files (added per session)
└── SETUP.md                  # This file
```
