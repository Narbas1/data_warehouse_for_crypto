CREATE TABLE meta.watermarks (
  pipeline TEXT PRIMARY KEY,
  last_ingestion_id BIGINT NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);