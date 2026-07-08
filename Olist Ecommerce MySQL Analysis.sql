USE olist_ecommerce;
SELECT *
FROM olist_orders_dataset o
JOIN olist_customers_dataset c 
ON o.customer_id=c.customer_id;

SELECT * 
FROM olist_products_dataset p
JOIN olist_order_items_dataset oi 
ON p.product_id =oi.product_id;

SELECT * 
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset orv
ON o.order_id = orv.order_id;

SELECT DISTINCT order_status FROM olist_orders_dataset;
-- order by status
SELECT order_status,count(*) AS total_orders
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

-- product_category_popularity
SELECT product_category_name, count(*) AS total_orders 
FROM olist_products_dataset
GROUP BY product_category_name
ORDER BY total_orders DESC;

-- delivery performance
SELECT AVG(datediff(order_delivered_customer_date,order_purchase_timestamp)) AS average_delivery_days 
FROM olist_orders_dataset
WHERE order_status="delivered";

-- ==================================================================
-- sales and revenue analysis
-- ==================================================================

USE olist_ecommerce;
-- total revenue
SELECT SUM(payment_value) AS total_revenue
FROM olist_order_payments_dataset;

-- total orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset;

-- average order value
SELECT SUM(payment_value) / COUNT(DISTINCT order_id) AS average_order_value
FROM olist_order_payments_dataset;

-- Monthly Revenue Trend
SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month, SUM(p.payment_value) AS monthly_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;

-- Monthly Orders Trend
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month, COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset
GROUP BY month
ORDER BY month;

-- Top revenue generating product categories
SELECT p.product_category_name, SUM(oi.price) AS total_revenue
FROM olist_products_dataset p
JOIN olist_order_items_dataset oi
ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;

-- Most Ordered Product Categories
SELECT p.product_category_name, COUNT(oi.order_id) AS total_orders
FROM olist_products_dataset p
JOIN olist_order_items_dataset oi
ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_orders DESC;

-- Top 5 Revenue Generating Products
SELECT product_id, SUM(price) AS total_revenue
FROM olist_order_items_dataset
GROUP BY product_id
ORDER BY total_revenue DESC limit 5; 

-- Payment Method Usage Count
SELECT payment_type, COUNT(*) AS usage_count
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY usage_count DESC;

-- =================================================
-- Customer analysis
-- =================================================

USE olist_ecommerce;

-- total customers
SELECT COUNT(customer_unique_id) as total_customers
FROM olist_customers_dataset;

-- Repeat Customers
SELECT customer_unique_id,COUNT(o.order_id) AS total_orders
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id
GROUP BY customer_unique_id
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

-- States with the Highest Number of Customers
SELECT customer_state, COUNT(customer_unique_id) AS total_customers
FROM olist_customers_dataset 
GROUP BY customer_state
ORDER BY total_customers DESC;

-- Most Active Customers
SELECT customer_unique_id, COUNT(o.order_id) AS total_orders
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id
GROUP BY customer_unique_id
ORDER BY total_orders DESC;

-- Top Customers by Revenue
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

-- ====================================
-- order and delivery performance
-- ====================================

USE olist_ecommerce;

-- order status percentage
SELECT order_status,COUNT(order_id) AS total_orders,
ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(order_id) 
FROM olist_orders_dataset), 2) AS status_percentage
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY status_percentage DESC;
  
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

--  total delayed orders
SELECT count(order_id) AS delayed_orders
FROM olist_orders_dataset
WHERE order_status="delivered"
AND order_delivered_customer_date> order_estimated_delivery_date;

-- delayed orders percentage
SELECT ROUND(SUM(
CASE
	WHEN order_delivered_customer_date > order_estimated_delivery_date
	THEN 1 
    ELSE 0 
    END
	) * 100.0 / COUNT(order_id), 2)
AS delayed_order_percentage
FROM olist_orders_dataset
WHERE order_status = 'delivered';

-- average delay duration
SELECT avg(datediff(order_delivered_customer_date,order_estimated_delivery_date)) AS average_delay_days
FROM olist_orders_dataset
WHERE order_status="delivered"
AND order_delivered_customer_date > order_estimated_delivery_date;

--  on time vs late orders
SELECT 
	CASE 
        WHEN order_delivered_customer_date > order_estimated_delivery_date 
        THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    COUNT(order_id) AS total_orders
FROM olist_orders_dataset
WHERE order_status = 'delivered'
GROUP BY delivery_status;

