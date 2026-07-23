CREATE DATABASE pizza_sales_db;
USE pizza_sales_db;

-- creating table of customers 
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

-- creating orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_time TIME,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- creating pizza menu table
CREATE TABLE pizza_menu (
    pizza_id INT PRIMARY KEY,
    pizza_name VARCHAR(100),
    category VARCHAR(50),
    size VARCHAR(10),
    price DECIMAL(6,2)
);

-- creating order details
CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    pizza_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (pizza_id) REFERENCES pizza_menu(pizza_id)
);

-- inserting customer values
INSERT INTO customers VALUES
(1,'Ankita','Mumbai','2023-01-10'),
(2,'Rahul','Pune','2023-02-15'),
(3,'Sneha','Delhi','2023-03-05'),
(4,'Amit','Mumbai','2023-04-20'),
(5,'Priya','Bangalore','2023-05-18');

-- inserting pizza menu values
INSERT INTO pizza_menu VALUES
(1,'Margherita','Veg','Small',150),
(2,'Margherita','Veg','Medium',250),
(3,'Farmhouse','Veg','Large',450),
(4,'Peppy Paneer','Veg','Medium',350),
(5,'Chicken Dominator','Non-Veg','Large',550),
(6,'Chicken Pepperoni','Non-Veg','Medium',400),
(7,'Veg Extravaganza','Veg','Large',500),
(8,'Cheese Burst','Veg','Medium',300);

-- inserting orders values
INSERT INTO orders VALUES
(101,1,'2024-01-10','12:30:00'),
(102,2,'2024-01-11','18:45:00'),
(103,3,'2024-01-12','20:00:00'),
(104,1,'2024-01-15','14:15:00'),
(105,4,'2024-02-01','19:30:00'),
(106,5,'2024-02-03','21:10:00');

-- inserting order details values 
INSERT INTO order_details VALUES
(1,101,2,2),
(2,101,4,1),
(3,102,5,1),
(4,103,3,2),
(5,104,1,3),
(6,105,6,2),
(7,106,7,1),
(8,106,8,2);

-- 1. Total number of orders
SELECT COUNT(*) AS total_orders FROM orders;

-- 2. Total revenue generated
SELECT SUM(pm.price * od.quantity) AS total_revenue
FROM order_details od
JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id;

-- 3. Average order value
SELECT AVG(order_total) 
FROM (
    SELECT SUM(pm.price * od.quantity) AS order_total
    FROM order_details od
    JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
    GROUP BY order_id
) AS order_values;

-- 4. Top 3 most expensive pizzas
SELECT pizza_name, price
FROM pizza_menu
ORDER BY price DESC
LIMIT 3;

-- 5. Total customers
SELECT COUNT(*) FROM customers;

-- 6. Revenue by category
SELECT category,
SUM(pm.price * od.quantity) AS revenue
FROM order_details od
JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
GROUP BY category;

-- 7. Most ordered pizza (by quantity)
SELECT pizza_name,
SUM(quantity) AS total_quantity
FROM order_details od
JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
GROUP BY pizza_name
ORDER BY total_quantity DESC
LIMIT 1;

-- 8. Orders per city
SELECT city, COUNT(order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY city;

-- 9. Monthly revenue
SELECT MONTH(order_date) AS month,
SUM(pm.price * od.quantity) AS revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
GROUP BY MONTH(order_date);

-- 10. Customers who placed more than 1 order
SELECT customer_id, COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1;

-- 11. Rank pizzas by revenue
SELECT pizza_name,
SUM(pm.price * od.quantity) AS revenue,
RANK() OVER (ORDER BY SUM(pm.price * od.quantity) DESC) AS ranking
FROM order_details od
JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
GROUP BY pizza_name;

-- 12. Running total revenue
SELECT order_date,
SUM(SUM(pm.price * od.quantity)) OVER (ORDER BY order_date) AS running_total
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
GROUP BY order_date;

-- 13. Highest spending customer
SELECT c.customer_name,
SUM(pm.price * od.quantity) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
GROUP BY c.customer_name
ORDER BY total_spent DESC
LIMIT 1;

-- 14. Veg vs Non-Veg revenue comparison
SELECT category,
SUM(pm.price * od.quantity) AS revenue
FROM pizza_menu pm
JOIN order_details od ON pm.pizza_id = od.pizza_id
GROUP BY category;

-- 15. Peak order hour
SELECT HOUR(order_time) AS hour,
COUNT(*) AS total_orders
FROM orders
GROUP BY HOUR(order_time)
ORDER BY total_orders DESC
LIMIT 1;

-- 16. Orders above average order value
SELECT order_id
FROM (
    SELECT order_id,
    SUM(pm.price * od.quantity) AS order_total
    FROM order_details od
    JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
    GROUP BY order_id
) t
WHERE order_total > (
    SELECT AVG(order_total)
    FROM (
        SELECT SUM(pm.price * od.quantity) AS order_total
        FROM order_details od
        JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
        GROUP BY order_id
    ) x
);

-- 17. Categorize orders as High/Medium/Low value
SELECT order_id,
CASE 
    WHEN SUM(pm.price * od.quantity) > 800 THEN 'High'
    WHEN SUM(pm.price * od.quantity) BETWEEN 400 AND 800 THEN 'Medium'
    ELSE 'Low'
END AS order_category
FROM order_details od
JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
GROUP BY order_id;

-- 18. Revenue in January
SELECT SUM(pm.price * od.quantity) AS january_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
WHERE MONTH(order_date) = 1;

-- 19. Orders placed on weekend
SELECT *
FROM orders
WHERE DAYOFWEEK(order_date) IN (1,7);

-- 20. Best selling size
SELECT size,
SUM(quantity) AS total_sold
FROM pizza_menu pm
JOIN order_details od ON pm.pizza_id = od.pizza_id
GROUP BY size
ORDER BY total_sold DESC;

-- 21. Revenue per customer
SELECT c.customer_name,
SUM(pm.price * od.quantity) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
GROUP BY c.customer_name;

-- 22. Top 3 revenue generating cities
SELECT city,
SUM(pm.price * od.quantity) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
GROUP BY city
ORDER BY revenue DESC
LIMIT 3;

-- 23. Percentage contribution of each category
SELECT category,
ROUND(
SUM(pm.price * od.quantity) * 100 /
(SELECT SUM(pm.price * od.quantity)
 FROM order_details od
 JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id),
2) AS percentage
FROM pizza_menu pm
JOIN order_details od ON pm.pizza_id = od.pizza_id
GROUP BY category;

-- 24. Customer retention (repeat customers)
SELECT COUNT(*) AS repeat_customers
FROM (
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1
) t;

-- 25. Day-wise revenue
SELECT order_date,
SUM(pm.price * od.quantity) AS revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizza_menu pm ON od.pizza_id = pm.pizza_id
GROUP BY order_date
ORDER BY order_date;



















