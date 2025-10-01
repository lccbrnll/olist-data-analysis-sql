/*
===================================================================
|                                                                 |
|   EXPLORATORY DATA ANALYSIS FILE - OLIST E-COMMERCE             |
|   AUTHOR: Lucca                                                 |
|   DATE: 2025-10-01                                              |
|                                                                 |
===================================================================
*/


/*
-------------------------------------------------
|   Section 1: Revenue and Sales Analysis       |
-------------------------------------------------
*/

-- Question 1.A: What is the total monthly revenue?
SELECT TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS year_month, ROUND(SUM(p.payment_value),2) AS total_revenue
FROM orders AS o
INNER JOIN order_payments AS p ON o.order_id = p.order_id
-- Considering revenue only for 'delivered' orders, as this represents the completed sales cycle.
WHERE o.order_status = 'delivered'
-- Groups all payment values by the extracted year and month.
GROUP BY year_month
ORDER BY year_month;


-- Question 1.B: What is the average revenue per order?
-- Using a CTE to calculate the total value for each individual order first.
WITH order_revenue AS (
	SELECT order_id, SUM(payment_value) AS total_per_order
	FROM order_payments
	GROUP BY order_id
)
-- With the list of totals for each order, we can now calculate the overall average.
SELECT ROUND(AVG(total_per_order),2) AS avg_revenue_per_order
FROM order_revenue;


-- Question 1.C: Which day of the week has the highest sales volume?
-- I tackled this in two different ways. The first one that came to mind was this "simple" version below.
-- "Simple" version:
SELECT TRIM(TO_CHAR(order_purchase_timestamp,'day')) AS day_of_week, COUNT(*) AS total_orders
FROM orders
GROUP BY day_of_week
ORDER BY total_orders DESC
LIMIT 1;

-- In the approach below, I used EXTRACT to get the number of the day of the week and then "translated" it to a readable name using a CASE statement.
-- More "robust" version:
SELECT
    CASE EXTRACT(DOW FROM order_purchase_timestamp)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_of_week, COUNT(*) AS total_orders
FROM orders
GROUP BY EXTRACT(DOW FROM order_purchase_timestamp)
ORDER BY total_orders DESC;


/*
-----------------------------------------------
|   Section 2: Product Analysis               |
-----------------------------------------------
*/

-- Question 2.A: What are the top 10 best-selling product categories?
SELECT product_category_name, COUNT(*) AS total_sold
FROM order_items AS oi
INNER JOIN products AS p
ON p.product_id = oi.product_id
GROUP BY product_category_name
ORDER BY total_sold DESC
LIMIT 10;


-- Question 2.B: Which categories have the best average review score?
-- There's a common pitfall here. The query below was my first attempt, and it returns the categories with the highest average score. However, if a product gets just one 5-star review, it might show up at the top.
SELECT product_category_name,ROUND(AVG(review_score),2) AS avg_score
FROM order_reviews AS reviews
INNER JOIN order_items AS o
ON reviews.order_id = o.order_id
INNER JOIN products AS p
ON o.product_id = p.product_id
GROUP BY product_category_name
ORDER BY avg_score DESC
LIMIT 3;

-- For a more reliable analysis, and to prevent categories with few reviews from skewing the results, I added a filter to only consider categories with more than 20 reviews.
SELECT product_category_name,ROUND(AVG(review_score),2) AS avg_score, COUNT(r.review_id) AS total_reviews
FROM order_reviews AS r
INNER JOIN order_items AS oi
ON r.order_id = oi.order_id
INNER JOIN products AS p
ON oi.product_id = p.product_id
WHERE p.product_category_name IS NOT NULL
GROUP BY product_category_name
HAVING COUNT(r.review_id) > 20
ORDER BY avg_score DESC
LIMIT 5;


/*
------------------------------------------------------
|   Section 3: Customer and Logistics Analysis       |
------------------------------------------------------
*/

-- Question 3.A: Which states do most customers come from?
SELECT customer_state, COUNT(customer_state) AS customer_count
FROM customers
GROUP BY customer_state
ORDER BY customer_count DESC
LIMIT 5;


-- Question 3.B: What is the average time between purchase and delivery for different regions?
-- This query calculates the overall average delivery time:
-- I converted the timestamp columns to date format to ignore hours and minutes in the calculation.
SELECT ROUND(AVG(CAST(order_delivered_customer_date AS DATE) - CAST(order_purchase_timestamp AS DATE))) AS overall_avg_delivery_time_days
FROM orders
-- Considered only orders that were effectively delivered.
WHERE order_status = 'delivered'
-- Ensures the calculation doesn't fail due to null values.
AND order_delivered_customer_date IS NOT NULL
AND order_purchase_timestamp IS NOT NULL;

-- This query calculates the average delivery time for each state:
SELECT c.customer_state, AVG(CAST(o.order_delivered_customer_date AS DATE) - CAST(o.order_purchase_timestamp AS DATE)) AS avg_delivery_time
FROM orders AS o
INNER JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY avg_delivery_time DESC;


/*
-------------------------------------------------
|   Section 4: Payment Analysis                 |
-------------------------------------------------
*/

-- Question 4.A: What are the most used payment methods?
SELECT payment_type, COUNT(*) AS total_uses
FROM order_payments
GROUP BY payment_type
ORDER BY total_uses DESC;


-- Question 4.B: What is the average number of installments per purchase?
SELECT ROUND(AVG(payment_installments),2) AS avg_installments
FROM order_payments
-- Installment analysis is only applicable to credit card payments.
WHERE payment_type = 'credit_card';
