# SQL

## COMMANDS
```sql
-- CREATE
CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(100),
    salary DECIMAL(10, 2)
);

-- INSERT
INSERT INTO employees (id, name, department, salary)
VALUES (1, 'Alice', 'HR', 50000.00);

-- UPDATE
UPDATE employees
SET salary = 55000.00
WHERE name = 'Alice';

-- DELETE
DELETE FROM employees
WHERE name = 'Alice';

-- VIEW
CREATE VIEW hr_employees AS
SELECT id, name, salary
FROM employees
WHERE department = 'HR';

-- ALTER
ALTER TABLE Customers
    ADD Email varchar(255);
    RENAME COLUMN old_name to new_name;
    DROP COLUMN Email;

-- MERGE
MERGE INTO target_table AS TARGET
USING source_table AS SOURCE
ON TARGET.key_column = SOURCE.key_column

WHEN MATCHED THEN
    UPDATE SET
        TARGET.col1 = SOURCE.col1,
        TARGET.col2 = SOURCE.col2

WHEN NOT MATCHED BY TARGET THEN
    INSERT (key_column, col1, col2)
    VALUES (SOURCE.key_column, SOURCE.col1, SOURCE.col2)

WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

-- EXPLAIN: shows the plan.
EXPLAIN sql_statement

-- ANALYZE: updates the distribution statistics for the table.
ANALYZE TABLE table_name
```

## DML DDL etc
1. DELETE(DML), DROP(DDL), TRUNCATE(DDL) - difference - what can be rolled back, what cannot?
    - DDL commands (DROP and TRUNCATE) often have implicit commits in many databases, making rollback impossible

## PIVOT
How to `PIVOT`?
```sql
SELECT * FROM (
  SELECT customer_id, YEAR(order_date) AS order_year, amount
  FROM orders
) AS src
PIVOT (
  SUM(amount) FOR order_year IN ([2022], [2023], [2024])
) AS pvt;
``` 
- 🚫 Incorrect approach (manual aggregation)
    ```sql
    SELECT 
    customer_id,
    SUM(CASE WHEN YEAR(order_date) = 2022 THEN amount ELSE 0 END) AS amt_2022,
    SUM(CASE WHEN YEAR(order_date) = 2023 THEN amount ELSE 0 END) AS amt_2023
    FROM orders
    GROUP BY customer_id;
    ```
- 🧠 `PIVOT` simplifies transforming rows into columns, especially when aggregating by known, static values. It enhances readability and can be more efficient than multiple `CASE` statements when supported by the database engine.

## UNPIVOT
How to `UNPIVOT`?
```sql
SELECT customer_id, order_year, amount
FROM (
  SELECT customer_id, [2022], [2023], [2024]
  FROM sales_by_year
) AS src
UNPIVOT (
  amount FOR order_year IN ([2022], [2023], [2024])
) AS unpvt;
``` 
- 🚫 Incorrect approach (manual aggregation)
    ```sql
    SELECT customer_id, '2022' AS order_year, [2022] AS amount FROM sales_by_year
    UNION ALL
    SELECT customer_id, '2023', [2023] FROM sales_by_year
    UNION ALL
    SELECT customer_id, '2024', [2024] FROM sales_by_year;
    ```
- 🧠 `UNPIVOT` turns columns into rows, which is useful for normalizing denormalized data. It avoids repetitive `UNION` logic and keeps queries cleaner and more maintainable.

## INDEXING
How to create an `INDEX`?
```sql
CREATE INDEX idx_order_date ON orders(order_date);
``` 
- 🚫 Prevents index use
    ```sql
    SELECT * FROM orders WHERE YEAR(order_date) = 2023;
    ```
- ✅ Correct way
    ```sql
    SELECT * FROM orders 
    WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01';
    ```
- 🧠 When you wrap a column in a function like YEAR(order_date), it prevents the database from using an index on order_date (if one exists). This can 
lead to full table scans, which are expensive for large tables.

- Performance Impact on Writes:
    - Each index created on a table adds overhead to data modification operations (INSERT, UPDATE, DELETE). When data is modified, the corresponding indexes must also be updated, which takes time and resources. Indexing all columns would significantly slow down these operations.
