-- CREATE TABLE hall_events(hall_id integer,start_date date,end_date date);
-- INSERT INTO hall_events values (1,'2023-01-13','2023-01-14'),(1,'2023-01-14','2023-01-17'),(1,'2023-01-15','2023-01-17'),(1,'2023-01-18','2023-01-25'),(2,'2022-12-09','2022-12-23'),(2,'2022-12-13','2022-12-17'),(3,'2022-12-01','2023-01-30');

WITH RECURSIVE base AS (
	SELECT *,
		ROW_NUMBER() OVER(ORDER BY hall_id, start_date) AS event_id
	FROM hall_events
),
r_base AS (
	SELECT hall_id, start_date, end_date, event_id, 1 AS group_ FROM base WHERE event_id = 1
	
	UNION ALL
	
	SELECT b.hall_id, b.start_date, b.end_date, b.event_id, 
	CASE WHEN a.hall_id = b.hall_id AND ((a.start_date BETWEEN b.start_date AND b.end_date) OR 
	(b.start_date BETWEEN a.start_date AND a.end_date)) THEN group_ ELSE group_ +1 END AS group_ 
	FROM r_base a	
	INNER JOIN base b ON a.event_id+1 = b.event_id
)

SELECT hall_id, MIN(start_date), MAX(end_date) FROM r_base
GROUP BY hall_id, group_


-- SELECT hall_id, MIN(start_date), MAX(end_date)
-- FROM grouped
-- GROUP BY hall_id, group_
-- ORDER BY hall_id 