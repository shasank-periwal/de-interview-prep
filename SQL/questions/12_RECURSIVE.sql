-- create table sales (
-- product_id int,
-- period_start date,
-- period_end date,
-- average_daily_sales int
-- );

-- insert into sales values(1,'2019-01-25','2019-02-28',100),(2,'2018-12-01','2020-01-01',10),(3,'2019-12-01','2020-01-31',1);

WITH RECURSIVE all_dates AS (
	SELECT MIN(CAST(period_start AS DATE)) as start_date, MAX(period_end) as end_date FROM sales
	UNION
	SELECT CAST(start_date + INTERVAL '1 day' AS DATE), end_date
	FROM all_dates
	WHERE start_date < end_date
)

SELECT product_id, EXTRACT(YEAR FROM start_date) AS year, SUM(average_daily_sales) AS sum_amount
FROM all_dates a
LEFT JOIN sales s ON a.start_date BETWEEN s.period_start AND s.period_end
GROUP BY EXTRACT(YEAR FROM start_date), product_id
ORDER BY product_id
