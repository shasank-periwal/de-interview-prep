-- create table prdcts(product_id varchar(20), cost int);
-- insert into prdcts values ('P1',200),('P2',300),('P3',500),('P4',800);

-- create table customer_budget(customer_id int,budget int);
-- insert into customer_budget values (100,400),(200,800),(300,1500);

WITH base AS(
	SELECT 
		customer_id, 
		budget, 
		cost,
		product_id,
		SUM(cost) OVER(PARTITION BY customer_id ORDER BY cost ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) as sum_cost
	FROM customer_budget c
	LEFT JOIN prdcts p ON p.cost <= c.budget
	ORDER BY customer_id, cost
)
SELECT customer_id, budget, COUNT(product_id), string_agg(distinct product_id, ', ') FROM base 
WHERE sum_cost<=budget
GROUP BY customer_id, budget
