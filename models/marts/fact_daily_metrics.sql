{{ config(materialized='table') }}

WITH base AS (
    SELECT
        date_trunc('day', event_time) AS date,
        event_type,
        COUNT(*) AS event_count
    FROM {{ ref('fact_transactions') }}
    GROUP BY 1, 2
)

SELECT
    date,
    COALESCE(MAX(CASE WHEN event_type = 'authorization' THEN event_count END), 0) AS authorized_count,
    COALESCE(MAX(CASE WHEN event_type = 'settlement' THEN event_count END), 0) AS settled_count,
    CASE
        WHEN COALESCE(MAX(CASE WHEN event_type = 'authorization' THEN event_count END), 0) = 0 THEN 0
        ELSE
            COALESCE(MAX(CASE WHEN event_type = 'settlement' THEN event_count END), 0) * 1.0 /
            COALESCE(MAX(CASE WHEN event_type = 'authorization' THEN event_count END), 1)
    END AS conversion_rate
FROM base
GROUP BY date
ORDER BY date
