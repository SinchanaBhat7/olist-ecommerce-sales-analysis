-- ====================================
-- order and delivery performance
-- ====================================

USE olist_ecommerce;

-- order status percentage
  
  
-- avg delivery time
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS average_delivery_days
FROM olist_orders_dataset
WHERE order_status = 'delivered';

-- fastest and slowest delivery
SELECT 
min(datediff(order_delivered_customer_date,order_purchase_timestamp)) AS fastest_delivery,
max(datediff(order_delivered_customer_date,order_purchase_timestamp)) AS slowest_delivery
FROM olist_orders_dataset
WHERE order_status = 'delivered';

--  delayed orders count
SELECT count(order_id) AS delayed_orders
FROM olist_orders_dataset
WHERE order_status="delayed";

-- delayed orders percentage


-- average delay duration
SELECT avg(count(timestampdiff(order_estimated_delivery_date,order_delivered_customer_date))) 
FROM olist_orders_dataset
WHERE order_status="delayed";

--  on time vs late orders
SELECT count(order_id) 
WHERE order_estimated_delivery_date = order_delivered_customer_date; 

-- delivery performance by state

-- monthly delivery trend

-- orders delivered before estimated date
SELECT order_id 

