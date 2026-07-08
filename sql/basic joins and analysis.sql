USE olist_ecommerce;
SELECT *
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id=c.customer_id;

USE olist_ecommerce;
SELECT * 
FROM olist_products_dataset p
JOIN olist_order_items_dataset oi 
ON p.product_id =oi.product_id;

USE olist_ecommerce;
SELECT * 
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset orv
ON o.order_id = orv.order_id;

SELECT DISTINCT order_status FROM olist_orders_dataset;
-- order by status
SELECT order_status,
count(*) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status;

-- average review score
SELECT avg(review_score)
FROM olist_order_reviews_dataset;

-- revenue basics
-- total revenue 
SELECT sum(payment_value) FROM olist_order_payments_dataset;
-- average_payment
SELECT avg(payment_value) FROM olist_order_payments_dataset;
-- payment_type_distribution
SELECT payment_type, COUNT(*) as number_of_payments FROM olist_order_payments_dataset
GROUP BY payment_type;

USE olist_ecommerce;
-- product_category_popularity
SELECT product_category_name, count(*) AS total_orders 
FROM olist_products_dataset
GROUP BY product_category_name
ORDER BY total_orders DESC;

USE olist_ecommerce;
-- delivery performance
SELECT AVG(datediff(order_delivered_customer_date,order_purchase_timestamp)) AS
average_delivery_days 
FROM olist_orders_dataset
WHERE order_status="delivered";