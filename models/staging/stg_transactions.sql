WITH base AS (
  SELECT
    event_id,
    event_type,
    timestamp::timestamp,
    user_id,
    provider_id,
    amount::numeric,
    currency
  FROM {{ source('katapay', 'raw_transactions') }}
  WHERE event_type IN ('authorization', 'settlement')
),

auth_by_user_date AS (
  SELECT DISTINCT
    user_id,
    DATE(timestamp) AS date
  FROM base
  WHERE event_type = 'authorization'
)

SELECT
  b.*
FROM base b
LEFT JOIN auth_by_user_date a
  ON b.user_id = a.user_id AND DATE(b.timestamp) = a.date
WHERE
  -- Убираем settlement без авторизации
  NOT (b.event_type = 'settlement' AND a.user_id IS NULL)
