WITH per_user_per_day AS (
  SELECT
    DATE(timestamp) AS date,
    user_id,
    COUNT(*) FILTER (WHERE event_type = 'authorization') AS auth_count,
    COUNT(*) FILTER (WHERE event_type = 'settlement') AS settle_count
  FROM fact_transactions
  GROUP BY 1, 2
  HAVING COUNT(*) FILTER (WHERE event_type = 'authorization') > 0
)
SELECT
  date,
  ROUND(AVG(settle_count::numeric / auth_count), 4) AS avg_conversion_rate
FROM per_user_per_day
GROUP BY date
ORDER BY date;
