-- A. Pizza Metrics 
-- 1. How many pizzas were ordered?
Select Count(*) as TotalPizzaOrdered
From customer_orders1

-- 2. How many unique customer orders were made?
Select Count(distinct order_id) as TotalOrdered
From customer_orders1

-- 3. How many successful orders were delivered by each runner?
Select runner_id, Count(order_id) as TotalDelivered 
From runner_orders1
Where cancellation is Null
Group by runner_id

-- 4. How many of each type of pizza was delivered?
Select Cast(p.pizza_name as Nvarchar) AS pizza_name, 
	Count(c.pizza_id) as TotalDelivered
From pizza_names p
Inner Join customer_orders1 c
    on p.pizza_id = c.pizza_id
Inner Join runner_orders1 r
    on c.order_id = r.order_id
Where r.cancellation is Null
Group by Cast(p.pizza_name as Nvarchar)

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
Select c.customer_id,
	Cast(p.pizza_name as Nvarchar) AS pizza_name, 
	Count(c.order_id)
From pizza_names p
Inner Join customer_orders1 c
	on p.pizza_id = c.pizza_id
Group by c.customer_id,
	Cast(p.pizza_name as Nvarchar)
Order by c.customer_id

-- 6. What was the maximum number of pizzas delivered in a single order?
Select Top(1) r.order_id, count(c.order_id) as TotalDelivered
From customer_orders1 c
Join pizza_names p
	on p.pizza_id = c.pizza_id
Join runner_orders r
	on r.order_id = c.order_id
Where r.cancellation is Null
Group by r.order_id
Order by count(c.order_id) Desc

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
With status_cte as
(
	Select *, 
	Case
		When exclusions is Null or  extras is Null then 'Not Change'
		Else 'Change'
		end as status 
	From customer_orders1
)

Select s.customer_id, status, count(status) as count 
From status_cte s
Join runner_orders1 r 
	on s.order_id = r.order_id
Where r.cancellation is Null 
Group by s.customer_id, status
Order by s.customer_id

-- 8. How many pizzas were delivered that had both exclusions and extras?
Select count(c.pizza_id) as Pizza_Delivered_exclusions_extras 
From customer_orders1 c
Join runner_orders1 r
	on c.order_id = r.order_id
Where r.cancellation is Null
	and c.exclusions is not Null
	and c.extras is not Null

-- 9. What was the total volume of pizzas ordered for each hour of the day?
Select Datepart(hour, order_time) as hour, 
	Count(*) as PizzaOrdered 
From customer_orders1
Group by Datepart(hour, order_time)

-- 10. What was the volume of orders for each day of the week?
Select Datename(Weekday, order_time) as weekday,
	Count(*) as Volume 
From customer_orders1
Group by Datename(Weekday, order_time)

-----------------------------------------------------------------------------------------------------------------

-- B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
Set Datefirst 1
Select Datepart(Week, registration_date) as week, 
	Count(runner_id) as sign_up
From runners
Group by Datepart(Week, registration_date)

--  2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
Select r.runner_id,
	Round(Avg(Cast(Datediff(minute, order_time, pickup_time)as Float)),2) as time 
From customer_orders1 c
Inner Join runner_orders1 r
	on c.order_id = r.order_id
Where r.cancellation is Null 
Group by r.runner_id

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
With cte as 
(
	Select c.order_id,
	Count(c.order_id) as num_pizza,
	c.order_time, r.pickup_time,
	Cast(Datediff(minute, c.order_time, r.pickup_time)as Float) as time 
	From customer_orders1 c
	Inner Join runner_orders1 r
		on c.order_id = r.order_id
	Where r.cancellation is Null 
	Group by c.order_id, c.order_time, r.pickup_time 
)

Select num_pizza,
	Round(Avg(time),2) as avg_time,
	(Avg(time)/num_pizza) as avg_time_per_pizza
From cte
group by num_pizza

-- 4. What was the average distance travelled for each customer?
Select c.customer_id, 
	Round(Avg(r.distance),2) as avg_distance
From customer_orders1 c
Inner Join runner_orders1 r
	on c.order_id = r.order_id
Group by c.customer_id

-- 5. What was the difference between the longest and shortest delivery times for all orders?
Select max(r.durations) - min(r.durations) as dif_longest_shortest 
From customer_orders1 c
Inner Join runner_orders1 r
	on c.order_id = r.order_id

-- 6. What was the average speed for each runner for each delivery ?
Select r.runner_id,
	Round(Avg(distance*60/durations),2) as avg_speed 
From customer_orders1 c
Inner Join runner_orders1 r
	on c.order_id = r.order_id
Where r.cancellation is Null
Group by r.runner_id

-- 7. What is the successful delivery percentage for each runner?
Select r.runner_id,
	Sum(
		Case
			When r.cancellation is Null 
			Then 1
			Else 0
		End)*100/Count(c.order_id) as delivered_percentage  
From customer_orders1 c
Join runner_orders1 r
	on c.order_id = r.order_id
Group by r.runner_id

-----------------------------------------------------------------------------------------------------------------

-- C. Ingredient Optimisation
-- 1. What are the standard ingredients for each pizza?
Select * 
From pizza_recipes

Select * 
From pizza_toppings

-- Normalize Pizza Recipe
