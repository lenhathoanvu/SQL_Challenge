# Solution
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
