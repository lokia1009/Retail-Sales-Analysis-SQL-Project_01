-- =============================================================================================================================================
-- Category Performance
-- =============================================================================================================================================
-- 15. Find the fastest-growing category month over month.
-- Use:
	-- SUM(total_sale)
	-- LAG()
	-- Percentage growth formula

WITH monthly_sales AS (
  SELECT
    category
    , DATE_FORMAT(sale_date, '%Y-%m') AS sale_month
    , SUM(total_sale) AS monthly_revenue
  FROM retail_sales
  GROUP BY 
	category
    , sale_month
)
SELECT
  category
  , sale_month
  , monthly_revenue
  , prev_month_revenue
  , IFNULL(ROUND((monthly_revenue - prev_month_revenue) / (prev_month_revenue) * 100, 2), 0) AS pct_growth
FROM (
  SELECT
    category
    , sale_month
    , monthly_revenue
    , IFNULL(LAG(monthly_revenue) OVER (PARTITION BY category ORDER BY sale_month),0) AS prev_month_revenue
  FROM monthly_sales
) t
ORDER BY sale_month DESC
;
-- 16. Which category has the highest average selling price?

WITH avg_selling_price AS (
SELECT
  category
  , ROUND(AVG(price_per_unit), 2) AS avg_selling_price
  , COUNT(*) AS transactions -- optional: shows sample size
FROM retail_sales
GROUP BY category
),
ranked AS (
SELECT 
	category
    , avg_selling_price
    , transactions
    , DENSE_RANK() OVER(ORDER BY avg_selling_price DESC) AS rn
FROM avg_selling_price
)
SELECT 
	category
    , avg_selling_price
    , transactions
FROM ranked
WHERE rn = 1
;

-- 17. Which category is most popular among each gender?

WITH gender_cat AS (
  SELECT
    gender
    , category
    , SUM(quantity) AS total_units_sold
  FROM retail_sales
  GROUP BY 
	gender
    , category
)
SELECT 
	gender
    , category AS most_popular_category
    , total_units_sold
FROM (
  SELECT
    gender
    , category
    , total_units_sold
    , DENSE_RANK() OVER (PARTITION BY gender ORDER BY total_units_sold DESC) AS rn
  FROM gender_cat
) t
WHERE rn = 1
;


