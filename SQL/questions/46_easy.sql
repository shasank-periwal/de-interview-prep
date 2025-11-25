-- CREATE TABLE drivers(id varchar(10), start_time time, end_time time, start_loc varchar(10), end_loc varchar(10));
-- INSERT INTO drivers values('dri_1', '09:00', '09:30', 'a','b'),('dri_1', '09:30', '10:30', 'b','c'),('dri_1','11:00','11:30', 'd','e'),('dri_1', '12:00', '12:30', 'f','g'),('dri_1', '13:30', '14:30', 'c','h'),('dri_2', '12:15', '12:30', 'f','g'),('dri_2', '13:30', '14:30', 'c','h');
-- write a query to print total rides and profit rides for each driver
-- profit ride is when the end location of current ride is same as start location on next ride

WITH base AS (
	SELECT d1.id as match_, d2.id as mat_ FROM drivers d1
	LEFT JOIN drivers d2 ON d1.id = d2.id AND d1.end_time = d2.start_time
)

SELECT match_, COUNT(match_) AS total, COUNT(mat_) as profit
FROM base
GROUP BY match_