-- CREATE TABLE subscriber(sms_date date, sender varchar(20), receiver varchar(20), sms_no int);
-- INSERT INTO subscriber VALUES ('2020-4-1', 'Avinash', 'Vibhor',10),('2020-4-1', 'Vibhor', 'Avinash',20), ('2020-4-1', 'Avinash', 'Pawan',30), ('2020-4-1', 'Pawan', 'Avinash',20), ('2020-4-1', 'Vibhor', 'Pawan',5), ('2020-4-1', 'Pawan', 'Vibhor',8), ('2020-4-1', 'Vibhor', 'Deepak',50);

WITH base AS(
	SELECT *,
		CASE WHEN sender<receiver THEN sender ELSE receiver END AS p1,
		CASE WHEN sender>receiver THEN sender ELSE receiver END AS p2
	FROM subscriber
)

SELECT p1, p2, SUM(sms_no) AS sms_count
FROM base
GROUP BY p1, p2