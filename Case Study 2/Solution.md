# <p align = "center"> Solution

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

## <p align = "center"> A. Pizza Metrics 
### 1. 1. How many pizzas were ordered?
```sql
Select Count(*) as TotalPizzaOrdered
From customer_orders1
```
Result 
![image](https://github.com/user-attachments/assets/ecbf7720-6a82-479a-8629-b6fcc6f2369b)
