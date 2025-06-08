SELECT *
FROM {{ ref('stg_transactions') }} s
WHERE s.event_type = 'settlement'
  AND NOT EXISTS (
    SELECT 1
    FROM {{ ref('stg_transactions') }} a
    WHERE a.event_type = 'authorization'
      AND a.user_id = s.user_id
      AND DATE(a.timestamp) = DATE(s.timestamp)
  )
