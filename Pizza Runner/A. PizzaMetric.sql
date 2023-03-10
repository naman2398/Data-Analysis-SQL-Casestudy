-- 1. How many pizzas were ordered?

SELECT count(*) AS pizzas_ordered
FROM pizza_runner.customer_orders;

--2 How many unique customer orders were made?

SELECT count(distinct(order_id)) AS unique_order_count
FROM pizza_runner.customer_orders;

--3.How many successful orders were delivered by each runner?

SELECT runner_id, count(*) as orders_delivered
FROM pizza_runner.runner_orders_temp
WHERE distance != 0
GROUP BY 1
ORDER BY 2 DESC;

--4. How many of each type of pizza was delivered?

SELECT  pn.pizza_name, count(*) as quantity_delivered 
FROM pizza_runner.runner_orders_temp ro
JOIN pizza_runner.customer_orders_temp co ON ro.order_id = co.order_id
JOIN pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
WHERE distance != 0
GROUP BY 1
ORDER BY 2 DESC;

--5 How many Vegetarian and Meatlovers were ordered by each customer?
SELECT  co.customer_id,pn.pizza_name, count(*) as quantity_ordered
FROM pizza_runner.customer_orders_temp co 
JOIN pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
GROUP BY 1,2
ORDER BY 1,2;

--6 What was the maximum number of pizzas delivered in a single order?

WITH max_pizza_delivered AS (
    SELECT  ro.order_id, count(*) as pizzas_delivered
    FROM pizza_runner.runner_orders_temp ro
    JOIN pizza_runner.customer_orders_temp co ON ro.order_id = co.order_id
    WHERE distance != 0
    GROUP BY  ro.order_id
    ORDER BY 2  DESC
)

SELECT  max(pizzas_delivered) FROM max_pizza_delivered;


--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT  co.customer_id,
SUM(CASE
          WHEN co.exclusions != ' ' or co.extras != ' ' THEN 1 ELSE 0 
          END) AS change,
SUM(CASE
        WHEN co.exclusions = ' ' and co.extras = ' ' THEN 1 ELSE 0
          END) AS no_change       
FROM pizza_runner.runner_orders_temp ro
JOIN pizza_runner.customer_orders_temp co ON ro.order_id = co.order_id
WHERE ro.distance != 0
GROUP BY co.customer_id
ORDER BY co.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT  
SUM(CASE
          WHEN co.exclusions != ' ' and co.extras != ' ' THEN 1 ELSE 0 
          END) AS extras_exclusions       
FROM pizza_runner.runner_orders_temp ro
JOIN pizza_runner.customer_orders_temp co ON ro.order_id = co.order_id
WHERE ro.distance != 0

--9. What was the total volume of pizzas ordered for each hour of the day?

SELECT EXTRACT(hour from order_time) as hour_day,
       COUNT(*) as hourly_pizza_ordered_count
FROM pizza_runner.customer_orders_temp
GROUP BY 1
ORDER BY 1;

--10. What was the volume of orders for each day of the week?
SELECT TO_CHAR(order_time,'DAY'),
       COUNT(*) as pizza_ordered_count
FROM pizza_runner.customer_orders_temp
GROUP BY 1
ORDER BY 1;



