-- CREATE TABLE trade_tbl(TRADE_ID varchar(20),Trade_Timestamp time,Trade_Stock varchar(20),Quantity int,Price Float);
-- INSERT INTO trade_tbl VALUES('TRADE1','10:01:05','ITJunction4All',100,20),('TRADE2','10:01:06','ITJunction4All',20,15),('TRADE3','10:01:08','ITJunction4All',150,30),('TRADE4','10:01:09','ITJunction4All',300,32),('TRADE5','10:10:00','ITJunction4All',-100,19),('TRADE6','10:10:01','ITJunction4All',-300,19);

WITH base AS(
	SELECT 
		CASE WHEN a.trade_id < b.trade_id THEN a.trade_id ELSE b.trade_id END AS t2,
		CASE WHEN a.trade_id > b.trade_id THEN a.trade_id ELSE b.trade_id END AS t1,
		CASE WHEN a.trade_id < b.trade_id THEN a.trade_timestamp ELSE b.trade_timestamp END AS t2_timestamp,
		CASE WHEN a.trade_id > b.trade_id THEN a.trade_timestamp ELSE b.trade_timestamp END AS t1_timestamp,
		CASE WHEN a.trade_id < b.trade_id THEN a.price ELSE b.price END AS t2_price,
		CASE WHEN a.trade_id > b.trade_id THEN a.price ELSE b.price END AS t1_price
	FROM trade_tbl a
	JOIN trade_tbl b 
	ON a.trade_timestamp BETWEEN b.trade_timestamp - INTERVAL '10 SECOND' AND b.trade_timestamp + INTERVAL '10 SECOND'
	AND a.trade_id != b.trade_id
)

SELECT * FROM base
WHERE ABS((t2_price*1.0)-t1_price)/((t2_price*1.0)+t1_price) > 0.10
GROUP BY t1,t2,t1_timestamp,t2_timestamp,t1_price,t2_price
ORDER BY t2