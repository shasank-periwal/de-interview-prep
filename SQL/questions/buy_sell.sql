-- SELECT * FROM item_prices;
WITH buy_sell_pairs AS (
  SELECT
    buy.event_time AS buy_time,
    sell.event_time AS sell_time,
    sell.price - buy.price AS profit,
    ROW_NUMBER() OVER (ORDER BY sell.price - buy.price DESC) AS profit_rank
  FROM ranked_prices buy
  JOIN ranked_prices sell
    ON sell.event_time > buy.event_time
)
SELECT buy_time, sell_time, profit AS max_profit
FROM buy_sell_pairs
WHERE profit_rank = 1;

-- CREATE TABLE item_prices (
--   event_time    TIMESTAMP,
--   price         DECIMAL(10,2)
-- );

-- INSERT INTO item_prices (event_time, price) VALUES
-- ('2025-10-01 09:00:00', 100.00),
-- ('2025-10-01 10:00:00', 102.50),
-- ('2025-10-01 11:00:00', 101.20),
-- ('2025-10-01 12:00:00', 105.00),
-- ('2025-10-01 13:00:00', 104.75),
-- ('2025-10-01 14:00:00', 107.30),
-- ('2025-10-01 15:00:00', 106.00),
-- ('2025-10-01 16:00:00', 108.50),
-- ('2025-10-02 09:00:00', 107.00),
-- ('2025-10-02 10:00:00', 110.00),
-- ('2025-10-02 11:00:00', 109.50),
-- ('2025-10-02 12:00:00', 112.00),
-- ('2025-10-02 13:00:00', 111.25),
-- ('2025-10-02 14:00:00', 113.75),
-- ('2025-10-02 15:00:00', 112.50),
-- ('2025-10-02 16:00:00', 115.00);
