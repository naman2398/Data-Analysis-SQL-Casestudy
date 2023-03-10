/* -------------
   DATA CLEANING
   -------------*/

-- Customer Orders Table

SELECT order_id, customer_id, pizza_id, 
CASE
	WHEN exclusions IS null OR exclusions LIKE 'null' or exclusions ='' THEN ' '
	ELSE exclusions
	END AS exclusions,
CASE
	WHEN extras IS NULL or extras LIKE 'null' or extras = '' THEN ' '
	ELSE extras
	END AS extras,
	order_time
INTO pizza_runner.customer_orders_temp
FROM pizza_runner.customer_orders;

-- Runner Orders table

SELECT order_id, runner_id, 
CASE
	WHEN pickup_time IS null OR pickup_time LIKE 'null' THEN NULL
	ELSE pickup_time
	END AS pickup_time,
CASE
	WHEN distance IS NULL or distance LIKE 'null' THEN NULL
	WHEN distance LIKE '%km' THEN trim('km' from distance)
    ELSE distance
	END AS distance,
CASE
	WHEN duration IS NULL or duration LIKE 'null' THEN NULL
	WHEN duration LIKE '%mins' THEN trim('mins' from duration)
    WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	ELSE duration
	END AS duration,
CASE
    WHEN cancellation IS NULL or cancellation LIKE 'null' or cancellation ='' THEN NULL
    ELSE cancellation
    END AS cancellation
INTO pizza_runner.runner_orders_temp
FROM pizza_runner.runner_orders;

ALTER TABLE pizza_runner.runner_orders_temp
ALTER COLUMN pickup_time TYPE timestamp USING(pickup_time::timestamp without time zone),
ALTER COLUMN distance TYPE FLOAT USING (distance::double precision),
ALTER COLUMN duration TYPE FLOAT USING (duration::double precision);



