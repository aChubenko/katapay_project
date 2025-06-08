SELECT
  event_id,
  event_type,
  timestamp,
  user_id,
  provider_id,
  amount,
  currency
FROM {{ ref('stg_transactions') }}
