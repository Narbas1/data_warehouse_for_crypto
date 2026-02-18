CREATE TABLE IF NOT EXISTS silver.prices (
  coin_id TEXT NOT NULL,
  vs_currency TEXT NOT NULL,
  price NUMERIC NOT NULL,
  api_last_updated_at TIMESTAMPTZ NULL,
  ingested_at TIMESTAMPTZ NOT NULL,
  source_ingestion_id BIGINT NOT NULL
);