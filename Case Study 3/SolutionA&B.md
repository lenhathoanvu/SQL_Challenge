# <p align = "center"> Solution 

## A. Customer Journey

Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey. Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

```sql
select s.customer_id, p.plan_name, s.start_date, p.price 
from dbo.plans p
join dbo.subscriptions s
on p.plan_id = s.plan_id
where customer_id in (3, 4, 6, 13, 18, 25, 28, 33)
order by customer_id
```
### Solution

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/412be348-c9ef-4dd0-825a-49c61edf7d08)

## B. Data Analysis Questions
### 1. How many customers has Foodie-Fi ever had?

```sql
select count(distinct customer_id) as customers_count
from dbo.subscriptions
```

#### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/fbf26acc-b47d-451f-925c-c7c3690ff853)

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

```sql
select datepart(month, start_date) as Months,
count(customer_id) as trial
from dbo.subscriptions
where plan_id = 0
group by datepart(month, start_date)
order by datepart(month, start_date)
```

#### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/c2ad30c3-2f52-430d-b3dc-94885b769b62)

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

```sql
select p.plan_name,
count(*) count_events
from dbo.subscriptions s
join dbo.plans p
on s.plan_id = p.plan_id
where datepart(year, start_date) > 2020
group by p.plan_name
```

#### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/319760f7-dcb7-4362-af1c-336e04451ade)

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```sql
select count(*) as customer_count,
Round(Cast(count(*) as float) / (select count(distinct customer_id) from dbo.subscriptions)*100, 1) as churn_percent
from dbo.subscriptions
where plan_id = 4
```

#### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/0bee9226-49fc-401b-a0bf-35325fd94ea4)

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

```sql
with churn_cte as 
	(select *, 
	lag(plan_id) over(partition by customer_id order by plan_id) as previous_plan
	from dbo.subscriptions)		

select count(*) as churn_count,
round(count(*) * 100/ (select count(distinct customer_id) from dbo.subscriptions), 1) as free_2churn_percent 
from churn_cte
where plan_id = 4 and previous_plan = 0
```

#### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/e6f9f8e5-e294-4313-8e46-8eef8b277906)

### 6. What is the number and percentage of customer plans after their initial free trial?

```sql
with next_plan_cte as (
	select *, lead(plan_id) over(partition by customer_id order by plan_id) as next_plan
	from dbo.subscriptions
),
planning as (
	select c.next_plan,
	count(distinct customer_id) as customer_count,
	round(100 * cast(count(distinct customer_id) as float)/(select count(distinct customer_id) from subscriptions), 1) as percentage
	from next_plan_cte c
	join plans p
	on c.plan_id = p.plan_id
	where c.plan_id = 0 and c.next_plan is not Null
	group by c.next_plan
)

select p.plan_name, s.customer_count, s.percentage 
from planning s
join plans p
on s.next_plan = p.plan_id
```

#### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/8f4f6552-1494-46f4-978c-f91cfe1ad9f0)

### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```sql
with next_date_cte as (
	select *,
	lead(start_date,1) over(partition by customer_id order by plan_id) as next_date
	from dbo.subscriptions
	where start_date <= '2020-12-31'
),

plan_breakdown as (
	select plan_id,
	cast(count(distinct customer_id) as float) total,
	cast((select count(distinct customer_id) from subscriptions) as float) all_total
	from next_date_cte c
	where next_date is Null
	Group by plan_id
)

select p.plan_name, 
pb.total,
round(total * 100 / all_total, 1) percentage
from plan_breakdown pb
join plans p
on p.plan_id = pb.plan_id
```

#### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/dbca2d7c-60de-4da9-bfcf-2707f2ec270a)

### 8. How many customers have upgraded to an annual plan in 2020?

```sql
select count(distinct customer_id) as annual_upgrade_customer
from dbo.subscriptions
where plan_id = 3 and datepart(year, start_date) = 2020
```

#### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/35b61f6d-aa90-47e6-82e7-3336e0ad9641)

### 9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?

```sql
with trial_plan as (
	select customer_id,
	start_date as trial_day
	from dbo.subscriptions
	where plan_id = 0
),

annual_plan as (
	select customer_id,
	start_date as annual_day
	from dbo.subscriptions
	where plan_id = 3
)

select round(avg(abs(datediff(day, trial_day, annual_day))),0) as avg_days_2upgrade
from trial_plan tp
join annual_plan ap
on tp.customer_id = ap.customer_id
```
#### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/34df1228-3e07-4447-9946-68f91ae40c14)

### 10. Can you further break down this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

```sql
with trial_plan as (
	select customer_id,
	start_date as trial_day
	from dbo.subscriptions
	where plan_id = 0
),

annual_plan as (
	select customer_id,
	start_date as annual_day
	from dbo.subscriptions
	where plan_id = 3
)
select concat(floor(datediff(day, trial_day, annual_day)/30)*30,'-',floor(datediff(day, trial_day, annual_day)/30)*30+30, 'days') as period,
count(*) as total_customers,
round(avg(datediff(day, trial_day, annual_day)),0) as avg_days_2upgrade
from trial_plan tp 
join annual_plan ap
on tp.customer_id = ap.customer_id
group by floor(datediff(day, trial_day, annual_day)/30)
```

#### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/18fcbdf8-e025-4674-901f-d59e389a49b8)

### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
with next_plan_cte as(
	select *,
	lead(plan_id) over(partition by customer_id order by plan_id) as next_plan
	from dbo.subscriptions
)

select count(*) as downgraded
from next_plan_cte
where datepart(year, start_date) = 2020
and  plan_id = 2 and next_plan = 1
```

#### Result

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/d0681f78-34a4-482a-8f49-6372fa512b82)