-- delivery performance by state
SELECT c.customer_state, 
COUNT(o.order_id) AS total_delivered_orders,
ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days,
SUM(CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 
        ELSE 0 
    END) AS delayed_orders,
ROUND(SUM(CASE 
		WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 
		ELSE 0 
		END) * 100.0 / COUNT(o.order_id), 2) AS delayed_percentage
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY avg_delivery_days ASC;

-- monthly delivery trend
SELECT DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS month,
ROUND(AVG(DATEDIFF(order_delivered_customer_date,order_purchase_timestamp)),2) AS avg_delivery_days
FROM olist_orders_dataset
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- Early deliveries
SELECT COUNT(order_id) AS early_deliveries
FROM olist_orders_dataset
WHERE order_status = 'delivered'
AND order_delivered_customer_date < order_estimated_delivery_date;

-- ======================================
-- Customer satisfaction analysis
-- ======================================

USE olist_ecommerce;

--  average customer review score
SELECT AVG(review_score) AS avg_review_score
FROM olist_order_reviews_dataset;

-- review score distribution
SELECT  review_score, COUNT(review_id) AS total_reviews
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score;

-- positive vs negative reviews
SELECT
	CASE
		WHEN review_score IN(4,5) THEN 'Positive'
		WHEN review_score IN(1,2) THEN 'Negative'
		ELSE 'Neutral'
	END AS review_category,
	COUNT(*) AS total_reviews
FROM olist_order_reviews_dataset
GROUP BY review_category
ORDER BY total_reviews DESC;

-- Average Review Score for Delayed Deliveries
SELECT AVG(review_score) AS avg_review_score
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
ON o.order_id=r.order_id
WHERE o.order_status='delivered'
AND o.order_delivered_customer_date > o.order_estimated_delivery_date;

-- ontime delivery vs delay delivery review scores
SELECT
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    ROUND(AVG(r.review_score),2) AS avg_review_score
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
ON o.order_id = r.order_id
WHERE o.order_status='delivered'
GROUP BY delivery_status;

 -- average review score by product category
 SELECT
    p.product_category_name, AVG(r.review_score) AS avg_review_score
FROM olist_order_reviews_dataset r
JOIN olist_orders_dataset o
ON r.order_id=o.order_id

JOIN olist_order_items_dataset oi
ON o.order_id=oi.order_id

JOIN olist_products_dataset p
ON oi.product_id=p.product_id

GROUP BY p.product_category_name
ORDER BY avg_review_score DESC;
 
 -- average review score by state
 SELECT c.customer_state,AVG(r.review_score) AS avg_review_score
FROM olist_order_reviews_dataset r

JOIN olist_orders_dataset o
ON r.order_id=o.order_id

JOIN olist_customers_dataset c
ON o.customer_id=c.customer_id

GROUP BY c.customer_state
ORDER BY avg_review_score DESC;
 
 -- average review score by delivery time
SELECT
CASE
WHEN DATEDIFF(o.order_delivered_customer_date,
              o.order_purchase_timestamp)
BETWEEN 0 AND 5
THEN '0-5 Days'
WHEN DATEDIFF(o.order_delivered_customer_date,
              o.order_purchase_timestamp)
BETWEEN 6 AND 10
THEN '6-10 Days'
WHEN DATEDIFF(o.order_delivered_customer_date,
              o.order_purchase_timestamp)
BETWEEN 11 AND 15
THEN '11-15 Days'
ELSE '15+ Days'
END AS delivery_time,
AVG(r.review_score) AS avg_review_score
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
ON o.order_id=r.order_id
WHERE o.order_status='delivered'
GROUP BY delivery_time
ORDER BY delivery_time;

 -- Five-star review percentage
 SELECT COUNT(
CASE
WHEN review_score=5
THEN 1
END
)*100.0/COUNT(*) AS five_star_percentage
FROM olist_order_reviews_dataset;

-- ======================================
-- SELLER PERFORMANCE ANALYSIS
-- ======================================
USE olist_ecommerce;

-- total sellers
SELECT COUNT(DISTINCT seller_id) AS total_sellers
FROM olist_sellers_dataset;

-- top sellers by revenue
SELECT sum(oi.price) AS total_revenue,s.seller_id AS seller_id
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
ON oi.seller_id=s.seller_id
GROUP BY s.seller_id
ORDER BY total_revenue DESC;

-- top sellers by number of orders
SELECT COUNT(DISTINCT order_id) AS number_of_orders, s.seller_id AS seller_id
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
ON oi.seller_id=s.seller_id
GROUP BY s.seller_id
ORDER BY number_of_orders DESC;

