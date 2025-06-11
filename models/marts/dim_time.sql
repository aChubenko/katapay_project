SELECT
  DISTINCT date_trunc('day', event_time) AS date,
  extract(hour from event_time) AS hour,
  extract(dow from event_time) AS day_of_week
FROM {{ ref('fact_transactions') }}

