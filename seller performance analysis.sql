-- ======================================
-- SELLER PERFORMANCE ANALYSIS
-- ======================================
use olist_ecommerce;

-- total sellers
SELECT count(distinct seller_id) as total_sellers
from olist_sellers_dataset;

-- top sellers by revenue
SELECT sum(oi.price) as total_revenue,s.seller_id as sellers
from olist_order_items_dataset oi
join olist_sellers_dataset s
on oi.seller_id=s.seller_id
group by s.seller_id
order by total_revenue desc;

-- top sellers by number of orders
SELECT count(distinct order_id) as number_of_orders, s.seller_id as sellers
from olist_order_items_dataset oi
join olist_sellers_dataset s
on oi.seller_id=s.seller_id
group by s.seller_id
order by number_of_orders desc;

-- average revenue per seller
Select s.seller_id, sum(oi.price) as total_revenue from olist_sellers_dataset s
join olist_order_items_dataset oi
on s.seller_id=oi.seller_id
group by seller_id;

-- average product sold per seller
SELECT count(distinct product_id) as products_sold, seller_id
from olist_order_items_dataset
group by seller_id;

SELECT avg(products_sold) AS avg_product_per_seller
FROM
(
	SELECT seller_id,count(distinct product_id) AS products_sold
	from olist_order_items_dataset
	GROUP BY seller_id
)t;

-- seller performance by state
select s.seller_state, sum(oi.price) as total_revenue
FROM olist_sellers_dataset s
JOIN olist_order_items_dataset oi
ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY total_revenue DESC;

-- average delivery time by seller
Select s.seller_id,
round(avg(datediff(o.order_delivered_customer_date,o.order_purchase_timestamp)),2) 
as avg_delivery_days
from olist_sellers_dataset s
join olist_order_items_dataset oi
on s.seller_id=oi.seller_id
join olist_orders_dataset o
on oi.order_id=o.order_id
where o.order_status='delivered'
group by s.seller_id
order by avg_delivery_days;

-- seller review score
SELECT s.seller_id, AVG(r.review_score) as avg_review_score
from olist_sellers_dataset s
join olist_order_items_dataset oi
on oi.seller_id=s.seller_id
join olist_orders_dataset o
on o.order_id=oi.order_id
join olist_order_reviews_dataset r
on r.order_id=o.order_id
group by seller_id
order by avg_review_score desc;

-- lowest rated sellers
SELECT s.seller_id, AVG(r.review_score) as avg_review_score
from olist_sellers_dataset s
join olist_order_items_dataset oi
on oi.seller_id=s.seller_id
join olist_orders_dataset o
on o.order_id=oi.order_id
join olist_order_reviews_dataset r
on r.order_id=o.order_id
group by seller_id
order by avg_review_score asc;

-- delayed deliveries by seller
SELECT s.seller_id, count(o.order_id) as delayed_orders
from olist_sellers_dataset s
join olist_order_items_dataset oi
on s.seller_id=oi.seller_id
join olist_orders_dataset o
on o.order_id=oi.order_id
where o.order_delivered_customer_date > o.order_estimated_delivery_date
and order_status='delivered'
group by seller_id
order by delayed_orders desc;

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
