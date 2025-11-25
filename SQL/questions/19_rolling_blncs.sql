-- create table orderbook (
--     row_id integer primary key, order_id varchar,  order_date date, ship_date date, customer_id varchar, customer_name varchar, segment varchar, country_region varchar, city varchar, state varchar, 
--     postal_code integer, region varchar,product_id varchar,category varchar,sub_category varchar, sales decimal, quantity integer, discount decimal, profit decimal
-- );

-- select * from orderbook;

WITH base AS (
	SELECT 
		EXTRACT(YEAR FROM order_date) AS yr,
		EXTRACT(MONTH FROM order_date) AS mnth,
		SUM(sales * quantity) AS order_total
	FROM orderbook
	GROUP BY yr, mnth
),
final as (
	SELECT
		*,
		SUM(order_total) OVER (PARTITION BY yr ORDER BY yr, mnth ASC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING)
	FROM base
)
SELECT * FROM FINAL