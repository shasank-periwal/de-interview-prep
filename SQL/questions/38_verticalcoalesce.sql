-- CREATE TABLE brands (category varchar(20),brand_name varchar(20));
-- INSERT INTO brands values('chocolates','5-star'),(null,'dairy milk'),(null,'perk'),(null,'eclair'),('Biscuits','britannia'),(null,'good day'),(null,'boost');

WITH base AS (
	SELECT *, ROW_NUMBER() OVER() as rnk
	FROM brands
),
base2 AS (
	SELECT *, LEAD(rnk, 1, 9999) OVER() as ld
	FROM base
	WHERE category IS NOT NULL
)

SELECT b.category, a.brand_name
FROM base a
INNER JOIN base2 b 
ON a.rnk BETWEEN b.rnk AND b.ld-1
-- a.rnk <= b.ld-1


-- SELECT * FROM BRANDS;