SELECT DISTINCT
  timestamp::date AS date,
  EXTRACT(hour FROM timestamp) AS hour,
  TO_CHAR(timestamp, 'Day') AS day_of_week
FROM {{ ref('stg_transactions') }}
