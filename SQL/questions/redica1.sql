WITH base AS (
    SELECT *,
        MAX(c4) OVER(PARTITION BY c1, c2) as mx 
    FROM radica_question
),
base30 AS (
    SELECT 
        c1, c2, c3, c4 
    FROM base 
    WHERE c4 = 30
),
basemx AS (
    SELECT
        a.c1, a.c2, a.c3, a.c4
    FROM base a
	LEFT JOIN base30 b ON a.c1 = b.c1 and b.c2 = a.c2 
	WHERE b.c1 IS NULL AND a.c4 = a.mx
),
v_final AS (
	SELECT * FROM base30
	UNION 
	SELECT * FROM basemx 
)

SELECT * FROM v_final 
ORDER BY c1, c2

-- WITH base AS (
--     SELECT *,
--         MAX(c4) OVER(PARTITION BY c1, c2) as mx 
--     FROM radica_question
-- ),
-- base30 AS (
--     SELECT 
--         c1, c2, c3, c4 
--     FROM base 
--     WHERE c4 = 30
-- ),
-- basemx AS (
--     SELECT
--         c1, c2, c3, c4 
--     FROM base 
--     WHERE c4 = mx 
-- ),
-- v_final AS (
-- 	SELECT * FROM base30
-- 	UNION 
-- 	SELECT * FROM basemx 
-- 	WHERE (c1, c2) NOT IN (SELECT c1, c2 FROM base30)
-- )

-- SELECT * FROM v_final 
-- ORDER BY c1, c2

-- CREATE TABLE radica_question (
--     c1 VARCHAR(10),
--     c2 VARCHAR(10),
--     c3 DATE,
--     c4 INTEGER
-- );


-- INSERT INTO radica_question (c1, c2, c3, c4) VALUES
-- ('a', 'b', '2020-01-01', 20),
-- ('a', 'b', '2020-01-17', 30),
-- ('b', 'b', '2020-01-23', 40),
-- ('c', 'd', '2020-01-05', 50),
-- ('c', 'd', '2020-01-25', 20),
-- ('c', 'd', '2020-01-28', 30),
-- ('e', 'f', '2020-01-09', 10),
-- ('g', 'h', '2020-03-14', 20),
-- ('g', 'h', '2020-03-24', 20),
-- ('g', 'h', '2020-03-27', 25);

-- SELECT * FROM radica_question
-- -- TRUNCATE table radica_question