--1. What are the standard ingredients for each pizza?

WITH topping AS (
    SELECT pizza_id,
           unnest(string_to_array(toppings,','))::INT as topping_id
    FROM pizza_runner.pizza_recipes
    ),
    
recipe_name as (   
    SELECT tp.pizza_id, tp.topping_id, pt.topping_name
    FROM topping tp
    JOIN pizza_runner.pizza_toppings pt ON tp.topping_id=pt.topping_id
    )
    
SELECT pizza_id,
       string_agg(topping_name,', ') as toppings
FROM recipe_name
GROUP BY pizza_id
ORDER BY pizza_id

--2 What was the most commonly added extra?

WITH pizza_extras AS (
    SELECT unnest(string_to_array(extras,','))::INT as extras_id
    FROM pizza_runner.customer_orders_temp
    WHERE extras!=' '
    ),
extras_frequency AS(
    SELECT pt.topping_name as extras, count(*) as number_of_times
    FROM pizza_extras pe 
    JOIN pizza_runner.pizza_toppings pt ON pe.extras_id = pt.topping_id
    GROUP BY pt.topping_name
    )
SELECT extras, number_of_times
FROM extras_frequency
WHERE number_of_times = (SELECT max(number_of_times) FROM extras_frequency)

--3. What was the most common exclusion?

WITH pizza_exclusions AS (
    SELECT unnest(string_to_array(exclusions,','))::INT as exclusions_id
    FROM pizza_runner.customer_orders_temp
    WHERE exclusions!=' '
    ),
exclusions_frequency AS(
    SELECT pt.topping_name as exclusions, count(*) as number_of_times
    FROM pizza_exclusions pe 
    JOIN pizza_runner.pizza_toppings pt ON pe.exclusions_id = pt.topping_id
    GROUP BY pt.topping_name
    )
SELECT exclusions, number_of_times
FROM exclusions_frequency
WHERE number_of_times = (SELECT max(number_of_times) FROM exclusions_frequency);

--4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--     Meat Lovers
--     Meat Lovers - Exclude Beef
--     Meat Lovers - Extra Bacon
--     Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
WITH cte1 AS(
    SELECT row_number() over() as row_num, 
           co.order_id,co.customer_id, co.extras,co.exclusions,pn.pizza_name
    FROM pizza_runner.customer_orders_temp co
    JOIN pizza_runner.pizza_names pn ON co.pizza_id = pn.pizza_id   
    ),
    
pizza_exclusions AS (
    SELECT row_num,
    unnest(string_to_array(exclusions,','))::INT as exclusions_id
    FROM cte1
    WHERE exclusions!=' '
    ),
    
pizza_extras AS (
    SELECT row_num,
    unnest(string_to_array(extras,','))::INT as extras_id
    FROM cte1
    WHERE extras!=' '
    ),

pizza_exclusions_combined AS(
    SELECT pe.row_num,
           string_agg(pt.topping_name,', ') as exclusions_nm
    FROM pizza_exclusions pe JOIN pizza_runner.pizza_toppings pt
    ON pe.exclusions_id = pt.topping_id
    GROUP BY pe.row_num
    ),

pizza_extras_combined AS(
    SELECT pe.row_num,
           string_agg(pt.topping_name,', ') as extras_nm
    FROM pizza_extras pe JOIN pizza_runner.pizza_toppings pt
    ON pe.extras_id = pt.topping_id
    GROUP BY pe.row_num
    )
SELECT *  
FROM cte1 c1
LEFT JOIN pizza_extras_combined ti ON c1.row_num = ti.row_num
LEFT JOIN pizza_exclusions_combined te ON c1.row_num = te.row_num
SELECT c1.order_id, c1.customer_id,
       CASE
           WHEN c1.pizza_name = 'Meatlovers' and extras_nm is not NULL and exclusions_nm is NULL THEN concat('Meat Lovers - Extra ',extras_nm)
           WHEN c1.pizza_name = 'Meatlovers' and exclusions_nm is not NULL and extras_nm is NULL THEN concat('Meat Lovers - Exclude ',exclusions_nm)
           WHEN c1.pizza_name = 'Meatlovers' and exclusions_nm is not NULL and extras_nm is not NULL
           THEN concat('Meat Lovers - Exclude ',exclusions_nm,'- Extra ',extras_nm)
           WHEN c1.pizza_name = 'Meatlovers' and exclusions_nm is NULL and extras_nm is NULL THEN 'Meat Lovers'
           WHEN c1.pizza_name = 'Vegetarian' and extras_nm is not NULL  and exclusions_nm is NULL THEN concat('Vegetarian - Extra ',extras_nm)
           WHEN c1.pizza_name = 'Vegetarian' and exclusions_nm is not NULL and extras_nm is NULL THEN concat('Vegetarian - Exclude ',exclusions_nm)
           WHEN c1.pizza_name = 'Vegetarian' and exclusions_nm is not NULL and extras_nm is not NULL
           THEN concat('Vegetarian - Exclude ',exclusions_nm,'- Extra ',extras_nm)
           ELSE 'Vegetarian'
           END AS order_item
