-- Challenge : Write an SQL query to reverse the order of product_id within each category while keeping the corresponding product_name unchanged.

WITH base AS (
	SELECT *,
		row_number() over(partition by category order by product_id) as ordr,
		row_number() over(partition by category order by product_id desc) as ordr_desc
	FROM product_details
	ORDER BY category, product_id
)
SELECT b1.product_id,b2.product_id, b1.product_name, b1.category
FROM base b1
JOIN base b2 ON b1.ordr = b2.ordr_desc AND b1.category = b2.category
	









-- CREATE TABLE 
--     product_details( 
--         product_id INT PRIMARY KEY, 
--         product_name VARCHAR(100), 
--         category VARCHAR(100)
-- );
 
-- INSERT INTO product_details (product_id, product_name, category) VALUES
-- (1, 'Laptop', 'Electronics'),
-- (2, 'Smartphone', 'Electronics'),
-- (3, 'Tablet', 'Electronics'),
-- (4, 'Headphones', 'Accessories'),
-- (5, 'Smartwatch', 'Accessories'),
-- (6, 'Keyboard', 'Accessories'),
-- (7, 'Mouse', 'Accessories'),
-- (8, 'Monitor', 'Accessories'),
-- (9, 'Printer', 'Electronics');
 
