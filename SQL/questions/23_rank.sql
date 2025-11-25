-- create table covid(city varchar(50),days date,cases int);
-- insert into covid values('DELHI','2022-01-01',100),('DELHI','2022-01-02',200), ('DELHI','2022-01-03',300), ('MUMBAI','2022-01-01',100), ('MUMBAI','2022-01-02',100), ('MUMBAI','2022-01-03',300), ('CHENNAI','2022-01-01',100), ('CHENNAI','2022-01-02',200), ('CHENNAI','2022-01-03',150), ('BANGALORE','2022-01-01',100), ('BANGALORE','2022-01-02',300), ('BANGALORE','2022-01-03',200), ('BANGALORE','2022-01-04',400)

WITH base AS (
	SELECT *,
		RANK() OVER(PARTITION BY city ORDER BY DAYS) as rnkdays,
		RANK() OVER(PARTITION BY city ORDER BY cases) as rnkcases,
		RANK() OVER(PARTITION BY city ORDER BY DAYS) - RANK() OVER(PARTITION BY city ORDER BY cases) as diff
	FROM covid
)
SELECT b.city
FROM base b
GROUP BY b.city
HAVING COUNT(DISTINCT DIFF) = 1
-- SELECT * FROM covid;