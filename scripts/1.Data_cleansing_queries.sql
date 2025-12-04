
-- Data imported to database from local csv file. 

-- ================================  
-- DATA CLEANING
-- ================================

-- --------------------------
-- **** 1) FORMATTING	****
-- --------------------------

DESC retail_sales;  -- The date & time columns are in text type
-- Reformatted inconsistent date and time values into standard SQL formats
UPDATE retail_sales
SET 
	sale_date = STR_TO_DATE(NULLIF(sale_date,''), '%d-%m-%Y') 
    , sale_time = STR_TO_DATE(REPLACE(NULLIF(sale_time,''), '.', ':'), '%H:%i:%s')
;

ALTER TABLE retail_sales
	MODIFY sale_date DATE
	, MODIFY sale_time TIME
;

DESC retail_sales; -- date & time columns are in standard SQL formats

-- -----------------------------------
-- **** 2) DUPLICATES HANDLING	****
-- -----------------------------------

-- Adding duplicate rows across all columns
INSERT INTO retail_sales VALUES
(522, '2022-07-09', '11:00:00',	52, 'Male', 46,	'Beauty', 3, 500, 145, 1500)
, (559, '2022-12-12', '10:48:00',	5, 'Female', 40, 'Clothing', 4, 300, 84, 1200)
;
-- IDENTIFYING DUPLICATES
-- METHOD - 1 
SELECT 
	transactions_id, sale_date, sale_time, customer_id, gender, age, category, quantity, price_per_unit, cogs, total_sale
FROM
	retail_sales
GROUP BY 
	transactions_id, sale_date, sale_time, customer_id, gender, age, category, quantity, price_per_unit, cogs, total_sale
HAVING 
	COUNT(1) > 1
;

-- METHOD - 2
SELECT transactions_id, sale_date, sale_time, customer_id, gender, age, category, quantity, price_per_unit, cogs, total_sale
FROM
	( SELECT 
		rs.*
		, ROW_NUMBER() OVER(PARTITION BY transactions_id, sale_date, sale_time, customer_id, gender, age, category, quantity, price_per_unit, cogs, total_sale ORDER BY transactions_id ) AS rn
	FROM
		retail_sales AS rs
    ) as t1
WHERE rn > 1   
;

-- REMOVING DUPLICATES
-- >> By creating a temporary unique id column

SELECT * FROM retail_sales;  -- 1989 Rows with duplicates

ALTER TABLE retail_sales
ADD COLUMN temp_unique_id INT PRIMARY KEY AUTO_INCREMENT; -- CREATING TEMP COLUMN 

DELETE FROM retail_sales
WHERE temp_unique_id IN (
	SELECT temp_unique_id
	FROM
		( SELECT 
			rs.*
			, ROW_NUMBER() OVER(PARTITION BY transactions_id, sale_date, sale_time, customer_id, gender, age, category, quantity, price_per_unit, cogs, total_sale ORDER BY temp_unique_id ) AS rn
		FROM
			retail_sales AS rs
		) AS t1
	WHERE rn > 1 
    );

ALTER TABLE retail_sales DROP COLUMN temp_unique_id; -- REMOVING THE TEMP COLUMN 

SELECT * FROM retail_sales; -- 1987 Rows without duplicates

-- ------------------------------
-- ****  3) NULLs HANDLING	****
-- ------------------------------

-- Adding NULL values
INSERT INTO retail_sales VALUES
(52333, '2022-07-09', '11:00:00',	52, NULL, 46,	'Beauty', 3, 500, 145, 1500)
, (55569, '2022-12-12', '10:48:00',	5, 'Female', 40, NULL, 4, 300, 84, 1200);

SELECT * FROM  retail_sales; -- 1989 Rows with NULLs
-- IDENTIFYING NULLS ON EACH COULMN
SELECT * FROM  retail_sales
WHERE 
	transactions_id	IS NULL
    OR
    sale_date IS NULL
    OR
    sale_time IS NULL
    OR
    customer_id IS NULL
    OR
    gender IS NULL
    OR
    age IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    price_per_unit IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL
;

-- REMOVING NULLS
DELETE FROM  retail_sales
WHERE 
	transactions_id	IS NULL
    OR
    sale_date IS NULL
    OR
    sale_time IS NULL
    OR
    customer_id IS NULL
    OR
    gender IS NULL
    OR
    age IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    price_per_unit IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL
;
SELECT * FROM  retail_sales; -- 1987 Rows After Removing NULLs
