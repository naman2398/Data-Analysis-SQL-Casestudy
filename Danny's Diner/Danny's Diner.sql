-- 1. What is the total amount each customer spent at the restaurant? 
SELECT s.customer_id , SUM(m.price) as amount_spent FROM
dannys_diner.sales s join dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
order by 2 DESC;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, count(DISTINCT order_date) as days_visited
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY 2 DESC;

-- 3. What was the first item from the menu purchased by each customer?
with min_order_date as (
	SELECT s.*,m.*,
    min(s.order_date) over (PARTITION BY s.customer_id) as first_order_date
    FROM dannys_diner.sales s join dannys_diner.menu m
	on s.product_id = m.product_id
  )
SELECT distinct customer_id, product_name
FROM min_order_date as o
where order_date = first_order_date;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
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

-- 5. Which item was the most popular for each customer?
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

-- 6. Which item was purchased first by the customer after they became a member?
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


-- 7. Which item was purchased just before the customer became a member?
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


-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, count(DISTINCT me.product_name),sum(me.price)
FROM dannys_diner.members m
JOIN dannys_diner.sales s on m.customer_id = s.customer_id
JOIN dannys_diner.menu me on me.product_id = s.product_id
WHERE m.join_date > s.order_date
GROUP BY s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id,
sum(CASE
	WHEN m.product_name = 'sushi' then 20*m.price else 10*m.price
    end) as total_points
FROM
dannys_diner.sales s join dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY 2 DESC;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
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

-- BONUS QUESTION

--1. Join All The Things
--   Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
SELECT s.customer_id,s.order_date,me.product_name,me.price,
CASE 
	WHEN m.join_date > s.order_date or m.join_date is null then 'N' else 'Y'
    end as member
FROM dannys_diner.members m
RIGHT JOIN dannys_diner.sales s on m.customer_id = s.customer_id
JOIN dannys_diner.menu me on me.product_id = s.product_id
ORDER BY 1,5;

--2. Rank All The Things
--  Recreate the table with: customer_id, order_date, product_name, price, member (Y/N), ranking(null/123)
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



  
