--1. How many customers has Foodie-Fi ever had?

SELECT 
    COUNT(DISTINCT(customer_id)) AS customer_count
FROM foodie_fi.subscriptions;

--2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value?

SELECT 
    month, COUNT(month) as monthly_distribution
FROM (
    SELECT 
        EXTRACT(MONTH FROM start_date) AS month
    FROM foodie_fi.subscriptions s JOIN foodie_fi.plans p
    ON p.plan_id = s.plan_id
    WHERE p.plan_id=0
)x
GROUP BY month
ORDER BY month;

--3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name?

SELECT 
    p.plan_id, p.plan_name,
    COUNT(p.plan_id) AS events_count
FROM foodie_fi.subscriptions s JOIN foodie_fi.plans p
ON p.plan_id = s.plan_id
WHERE s.start_date > '2020-12-31'
GROUP BY p.plan_id, p.plan_name
ORDER BY p.plan_id;

--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT 
    COUNT(DISTINCT customer_id) AS customer_churned_count,
    ROUND(100.0*COUNT(DISTINCT customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions),1) AS churned_percentage
FROM foodie_fi.subscriptions
WHERE plan_id = 4;

--5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

WITH next_pln AS(
    SELECT *,
        LEAD(plan_id,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan
    FROM foodie_fi.subscriptions
    )
SELECT 
    COUNT(DISTINCT customer_id) AS customer_churned_count,
    ROUND(100.0*COUNT(DISTINCT customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions),1) AS churned_percentage
    FROM next_pln 
    WHERE plan_id = 0 and next_plan = 4
    
--6. What is the number and percentage of customer plans after their initial free trial?

WITH previous_pln AS(
    SELECT *,
        LAG(plan_id,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS previous_plan
    FROM foodie_fi.subscriptions
    )

SELECT 
    p.plan_name, COUNT(p.plan_name),
    ROUND(100.0*COUNT(p.plan_name) / (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions),1) AS customer_plan_percentage
FROM previous_pln pp JOIN foodie_fi.plans p 
ON pp.plan_id = p.plan_id
WHERE pp.previous_plan = 0
GROUP BY p.plan_name;

--7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH latest_pln AS(
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY start_date DESC) AS latest_plan
    FROM foodie_fi.subscriptions
    WHERE start_date <= '2020-12-31'
    )

SELECT 
    p.plan_name,
    COUNT(DISTINCT lp.customer_id) AS customer_count,
    ROUND(100.0*COUNT(DISTINCT lp.customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions),1) AS customer_percentage
FROM latest_pln lp JOIN foodie_fi.plans p
ON lp.plan_id = p.plan_id
WHERE lp.latest_plan = 1
GROUP BY  p.plan_name;

--8. How many customers have upgraded to an annual plan in 2020?

SELECT 
    COUNT(DISTINCT x.customer_id) AS customers_upgraded_to_annual_plan
FROM (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.start_date) as rnk
    FROM foodie_fi.subscriptions s JOIN foodie_fi.plans p
    ON s.plan_id = p.plan_id
    WHERE s.start_date BETWEEN '2020-01-01' AND '2020-12-31'
   )x
WHERE x.plan_name = 'pro annual' and x.rnk>1;

--9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH day_joined AS(
    SELECT *,
            MIN(start_date) OVER (PARTITION BY s.customer_id) as day_joined_foodiefi
    FROM foodie_fi.subscriptions s JOIN foodie_fi.plans p
    ON s.plan_id = p.plan_id
    )
    
SELECT 
    ROUND(AVG(start_date-day_joined_foodiefi),2) AS average_conversion_time
FROM day_joined
WHERE plan_name = 'pro annual';

--10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)?

WITH day_joined AS(
    SELECT *,
            MIN(start_date) OVER (PARTITION BY s.customer_id) as day_joined_foodiefi
    FROM foodie_fi.subscriptions s JOIN foodie_fi.plans p
    ON s.plan_id = p.plan_id
    ),

window_30 AS(    
    SELECT 
        (start_date - day_joined_foodiefi) AS days_conversion,
        ROUND((start_date - day_joined_foodiefi)/30) AS window_30days
    FROM day_joined
    WHERE plan_name = 'pro annual'
   )

SELECT 
    window_30days, COUNT(*) AS conversion_days_count
FROM window_30
GROUP BY window_30days
ORDER BY window_30days;

--11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH next_plan_cte AS(
    SELECT *,
            LEAD(p.plan_name,1) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) as nxt_plan
    FROM foodie_fi.subscriptions s JOIN foodie_fi.plans p
    ON s.plan_id = p.plan_id
    WHERE p.plan_name IN ('pro monthly','basic monthly')
    )
    
SELECT 
    COUNT(DISTINCT customer_id) AS downgraded_customer_count
FROM next_plan_cte
WHERE nxt_plan = 'basic monthly';



















