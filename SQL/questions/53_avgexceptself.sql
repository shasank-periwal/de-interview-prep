-- CREATE TABLE emp(emp_id int,emp_name varchar(20),department_id int,salary int,manager_id int,emp_age int);
-- INSERT INTO emp values (1, 'Ankit', 100,10000, 4, 39),(2, 'Mohit', 100, 15000, 5, 48),(3, 'Vikas', 100, 10000,4,37),(4, 'Rohit', 100, 5000, 2, 16),(5, 'Mudit', 200, 12000, 6,55),(6, 'Agam', 200, 12000,2, 14),(7, 'Sanjay', 200, 9000, 2,13),(8, 'Ashish', 200,5000,2,12),(9, 'Mukesh',300,6000,6,51),(10, 'Rakesh',300,7000,6,50);

-- Q) Find department whose avg salary is less than rest department's avg salary

SELECT department_id, ROUND(AVG(salary)) FROM emp e1
GROUP BY department_id
HAVING AVG(salary) < (
	SELECT AVG(salary) FROM emp e2
	WHERE e1.department_id != e2.department_id
	-- GROUP BY department_id
)
