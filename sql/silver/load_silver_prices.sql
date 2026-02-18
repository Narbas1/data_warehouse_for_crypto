WITH w AS (
  SELECT last_ingestion_id
  FROM meta.watermarks
  WHERE pipeline = 'silver_prices'
),
ins AS (
  INSERT INTO silver.prices (
    coin_id, vs_currency, price, api_last_updated_at, ingested_at, source_ingestion_id
  )
  SELECT
    e.key AS coin_id,
    'eur' AS vs_currency,
    (e.value->>'eur')::numeric AS price,
    CASE
      WHEN e.value ? 'last_updated_at'
        THEN to_timestamp((e.value->>'last_updated_at')::bigint) AT TIME ZONE 'UTC'
      ELSE NULL
    END AS api_last_updated_at,
    b.ingested_at,
    b.ingestion_id
  FROM bronze.coingecko_raw b
  CROSS JOIN LATERAL jsonb_each(b.payload) AS e(key, value)
  WHERE
    b.request_params->>'vs_currencies' = 'eur'
    AND e.value ? 'eur'
    AND b.ingestion_id > (SELECT last_ingestion_id FROM w)
  ON CONFLICT DO NOTHING
  RETURNING source_ingestion_id
)
UPDATE meta.watermarks
SET
  last_ingestion_id = COALESCE((SELECT MAX(source_ingestion_id) FROM ins), last_ingestion_id),
  updated_at = now()
WHERE pipeline = 'silver_prices';