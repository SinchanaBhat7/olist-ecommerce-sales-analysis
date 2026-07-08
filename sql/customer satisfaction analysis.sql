-- ======================================
-- Customer satisfaction analysis
-- ======================================

USE olist_ecommerce;

--  average review score
SELECT AVG(review_score)
FROM olist_order_reviews_dataset;

-- review score distribution
SELECT  review_score, count(review_id) as total_reviews
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score;

-- positive vs negative reviews
SELECT
	CASE
		when review_score in(4,5) then 'positive'
		When review_score in(1,2) then 'negetive'
		else 'neutral'
	END AS review_category,
	COUNT(*) AS total_reviews
From olist_order_reviews_dataset
group by review_category
order by total_reviews desc;

-- delivery delay and review score
SELECT avg(review_score)
from olist_orders_dataset o
join olist_order_reviews_dataset r
on o.order_id=r.order_id
where o.order_status='delivered'
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
 
 -- review score by delivery time
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

 -- 5 star review percentage
 SELECT COUNT(
CASE
WHEN review_score=5
THEN 1
END
)*100.0/COUNT(*) AS five_star_percentage
FROM olist_order_reviews_dataset;
 
 