-- average product sold per seller
SELECT COUNT(DISTINCT product_id) AS products_sold, seller_id
FROM olist_order_items_dataset
GROUP BY seller_id;

SELECT AVG(products_sold) AS avg_products_per_seller
FROM
(
	SELECT seller_id,COUNT(DISTINCT product_id) AS products_sold
	FROM olist_order_items_dataset
	GROUP BY seller_id
)t;

-- seller performance by state
SELECT s.seller_state, SUM(oi.price) AS total_revenue
FROM olist_sellers_dataset s
JOIN olist_order_items_dataset oi
ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY total_revenue DESC;

-- average delivery time by seller
SELECT s.seller_id,
ROUND(AVG(DATEDIFF(o.order_delivered_customer_date,o.order_purchase_timestamp)),2) 
AS avg_delivery_days
FROM olist_sellers_dataset s
JOIN olist_order_items_dataset oi
ON s.seller_id=oi.seller_id
JOIN olist_orders_dataset o
ON oi.order_id=o.order_id
WHERE o.order_status='delivered'
GROUP BY s.seller_id
ORDER BY avg_delivery_days;

-- seller review score
SELECT s.seller_id, AVG(r.review_score) AS avg_review_score
FROM olist_sellers_dataset s
JOIN olist_order_items_dataset oi
ON oi.seller_id=s.seller_id
JOIN olist_orders_dataset o
ON o.order_id=oi.order_id
JOIN olist_order_reviews_dataset r
ON r.order_id=o.order_id
GROUP BY seller_id
ORDER BY avg_review_score DESC;

-- lowest rated sellers
SELECT s.seller_id, AVG(r.review_score) AS avg_review_score
FROM olist_sellers_dataset s
JOIN olist_order_items_dataset oi
ON oi.seller_id=s.seller_id
JOIN olist_orders_dataset o
ON o.order_id=oi.order_id
JOIN olist_order_reviews_dataset r
ON r.order_id=o.order_id
GROUP BY seller_id
ORDER BY avg_review_score ASC;

-- delayed deliveries by seller
SELECT s.seller_id, COUNT(o.order_id) as delayed_orders
FROM olist_sellers_dataset s
JOIN olist_order_items_dataset oi
ON s.seller_id=oi.seller_id
JOIN olist_orders_dataset o
ON o.order_id=oi.order_id
WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
AND order_status='delivered'
GROUP BY seller_id
ORDER BY delayed_orders DESC;

-- delayed delivery percentage by seller
SELECT s.seller_id,
COUNT(
        CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 1
        END
    ) AS delayed_orders,
COUNT(o.order_id) AS total_orders,
	ROUND(
		COUNT(
            CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            END
        ) * 100.0 /COUNT(o.order_id),2) AS delayed_percentage
FROM olist_sellers_dataset s
JOIN olist_order_items_dataset oi
ON s.seller_id = oi.seller_id
JOIN olist_orders_dataset o
ON oi.order_id = o.order_id
WHERE o.order_status='delivered'
GROUP BY s.seller_id
ORDER BY delayed_percentage DESC;

-- top performing sellers
SELECT s.seller_id,SUM(oi.price) AS total_revenue,
ROUND(AVG(r.review_score),2) AS avg_review_score
FROM olist_sellers_dataset s
JOIN olist_order_items_dataset oi
ON s.seller_id=oi.seller_id
JOIN olist_orders_dataset o
ON oi.order_id=o.order_id
JOIN olist_order_reviews_dataset r
ON o.order_id=r.order_id
GROUP BY s.seller_id
ORDER BY total_revenue DESC,avg_review_score DESC;

-- ==========================================
-- Common Table Expressions 
-- ==========================================

