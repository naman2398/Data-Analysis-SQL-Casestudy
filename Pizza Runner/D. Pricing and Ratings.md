## :pizza: Case Study #2: Pizza runner - Pricing and Ratings

####  1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

```sql
SELECT CONCAT('$ ',SUM(CASE
           WHEN pn.pizza_name = 'Meatlovers' THEN 12
           ELSE 10
           END)) AS Total_revenue
FROM pizza_runner.customer_orders_temp co   
JOIN pizza_runner.runner_orders_temp ro ON ro.order_id = co.order_id
JOIN pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
WHERE ro.distance IS NOT NULL;
``` 
	
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/D1.PNG)

***

####  2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra

```sql
SELECT CONCAT('$ ',pizza_revenue+topping_revenue) AS total_revenue
FROM (
    SELECT SUM(CASE
               WHEN pn.pizza_name = 'Meatlovers' THEN 12
               ELSE 10
               END) AS pizza_revenue,
            SUM(CASE
                WHEN co.extras!=' ' THEN length(replace(extras,', ',''))
                ELSE 0
                END) AS topping_revenue
    FROM pizza_runner.customer_orders_temp co   
    JOIN pizza_runner.runner_orders_temp ro ON ro.order_id = co.order_id
    JOIN pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
    WHERE ro.distance IS NOT NULL
    )x;
``` 
	
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/D2.PNG)

***

####  3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

```sql
DROP TABLE IF EXISTS pizza_runner.runner_rating;

CREATE TABLE pizza_runner.runner_rating (order_id INTEGER, rating FLOAT, review VARCHAR(100)) ;

-- Order 6 and 9 were cancelled, hence no runner rating
INSERT INTO pizza_runner.runner_rating
VALUES ('1', '1', 'Poor service, rude behaviour'),
       ('2', '4', NULL),
       ('3', '3.5', 'Delayed...'),
       ('4', '1','Runner was lost and could not find my location, delivered it AFTER two hours. Pizza arrived cold'),
       ('5', '4.5', 'Good service'),
       ('7', '5', 'It was great, good service'),
       ('8', '1.5', 'Runner tossed the parcel on the doorstep, bad service'),
       ('10', '5', 'Pizza Delicious!, delivered 10 mins before the expected delivery time!');

SELECT *
FROM pizza_runner.runner_rating;
``` 
	
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/D3.PNG)

***

####  4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
- customer_id
- order_id
- runner_id
- rating
- order_time
- pickup_time
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas

```sql
WITH pizza_cnt AS(
    SELECT order_id,
           COUNT(*) as total_pizzas
    FROM pizza_runner.customer_orders_temp
    GROUP BY order_id
    )

SELECT distinct co.order_id,
       co.customer_id,
       ro.runner_id,
       r.rating,
       co.order_time,
       ro.pickup_time,
       round(EXTRACT(EPOCH FROM (ro.pickup_time - co.order_time))/60.0,2) as pick_up_time,
       ro.duration,
       round(distance::NUMERIC/(duration::NUMERIC/60.0),2) as average_speed,
       pc.total_pizzas
FROM pizza_runner.customer_orders_temp co
JOIN pizza_runner.runner_orders_temp ro ON co.order_id=ro.order_id
JOIN pizza_runner.runner_rating r ON co.order_id=r.order_id
JOIN pizza_cnt pc ON pc.order_id=co.order_id
WHERE ro.distance is not null
ORDER BY order_id
``` 
	
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/D4.PNG)

***

###  5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

```sql

``` 
	
#### Result set:
![image]()

***