- Increased Storage Space:
    - Indexes consume disk space. Indexing every column, especially in a large table, can significantly increase the storage requirements, potentially doubling or more the space used by the table itself.
- Limited Benefit for Queries:
    - While indexes are designed to speed up data retrieval, indexing all columns does not guarantee optimal performance for all queries.
    - For queries that retrieve all columns, an index containing all columns would essentially be a duplicate of the table data, offering no performance advantage over a full table scan, especially if the primary key is used for ordering.
    - Indexes are most effective when applied to columns frequently used in WHERE, JOIN, ORDER BY, or GROUP BY clauses, particularly those with high selectivity (a wide range of distinct values). Indexing columns with low selectivity (e.g., a "gender" column with only two distinct values) provides minimal or no performance benefit and can even be detrimental.
- Query Optimizer Overhead:
    - A large number of indexes can increase the complexity for the query optimizer, as it has more potential access paths to evaluate when determining the most efficient way to execute a query.

### Primary differences between clustered and non-clustered indexes

| **FEATURE**       |	**CLUSTERED INDEX**	                                        | **NON-CLUSTERED INDEX**                                              |
|---------------|-----------------------------------------------------------|------------------------------------------------------------------|
| **Speed**         |	Faster for range-based queries and sorting.             | Slower for range-based queries but faster for specific lookups.  |
| **Memory Usage**  |	Requires less memory for operations.	                | Requires more memory due to additional index structure.          |
| **Data Storage**  |	The clustered index stores data in the table itself.	| The non-clustered index stores data separately from the table.   |
| **Count**         |	At most one.	                                        | Can be more than one.                                            |

## PARITIONING
🧠 Partitioning physically separates data (e.g., by year), which improves performance for large datasets. Queries with partition-aligned filters can skip irrelevant partitions (partition pruning), making reads faster.

#### 📊 Indexing vs Partitioning
| **FEATURE**                 | **INDEXING**                                                  | **PARTITIONING**                                                |
|------------------------|---------------------------------------------------------------|------------------------------------------------------------------|
| 🔍 **Purpose**         | Speeds up data lookup via pointers                            | Physically splits table into chunks for better query performance |
| 📁 **Data Layout**     | Logical (data remains in one table)                           | Physical (data split into partitions)                            |
| 📈 **Best for**         | Small to medium-sized tables with frequent lookups/filters    | Large tables with range-based access patterns                   |
| 🧠 **Usage Tip**       | Avoid wrapping indexed columns in functions                   | Always filter by partition key to enable partition pruning       |
| ⚠️ **Common Pitfall**  | Index not used if column is in a function                    | Partition scan happens if filter doesn't match partition column  |

#### 🧩 Clustering vs Bucketing
| **FEATURE**                 | **CLUSTERING**                                                   | **BUCKETING**                                                   |
|------------------------|------------------------------------------------------------------|-----------------------------------------------------------------|
| 🔍 **Purpose**         | Groups similar rows together physically within partitions        | Divides data into fixed number of buckets based on a column     |
| 📁 **Data Layout**     | Sorted within partitions                                         | Hash-distributed into fixed buckets                             |
| 📈 **Best for**         | Range filters and efficient pruning within partitions            | Join optimization and better parallelism                        |
| 🧠 **Usage Tip**       | Cluster on frequently filtered columns inside a partition        | Bucket on join keys for large joins across datasets             |
| 🛠️ **Example Query**    | `SELECT * FROM logs WHERE user_id BETWEEN 100 AND 200;`         | `SELECT * FROM a JOIN b ON a.customer_id = b.customer_id;`     |
| ⚠️ **Common Pitfall**  | Too many clusters can reduce performance                         | Must ensure bucket count matches across tables for joins        |

#### 🧠 Summary
- `Partitioning` is ideal for filtering large datasets based on specific column values.
- `Clustering` enhances performance by sorting data within partitions.
- `Bucketing` is beneficial for optimizing joins and ensuring even data distribution.
- Can we first have `clustering` and then `partitioning`? No.
- Can we have `clustering` without `paritition`? Yes.

