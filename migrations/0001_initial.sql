-- =============================================================================
-- Migration: 0001_initial.sql
-- Creates the four core tables for Career OS:
--   person         - singleton row describing you
--   employer       - companies you have worked at
--   role           - positions held, linked to an employer
--   activity_event - append-only log of career events
-- =============================================================================

-- Table 1: person (singleton — only one row, ever)
CREATE TABLE IF NOT EXISTS person (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT        NOT NULL,
  email      TEXT,
  location   TEXT,
  summary    TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- Table 2: employer
CREATE TABLE IF NOT EXISTS employer (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT        NOT NULL,
  industry   TEXT,
  size_range TEXT,
  location   TEXT,
  summary    TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- Table 3: role (positions held)
CREATE TABLE IF NOT EXISTS role (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  employer_id UUID        NOT NULL REFERENCES employer(id) ON DELETE RESTRICT,
  title       TEXT        NOT NULL,
  level       TEXT,
  started_at  DATE,
  ended_at    DATE,        -- NULL means current role
  summary     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

-- Table 4: activity_event (append-only log)
-- No updated_at or deleted_at: this table is intentionally append-only.
-- Events represent facts that happened at a point in time and must never
-- be silently mutated or soft-deleted — corrections are new events.
CREATE TABLE IF NOT EXISTS activity_event (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  kind        TEXT        NOT NULL,  -- e.g. 'shipped', 'learned', 'decided', 'failed', 'won'
  summary     TEXT        NOT NULL,
  payload     JSONB,
  tags        TEXT[],
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
