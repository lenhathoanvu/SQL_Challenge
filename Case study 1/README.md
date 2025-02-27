# <p align = "center"> CASE STUDY 1: Danny's Diner

## Introduction 
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favorite foods: sushi, curry, and ramen.
Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from its few months of operation but has no idea how to use its data to help it run the business.

## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent, and also which menu items are their favorite. Having this deeper connection with his customers will help him deliver a better and more personalized experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

Danny has shared with you 3 key datasets for this case study:
- ```sales```
- ```menu```
- ```members```

### Entity Relationship Diagram

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/3fc41857-ce1d-404a-9bd5-48fea02339ca)

### Table 1: sales
The ```sales``` table captures all ```customer_id``` level purchases with a corresponding ```order_date``` and ```product_id``` information for when and what menu items were ordered.

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/bdcc2691-45f9-4196-8599-798f0c122142)

### Table 2: menu 
The ```menu``` table maps the ```product_id``` to the actual ```product_name``` and ```price``` of each menu item.

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/2b6f1ff0-afce-422e-b53e-e92712c36755)

### Table 3: members
The final ```members``` table captures the ```join_date``` when a ```customer_id``` joined the beta version of the Danny’s Diner loyalty program.

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/ae40d1c2-cdb7-4bab-ac36-9463cd0c1fdf)

## Case Study Questions
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

## Bonus questions
### Join All The Things 
The following questions are related to creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

Recreate the following table output using the available data:

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/49d47b38-bfdd-40d9-ac06-7be248be8d30)

### Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

![image](https://github.com/lenhathoanvu/SQL_Challenge/assets/173127058/422e920e-9224-4aea-ac69-17caaf964306)



