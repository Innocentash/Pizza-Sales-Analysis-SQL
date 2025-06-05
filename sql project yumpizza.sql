create database YumPizza;
use Yumpizza;

Select * from pizzas;
Select * from Pizza_types;

Create table orders(
order_id int,
order_date date,
order_time time);

select * from order_details;

-- Basic:


-- Retrieve the total number of orders placed.

Select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS revenue
FROM
    pizzas p
        JOIN
    order_details od ON od.pizza_id = p.pizza_id;
    
-- Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

select p.size, count(od.quantity) as count_orders
from pizzas p 
join order_details od
on p.pizza_id = od.pizza_id
group by p.size 
order by count_orders desc;

-- List the top 5 most ordered pizza types along with their quantities.

select pt.name,count(od.quantity) as total_quantity
from order_details od
join pizzas p 
on p.pizza_id = od.pizza_id
join pizza_types pt
on pt.pizza_type_id = p.pizza_type_id
group by pt.name
order by  total_quantity desc limit 5;


-- Intermediate:


-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pt.Category,count(od.quantity) as total_quantity
from order_details od
join pizzas p 
on p.pizza_id = od.pizza_id
join pizza_types pt
on pt.pizza_type_id = p.pizza_type_id
group by pt.category;

-- Determine the distribution of orders by hour of the day.

select hour(order_time) as order_hours,count(order_id) as order_count
from orders
group by order_hours;

-- Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) as Category_wise_distribustion
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

with pizza_order_per_day as(
select o.order_date,sum(od.quantity) as quantity_total from 
orders o 
join order_details od
on od.order_id = o.order_id
group by o.order_date)
select Avg(quantity_total) as avg_pizza_order_per_day from Pizza_order_per_day;

-- Determine the top 3 most ordered pizza types based on revenue.

select pt.name, round(Sum(price*quantity),0) as revenue
from pizza_types pt
join pizzas p
on p.pizza_type_id = pt.pizza_type_id
join order_details od
on od.pizza_id = p.pizza_id 
group by pt.name
order by revenue desc limit 3;

-- Advanced:


-- Calculate the percentage contribution of each pizza category to total revenue.
SELECT 
    category,
    Round(SUM(quantity * price),0) AS revenue,
   concat(ROUND(100.0 * SUM(quantity * price) / SUM(SUM(quantity * price)) OVER (), 2),"%") AS percent_contribution
FROM pizza_types pt
join pizzas p
on p.pizza_type_id = pt.pizza_type_id
join order_details od
on od.pizza_id = p.pizza_id 
group by category
order by revenue desc;

-- Analyze the cumulative revenue generated over time.
select order_date,revenue, round(sum(revenue) over (order by order_date),2) as cum_revenue from
(select order_date, round(sum(price*quantity),2) as revenue
from orders o 
join order_details od
on od.order_id = o.order_id
join pizzas p
on p.pizza_id = od.pizza_id
group by order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with revenue_cat as(select category,name, sum(price*quantity) as revenue,rank() over(partition by category order by sum(price*quantity)) as rn
from pizza_types pt
join pizzas p
on p.pizza_type_id = pt.pizza_type_id
join order_details od
on od.pizza_id = p.pizza_id
group by category,name)
select name,revenue,rn
from revenue_cat 
where rn<=3;

