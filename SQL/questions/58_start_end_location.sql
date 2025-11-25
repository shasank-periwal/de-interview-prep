-- CREATE TABLE travel_data (customer VARCHAR(10),start_loc VARCHAR(50),end_loc VARCHAR(50));
-- INSERT INTO travel_data (customer, start_loc, end_loc) VALUES('c1', 'New York', 'Lima'),('c1', 'London', 'New York'),('c1', 'Lima', 'Sao Paulo'),('c1', 'Sao Paulo', 'New Delhi'),('c2', 'Mumbai', 'Hyderabad'),('c2', 'Surat', 'Pune'),('c2', 'Hyderabad', 'Surat'),('c3', 'Kochi', 'Kurnool'),('c3', 'Lucknow', 'Agra'),('c3', 'Agra', 'Jaipur'),('c3', 'Jaipur', 'Kochi');

-- Q) Find the starting and ending location of a customer

-- METHOD 1
-- WITH base AS (
-- 	SELECT customer, start_loc as places, 'start'  as loc FROM travel_data
-- 	UNION ALL
-- 	SELECT customer, end_loc, 'end'  as loc FROM travel_data
-- ),
-- base2 AS (	
-- 	SELECT customer, places,
-- 		COUNT(*) as cnt,
-- 		MAX(loc) as loc
-- 	FROM base
-- 	GROUP BY customer, places
-- 	ORDER BY customer
-- )
-- SELECT customer, 
-- 	MAX(CASE WHEN loc = 'start' THEN places END) as starting_location,
-- 	MAX(CASE WHEN loc = 'end' THEN places END) as ending_location
-- FROM base2
-- WHERE cnt = 1
-- GROUP BY customer


-- METHOD 2
SELECT t.customer, 
	MAX(CASE WHEN e.end_loc IS NULL THEN t.start_loc END) as starting_location,
	MAX(CASE WHEN s.end_loc IS NULL THEN t.end_loc END) as ending_location
FROM travel_data t
LEFT JOIN travel_data s ON t.customer = s.customer AND s.start_loc = t.end_loc
LEFT JOIN travel_data e ON t.customer = e.customer AND e.end_loc = t.start_loc
GROUP BY t.customer