# <p align="center" style="margin-top: 0px;"> SOLUTION 
## 1. What is the total amount each customer spent at the restaurant?

```sql
select s.customer_id, sum(m.price) as total_sales
from dbo.sales s join dbo.menu m
on s.product_id = m.product_id
group by s.customer_id
```
### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/a4a5c1e3-1f50-4ad2-b691-698cec9e9c74)

## 2. How many days has each customer visited the restaurant?

```sql
select customer_id, count(distinct(order_date)) as days_visit
from dbo.sales 
group by customer_id
```
### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/2a16d441-dbff-4f1a-a8cb-77d8ec565629)

## 3. What was the first item from the menu purchased by each customer?

```sql
select customer_id, product_name
from (
select s.customer_id, s.order_date, m.product_name,
		DENSE_RANK() over( partition by s.customer_id order by s.order_date asc) as Rank 
from dbo.sales s join dbo.menu m
on s.product_id = m.product_id
) as T1
where Rank = 1
```

### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/5166d90d-07c8-41da-bdeb-278644b907d3)

## 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
select top 1 m.product_name, count(s.product_id) as most_purchased
from dbo.sales s join dbo.menu m
on s.product_id = m.product_id
group by m.product_name
order by most_purchased desc
```
### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/f0716849-9c46-4d46-acc9-44c5702757e5)

## 5. Which item was the most popular for each customer?

```sql
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
```

### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/630f7920-4765-48d9-a69a-f0aef6427f3e)

## 6. Which item was purchased first by the customer after they became a member?

```sql
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
```
## Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/6621c0c4-8dbd-4450-8484-2128d1302051)

## 7. Which item was purchased just before the customer became a member?

```sql
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
```

### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/7a464232-fd5d-4a5f-98a0-74f1515ac8ea)

## 8. What is the total items and amount spent for each member before they became a member? 

```sql
select s.customer_id, count(s.product_id) as total_items, sum(m.price) as total_amount
from dbo.sales s join dbo.members me
on s.customer_id = me.customer_id
join dbo.menu m
on s.product_id = m.product_id
where me.join_date > s.order_date
group by s.customer_id;
```

### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/24d8fcf3-8941-4d09-bb39-31f3c6a71133)

## 9. If each $1 spent equates to 10 points and sushi has a x2 points multiplier — how many points would each customer have?

```sql
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
```

### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/5b21f0f8-f4f5-41fa-a2c3-e882bdcb78c7)

## 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi. how many points do customer A and B have at the end of January?

```sql
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
```

### Result 

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/67b3949c-f627-49fa-8e5a-c2f07de3bc73)

## Join All The Things

```sql
Select s.customer_id, s.order_date, m.product_name, m.price,
case when me.join_date > s.order_date then 'N'
	when me.join_date <= s.order_date THEN 'Y'
	else 'N' end as member
from dbo.sales s left join dbo.members me
on s.customer_id = me.customer_id
inner join dbo.menu m
on s.product_id = m.product_id
```

### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/5e720cc2-19ec-4a26-b0da-d445115217ad)

## Rank All The Things

```sql
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
```

### Result 

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/0740363f-462e-4f10-bc69-ebae8cbbe71e)
