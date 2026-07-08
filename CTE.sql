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