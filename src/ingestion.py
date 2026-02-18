import requests
import psycopg
import os, json, hashlib
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("GECKO_API_KEY")

endpoint = "https://api.coingecko.com/api/v3/simple/price"
params = {"ids": "bitcoin,ethereum,solana", "vs_currencies": "eur", "include_last_updated_at": "true"}
headers = {"x-cg-demo-api-key": API_KEY} if API_KEY else {}

r = requests.get(endpoint, params=params, headers=headers, timeout=30)
r.raise_for_status()
payload = r.json()

payload_hash = hashlib.sha256(json.dumps(payload, sort_keys=True).encode()).hexdigest()

conn_str = (
    f"host={os.getenv('PGHOST')} port={os.getenv('PGPORT','5432')} dbname={os.getenv('PGDATABASE')} "
    f"user={os.getenv('PGUSER')} password={os.getenv('PGPASSWORD')}"
)

sql = """
INSERT INTO bronze.coingecko_raw (endpoint, request_params, payload, payload_hash)
VALUES (%s, %s::jsonb, %s::jsonb, %s)
ON CONFLICT (payload_hash) DO NOTHING;
"""

with psycopg.connect(conn_str) as conn:
    with conn.cursor() as cur:
        cur.execute(sql, (endpoint, json.dumps(params), json.dumps(payload), payload_hash))
    conn.commit()

print("Inserted 1 row (1 response)")
