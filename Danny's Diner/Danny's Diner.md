# :ramen: :curry: :sushi: Case Study #1: Danny's Diner

###  1. What is the total amount each customer spent at the restaurant?

```sql
SELECT s.customer_id , SUM(m.price) as amount_spent FROM
dannys_diner.sales s join dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
order by 2 DESC;
``` 
	
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/DD1.PNG)

***

###  2. How many days has each customer visited the restaurant?

```sql
SELECT customer_id, count(DISTINCT order_date) as days_visited
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY 2 DESC;
``` 
	
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/DD2.PNG)

***

###  3. What was the first item from the menu purchased by each customer?

```sql
WITH min_order_date as (
	SELECT s.*,m.*,
    min(s.order_date) over (PARTITION BY s.customer_id) as first_order_date
    FROM dannys_diner.sales s join dannys_diner.menu m
	on s.product_id = m.product_id
  )
SELECT distinct customer_id, product_name
FROM min_order_date as o
where order_date = first_order_date;
``` 
		
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/DD3.PNG)

***

###  4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
with count_orders as (
  SELECT m.product_name, count(*) as order_count 
  FROM dannys_diner.sales s join dannys_diner.menu m
  on s.product_id = m.product_id 
  GROUP BY m.product_name
  ORDER BY 2 DESC
  ) 
SELECT co.product_name, co.order_count
FROM count_orders co
WHERE co.order_count = (select max(order_count) from count_orders);
``` 
	
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/DD4.PNG)

***

###  5. Which item was the most popular for each customer?

```sql
with count_orders as (
  SELECT s.customer_id,m.product_name, count(*) as order_count 
  FROM dannys_diner.sales s join dannys_diner.menu m
  on s.product_id = m.product_id 
  GROUP BY s.customer_id,m.product_name
  ORDER BY 1,3 DESC
  ), 
max_product_count_per_customer as (
	SELECT co.*,
  	max(co.order_count) OVER (PARTITION BY co.customer_id) as max_count
  	FROM count_orders co
	)
SELECT mc.customer_id, mc.product_name,mc.order_count
FROM max_product_count_per_customer mc
WHERE mc.order_count = mc.max_count;
``` 
	
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/DD5.PNG)

***

###  6. Which item was purchased first by the customer after they became a member?

```sql
with order_after_member as (
  SELECT s.customer_id, s.order_date, me.product_name,
  min(s.order_date) OVER (PARTITION BY s.customer_id) as first_order_date 
  FROM dannys_diner.members m
  LEFT JOIN dannys_diner.sales s on m.customer_id = s.customer_id
  JOIN dannys_diner.menu me on me.product_id = s.product_id
  where m.join_date <= s.order_date
  )

SELECT om.customer_id,om.order_date,om.product_name
FROM order_after_member om
WHERE om.order_date = om.first_order_date;
``` 
	
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/DD6.PNG)

***

###  7. Which item was purchased just before the customer became a member?

```sql
with order_before_member as (
  SELECT s.customer_id, s.order_date, me.product_name,
  max(s.order_date) OVER (PARTITION BY s.customer_id) as last_order_date 
  FROM dannys_diner.members m
  LEFT JOIN dannys_diner.sales s on m.customer_id = s.customer_id
  JOIN dannys_diner.menu me on me.product_id = s.product_id
  where m.join_date > s.order_date
  )

SELECT om.customer_id,om.order_date,om.product_name
FROM order_before_member om
WHERE om.order_date = om.last_order_date;
``` 
	
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/DD7.PNG)

***

###  8. What is the total items and amount spent for each member before they became a member?

```sql
SELECT s.customer_id, count(DISTINCT me.product_name),sum(me.price)
FROM dannys_diner.members m
JOIN dannys_diner.sales s on m.customer_id = s.customer_id
JOIN dannys_diner.menu me on me.product_id = s.product_id
WHERE m.join_date > s.order_date
GROUP BY s.customer_id;
``` 
	
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/DD8.PNG)

***

###  9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

#### Had the customer joined the loyalty program before making the purchases, total points that each customer would have accrued
```sql
SELECT s.customer_id,
	sum(CASE
		WHEN m.product_name = 'sushi' then 20*m.price else 10*m.price
	    end) as total_points
FROM
dannys_diner.sales s join dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY 2 DESC;
``` 
	
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/DD9.PNG)

***

###  10. In the first week after a customer joins the program (including their join date)            they earn 2x points on all items, not just sushi - how many points do customer A            and B have at the end of January

```sql
SELECT s.customer_id,
SUM(CASE
   WHEN s.order_date BETWEEN m.join_date and (m.join_date + 6) then 20*me.price    WHEN me.product_name = 'sushi' then 20*me.price 
   else 10*me.price end) as total_points
FROM dannys_diner.members m
JOIN dannys_diner.sales s on m.customer_id = s.customer_id
JOIN dannys_diner.menu me on me.product_id = s.product_id
WHERE s.order_date <= TO_DATE('2021-01-31','YYYY-MM-DD')
GROUP BY s.customer_id
ORDER BY 2 DESC;
``` 

#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/DD10.PNG)

***

###  Bonus Questions

#### 1. Join All The Things
Create basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL. Fill Member column as 'N' if the purchase was made before becoming a member and 'Y' if the after is amde after joining the membership.

```sql
SELECT s.customer_id,s.order_date,me.product_name,me.price,
CASE 
	WHEN m.join_date > s.order_date or m.join_date is null then 'N' else 'Y'
    end as member
FROM dannys_diner.members m
RIGHT JOIN dannys_diner.sales s on m.customer_id = s.customer_id
JOIN dannys_diner.menu me on me.product_id = s.product_id
ORDER BY 1,5;
``` 
	
#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/DDB1.PNG)

***

#### 2. Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

```sql
with member_cte as (
  SELECT s.customer_id,s.order_date,me.product_name,me.price,
  CASE 
      WHEN m.join_date > s.order_date or m.join_date is null then 'N' else 'Y'
      end as member
  FROM dannys_diner.members m
  RIGHT JOIN dannys_diner.sales s on m.customer_id = s.customer_id
  JOIN dannys_diner.menu me on me.product_id = s.product_id
  )

SELECT mc.*,
CASE
	WHEN member = 'Y' then 
    dense_rank() over (PARTITION BY customer_id,member ORDER BY order_date)
    ELSE null end as ranking
FROM member_cte mc
ORDER BY 1;
```

#### Result set:
![image](https://github.com/naman2398/SQL-Casestudy/blob/main/Result/DDB2.PNG)

***


