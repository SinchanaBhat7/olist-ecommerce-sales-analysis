USE olist_ecommerce;

-- Running monthly revenue
WITH monthly_revenue AS
(
SELECT DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS order_month,SUM(oi.price) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o
ON o.order_id=oi.order_id
GROUP BY order_month
 )
 SELECT order_month,
 SUM(total_revenue) OVER(
 ORDER BY order_month) AS running_revenue
 FROM monthly_revenue;
 
 -- Month over month revenue difference
 WITH monthly_revenue AS
(
SELECT DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS order_month,SUM(oi.price) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o
ON o.order_id=oi.order_id
GROUP BY order_month
 )
 SELECT order_month, total_revenue,
 LAG(total_revenue) OVER(
 ORDER BY order_month) AS previous_month_revenue,
 total_revenue - LAG(total_revenue) OVER (ORDER BY order_month) AS revenue_difference
 FROM monthly_revenue;
 
 -- Highest revenue seller in each state
 WITH seller_revenue AS
 (
 SELECT s.seller_state,s.seller_id,SUM(oi.price) AS total_revenue
 FROM olist_sellers_dataset s
 JOIN olist_order_items_dataset oi
 ON oi.seller_id=s.seller_id
 GROUP BY s.seller_id,s.seller_state
 ),
 seller_rank AS
 (
 SELECT seller_state,seller_id,total_revenue,
 ROW_NUMBER() OVER(
 PARTITION BY seller_state
 ORDER BY total_revenue DESC
 ) AS row_num
 FROM seller_revenue
 )
 SELECT
    seller_state,
    seller_id,
    total_revenue
FROM seller_rank
WHERE row_num = 1
ORDER BY seller_state;
 
 -- customer spending quartile
 WITH customer_spending AS
 (
 SELECT c.customer_unique_id,SUM(op.payment_value) AS total_spent
 FROM olist_customers_dataset c
 JOIN olist_orders_dataset o
 ON c.customer_id=o.customer_id
 JOIN olist_order_payments_dataset op
 ON op.order_id=o.order_id
 GROUP BY c.customer_unique_id
 )
 SELECT
    customer_unique_id,
    total_spent,
    NTILE(4) OVER(
        ORDER BY total_spent DESC
    ) AS spending_quartile
FROM customer_spending;
 
 
 
 