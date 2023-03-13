## :pizza: Case Study #2: Pizza runner - Pizza Metrics

####  1. How many pizzas were ordered?

```sql
SELECT count(*) AS pizzas_ordered
FROM pizza_runner.customer_orders;
``` 
	
#### Result set:
![image](https://user-images.githubusercontent.com/77529445/164606099-9ea969f1-928e-4bbd-90cd-5211aaed7e89.png)

***

####  2. How many unique customer orders were made?

```sql
SELECT count(distinct(order_id)) AS unique_order_count
FROM pizza_runner.customer_orders;
``` 
	
#### Result set:
![image](https://user-images.githubusercontent.com/77529445/164606186-2b5465ef-69df-4fbb-9a2d-cd50afd49c7a.png)

***

####  3. How many successful orders were delivered by each runner?

```sql
SELECT runner_id, count(*) as orders_delivered
FROM pizza_runner.runner_orders_temp
WHERE distance != 0
GROUP BY 1
ORDER BY 2 DESC;
``` 
	
#### Result set:
![image](https://user-images.githubusercontent.com/77529445/164606290-b70ee6e3-ed23-417a-9e86-e8555d9e55c3.png)

***

####  4. How many of each type of pizza was delivered?

```sql
SELECT  pn.pizza_name, count(*) as quantity_delivered 
FROM pizza_runner.runner_orders_temp ro
JOIN pizza_runner.customer_orders_temp co ON ro.order_id = co.order_id
JOIN pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
WHERE distance != 0
GROUP BY 1
ORDER BY 2 DESC;
``` 
	
#### Result set:
![image](https://user-images.githubusercontent.com/77529445/164606389-9128a4e0-90e9-467b-a593-c18c62ca007e.png)

***

####  5. How many Vegetarian and Meatlovers were ordered by each customer?

```sql
SELECT  co.customer_id,pn.pizza_name, count(*) as quantity_ordered
FROM pizza_runner.customer_orders_temp co 
JOIN pizza_runner.pizza_names pn ON pn.pizza_id = co.pizza_id
GROUP BY 1,2
ORDER BY 1,2;
``` 
	
#### Result set:
![image](https://user-images.githubusercontent.com/77529445/164606480-326c416f-a909-49e8-8bda-8055ee247fd1.png)

***

####  6. What was the maximum number of pizzas delivered in a single order?

```sql
WITH max_pizza_delivered AS (
    SELECT  ro.order_id, count(*) as pizzas_delivered
    FROM pizza_runner.runner_orders_temp ro
    JOIN pizza_runner.customer_orders_temp co ON ro.order_id = co.order_id
    WHERE distance != 0
    GROUP BY  ro.order_id
    ORDER BY 2  DESC
)

SELECT  max(pizzas_delivered) AS max_pizza_delivered FROM max_pizza_delivered;

``` 
	
#### Result set:
![image](https://user-images.githubusercontent.com/77529445/164608353-a577858f-1d1c-46ed-b1f2-05644b756604.png)

***

####  7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
- at least 1 change -> either exclusion or extras 
- no changes -> exclusion and extras are NULL

```sql
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
``` 

#### Result set:
![image](https://user-images.githubusercontent.com/77529445/164609444-9b7453ed-2477-4ce0-b7f7-39768a0ce808.png)

***

####  8. How many pizzas were delivered that had both exclusions and extras?

```sql

SELECT  
      SUM(CASE
              WHEN co.exclusions != ' ' and co.extras != ' ' THEN 1 ELSE 0 
              END) AS with_extras_exclusions       
FROM pizza_runner.runner_orders_temp ro
JOIN pizza_runner.customer_orders_temp co ON ro.order_id = co.order_id
WHERE ro.distance != 0
``` 
	
#### Result set:
![image](https://user-images.githubusercontent.com/77529445/164609941-c2a6f1f8-38c2-4e1c-ab64-a9dd557077e5.png)

***

####  9. What was the total volume of pizzas ordered for each hour of the day?

```sql
SELECT EXTRACT(hour from order_time) as hour_of_day,
       COUNT(*) as hourly_pizza_ordered_count
FROM pizza_runner.customer_orders_temp
GROUP BY 1
ORDER BY 1;
``` 
	
#### Result set:
![image](https://user-images.githubusercontent.com/77529445/164611355-1e9338d0-0523-42f6-8648-079a394387ff.png)

***

#### 10. What was the volume of orders for each day of the week?
 
```sql
SELECT TO_CHAR(order_time,'DAY') AS day_of_week,
       COUNT(*) as pizza_ordered_count
FROM pizza_runner.customer_orders_temp
GROUP BY 1
ORDER BY 1;
``` 
	
#### Result set:
![image](https://user-images.githubusercontent.com/77529445/164612599-c3903593-98e1-4fec-8076-9aa14d9601f9.png)

***
