# <p align = "center"> CASE STUDY 3: Foodie-Fi

## Introduction
Subscription-based businesses are super popular and Danny realized that there was a large gap in the market - he wanted to create a new streaming service that only had food-related content - something like Netflix but with only cooking shows!

Danny found a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

Danny created Foodie-Fi with a data-driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

## Available Data

Danny has shared the data design for Foodie-Fi and also short descriptions of each of the database tables - our case study focuses on only 2 tables but there will be a challenge to create a new table for the Foodie-Fi team.

All datasets exist within the foodie_fi database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

### Entity Relationship Diagram

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/964c8e24-dfe0-417d-b65d-d51f7c6113d4)

### Table 1: plans

Customers can choose which plans to join Foodie-Fi when they first sign up.

Basic plan customers have limited access and can only stream their videos and is only available monthly at $9.90

Pro plan customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.

Customers can sign up for an initial 7-day free trial and will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic, or upgrade to an annual pro plan at any point during the trial.

When customers cancel their Foodie-Fi service - they will have a ```churn``` plan record with a ```null``` price but their plan will continue until the end of the billing period.

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/40510bc9-d1e3-481f-96d2-6996bbb130d6)

### Table 2: subscriptions

Customer subscriptions show the exact date when their specific ```plan_id``` starts.

If customers downgrade from a pro plan or cancel their subscription - the higher plan will remain in place until the period is over - the ```start_date``` in the ```subscriptions``` table will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan - the higher plan will take effect straight away.

When customers churn - they will keep their access until the end of their current billing period but the ```start_date``` will be technically the day they decide to cancel their service.

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/fd427cd5-4b7e-48c0-8dc4-e7048f2725d5)

## Case Study Questions

### A. Customer Journey
Based on the 8 sample customers provided in the sample from the subscriptions table, write a brief description of each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

### B. Data Analysis Questions
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of ```trial``` plan ```start_date``` values for our dataset - use the start of the month as the group by value
3. What plan ```start_date``` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each ```plan_name```
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 ```plan_name``` values at ```2020-12-31```?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30-day periods (i.e. 0-30 days, 31-60 days, etc)
11. How many customers were downgraded from a pro monthly to a basic monthly plan in 2020?
