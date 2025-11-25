-- CREATE TABLE event_status(event_time varchar(10),status varchar(10));
-- INSERT INTO event_status VALUES ('10:01','on'),('10:02','on'),('10:03','on'),('10:04','off'),('10:07','on'),('10:08','on'),('10:09','off'),('10:11','on'),('10:12','off');

WITH base AS(
	SELECT *,
		lag(status,1,status) over(ORDER BY event_time) as lagstatus
	FROM event_status
),
base2 AS(	
	SELECT *,
		SUM(CASE WHEN status='on' AND lagstatus='off' THEN 1 ELSE 0 END) OVER(ORDER BY event_time) AS groupky
	FROM base
)
SELECT MIN(event_time),MAX(event_time), 'ON' AS status
FROM base2 
GROUP BY groupky