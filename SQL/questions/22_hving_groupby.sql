-- CREATE TABLE marks (id integer, subject varchar, marks integer);
-- DELETE FROM marks
-- INSERT INTO marks VALUES(1, 'Physics', 91), (1, 'Chemistry', 91),(2,'Chemistry',80),(2,'Physics',90),(3,'Chemistry',80),(4,'Chemistry',71),(4,'Physics',54);

SELECT id FROM marks
WHERE subject IN ('Physics', 'Chemistry')
GROUP BY id
HAVING COUNT(DISTINCT subject) > 1 AND COUNT(DISTINCT marks) = 1
-- SELECT * FROM marks;