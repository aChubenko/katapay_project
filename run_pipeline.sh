#!/bin/bash
set -e

echo "🐳 Step 0: Starting Docker Compose services..."
docker-compose up -d

echo "📦 Step 1: Installing dbt dependencies..."
dbt deps

echo "🌱 Step 2: Seeding data into the warehouse..."
dbt seed

echo "🚀 Step 3: Ingesting raw data..."
python ingest.py

echo "🏗️ Step 4: Running dbt models..."
dbt run

echo "✅ Step 5: Running dbt tests..."
dbt test

echo "📘 Step 6: Generating docs..."
dbt docs generate

echo "🎉 Done!"
