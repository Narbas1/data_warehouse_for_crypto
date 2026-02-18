CREATE TABLE IF NOT EXISTS bronze.coingecko_raw (
  ingestion_id BIGSERIAL PRIMARY KEY,
  endpoint TEXT NOT NULL,
  request_params JSONB NOT NULL,
  payload JSONB NOT NULL,
  ingested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  payload_hash TEXT NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_coingecko_raw_payload_hash
ON bronze.coingecko_raw(payload_hash);