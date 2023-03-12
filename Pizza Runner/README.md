# 🍕 Case Study: Pizza Runner

<img src="https://user-images.githubusercontent.com/81607668/127271856-3c0d5b4a-baab-472c-9e24-3c1e3c3359b2.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Dataset](#dataset)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Case Study Questions](#case-study-questions)
- Solution
  - [Data Cleaning and Transformation](https://github.com/naman2398/SQL-Casestudy/blob/main/Pizza%20Runner/Data%20Cleaning%20and%20Transformation.sql)
  - [A. Pizza Metrics](https://github.com/naman2398/SQL-Casestudy/blob/main/Pizza%20Runner/A.%20PizzaMetric.sql)
  - [B. Runner and Customer Experience](https://github.com/naman2398/SQL-Casestudy/blob/main/Pizza%20Runner/B.%20Runner%20and%20Customer%20Experience.sql)
  - [C. Ingredient Optimisation](https://github.com/naman2398/SQL-Casestudy/blob/main/Pizza%20Runner/C.%20Ingredient%20Optimisation.sql)
  - [D. Pricing and Ratings](https://github.com/naman2398/SQL-Casestudy/blob/main/Pizza%20Runner/D.%20Pricing%20and%20Ratings.md)
 
 ***

## Business Task
Danny is expanding his new Pizza Empire and at the same time, he wants to Uberize it, so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers. 

## Dataset
Key datasets for this case study
- **runners** : The table shows the registration_date for each new runner
- **customer_orders** : Customer pizza orders are captured in the customer_orders table with 1 row for each individual pizza that is part of the order. The pizza_id relates to the type of pizza which was ordered whilst the exclusions are the ingredient_id values which should be removed from the pizza and the extras are the ingredient_id values which need to be added to the pizza.
- **runner_orders** : After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and can be cancelled by the restaurant or the customer. The pickup_time is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. The distance and duration fields are related to how far and long the runner had to travel to deliver the order to the respective customer.
- **pizza_names** : Pizza Runner only has 2 pizzas available the Meat Lovers or Vegetarian!
- **pizza_recipes** : Each pizza_id has a standard set of toppings which are used as part of the pizza recipe.
- **pizza_toppings** : The table contains all of the topping_name values with their corresponding topping_id value

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/127271531-0b4da8c7-8b24-4a14-9093-0795c4fa037e.png)

## Case Study Questions

### A. Pizza Metrics

View my solution [here](https://github.com/naman2398/SQL-Casestudy/blob/main/Pizza%20Runner/A.%20PizzaMetric.sql).

<details>
<summary>
Click here to view the questions!
</summary>

1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?
</details>

### B. Runner and Customer Experience

View my solution [here](https://github.com/naman2398/SQL-Casestudy/blob/main/Pizza%20Runner/B.%20Runner%20and%20Customer%20Experience.sql).

<details>
<summary>
Click here to view the questions!
</summary>

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?
</details>

### C. Ingredient Optimisation

View my solution [here](https://github.com/naman2398/SQL-Casestudy/blob/main/Pizza%20Runner/C.%20Ingredient%20Optimisation.sql).

<details>
<summary>
Click here to view the questions!
</summary>

1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
</details>

### D. Pricing and Ratings

View my solution [here](https://github.com/naman2398/SQL-Casestudy/blob/main/Pizza%20Runner/D.%20Pricing%20and%20Ratings.md).

<details>
<summary>
Click here to view the questions!
</summary>

1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras?
- Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
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
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
</details>

### E. Bonus Questions

<details>
<summary>
Click here to view the questions!
</summary>

If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
</details>

***
