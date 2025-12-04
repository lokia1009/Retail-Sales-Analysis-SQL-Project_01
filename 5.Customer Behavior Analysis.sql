-- =============================================================================================================================================
-- Customer Behavior Analysis
-- =============================================================================================================================================
-- 10. Who are the top 10 highest spending customers? (based on AOV)

WITH high_spending_cus AS (
SELECT customer_id
       , SUM(total_sale) AS total_spent
       , COUNT(1) AS orders
       , ROUND(AVG(total_sale),2) AS avg_order_value
FROM retail_sales
GROUP BY customer_id
),
ranked_cus AS (
SELECT 
	customer_id
    , total_spent
    , orders
    , avg_order_value
    , DENSE_RANK() OVER( ORDER BY avg_order_value DESC) AS rn
FROM high_spending_cus
)
SELECT 
	customer_id
    , total_spent
    , orders
    , avg_order_value
FROM ranked_cus
WHERE rn <= 10
;
-- 11. Average spending per customer by gender.

WITH cust AS (
  SELECT 
	customer_id
    , gender
    , SUM(total_sale) AS cust_total
  FROM retail_sales
  GROUP BY customer_id, gender
)
SELECT 
	gender
	, ROUND(AVG(cust_total),2) AS avg_spend_per_customer
	, SUM(cust_total) AS total_revenue
FROM cust
GROUP BY gender;

-- 12. What age group contributes the highest revenue?
	-- Example buckets: 18–25, 26–35, 36–50, 50+.
WITH revenue_age_group AS (
SELECT
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        WHEN age > 50 THEN '50+'
        ELSE 'Unknown'
    END AS age_group
    , SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY age_group
),
ranked_age_group AS (
SELECT 
	*
    , DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS rn
FROM revenue_age_group
)
SELECT 
	age_group
    , total_revenue
FROM ranked_age_group
WHERE rn = 1
;
-- 13. RFM Analysis (Recency, Frequency, Monetary) using SQL window functions.

WITH rfm AS (
SELECT
	customer_id
	-- Recency: days since last purchase
	, DATEDIFF(
		(SELECT MAX(sale_date) FROM retail_sales),	-- snapshot date
		MAX(sale_date)								-- customer's last purchase
		) AS recency
	-- Frequency: number of purchases
	, COUNT(*) AS frequency
	-- Monetary: total revenue from this customer
	, SUM(total_sale) AS monetary
FROM retail_sales
GROUP BY customer_id
)
SELECT *
FROM rfm
ORDER BY monetary DESC;

-- 14. Find repeat customers vs one-time customers.

SELECT
    customer_id
    , gender
    , COUNT(*) AS purchase_count
    , CASE
        WHEN COUNT(*) = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type
FROM retail_sales
GROUP BY 
	customer_id
    , gender
ORDER BY purchase_count DESC
;

