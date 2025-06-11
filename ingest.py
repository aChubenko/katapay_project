import os
import json
import psycopg2
from pathlib import Path

DATA_DIR = Path("data/events")
PG_CONN = {
    "dbname": "katapay",
    "user": "airflow",
    "password": "airflow",
    "host": "localhost",
    "port": 5440,
}

def load_json(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        return json.load(f)

def create_table_if_not_exists(cur):
    cur.execute("""
        CREATE TABLE IF NOT EXISTS raw_transactions (
            event_id    TEXT PRIMARY KEY,
            event_type  TEXT,
            timestamp   TIMESTAMP,
            user_id     TEXT,
            provider_id TEXT,
            amount      NUMERIC,
            currency    TEXT
        );
    """)

def main():
    conn = psycopg2.connect(**PG_CONN)
    cur = conn.cursor()

    # ✅ создание таблицы при необходимости
    create_table_if_not_exists(cur)
    conn.commit()

    inserted = 0
    skipped = 0

    for file in DATA_DIR.glob("*.json"):
        try:
            event = load_json(file)

            cur.execute("""
                INSERT INTO raw_transactions (
                    event_id, event_type, timestamp, user_id,
                    provider_id, amount, currency
                ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (event_id) DO NOTHING;
            """, (
                event["event_id"],
                event["event_type"],
                event["timestamp"],
                event["user_id"],
                event["provider_id"],
                event["amount"],
                event["currency"],
            ))

            if cur.rowcount > 0:
                inserted += 1
            else:
                skipped += 1

        except Exception as e:
            print(f"❌ Error in {file.name}: {e}")

    conn.commit()
    cur.close()
    conn.close()

    print(f"✅ Inserted: {inserted}, Skipped (duplicates): {skipped}")

if __name__ == "__main__":
    main()
