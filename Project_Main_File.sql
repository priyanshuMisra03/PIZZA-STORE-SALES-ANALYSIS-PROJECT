create database pizzahut;

use pizzahut;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);


create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);


select * from pizzas;
select * from pizza_types;
select * from orders;
select * from order_details;


-- # Basic Questions

-- Q1. Retrieve the total no. of orders placed. 

SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;


-- Q2. Calculate total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS Total_Sales
FROM
    order_details od
        INNER JOIN
    pizzas p ON od.pizza_id = p.pizza_id;
    
    
-- Q3. Identify the highest-priced pizza.->

SELECT 
    pt.name AS Name, p.price
FROM
    pizza_types AS pt
        INNER JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


-- Q4. Identify the most common pizza size ordered

SELECT 
    p.Size, COUNT(od.order_id) AS Total_Ordered
FROM
    pizzas p
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.Size
ORDER BY Total_Ordered DESC;


-- Q5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name AS Name, SUM(quantity) AS Quantity
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY Name
ORDER BY Quantity DESC
LIMIT 5;


-- Intermediate Questions

-- Q1. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.Category, SUM(Quantity) AS Total_Quantity
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.Category
ORDER BY Total_Quantity DESC;


-- Q2. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS Order_Count
FROM
    orders
GROUP BY Hour
ORDER BY Order_Count DESC;


-- Q3. Join relevant tables to find the category-wise distribution of pizzas.

select Category, count(name) as Pizza_Count
from pizza_types 
group by Category 
order by Pizza_Count desc;


-- Q4. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 2) AS Avg_pizza_Order_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    INNER JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity;


-- Q5. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name AS Name, SUM(od.quantity * p.price) AS Revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY Name
ORDER BY Revenue DESC
LIMIT 3;


-- Advanced 

-- Q1. Calculate the percentage contribution of each pizza type to total revenue.


SELECT 
    pt.category AS Pizza_Category,
    ROUND(SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) AS Total_Sales
                FROM
                    order_details od
                        INNER JOIN
                    pizzas p ON od.pizza_id = p.pizza_id) * 100,
            2) AS Revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY Pizza_Category
ORDER BY Revenue DESC;

-- OR --

WITH TotalSales AS (
    SELECT 
        SUM(od.quantity * p.price) AS Total_Sales
    FROM
        order_details od
    INNER JOIN
        pizzas p ON od.pizza_id = p.pizza_id
)
SELECT 
    pt.category AS Pizza_Category,
    ROUND(SUM(od.quantity * p.price) / (SELECT Total_Sales FROM TotalSales), 2) * 100 AS Revenue_Percentage
FROM
    pizza_types pt
JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY 
    Pizza_Category
ORDER BY 
    Revenue_Percentage DESC;


-- Q2. Analyze the cumulative revenue generated over time.

SELECT Order_Date,
round(sum(revenue) OVER (ORDER BY order_date),2) AS Cum_Revenue
FROM
(SELECT 
    o.order_date, SUM(od.quantity * p.price) AS revenue
FROM
    order_details AS od
        JOIN
    orders o ON od.order_id = o.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.order_date) AS Sales;


-- Q3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select rn as C_Rank, Category, Name, Revenue 
from
(select Category, Name, Revenue,
rank() over ( partition by Category order by revenue desc) as rn
from
(
select pt.category as Category, pt.name as Name, SUM(od.quantity * p.price) AS revenue
FROM
    order_details AS od
        JOIN
    orders o ON od.order_id = o.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        join
	pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by Category, Name
) as a
) as b
where rn <= 3;

-- OR--


WITH PizzaRevenueRank AS (
    SELECT 
        pt.category AS Category,
        pt.name AS Name,
        SUM(od.quantity * p.price) AS Revenue,
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS Category_Rank
    FROM
        order_details od
    JOIN
        pizzas p ON od.pizza_id = p.pizza_id
    JOIN
        pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY
        pt.category, pt.name
)
SELECT 
    Category_Rank AS C_Rank,
    Category,
    Name,
    Revenue
FROM
    PizzaRevenueRank
WHERE
    Category_Rank <= 3;