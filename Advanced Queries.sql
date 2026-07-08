-- revenue contribution by product category
WITH category_revenue AS
(
SELECT p.product_category_name AS product_category, SUM(oi.price) AS total_revenue
FROM olist_products_dataset p
JOIN olist_order_items_dataset oi
ON p.product_id=oi.product_id
GROUP BY p.product_category_name
)
SELECT product_category,total_revenue,
ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER(),2) AS revenue_contribution_percentage
FROM category_revenue
ORDER BY revenue_contribution_percentage DESC;

-- Monthly growth rate
WITH monthly_revenue AS
(
SELECT DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS order_month, SUM(oi.price) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id=oi.order_id
GROUP BY order_month
)
SELECT order_month,total_revenue,
LAG(total_revenue) OVER(
ORDER BY order_month) AS previous_month_revenue,
ROUND(
(total_revenue-LAG(total_revenue) OVER(ORDER BY order_month))*100/
NULLIF(LAG(total_revenue) OVER(ORDER BY order_month),0),2)
AS monthly_growth_percentage
FROM monthly_revenue;

-- Customer lifetime value (CLV)
WITH customer_lifetime AS
(
SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS total_orders, 
SUM(op.payment_value) AS lifetime_revenue 
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
ON o.customer_id=c.customer_id
JOIN olist_order_payments_dataset op
ON op.order_id=o.order_id
GROUP BY c.customer_unique_id
)
SELECT * FROM customer_lifetime
ORDER BY lifetime_revenue DESC;

-- Best selling category every month
WITH monthly_category_revenue AS
(
SELECT DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS order_month,
p.product_category_name AS product_category,
SUM(oi.price) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id=oi.order_id
JOIN olist_products_dataset p
ON p.product_id=oi.product_id
GROUP BY product_category,order_month
),
category_rank AS 
(
SELECT order_month,product_category,total_revenue,ROW_NUMBER() OVER(
    PARTITION BY order_month
    ORDER BY total_revenue DESC
) AS rank_num
FROM monthly_category_revenue
)
SELECT order_month,
    product_category,
    total_revenue
FROM category_rank
WHERE rank_num = 1
ORDER BY order_month;