FROM cte1 c1
LEFT JOIN pizza_extras_combined ti ON c1.row_num = ti.row_num
LEFT JOIN pizza_exclusions_combined te ON c1.row_num = te.row_num
ORDER BY c1.order_id, c1.customer_id

--5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--   For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

WITH topping AS (
    SELECT pizza_id,
           unnest(string_to_array(toppings,','))::INT as topping_id
    FROM pizza_runner.pizza_recipes
    ),
    
recipe_name as (   
    SELECT tp.pizza_id, tp.topping_id, pt.topping_name
    FROM topping tp
    JOIN pizza_runner.pizza_toppings pt ON tp.topping_id=pt.topping_id
    ),

pizza_recipes_name AS(  
    SELECT pizza_id,
           string_agg(topping_name,', ') as toppings
    FROM recipe_name
    GROUP BY pizza_id
    ORDER BY pizza_id
),

cte1 AS(
    SELECT row_number() over() as row_num, 
           co.order_id,co.customer_id,co.pizza_id, co.extras,co.exclusions,pn.pizza_name
    FROM pizza_runner.customer_orders_temp co
    JOIN pizza_runner.pizza_names pn ON co.pizza_id = pn.pizza_id   
    ),
    
pizza_exclusions AS (
    SELECT row_num,
    unnest(string_to_array(exclusions,','))::INT as exclusions_id
    FROM cte1
    WHERE exclusions!=' '
    ),
    
pizza_extras AS (
    SELECT row_num,
    unnest(string_to_array(extras,','))::INT as extras_id
    FROM cte1
    WHERE extras!=' '
    ),

pizza_exclusions_combined AS(
    SELECT pe.row_num,
           string_agg(pt.topping_name,', ') as exclusions_nm
    FROM pizza_exclusions pe JOIN pizza_runner.pizza_toppings pt
    ON pe.exclusions_id = pt.topping_id
    GROUP BY pe.row_num
    ),

pizza_extras_combined AS(
    SELECT pe.row_num,
           string_agg(pt.topping_name,', ') as extras_nm
    FROM pizza_extras pe JOIN pizza_runner.pizza_toppings pt
    ON pe.extras_id = pt.topping_id
    GROUP BY pe.row_num
    ),
    
ingredient_list AS(
    SELECT c1.row_num,c1.order_id,c1.customer_id,c1.pizza_id,
    CASE
        WHEN extras_nm is null and exclusions_nm is null THEN toppings
        WHEN extras_nm is not null and exclusions_nm is null THEN concat(toppings,', ',extras_nm)
        WHEN extras_nm is null and exclusions_nm is not null THEN concat(toppings,', ',exclusions_nm)
        WHEN extras_nm is not null and exclusions_nm is not null THEN concat(toppings,', ',extras_nm,', ',exclusions_nm)
        END as order_item 
    FROM cte1 c1
    JOIN pizza_recipes_name rn ON c1.pizza_id = rn.pizza_id
    LEFT JOIN pizza_extras_combined ti ON c1.row_num = ti.row_num
    LEFT JOIN pizza_exclusions_combined te ON c1.row_num = te.row_num
    ),
    
ingredient_count AS(
    SELECT x.row_num, x.ingredient,
    COUNT(*) as ingredient_count
    FROM (SELECT row_num, unnest(string_to_array(order_item,', ')) as ingredient FROM ingredient_list ) x
    GROUP BY x.row_num, x.ingredient
    
    ),

