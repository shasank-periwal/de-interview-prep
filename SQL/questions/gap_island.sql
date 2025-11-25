-- SELECT * FROM OverlappingDateRanges;

SELECT
    *,
	CEIL(EXTRACT(EPOCH FROM (IslandEndDate - IslandStartDate)) / 60) AS ActualTimeSpent
FROM(
    SELECT
        Name,
        IslandId,
        MIN(StartDate) AS IslandStartDate,
        MAX(EndDate) AS IslandEndDate
    FROM(
        SELECT
            *,
            CASE WHEN Grouping.PreviousEndDate >= StartDate THEN 0 ELSE 1 END AS IslandStartInd,
            SUM (CASE WHEN Grouping.PreviousEndDate >= StartDate THEN 0 ELSE 1 END) OVER ( ORDER BY Grouping.RN) AS IslandId
        FROM(
            SELECT
                ROW_NUMBER() OVER (ORDER BY Name, StartDate, EndDate ) AS RN,
                Name,
                StartDate,
                EndDate,
                MAX(EndDate) OVER (PARTITION BY Name ORDER BY StartDate, EndDate ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING ) AS PreviousEndDate
            FROM
                OverlappingDateRanges
        ) Grouping
    ) Islands
    GROUP BY Name, IslandId
) b
ORDER BY NAME, IslandStartDate

-- CREATE TABLE OverlappingDateRanges (
--     Name TEXT,
--     StartDate TIMESTAMP,
--     EndDate TIMESTAMP,
--     ElapsedTimeInMins INTEGER
-- );

-- INSERT INTO OverlappingDateRanges (Name, StartDate, EndDate, ElapsedTimeInMins)
-- VALUES
--     ('Alice', '2019-10-29 03:26:58', '2019-10-29 03:27:02', 1),
--     ('Alice', '2019-10-29 05:42:05', '2019-10-30 10:44:30', 1742),
--     ('Alice', '2019-10-29 06:51:08', '2019-10-29 06:51:12', 1),
--     ('Alice', '2019-10-29 09:59:48', '2019-10-29 09:59:52', 1),
--     ('Alice', '2019-10-30 02:05:49', '2019-10-30 02:05:52', 1),
--     ('Bob', '2019-10-01 07:13:02', '2019-10-01 07:21:58', 9),
--     ('Bob', '2019-10-01 07:22:39', '2019-10-01 07:25:18', 3),
--     ('Bob', '2019-10-01 07:24:17', '2019-10-01 07:24:19', 1),
--     ('Bob', '2019-10-01 07:41:03', '2019-10-01 07:42:38', 2),
--     ('Bob', '2019-10-01 07:46:35', '2019-10-01 07:50:49', 4),
--     ('Bob', '2019-10-01 07:48:44', '2019-10-01 07:55:17', 7);
