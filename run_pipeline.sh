#!/bin/bash
set -e  # остановиться при ошибке

echo "🚀 Step 1: Ingesting raw data..."
python ingest.py

echo "✅ Step 2: Running dbt models..."
dbt run

echo "✅ Step 3: Running dbt tests..."
dbt test

echo "📘 Step 4: Generating docs..."
dbt docs generate

echo "🎉 Done!"
