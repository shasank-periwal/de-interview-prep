-- create table orders (order_id int, customer_id int, product_id int);
-- insert into orders VALUES (1, 1, 1), (1, 1, 2), (1, 1, 3), (2, 2, 1), (2, 2, 2), (2, 2, 4), (3, 1, 5);
-- create table products (id int, name varchar(10));
-- insert into products VALUES (1, 'A'),(2, 'B'),(3, 'C'),(4, 'D'),(5, 'E');

WITH base AS (
	SELECT CONCAT(p1.name,' ',p2.name) AS P2, COUNT(*) AS freq
	FROM orders a
	INNER JOIN orders b ON a.order_id = b.order_id
	INNER JOIN products p1 ON p1.id = a.product_id
	INNER JOIN products p2 ON p2.id = b.product_id
	WHERE a.product_id < b.product_id
	GROUP BY P1, p2
	ORDER BY freq DESC
)

SELECT * FROM base;

-- SELECT * FROM orders;
-- SELECT * FROM products;
