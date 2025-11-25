-- create table transactions( order_id int, cust_id int, order_date date, amount int );
-- insert into transactions values 
-- (1,1,'2020-01-15',150) ,(2,1,'2020-02-10',150) ,(3,2,'2020-01-16',150) ,(4,2,'2020-02-25',150)
-- ,(5,3,'2020-01-10',150) ,(6,3,'2020-02-20',150) ,(7,4,'2020-01-20',150) ,(8,5,'2020-02-20',150);


WITH base AS (
	SELECT 
		EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date),
		-- LEAD(order_date) OVER(PARTITION BY cust_id ORDER BY order_date) AS lead_order_date,
		(order_date - LAG(order_date) OVER(PARTITION BY cust_id ORDER BY order_date)) AS days
	FROM transactions
	GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
)

SELECT * FROM base

-- WITH base AS (
-- 	SELECT 
-- 		EXTRACT(YEAR FROM order_date) as yr,
-- 		EXTRACT(MONTH FROM order_date) as mnth,
-- 		COUNT(cust_id) OVER(PARTITION BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date) ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)) AS rnk
-- 	FROM transactions
-- )

-- SELECT * FROM base
-- SELECT * FROM transactions