-- create table bms (seat_no int ,is_empty varchar(10));
-- insert into bms values (1,'N') ,(2,'Y') ,(3,'N') ,(4,'Y') ,(5,'Y') ,(6,'Y') ,(7,'N') ,(8,'Y') ,(9,'Y') ,(10,'Y') ,(11,'Y') ,(12,'N') ,(13,'Y') ,(14,'Y');

-- Method 1
-- WITH base AS (
-- 	SELECT *, 
-- 		lag(is_empty, 1) over(order by seat_no) as lag1,
-- 		lag(is_empty, 2) over(order by seat_no) as lag2,
-- 		lead(is_empty, 1) over(order by seat_no) as lead1,
-- 		lead(is_empty, 2) over(order by seat_no) as lead2
-- 	FROM bms
-- )
-- SELECT 
-- 	seat_no
-- FROM base
-- WHERE (is_empty = 'Y' and lag1 = 'Y' and lag2 = 'Y')
-- 		OR (is_empty = 'Y' and lag1 = 'Y' and lead1 = 'Y')
-- 			OR (is_empty = 'Y' and lead1 = 'Y' and lead2 = 'Y')

-- Method 2
-- WITH base AS (
-- 	SELECT *, 
-- 		SUM(CASE WHEN is_empty = 'Y' THEN 1 ELSE 0 END) OVER (ORDER BY seat_no ROWS BETWEEN 2 PRECEDING AND 0 FOLLOWING) as prev,
-- 		SUM(CASE WHEN is_empty = 'Y' THEN 1 ELSE 0 END) OVER (ORDER BY seat_no ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) as mid,
-- 		SUM(CASE WHEN is_empty = 'Y' THEN 1 ELSE 0 END) OVER (ORDER BY seat_no ROWS BETWEEN 0 PRECEDING AND 2 FOLLOWING) as nxt
-- 	FROM bms
-- )
-- SELECT 
-- 	seat_no
-- FROM base
-- WHERE prev = 3 OR mid = 3 OR nxt = 3

-- Method 3
WITH base AS (
	SELECT *, 
		ROW_NUMBER() OVER (ORDER BY seat_no),
		seat_no - ROW_NUMBER() OVER (ORDER BY seat_no) as diff
	FROM bms
	WHERE is_empty = 'Y'
),
further AS (
	SELECT 
		diff, count(*)
	FROM base 
	GROUP BY diff
	HAVING count(*)>2
)
SELECT seat_no FROM base 
WHERE diff IN (SELECT diff FROM further)
