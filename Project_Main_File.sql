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



-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered.

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


-- Q7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS Order_Count
FROM
    orders
GROUP BY Hour
ORDER BY Order_Count DESC;


-- Q8. Join relevant tables to find the category-wise distribution of pizzas.

select Category, count(name) as Pizza_Count
from pizza_types 
group by Category 
order by Pizza_Count desc;


-- Q9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 2) AS Avg_pizza_Order_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    INNER JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity;


-- Q10. Determine the top 3 most ordered pizza types based on revenue.

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


