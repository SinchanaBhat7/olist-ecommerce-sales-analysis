-- ==================================================================
-- sales and revenue analysis
-- ==================================================================

USE olist_ecommerce;
-- total revenue
SELECT SUM(payment_value) AS total_revenue
FROM olist_order_payments_dataset;

-- total orders
SELECT 
COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset;

-- average order value
SELECT AVG(payment_value) / COUNT(DISTINCT order_id) AS average_order_value
FROM olist_order_payments_dataset;

-- Monthly Revenue Trend
SELECT 
DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
SUM(p.payment_value) AS monthly_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;

-- Monthly Orders Trend
SELECT 
DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset
GROUP BY month
ORDER BY month;

-- highest revenue product categories 
SELECT 
p.product_category_name,
SUM(oi.price) AS total_revenue
FROM olist_products_dataset p
JOIN olist_order_items_dataset oi
ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;

-- Most Ordered Product Categories
SELECT 
p.product_category_name,
COUNT(oi.order_id) AS total_orders
FROM olist_products_dataset p
JOIN olist_order_items_dataset oi
ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_orders DESC;

-- Top Revenue Generating Products
SELECT product_id, SUM(price) AS total_revenue
FROM olist_order_items_dataset
GROUP BY product_id
ORDER BY total_revenue DESC limit 5; 

-- Payment Method Usage 
SELECT payment_type, COUNT(*) AS usage_count
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY usage_count DESC;





