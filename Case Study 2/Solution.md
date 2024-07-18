![image](https://github.com/user-attachments/assets/f41c3903-ac6c-4e7e-985e-418e177684ee)# <p align = "center"> Solution

## <p align = "center"> Cleaning Data 
### Cleaning customer_orders 
```sql
Drop Table if exists customer_orders1
Select order_id, customer_id, pizza_id,
	Case 
		When exclusions = 'null' Then NULL 
		When exclusions = '' then NULL
		Else exclusions 
	End as exclusions,

	Case 
		When extras = 'null' then NULL
		When extras = '' then NULL
		Else extras
	End as extras,
	order_time
Into customer_orders1
From customer_orders
```

### Cleaning runner_orders 
```sql
Drop Table if exists runner_orders1
Select order_id, runner_id,
	Case
		When pickup_time = 'null' then Null
		Else pickup_time
	End as pickup_time,

	Case 
		When distance = 'null' then Null
		When distance like '%km' then trim('km' from distance)
		else distance
	End as distance,

	Case 
		When duration = 'null' then Null
		When duration like '%mins' then trim('mins' from duration)
		When duration like '%minute' then trim ('minute' from duration)
		When duration like '%minutes' then trim('minutes' from duration)
		Else duration
	End as durations,

	Case 
		When cancellation = 'null' then Null
		When cancellation = '' then Null
		Else cancellation
	End as cancellation
Into runner_orders1 
From runner_orders 

Alter table runner_orders1
Alter column pickup_time DateTime Null

Alter table runner_orders1
Alter column distance Decimal(5,1) Null 

Alter table runner_orders1
Alter column durations int Null 
```

### Change several data types of columns
```sql
Alter table pizza_toppings
Alter column topping_name NVARCHAR(max)

Alter table pizza_names
Alter column pizza_name NVARCHAR(max)

ALTER TABLE pizza_recipes
ALTER COLUMN toppings VARCHAR(MAX);
```
## <p align = "center"> A. Pizza Metrics 
### 1. 1. How many pizzas were ordered?
```sql
Select Count(*) as TotalPizzaOrdered
From customer_orders1
```
Result 

![image](https://github.com/user-attachments/assets/ecbf7720-6a82-479a-8629-b6fcc6f2369b)

### 2. How many unique customer orders were made?
```sql
Select Count(distinct order_id) as TotalOrdered
From customer_orders1
```
Result 

![image](https://github.com/user-attachments/assets/5d9ed885-7c9c-418f-b677-dc17a8cf6ed7)

### 3. How many successful orders were delivered by each runner?
```sql
Select runner_id, Count(order_id) as TotalDelivered 
From runner_orders1
Where cancellation is Null
Group by runner_id
```
Result

![image](https://github.com/user-attachments/assets/f90ee2f5-71da-43cc-bada-52279be08b4c)


### 4. How many of each type of pizza was delivered?
```sql
Select p.pizza_name AS pizza_name, 
	Count(c.pizza_id) as TotalDelivered
From pizza_names p
Inner Join customer_orders1 c
    on p.pizza_id = c.pizza_id
Inner Join runner_orders1 r
    on c.order_id = r.order_id
Where r.cancellation is Null
Group by p.pizza_name
```
Result 

![image](https://github.com/user-attachments/assets/f08896a2-21eb-4ee7-803d-47dd81db1904)

### 5. How many Vegetarian and Meatlovers were ordered by each customer?
```sql
Select c.customer_id,
	p.pizza_name as pizza_name, 
	Count(c.order_id) as TotalOrdered
From pizza_names p
Inner Join customer_orders1 c
	on p.pizza_id = c.pizza_id
Group by c.customer_id,
	p.pizza_name
Order by c.customer_id
```
Result

![image](https://github.com/user-attachments/assets/747879eb-11d7-4be0-b5d4-f484941d3575)

### 6. What was the maximum number of pizzas delivered in a single order?
```sql
Select Top(1) r.order_id, count(c.order_id) as TotalDelivered
From customer_orders1 c
Join pizza_names p
	on p.pizza_id = c.pizza_id
Join runner_orders r
	on r.order_id = c.order_id
Where r.cancellation is Null
Group by r.order_id
Order by count(c.order_id) Desc
```
Result

![image](https://github.com/user-attachments/assets/8647b898-8d7e-4d68-8092-4bc8c541a3e5)


### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```sql
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
```
Result

![image](https://github.com/user-attachments/assets/81938622-ced7-4eba-83a8-16de6f0eafb1)

### 8. How many pizzas were delivered that had both exclusions and extras?
```sql
Select count(c.pizza_id) as Pizza_Delivered_exclusions_extras 
From customer_orders1 c
Join runner_orders1 r
	on c.order_id = r.order_id
Where r.cancellation is Null
	and c.exclusions is not Null
	and c.extras is not Null
```
Result

![image](https://github.com/user-attachments/assets/f2355511-bab1-49a6-9e40-7a56246cf00c)

### 9. What was the total volume of pizzas ordered for each hour of the day?
```sql
Select Datepart(hour, order_time) as hour, 
	Count(*) as PizzaOrdered 
From customer_orders1
Group by Datepart(hour, order_time)
```

Result

![image](https://github.com/user-attachments/assets/a15fa543-4251-4423-9ffe-a99fbfc2f8c6)

### 10. What was the volume of orders for each day of the week?
```sql
Select Datename(Weekday, order_time) as weekday,
	Count(*) as Volume 
From customer_orders1
Group by Datename(Weekday, order_time)
```
Result

![image](https://github.com/user-attachments/assets/751c7053-db02-4e68-afca-87c877464b44)

## <p align = 'center'> B. Runner and Customer Experience
### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
```sql
Set Datefirst 1
Select Datepart(Week, registration_date) as week, 
	Count(runner_id) as sign_up
From runners
Group by Datepart(Week, registration_date)
```
Result

![image](https://github.com/user-attachments/assets/7045bd13-6e7c-495c-b5e5-8c603c0d633e)

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```sql
Select r.runner_id,
	Round(Avg(Cast(Datediff(minute, order_time, pickup_time)as Float)),2) as time 
From customer_orders1 c
Inner Join runner_orders1 r
	on c.order_id = r.order_id
Where r.cancellation is Null 
Group by r.runner_id
```
Result
![image](https://github.com/user-attachments/assets/0c8fcfba-5ec7-45a6-84c8-2f901bc97cbc)

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
```sql
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
```
Result

![image](https://github.com/user-attachments/assets/8c844d81-d9a2-4daf-9707-254174f62192)

### 4. What was the average distance travelled for each customer?
```sql
Select c.customer_id, 
	Round(Avg(r.distance),2) as avg_distance
From customer_orders1 c
Inner Join runner_orders1 r
	on c.order_id = r.order_id
Group by c.customer_id
```
Result

![image](https://github.com/user-attachments/assets/3858d03a-ee9b-43e2-a3b8-99b9da6ca60e)

### 5. What was the difference between the longest and shortest delivery times for all orders?
```sql
Select max(r.durations) - min(r.durations) as dif_longest_shortest 
From customer_orders1 c
Inner Join runner_orders1 r
	on c.order_id = r.order_id
```
Result

![image](https://github.com/user-attachments/assets/32bffec3-350d-47c4-8f1b-438cfa606cfd)

### 6. What was the average speed for each runner for each delivery ?
```sql
Select r.runner_id,
	Round(Avg(distance*60/durations),2) as avg_speed 
From customer_orders1 c
Inner Join runner_orders1 r
	on c.order_id = r.order_id
Where r.cancellation is Null
Group by r.runner_id
```
Result

![image](https://github.com/user-attachments/assets/8f9924c0-1821-41c4-b282-a8c8069e7eee)

### 7. What is the successful delivery percentage for each runner?
```sql
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
```
Result

![image](https://github.com/user-attachments/assets/9d20d95d-5659-4bec-86e5-1a908f912593)

## <p align='center'> C. Ingredient Optimisation
### Preparing data for this part 
####Cleaning pizza_recipes
```sql
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
```
- Original Table:

![image](https://github.com/user-attachments/assets/49944d25-86c4-473b-ac1a-dae76bbfa95d)

- New Table:

![image](https://github.com/user-attachments/assets/d15f335b-a342-4ae6-b9fc-98c014bf0c64)

#### Cleaning customer_orders
```sql
Alter table customer_orders1
Add record_id int Identity(1,1)
```
- New Table:
![image](https://github.com/user-attachments/assets/8ebc7cf4-e0f9-416e-a57d-3f1c6cf59145)

#### Add new tables Exclusions and Extras 
- New Exclusions table
```sql
Drop table if exists exclusions
Select c.record_id,
	Trim(exc.value) as topping_id
Into exclusions 
From customer_orders1 c
Cross Apply
	String_split(c.exclusions, ',')	as exc
```
Result

![image](https://github.com/user-attachments/assets/34be407e-c1a8-47ca-86b4-d33d6bd77c30)

- New Extras table
```sql
Drop table if exists extras
Select c.record_id,
	Trim(ext.value) as topping_id 
Into extras
From customer_orders1 c
Cross Apply
	String_split(c.extras,',') as ext
```
Result

![image](https://github.com/user-attachments/assets/421d9e90-aca6-4cc2-a0fb-e65f96181ade)

### 1. What are the standard ingredients for each pizza?
```sql
Select pizza_id, 
	String_agg(topping_name,',') as Standard_toppings
From pizza_recipes1
Group by pizza_id
```
Result

![image](https://github.com/user-attachments/assets/de995ae4-07a2-4e43-85f9-a3122b125dcf)

### 2. What was the most commonly added extra?
```sql
Select Top(1) p.topping_name, count(*) as added_extra_time
From extras e 
Inner Join pizza_toppings p
	on e.topping_id = p.topping_id
Group by p.topping_name
Order by count(*) desc
```
Result

![image](https://github.com/user-attachments/assets/36adc94a-f5f8-499a-ab7e-21beb5913265)

### 3. What was the most commonly exclusion?
```sql
Select Top(1) p.topping_name, count(*) as added_exclution_time
From exclusions e
Inner Join pizza_toppings p
	on e.topping_id = p.topping_id
Group by p.topping_name
Order by count(*) desc
```
Result

![image](https://github.com/user-attachments/assets/332846e0-e000-42c6-b270-c454241d7a78)

### 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
	- Meat Lovers
	- Meat Lovers - Exclude Beef
	- Meat Lovers - Extra Bacon
	- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
```sql
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
```
Result

![image](https://github.com/user-attachments/assets/29fd7634-5ced-43f2-bb8e-8abf2b739366)

## <p align='center'> D. Pricing and Ratings
### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
```sql
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
```
Result 

![image](https://github.com/user-attachments/assets/820c1acc-2049-4a4a-b25e-c936a3e19c8d)

### 2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra
```sql
Declare @basecost int = 138;

Select (Len(agg_extras) - Len(Replace(agg_extras, ',', '')) + 1) + @basecost as Total
From (
    Select String_agg(c.extras, ',') as agg_extras
    From customer_orders1 c
    Join runner_orders1 r 
		on c.order_id = r.order_id
    Where r.cancellation is Null
) as subquery
```
Result

![image](https://github.com/user-attachments/assets/64bcf028-73b8-4bd6-808e-3bbc942da8ab)

### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, - how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
```sql
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
```
Result

![image](https://github.com/user-attachments/assets/f0a8a9cf-078a-48b7-a7c3-a32fbef53b9d)

### 4. Using your newly generated table - can you join all of the information together to form a table
	- which has the following information for successful deliveries?
	- customer_id
	- order_id
	- runner_id
	- rating
	- order_time
	- pickup_time
	- Time between order and pickup
	- Delivery duration
	- Average speed
	- Total number of pizzas
 
```sql
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
```
Result

![image](https://github.com/user-attachments/assets/9b45be87-1e45-4d9e-9b67-1307935ebf30)

### 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
```sql
Declare @pizzaamountearned int = 138;
select @pizzaamountearned as revenue,
	sum(distance) * 0.3 as cost,
	@pizzaamountearned - (sum(distance))*0.3 as profit
from runner_orders1
```
Result

![image](https://github.com/user-attachments/assets/610ec6bb-b1df-42cd-aef5-c9977a9e484f)
