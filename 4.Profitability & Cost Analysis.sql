-- =============================================================================================================================================
-- Profitability & Cost Analysis
-- =============================================================================================================================================
-- 6. What is the gross profit (total_sale – cogs) by category? # cogs -> Cost of Goods Sold

SELECT category
       , SUM(total_sale - cogs) AS gross_profit
       , SUM(total_sale) AS total_revenue
       , SUM(cogs) AS total_cogs
FROM retail_sales
GROUP BY category
ORDER BY gross_profit DESC
;
-- 7. Which category has the best profit margin percentage?
	-- ((total_sale - cogs) / total_sale) * 100

WITH profit_margin AS (
SELECT category
       , SUM(total_sale) AS revenue
       , SUM(total_sale - cogs) AS profit
       , CONCAT(ROUND(SUM(total_sale - cogs) / NULLIF(SUM(total_sale),0) * 100, 2),'%') AS profit_margin_pct
FROM retail_sales
GROUP BY category
),
ranked_profit_margin AS (
SELECT 
	category
    , revenue
    , profit
    , profit_margin_pct
    , DENSE_RANK() OVER(ORDER BY profit_margin_pct DESC) AS rn
FROM profit_margin
)
SELECT 
	category
    , revenue
    , profit
    , profit_margin_pct
FROM ranked_profit_margin
WHERE rn = 1
;
-- 8. Identify loss-making transactions.

SELECT rs.*
FROM retail_sales as rs
WHERE (quantity * cogs) > total_sale
;
-- 9. Compute the rolling 7-day revenue using window functions.

WITH daily AS (
  SELECT 
	sale_date
	, SUM(total_sale) AS daily_revenue
  FROM retail_sales
  GROUP BY sale_date
)
SELECT sale_date
       , daily_revenue
       , SUM(daily_revenue) OVER (ORDER BY sale_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_7d_revenue
FROM daily
;




