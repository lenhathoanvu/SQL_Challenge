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
