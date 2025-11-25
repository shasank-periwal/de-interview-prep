-- CREATE TABLE employee (emp_id int,company varchar(10),salary int);
-- INSERT INTO employee values (1,'A',2341), (2,'A',341), (3,'A',15), (4,'A',15314), (5,'A',451), (6,'A',513), (7,'B',15), (8,'B',13), (9,'B',1154), (10,'B',1345), (11,'B',1221), (12,'B',234), (13,'C',2345), (14,'C',2645), (15,'C',2645), (16,'C',2652), (17,'C',65);

-- MEDIAN for each company

WITH base AS (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY company ORDER BY emp_id) as rnk,
		COUNT(1) OVER(PARTITION BY company) as cnt
	FROM employee
)

SELECT company, ROUND(AVG(salary),1)
FROM base
WHERE rnk BETWEEN cnt/2.0 AND (cnt/2.0)+1
GROUP BY company