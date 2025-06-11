SELECT
  event_id,
  event_type,
  CAST(timestamp AS TIMESTAMP) AS event_time,
  user_id,
  provider_id,
  amount,
  currency
FROM {{ source('public', 'raw_transactions') }}
WHERE event_type IN ('authorization', 'settlement')