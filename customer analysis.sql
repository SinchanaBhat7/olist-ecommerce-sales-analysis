-- =================================================
-- Customer analysis
-- =================================================

-- total customers
USE olist_ecommerce;
SELECT COUNT(customer_unique_id) FROM olist_customers_dataset;

-- Repeat Customers
SELECT customer_unique_id,COUNT(o.order_id) AS total_orders
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id
GROUP BY customer_unique_id
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

-- top customer state
SELECT customer_state, COUNT(DISTINCT customer_unique_id) AS total_spent
FROM olist_customers_dataset 
GROUP BY customer_state 
ORDER BY customer_unique_id desc;

-- Most Active Customers
SELECT customer_unique_id, COUNT(o.order_id) AS total_orders
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id
GROUP BY customer_unique_id
ORDER BY total_orders DESC;

-- Customers Generating Highest Revenue
SELECT customer_unique_id,SUM(payment_value) AS total_spent
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
GROUP BY customer_unique_id
ORDER BY total_spent DESC;

-- Average Revenue Per Customer
SELECT SUM(payment_value) / COUNT(DISTINCT customer_unique_id) AS avg_revenue_per_customer
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id;

