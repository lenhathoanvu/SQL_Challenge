# <p align = "center"> Case Study 2: Pizza Runner
## Introduction
Did you know that over 115 million kilograms of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

## Available Data
Because Danny had a few years of experience as a data scientist - he was very aware that data collection was going to be critical for his business’ growth.

He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimize Pizza Runner’s operations.

All datasets exist within the ```pizza_runner``` database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

### Entity Relationship Diagram
![image](https://github.com/user-attachments/assets/afd6d60b-7055-4901-9be7-996120cb563a)
### Table 1: runners
The ```runners``` table shows the ```registration_date``` for each new runner

![image](https://github.com/user-attachments/assets/d4a67070-1854-4ebe-8817-58f1fb4cb397)
### Table 2: customer_orders
Customer pizza orders are captured in the ```customer_orders``` table with 1 row for each individual pizza that is part of the order.

The ```pizza_id``` relates to the type of pizza which was ordered whilst the ```exclusions``` are the ```ingredient_id``` values which should be removed from the pizza and the ```extras``` are the ```ingredient_id``` values which need to be added to the pizza.

Note that customers can order multiple pizzas in a single order with varying ```exclusions``` and ```extras``` values even if the pizza is the same type!

The ```exclusions``` and ```extras``` columns will need to be cleaned up before using them in your queries.

![image](https://github.com/user-attachments/assets/fc63525f-6e61-42dd-bd85-f9aa560c351f)

### Table 3: runner_orders
After each order is received through the system - they are assigned to a runner - however not all orders are fully completed and can be canceled by the restaurant or the customer.

The ```pickup_time``` is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. The ```distance``` and ```duration``` fields are related to how far and long the runner had to travel to deliver the order to the respective customer.

There are some known data issues with this table so be careful when using this in your queries - make sure to check the data types for each column in the schema SQL!

![image](https://github.com/user-attachments/assets/91fc2453-ffb7-41db-993d-63cfea07d3d4)

### Table 4: pizza_names
At the moment - Pizza Runner only has 2 pizzas available the Meat Lovers or Vegetarian!

![image](https://github.com/user-attachments/assets/21fbd151-d5aa-4fc1-a658-ae11ad0a8f6e)

### Table 5: pizza_recipes
Each ```pizza_id``` has a standard set of ```toppings``` which are used as part of the pizza recipe.

![image](https://github.com/user-attachments/assets/a4bef569-50bc-4646-8ca1-1ab724387192)


### Table 6: pizza_toppings
This table contains all of the ```topping_name``` values with their corresponding ```topping_id``` value

![image](https://github.com/user-attachments/assets/e428b4e6-c95e-4ac7-b6fd-73ba44ec4812)

## Case Study Questions
This case study has LOTS of questions - they are broken up by area of focus including:

- Pizza Metrics
- Runner and Customer Experience
- Ingredient Optimisation
- Pricing and Ratings
- Bonus DML Challenges (DML = Data Manipulation Language)
- Each of the following case study questions can be answered using a single SQL statement.

Again, there are many questions in this case study - please feel free to pick and choose which ones you’d like to try!

Before you start writing your SQL queries however - you might want to investigate the data, you may want to do something with some of those ```null``` values and data types in the ```customer_orders``` and ```runner_orders``` tables!

## A. Pizza Metrics
1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change, and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

## B. Runner and Customer Experience
1. How many runners signed up for each 1 week period? (i.e. week starts ```2021-01-01```)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pick up the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance traveled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?

## C. Ingredient Optimisation
1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the ```customers_orders``` table in the format of one of the following:
- ```Meat Lovers```
- ```Meat Lovers - Exclude Beef```
- ```Meat Lovers - Extra Bacon```
- ```Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers```
5. Generate an alphabetically ordered comma-separated ingredient list for each pizza order from the ```customer_orders``` table and add a ```2x``` in front of any relevant ingredients
- For example: ```"Meat Lovers: 2xBacon, Beef, ..., Salami"```
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

## D. Pricing and Ratings
1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras?
- Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
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
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

### Link Solution:
[Solution.md](https://github.com/lenhathoanvu/SQL_Challenge/blob/master/Case%20Study%202/Solution.md)
