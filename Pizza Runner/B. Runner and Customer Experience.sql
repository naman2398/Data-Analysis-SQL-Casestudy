--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
WITH week_number as(
    SELECT CASE
                WHEN registration_date BETWEEN '2021-01-01' and '2021-01-07' THEN 1
                WHEN registration_date BETWEEN '2021-01-08' and '2021-01-14' THEN 2
                WHEN registration_date BETWEEN '2021-01-15' and '2021-01-21' THEN 3
                END AS week_number
    FROM pizza_runner.runners
    )
SELECT  week_number, COUNT(*) as runners_signed
FROM week_number
GROUP BY 1;

--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT ro.runner_id, ROUND(AVG(EXTRACT(EPOCH FROM(ro.pickup_time - co.order_time)))/ 60.0,2) as avg_arrival_time 
FROM pizza_runner.customer_orders_temp co
JOIN pizza_runner.runner_orders_temp ro ON ro.order_id = co.order_id
WHERE distance!=0
GROUP BY ro.runner_id;

--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH prep_time as (
    SELECT co.order_id, count(co.pizza_id) as pizza_count,
           ROUND(AVG(EXTRACT(EPOCH FROM(ro.pickup_time - co.order_time)))/ 60.0,2) as pizza_prepTime
    FROM pizza_runner.customer_orders_temp co
    JOIN pizza_runner.runner_orders_temp ro ON ro.order_id = co.order_id
    WHERE Distance!=0
    GROUP BY co.order_id
    ORDER BY 2,3
    )
    
SELECT pizza_count, round(avg(pizza_prepTime),2) as avg_pizza_prepTime
FROM prep_time
GROUP BY pizza_count

--4. What was the average distance travelled for each customer?

select co.customer_id, round(AVG(distance::numeric),2) as avg_distance_travelled
FROM pizza_runner.customer_orders_temp co
JOIN pizza_runner.runner_orders_temp ro ON ro.order_id = co.order_id
WHERE Distance!=0
GROUP BY co.customer_id
ORDER BY 2 DESC

--5. What was the difference between the longest and shortest delivery times for all orders?
SELECT max(duration) - min(duration) as delivery_diff
FROM pizza_runner.runner_orders_temp
WHERE Distance!=0

--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT runner_id,order_id, 
round(distance::NUMERIC/(duration::NUMERIC/60.0),2) as avg_speed
FROM pizza_runner.runner_orders_temp
WHERE distance is not NULL
ORDER BY 1,3

--7. What is the successful delivery percentage for each runner?

SELECT runner_id,
       ROUND((count(pickup_time)*1.0/count(*)*1.0)*100.0,0) as successful_delivery_percentage 
FROM pizza_runner.runner_orders_temp
GROUP BY runner_id

















