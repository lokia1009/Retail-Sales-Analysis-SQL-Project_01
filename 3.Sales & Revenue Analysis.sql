-- =============================================================================================================================================
-- Sales & Revenue Analysis
-- =============================================================================================================================================

SELECT * FROM retail_sales;
-- 1. What is the total revenue, total quantity sold, and total transactions per month?

SELECT 
	DATE_FORMAT(sale_date, '%Y-%m') AS year_mon
    , SUM(total_sale) AS total_revenue
    , SUM(quantity) AS total_quantity_sold
    , COUNT(transactions_id) AS transactions_per_month
FROM retail_sales
GROUP BY year_mon
ORDER BY year_mon
;
-- 2. Identify the highest revenue day of the year.

WITH daily AS (
  SELECT
    YEAR(sale_date) AS yr
    , sale_date
    , SUM(total_sale) AS daily_revenue
  FROM retail_sales
  GROUP BY 
	yr
	, sale_date
),
ranked AS (
  SELECT
    yr
    , sale_date
    , daily_revenue
    , DENSE_RANK() OVER (PARTITION BY yr ORDER BY daily_revenue DESC) AS rn
  FROM daily
)
SELECT 
	yr
    , sale_date
    , daily_revenue
FROM ranked
WHERE rn = 1
;
-- 3. Find the revenue trend (increasing/decreasing) across months.

WITH monthly_revenue AS (
  SELECT 
	DATE_FORMAT(sale_date, '%Y-%m') AS year_mon
	, SUM(total_sale) AS curr_month_revenue
  FROM retail_sales
  GROUP BY year_mon
)
SELECT 
	year_mon
	, curr_month_revenue
	, IFNULL(curr_month_revenue - LAG(curr_month_revenue) OVER (ORDER BY year_mon),0) AS diff_from_prev_month
	, CONCAT(IFNULL(ROUND((curr_month_revenue - LAG(curr_month_revenue) OVER (ORDER BY year_mon)) / IFNULL(LAG(curr_month_revenue) OVER (ORDER BY year_mon),0) * 100,2),0),'%')AS pct_change
FROM monthly_revenue
ORDER BY year_mon
;
-- 4. Which hour of the day has the highest sales volume?

SELECT 
	sale_hour
    , revenue
    , units_sold
FROM (
  SELECT 
	HOUR(sale_time) AS sale_hour
	, SUM(total_sale)  AS revenue
	, SUM(quantity)    AS units_sold
	, DENSE_RANK() OVER (ORDER BY SUM(total_sale) DESC) AS rn
  FROM retail_sales
  GROUP BY sale_hour
) t
WHERE rn = 1
;
-- 5. What are the top 3 revenue-generating customers?

SELECT 
	customer_id
    , revenue
FROM (
SELECT
	customer_id
    , SUM(total_sale) AS revenue
    , DENSE_RANK() OVER(ORDER BY SUM(total_sale) DESC) AS rn
FROM retail_sales
GROUP BY customer_id) AS t
WHERE rn <= 3
;