## JOINS
[Joins Simplified](https://youtu.be/xR87ctOgpAE?si=b6IziYzOH9jNfiG5)

## EXISTS
Use Case- Find customers who have made at least one purchase.
```sql
SELECT c.customer_id, c.name
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);
```
Difference between JOIN and EXISTS- 
-   JOIN: Give me the list of people and the books they borrowed.
-   EXISTS: Just tell me which people have borrowed at least one book.

## EXECUTION ORDER
FROM and JOINs → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT/OFFSET or TOP 

## STORED PROCEDURE
In MySQL, when you define parameters in a stored procedure, you must explicitly state whether each one is:
- IN → input only (default in many other DBs, but must be written in MySQL)
- OUT → output only (used to return values)
- INOUT → used for both input and output.

```sql
DELIMITER //

CREATE PROCEDURE compute_total (
    IN price DECIMAL(10,2),
    IN quantity INT,
    OUT total DECIMAL(10,2)
)
BEGIN
    SET total = price * quantity;
END;
DELIMITER ;

CALL ProcedureName([arguments]);
```

DELIMITER command to temporarily change the delimiter from ; to // for the duration of the CREATE PROCEDURE call. Then, all semicolons inside the stored procedure body will be passed to the server as-is. After the whole procedure is finished, the delimiter is changed back to ; with the last DELIMITER ;.


## OPTIMIZATIONS
1.  OR in WHERE Clauses
    - ⚠️ Bad: WHERE status = 'open' OR status = 'pending'
    - ✅ Better: WHERE status IN ('open', 'pending')
    - 🧠 Or use UNION ALL with index support if complex filters are involved.
2. NOT IN with NULLs
    - ⚠️ Bad: WHERE id NOT IN (SELECT user_id FROM banned_users)
    - ✅ Use: WHERE NOT EXISTS (SELECT 1 FROM banned_users WHERE banned_users.user_id = users.id)
    - 🧠 NOT IN fails when subquery returns NULLs — leads to wrong results.
3. In some databases (like Postgres), CTEs are optimization fences.
    - ⚠️ Bad:
        ```sql
        WITH temp AS (
            SELECT * FROM big_table WHERE expensive_filter
        )
        SELECT * FROM temp WHERE some_other_filter 
        ```
    - ✅ Better: Inline the CTE if reused only once, or materialize only when needed.
4. Joins without indexes
    - 🧠 When joining large tables, ensure foreign keys and join keys are indexed. Ensure both sides have indexes on joining columns.
    - 📉 Missing indexes = huge performance drop with hash joins or nested loops.
5. 🧠 
    - SQL is a set-based language — treat rows as groups, not individuals.
    - RBAR forces the DB to handle thousands/millions of individual steps = sloooow.
    - Set-based ops use bulk operations, query planning, and index scanning — all optimized under the hood.
    - Select only necessary columns instead of `SELECT *` for better performance and bandwidth.

## QnA
1. Is `delete` faster or `truncate`?
-  Truncate is faster.

2. `WHERE` vs `HAVING`.
-  Filter is applied on individual rows. Filter is applied on group of rows.

3. Default frame behavior is?
- `RANGE BETWEEN` UNBOUNDED PRECEDING AND CURRENT ROW, and not `ROWS BETWEEN`.

### DATABASE SNAPSHOT/DUMP
`$ mysqldump -u [uname] -p db_name > db_backup.sql`

### [🛠️ Resource](https://youtube.com/playlist?list=PLBTZqjSKn0IeKBQDjLmzisazhqQy4iGkb&si=uneWiyIO5Yjy9148)

```sql
SELECT * 
    IFNULL(ROUND(SUM(units*price)/SUM(units),2),0),
    SUM(balance) OVER(PARTITION BY department ORDER BY salary ROWS BETWEEN UNBOUNDED PRECEDING AND 2 FOLLOWING)
FROM users
WHERE REGEXP_LIKE(mail, '^[a-zA-Z][a-zA-Z0-9._-]*@leetcode\\.com$', 'c');
```