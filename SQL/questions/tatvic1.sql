WITH base AS (
	SELECT 
		* ,
		row_number() over() as rnk
	FROM marks
)
,nxt_cte AS (
	SELECT 
		*,
		LEAD(marks, 1, 0) OVER () AS lead_marks,
		LAG(marks, 1, 0) OVER () AS lag_marks,
		avg(marks) OVER( ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) as avg_3marks
	FROM base
)

SELECT (marks + lead_marks + lag_marks)/3 as avg_3marks FROM nxt_cte