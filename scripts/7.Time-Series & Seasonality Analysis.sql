-- =============================================================================================================================================
-- Time-Series & Seasonality
-- =============================================================================================================================================
-- 18. Find weekday vs weekend sales performance.

SELECT
    CASE 
        WHEN DAYOFWEEK(sale_date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type
    , COUNT(*) AS total_transactions
    , SUM(total_sale) AS total_revenue
    , ROUND(AVG(total_sale), 2) AS avg_sale_per_transaction
FROM retail_sales
GROUP BY day_type
;
-- 19. Find week-over-week sales growth.

WITH weekly_sales AS (
    SELECT
        YEARWEEK(sale_date, 3) AS year_week
        , SUM(total_sale) AS weekly_revenue
    FROM retail_sales
    GROUP BY year_week
)
SELECT
    year_week
    , weekly_revenue
    , prev_week_revenue
    , ROUND(
        (weekly_revenue - prev_week_revenue)
        / NULLIF(prev_week_revenue, 0) * 100, 2
    ) AS wow_growth_percent
FROM (
    SELECT
        year_week
        , weekly_revenue
        , LAG(weekly_revenue) OVER (ORDER BY year_week) AS prev_week_revenue
    FROM weekly_sales
) t
ORDER BY year_week
;

-- 20. Identify seasonal patterns (e.g., November spike).
-- Month-wise revenue for all years
SELECT
    MONTH(sale_date) AS month_num
    , DATE_FORMAT(sale_date, '%M') AS month_name
    , SUM(total_sale) AS monthly_revenue
    , COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY 
	month_num
    , month_name
ORDER BY month_num
;

-- year & month-wise revenue
SELECT
    DATE_FORMAT(sale_date, '%Y-%m') AS year_months
    , SUM(total_sale) AS monthly_revenue
FROM retail_sales
GROUP BY year_months
ORDER BY year_months
;




