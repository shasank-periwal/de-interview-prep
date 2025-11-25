-- CREATE TABLE table_name (
-- 	team1 VARCHAR(100),
-- 	team2 VARCHAR(100),
-- 	winner VARCHAR(100)
-- );

-- INSERT INTO table_name VALUES
-- ('IND', 'AUS', 'IND'),
-- ('AUS', 'IND', 'IND'),
-- ('IND', 'PAK', 'IND'),
-- ('PAK', 'IND', 'IND');

SELECT DISTINCT
	CASE WHEN team1>team2 THEN team1 ELSE team2 END AS t1,	
	CASE WHEN team1<team2 THEN team1 ELSE team2 END AS t2,
	winner
FROM table_name;