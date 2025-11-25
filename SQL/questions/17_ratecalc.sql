-- create table billings ( emp_name varchar(10), bill_date date, bill_rate int);
-- insert into billings values ('Sachin','01-JAN-1990',25) ,('Sehwag' ,'01-JAN-1989', 15) ,('Dhoni' ,'01-JAN-1989', 20) ,('Sachin' ,'05-Feb-1991', 30) ;
-- create table HoursWorked  ( emp_name varchar(20), work_date date, bill_hrs int );
-- insert into HoursWorked values ('Sachin', '01-JUL-1990' ,3) ,('Sachin', '01-AUG-1990', 5) ,('Sehwag','01-JUL-1990', 2) ,('Sachin','01-JUL-1991', 4);


WITH daterange AS (
	SELECT *, LEAD(CAST(bill_date - INTERVAL '1 day' AS DATE),1,'9999-12-01') OVER(PARTITION BY emp_name) as end_date
	FROM billings h
)
SELECT B.emp_name, sum(bill_rate*bill_hrs) as CHARGES FROM daterange h
JOIN hoursworked b ON b.emp_name = h.emp_name AND b.work_date BETWEEN h.bill_date AND h.end_date
GROUP BY B.emp_name
-- SELECT * FROM billings;
-- SELECT * FROM hoursworked;