USE olist_ecommerce;
-- Sellers above average revenue
 WITH seller_revenue AS
 (
 SELECT seller_id, SUM(price) AS total_revenue
 FROM olist_order_items_dataset
 GROUP BY seller_id
 )
 SELECT seller_id, total_revenue FROM seller_revenue
 WHERE total_revenue > 
 (
  SELECT AVG(total_revenue) FROM seller_revenue
 )
 ORDER BY total_revenue DESC;
 
 -- Product category above average revenue
 WITH product_category_revenue AS
 (
 SELECT p.product_category_name, SUM(oi.price) AS total_revenue
 FROM olist_order_items_dataset oi
 JOIN olist_products_dataset p
 ON oi.product_id=p.product_id
 GROUP BY p.product_category_name
 )
 SELECT product_category_name, total_revenue FROM product_category_revenue
 WHERE total_revenue >
 (
  SELECT AVG(total_revenue) FROM product_category_revenue
 )
 ORDER BY total_revenue DESC;
 
 -- Monthly revenue above average
 WITH monthly_revenue AS
 (
 SELECT SUM(oi.price) AS total_revenue, 
 date_format(o.order_purchase_timestamp, '%Y-%m') AS months
 FROM olist_order_items_dataset oi
 JOIN olist_orders_dataset o
 ON oi.order_id=o.order_id
 GROUP BY months
 )
 SELECT months, total_revenue FROM monthly_revenue
 WHERE total_revenue >
 (
 SELECT AVG(total_revenue) FROM monthly_revenue
 )
 ORDER BY total_revenue DESC;
 
 
 -- sellers above average orders
 WITH orders_per_seller AS
 (
 SELECT  seller_id, COUNT(DISTINCT order_id) AS total_orders
 FROM olist_order_items_dataset
 GROUP BY seller_id
 )
 SELECT seller_id,total_orders
 FROM orders_per_seller
 WHERE total_orders >
 (
 SELECT AVG(total_orders) 
 FROM orders_per_seller
 )
 ORDER BY total_orders DESC;
 
 -- High value customers
 WITH customer_spending AS
 (
 SELECT c.customer_unique_id, SUM(op.payment_value) AS total_spent
 FROM olist_customers_dataset c
 JOIN olist_orders_dataset o
 ON o.customer_id=c.customer_id
 JOIN olist_order_payments_dataset op
 ON o.order_id=op.order_id
 GROUP BY c.customer_unique_id
 )
 SELECT customer_unique_id,total_spent
 FROM customer_spending
 WHERE total_spent >
 (
 SELECT AVG(total_spent)
 FROM customer_spending
 )
 ORDER BY total_spent DESC;
 
 -- states above average revenue
 WITH state_revenue AS
 (
 SELECT c.customer_state AS state, SUM(oi.price) as total_revenue
 FROM olist_order_items_dataset oi
 JOIN olist_orders_dataset o
 ON o.order_id=oi.order_id
 JOIN olist_customers_dataset c
 ON o.customer_id=c.customer_id
 GROUP BY c.customer_state
 )
 SELECT state, total_revenue 
 FROM state_revenue
 WHERE total_revenue >
 (
 SELECT AVG(total_revenue)
 FROM state_revenue
 )
 ORDER BY total_revenue DESC;
 
 -- High revenue + high review sellers
 WITH seller_revenue AS
 (
 SELECT seller_id, SUM(price) AS total_revenue
 FROM olist_order_items_dataset
 GROUP BY seller_id
 ),
 seller_review AS
 (
 SELECT oi.seller_id, AVG(r.review_score)  AS avg_review
 FROM olist_order_items_dataset oi
 JOIN olist_order_reviews_dataset r 
 ON oi.order_id=r.order_id
 GROUP BY oi.seller_id
 )
 
 SELECT sr.seller_id, sr.total_revenue, rv.avg_review
 FROM seller_revenue sr 
 JOIN seller_review rv
 ON sr.seller_id=rv.seller_id
 WHERE sr.total_revenue >
 (
 SELECT AVG(total_revenue) 
 FROM seller_revenue
 )
 AND
 rv.avg_review >
 (
 SELECT AVG(avg_review) 
 FROM seller_review
 )
 ORDER BY sr.total_revenue DESC;
 
 -- High performing product categories
 WITH category_revenue AS
 (
 SELECT p.product_category_name AS product_category, SUM(oi.price) AS total_revenue
 FROM olist_products_dataset p
 JOIN olist_order_items_dataset oi
 on p.product_id=oi.product_id
 GROUP BY product_category
 ),
 
 category_review AS
 (
 SELECT p.product_category_name AS product_category, AVG(r.review_score) AS review_score
 FROM olist_products_dataset p
 JOIN olist_order_items_dataset oi
 ON oi.product_id=p.product_id
 JOIN olist_order_reviews_dataset r
 ON r.order_id=oi.order_id
 GROUP BY product_category
 )
 SELECT revenue.product_category, revenue.total_revenue, review.review_score
 FROM category_revenue revenue
 JOIN category_review review
 ON revenue.product_category=review.product_category
 WHERE revenue.total_revenue >
 (
 SELECT AVG(total_revenue)
 FROM category_revenue
 )
 AND review.review_score >
 (
 SELECT AVG(review_score)
 FROM category_review
 )
 ORDER BY revenue.total_revenue DESC;
 
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