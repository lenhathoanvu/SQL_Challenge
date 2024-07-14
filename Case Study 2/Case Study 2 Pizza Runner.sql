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
-- Preparing data for this part 
-- Cleaning pizza_recipes 
Alter table pizza_toppings
Alter column topping_name NVARCHAR(max)

Alter table pizza_names
Alter column pizza_name NVARCHAR(max)

Drop table if exists pizza_recipes1
Select pr.pizza_id, 
    Ltrim(Rtrim(topping_id.value)) as topping_id,
    pt.topping_name
Into pizza_recipes1  
From pizza_recipes pr
Cross Apply 
    string_split(Cast(pr.toppings as nvarchar(max)), ',') as topping_id
INNER JOIN pizza_toppings pt 
    on Ltrim(Rtrim(topping_id.value)) = pt.topping_id;

Select * 
From pizza_recipes1

-- Cleaning customer_orders
Alter table customer_orders1
Add record_id int Identity(1,1)

Select * 
From customer_orders1

-- Add new tables Exclusions and Extras 
-- New Exclusions table
Drop table if exists exclusions
Select c.record_id,
	Trim(exc.value) as topping_id
Into exclusions 
From customer_orders1 c
Cross Apply
	String_split(c.exclusions, ',')	as exc

Select * From exclusions

-- New Extras table
Drop table if exists extras
Select c.record_id,
	Trim(ext.value) as topping_id 
Into extras
From customer_orders1 c
Cross Apply
	String_split(c.extras,',') as ext

Select * From extras

-- 1. What are the standard ingredients for each pizza?
Select pizza_id, 
	String_agg(topping_name,',') as Standard_toppings
From pizza_recipes1
Group by pizza_id;	

-- 2. What was the most commonly added extra?
Select Top(1) p.topping_name, count(*) as added_extra_time
From extras e 
Inner Join pizza_toppings p
	on e.topping_id = p.topping_id
Group by p.topping_name
Order by count(*) desc

-- 3. What was the most commonly exclusion?
Select Top(1) p.topping_name, count(*) as added_exclution_time
From exclusions e
Inner Join pizza_toppings p
	on e.topping_id = p.topping_id
Group by p.topping_name
Order by count(*) desc

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
	-- Meat Lovers
	-- Meat Lovers - Exclude Beef
	-- Meat Lovers - Extra Bacon
	-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

With exc_cte as 
(
	Select e.record_id, 
		Concat(' - Exclude ', String_agg(p.topping_name, ', ')) as optional 	 
	From exclusions e
	Inner Join pizza_toppings p
		on e.topping_id = p.topping_id
	Group by e.record_id 
),

	ext_cte as
(
	select e.record_id,
		Concat(' - Extra ', String_agg(p.topping_name, ', ')) as optional 
	From extras e
	Inner Join pizza_toppings p
		on e.topping_id = p.topping_id
	Group by e.record_id
),

	cte as
(
	Select * From exc_cte 
	Union 
	Select * From ext_cte
)

Select c.record_id, c.order_id, 
	Concat(p.pizza_name, String_agg(optional, ',')) as order_item 
From customer_orders1 c
Inner Join pizza_names p
	on p.pizza_id = c.pizza_id
Left Join cte 
	on c.record_id = cte.record_id
Group by c.record_id, c.order_id, p.pizza_name

-- D. Pricing and Ratings
-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
-- how much money has Pizza Runner made so far if there are no delivery fees?
Select Sum(Case 
			When pizza_name = 'Meatlovers' 
			Then 12 
			Else 10
			End) as pizza_cost
From pizza_names pn
Inner Join customer_orders1 c
	on c.pizza_id = pn.pizza_id
Inner Join runner_orders1 r
	on c.order_id = r.order_id
Where r.cancellation is Null

-- 2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra
Declare @basecost int = 138;

Select Len(agg_extras), Len(Replace(agg_extras, ',', '')),
    (Len(agg_extras) - Len(Replace(agg_extras, ',', '')) + 1) + @basecost as Total
From (
    Select String_agg(c.extras, ',') as agg_extras
    From customer_orders1 c
    Join runner_orders1 r 
		on c.order_id = r.order_id
    Where r.cancellation is Null
) as subquery

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
-- how would you design an additional table for this new dataset - generate a schema for this new table 
-- and insert your own data for ratings for each successful customer order between 1 to 5.
Drop table if exists ratings
Create table ratings 
 (order_id int,
    rating int);
Insert into ratings
 (order_id ,rating)
Values 
(1,4),
(2,3),
(3,5),
(4,1),
(5,2),
(6,2),
(7,4),
(8,5),
(9,3),
(10,5)
Select * From ratings

--4. Using your newly generated table - can you join all of the information together to form a table
	-- which has the following information for successful deliveries?
	-- customer_id
	-- order_id
	-- runner_id
	-- rating
	-- order_time
	-- pickup_time
	-- Time between order and pickup
	-- Delivery duration
	-- Average speed
	-- Total number of pizzas
Select c.customer_id, c.order_id, r1.runner_id, r2.rating, 
	c.order_time, r1.pickup_time,
	datediff(minute, order_time, pickup_time) as time_between_order_pickup,
	r1.durations, 
	Round(Avg(distance/durations*60),2) as avg_speed,
	Count(pizza_id) as pizza_count
From customer_orders1 c
Left Join runner_orders1 r1
	on c.order_id = r1.order_id
Left Join ratings r2 
	on c.order_id = r2.order_id
Where r1.cancellation is Null
Group by c.customer_id, c.order_id, r1.runner_id, r2.rating, 
	c.order_time, r1.pickup_time, r1.durations,
	datediff(minute, order_time, pickup_time)
Order by customer_id

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled 
-- how much money does Pizza Runner have left over after these deliveries?
Declare @pizzaamountearned int = 138;
select @pizzaamountearned as revenue,
	sum(distance) * 0.3 as cost,
	@pizzaamountearned - (sum(distance))*0.3 as profit
from runner_orders1