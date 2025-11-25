-- CREATE TABLE Employee (
--     emp_id INT PRIMARY KEY,
--     emp_name VARCHAR(100),
--     manager_id INT
-- );

-- INSERT INTO Employee (emp_id, emp_name, manager_id) VALUES
-- (1, 'Alice', NULL),        -- CEO (top of the chain)
-- (2, 'Bob', 1),             -- Reports to Alice
-- (3, 'Charlie', 2),         -- Reports to Bob
-- (4, 'David', 2),           -- Reports to Bob
-- (5, 'Eve', 3),             -- Reports to Charlie
-- (6, 'Frank', 3),           -- Reports to Charlie
-- (7, 'Grace', 5);           -- Reports to Eve


-- WITH RECURSIVE base AS (
-- 	SELECT *, emp_name AS report FROM employee_tatvic WHERE manager_id IS NULL
-- 	UNION ALL 
-- 	SELECT 
-- 		e.*, 
-- 		b.emp_name AS report 
-- 	FROM base b
-- 	LEFT JOIN employee_tatvic e ON b.emp_id = e.manager_id
-- )

-- SELECT * FROM base

WITH RECURSIVE base AS (
    SELECT 
        emp_id, 
        emp_name, 
        manager_id, 
        CAST('Boss' AS VARCHAR(100)) AS report_chain
    FROM employee_tatvic
    WHERE manager_id IS NULL  -- Top-level (BOSS)
    
    UNION ALL
    
    SELECT 
        e.emp_id,
        e.emp_name,
        e.manager_id,
        CAST(CONCAT(b.report_chain, ' → ', e.emp_name) AS VARCHAR(100)) AS report_chain
    FROM base b
    JOIN employee_tatvic e ON e.manager_id = b.emp_id
)

SELECT * FROM base;

-- WITH RECURSIVE base AS (
--     SELECT 
--         emp_id AS employee,
--         emp_name AS employee_name,
--         emp_id AS origin_emp_id,
--         emp_name AS origin_emp_name,
--         manager_id,
--         NULL::INT AS reportee_id,
--         NULL::VARCHAR(100) AS reportee_name
--     FROM employee_tatvic
--     WHERE manager_id IS NULL

--     UNION ALL

--     SELECT 
--         e.emp_id AS employee,
--         e.emp_name AS employee_name,
--         b.origin_emp_id,
--         b.origin_emp_name,
--         e.manager_id,
--         b.employee AS reportee_id,
--         b.employee_name AS reportee_name
--     FROM base b
--     JOIN employee_tatvic e ON e.manager_id = b.employee
-- )

-- SELECT 
--     origin_emp_name AS top_level_manager,
--     reportee_name AS manager,
--     employee_name AS employee
-- FROM base
-- WHERE reportee_name IS NOT NULL;
