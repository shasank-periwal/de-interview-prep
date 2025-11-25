-- create table UserActivity(username varchar(20),activity varchar(20),startDate Date,endDate Date);

-- insert into UserActivity values 
-- ('Alice','Travel','2020-02-12','2020-02-20')
-- ,('Alice','Dancing','2020-02-21','2020-02-23')
-- ,('Alice','Travel','2020-02-24','2020-02-28')
-- ,('Bob','Travel','2020-02-11','2020-02-18');

WITH base AS (
	SELECT 
		*,
		COUNT(1) OVER (PARTITION BY username) AS totalactivity,
		RANK() OVER (PARTITION BY username ORDER BY startDate) AS rnk
	FROM useractivity
)

SELECT * FROM base
WHERE totalactivity = 1 or rnk = 2
