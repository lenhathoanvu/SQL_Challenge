-- ======================--CASE STUDY QUESTIONS--===============================

select * from dbo.members
select * from dbo.menu
select * from dbo.sales

-- 1. What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(m.price) as total_sales
from dbo.sales s join dbo.menu m
on s.product_id = m.product_id
group by s.customer_id

-- 2. How many days has each customer visited the restaurant?
select customer_id, count(distinct(order_date)) as days_visit
from dbo.sales 
group by customer_id

-- 3. What was the first item from the menu purchased by each customer?
select customer_id, product_name
from (
select s.customer_id, s.order_date, m.product_name,
		DENSE_RANK() over( partition by s.customer_id order by s.order_date asc) as Rank 
from dbo.sales s join dbo.menu m
on s.product_id = m.product_id
) as T1
where Rank = 1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1 m.product_name, count(s.product_id) as most_purchased
from dbo.sales s join dbo.menu m
on s.product_id = m.product_id
group by m.product_name
order by most_purchased desc

-- 5. Which item was the most popular for each customer?
select customer_id, product_name
from
(
select s.customer_id, m.product_name, count(m.product_id) order_count,
		DENSE_RANK() over(partition by s.customer_id order by count(m.product_id) desc) as Rank
from dbo.sales s join dbo.menu m
on s.product_id = m.product_id
group by s.customer_id, m.product_name
) as T1
where Rank = 1 

-- 6. Which item was purchased first by the customer after they became a member?
Select customer_id, order_date, product_name
from
(
select s.customer_id, s.order_date, s.product_id, m.product_name,
		DENSE_RANK() over(partition by s.customer_id order by s.order_date) as Rank
from dbo.sales s join dbo.members me
on s.customer_id = me.customer_id
join dbo.menu m
on s.product_id = m.product_id
where me.join_date < s.order_date
) as T1
Where Rank = 1

-- 7. Which item was purchased just before the customer became a member?
Select customer_id, order_date, product_name
from
(
select s.customer_id, s.order_date, s.product_id, m.product_name,
		DENSE_RANK() over(partition by s.customer_id order by s.order_date desc) as Rank
from dbo.sales s join dbo.members me
on s.customer_id = me.customer_id
join dbo.menu m
on s.product_id = m.product_id
where me.join_date > s.order_date
) as T1
Where Rank = 1

-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id, count(s.product_id) as total_items, sum(m.price) as total_amount
from dbo.sales s join dbo.members me
on s.customer_id = me.customer_id
join dbo.menu m
on s.product_id = m.product_id
where me.join_date > s.order_date
group by s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a x2 points multiplier — how many points would each customer have?
With Points_cte as (
select *, case when product_id = 1 then price * 10 * 2
		else price * 10 
		end as Points
from menu
)
Select s.customer_id, sum(p.Points) as total_points
from Points_cte p join dbo.sales s
on p.product_id = s.product_id
group by s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?
select s.customer_id,
sum(
	case 
		when s.order_date between me.join_date and dateadd(day, 6, me.join_date)
		then price*10*2
		when product_name = 'sushi' then price*10*2
		else price*10
	end
) as point
from dbo.sales s 
join dbo.members me
on s.customer_id = me.customer_id
join dbo.menu m
on s.product_id = m.product_id
where datetrunc(month, s.order_date) = '2021-01-01'
group by s.customer_id

-- Join All The Things 
Select s.customer_id, s.order_date, m.product_name, m.price,
case when me.join_date > s.order_date then 'N'
	when me.join_date <= s.order_date THEN 'Y'
	else 'N' end as member
from dbo.sales s left join dbo.members me
on s.customer_id = me.customer_id
inner join dbo.menu m
on s.product_id = m.product_id

-- Rank All The Things
with CTE as (
	select s.customer_id, s.order_date, product_name, price,
	case 
		when join_date is NULL then 'N'
		when join_date > order_date then 'N'
		else 'Y'
	end as members 
	from dbo.sales s
	inner join menu as m 
	on s.product_id = m.product_id
	left join dbo.members me
	on s.customer_id = me.customer_id
)

select *, 
	case
		When members = 'N' then NULL
		else rank() over(partition by customer_id, members order by order_date)
	end as ranking
from CTE
order by customer_id, order_date, price DESC 
