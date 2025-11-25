WITH all_dates AS (
    SELECT date_trunc('day', dd):: date as dates
    FROM generate_series('2020-01-01'::date,
                    '2020-12-31'::date,
                    '1 day'::interval) dd
),
base AS (
    SELECT 
        *,
        date_trunc('day', LEAD(c3, 1) OVER (PARTITION BY c1, c2 ORDER BY c3) - INTERVAL '1 day'):: date as to_date
    FROM radica_question
),
final_data AS (
	SELECT 
		c1, c2, c4, c3 as from_date, COALESCE(to_date, c3) as to_date
	FROM base
)

SELECT * 
FROM final_data f
LEFT JOIN all_dates d ON d.dates BETWEEN f.from_date AND f.to_date