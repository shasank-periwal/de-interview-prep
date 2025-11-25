-- create table tasks (
-- date_value date,
-- state varchar(10)
-- );

-- insert into tasks  values ('2019-01-01','success'),('2019-01-02','success'),('2019-01-03','success'),('2019-01-04','fail')
-- ,('2019-01-05','fail'),('2019-01-06','success')

WITH base as (
	SELECT 
		*,
		date_value - INTERVAL '1 day' * (ROW_NUMBER() OVER (PARTITION BY state ORDER BY date_value)) AS grouped_date
	FROM tasks
)

SELECT MIN(date_value) AS start_date, MAX(date_value) AS END_date, state
FROM base
GROUP BY grouped_date, state
ORDER BY 1 ASC