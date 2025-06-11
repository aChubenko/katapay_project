{{ config(materialized='table') }}

WITH base AS (
    SELECT
        dt AS datetime,
        dt::DATE AS date,
        EXTRACT(HOUR FROM dt) AS hour,
        EXTRACT(DOW FROM dt) AS day_of_week_index,
        TO_CHAR(dt, 'Day') AS day_of_week_name,
        CASE
            WHEN EXTRACT(DOW FROM dt) IN (0, 6) THEN TRUE
            ELSE FALSE
        END AS is_weekend
    FROM generate_series(
        '2024-01-01'::TIMESTAMP,
        '2024-12-31 23:00:00'::TIMESTAMP,
        INTERVAL '1 hour'
    ) AS dt
),

holidays AS (
    SELECT *
    FROM {{ ref('holiday_list') }}  -- тут должен быть seed или модель с праздниками
),

final AS (
    SELECT
        b.datetime,
        b.date,
        b.hour,
        b.day_of_week_index,
        b.day_of_week_name,
        b.is_weekend,
        CASE WHEN h.date IS NOT NULL THEN TRUE ELSE FALSE END AS is_holiday,
        COALESCE(h.holiday_name, '') AS holiday_name,
        CASE
            WHEN h.date IS NOT NULL THEN 'Holiday'
            WHEN b.is_weekend THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_type,
        CASE
            WHEN b.hour BETWEEN 6 AND 11 THEN 'Morning'
            WHEN b.hour BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN b.hour BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS hour_segment
    FROM base b
    LEFT JOIN holidays h ON b.date = h.date
)

SELECT *
FROM final
ORDER BY datetime