ingredient_vol_combined AS(
    SELECT *,
           CASE
               WHEN ingredient_count > 1 THEN concat(ingredient_count,'x',ingredient)
               ELSE ingredient 
               END AS ingredient_vol
    FROM ingredient_count
    order by 1,4
    )

SELECT c1.order_id, c1.customer_id,
       CASE
           WHEN c1.pizza_name = 'Meatlovers' THEN concat('Meat Lovers: ',x.order_ingredient_details)
           ELSE concat('Vegetarian: ',x.order_ingredient_details)
           END AS order_ingredient_list
FROM           
(
    SELECT row_num,
           string_agg(ingredient_vol,', ') as order_ingredient_details
    FROM ingredient_vol_combined
    GROUP BY row_num
    ) x 
JOIN cte1 c1 ON c1.row_num = x.row_num
ORDER BY c1.order_id, c1.customer_id

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

WITH topping AS (
    SELECT pizza_id,
           unnest(string_to_array(toppings,','))::INT as topping_id
    FROM pizza_runner.pizza_recipes
    ),
    
recipe_name as (   
    SELECT tp.pizza_id, tp.topping_id, pt.topping_name
    FROM topping tp
    JOIN pizza_runner.pizza_toppings pt ON tp.topping_id=pt.topping_id
    ),

pizza_recipes_name AS(  
    SELECT pizza_id,
           string_agg(topping_name,', ') as toppings
    FROM recipe_name
    GROUP BY pizza_id
    ORDER BY pizza_id
),

cte1 AS(
    SELECT row_number() over() as row_num, 
           co.order_id,co.customer_id,co.pizza_id, co.extras,co.exclusions,pn.pizza_name
    FROM pizza_runner.customer_orders_temp co
    JOIN pizza_runner.pizza_names pn ON co.pizza_id = pn.pizza_id   
    ),
    
pizza_exclusions AS (
    SELECT row_num,
    unnest(string_to_array(exclusions,','))::INT as exclusions_id
    FROM cte1
    WHERE exclusions!=' '
    ),
    
pizza_extras AS (
    SELECT row_num,
    unnest(string_to_array(extras,','))::INT as extras_id
    FROM cte1
    WHERE extras!=' '
    ),

pizza_exclusions_combined AS(
    SELECT pe.row_num,
           string_agg(pt.topping_name,', ') as exclusions_nm
    FROM pizza_exclusions pe JOIN pizza_runner.pizza_toppings pt
    ON pe.exclusions_id = pt.topping_id
    GROUP BY pe.row_num
    ),

pizza_extras_combined AS(
    SELECT pe.row_num,
           string_agg(pt.topping_name,', ') as extras_nm
    FROM pizza_extras pe JOIN pizza_runner.pizza_toppings pt
    ON pe.extras_id = pt.topping_id
    GROUP BY pe.row_num
    ),
    
ingredient_list AS(
    SELECT c1.row_num,c1.order_id,c1.customer_id,c1.pizza_id,
    CASE
        WHEN extras_nm is null and exclusions_nm is null THEN toppings
        WHEN extras_nm is not null and exclusions_nm is null THEN concat(toppings,', ',extras_nm)
        WHEN extras_nm is null and exclusions_nm is not null THEN concat(toppings,', ',exclusions_nm)
        WHEN extras_nm is not null and exclusions_nm is not null THEN concat(toppings,', ',extras_nm,', ',exclusions_nm)
        END as order_item 
    FROM cte1 c1
    JOIN pizza_recipes_name rn ON c1.pizza_id = rn.pizza_id
    LEFT JOIN pizza_extras_combined ti ON c1.row_num = ti.row_num
    LEFT JOIN pizza_exclusions_combined te ON c1.row_num = te.row_num
    ),
    
ingredient_count AS(
    SELECT x.row_num, x.ingredient,
    COUNT(*) as ingredient_count
    FROM (SELECT row_num, unnest(string_to_array(order_item,', ')) as ingredient FROM ingredient_list ) x
    GROUP BY x.row_num, x.ingredient
    )

SELECT ic.ingredient, sum(ic.ingredient_count) as total_quantity 
FROM ingredient_count ic
JOIN cte1 c1 ON c1.row_num = ic.row_num
JOIN pizza_runner.runner_orders_temp ro ON ro.order_id = c1.order_id
WHERE ro.distance is not null
GROUP BY ic.ingredient
ORDER BY sum(ic.ingredient_count) DESC ,ic.ingredient 









