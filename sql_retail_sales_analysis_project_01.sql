-- SQL Retail Sales Analysis -P1

CREATE DATABASE sql_project_p1;
USE sql_project_p1;

-- create table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales(
transactions_id	INT PRIMARY KEY,
sale_date DATE, 
sale_time TIME,
customer_id INT,
gender VARCHAR(10),
age INT,
category VARCHAR(25),	
quantiy INT,
price_per_unit FLOAT,
cogs FLOAT, 
total_sale FLOAT 
);
DESC retail_sales;
SELECT * FROM retail_sales
LIMIT 10;

-- DATA CLEANING

SELECT DISTINCT *  FROM retail_sales;

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
    quantiy IS NULL
    OR
    price_per_unit IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;

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
    quantiy IS NULL
    OR
    price_per_unit IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;

-- DATA EXPLORATION
-- How many sales we have ?
SELECT 
	COUNT(*) AS total_sales 
FROM 
	retail_sales;

-- How many unique customers we have?
SELECT  
	COUNT(DISTINCT customer_id ) AS unique_customers
FROM 
	retail_sales;

-- How many category we have?
SELECT DISTINCT category FROM retail_sales;

SELECT COUNT(DISTINCT category) AS total_category FROM retail_sales;


-- Data Analysis & Business Key Problems & Answers
-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'

SELECT * 
FROM 
	retail_sales
WHERE 
	sale_date = '2022-11-05';
	
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022

SELECT 
	transactions_id
FROM 
	retail_sales
WHERE 
	category='Clothing' AND 
    quantity >=4  AND 
    sale_date = STR_TO_DATE('Nov-2022', '%b-%Y');

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT 
	category,
    SUM(total_sale) AS total_sale
FROM
	retail_sales
GROUP BY 
	category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT 
	ROUND(AVG(age),2) as avg_age
FROM retail_sales
WHERE 
	category = 'Beauty';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT 
	transactions_id
FROM 
	retail_sales
WHERE 
	total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT 
	category,
    gender,
    COUNT(transactions_id) AS count
FROM 
	retail_sales 
GROUP BY
	category,
    gender
ORDER BY 
	category ,
    gender ;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

SELECT 
	year,
	month,
    avg_sale
FROM
		(SELECT
			EXTRACT(YEAR FROM sale_date)AS year,
			EXTRACT(MONTH FROM sale_date) AS month,
			ROUND(AVG(total_sale),2) AS avg_sale,
			DENSE_RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rk
		FROM
			retail_sales
		GROUP BY 
			EXTRACT(YEAR FROM sale_date),
			EXTRACT(MONTH FROM sale_date)) AS t1
	WHERE 
		rk=1;
	
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales.

SELECT 
	customer_id,
	total_sale
FROM
	(SELECT 
		customer_id,
		SUM(total_sale) as total_sale,
		DENSE_RANK() OVER(ORDER BY SUM(total_sale) DESC) AS rk
	FROM
		retail_sales
	GROUP BY 
		customer_id) AS t1
WHERE 
	rk <=5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT 
	category,
    COUNT(DISTINCT customer_id) AS no_of_customers
FROM 
	retail_sales
GROUP BY
	category;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

SELECT
CASE
WHEN HOUR(sale_time) <=12 THEN 'Morning'
WHEN HOUR(sale_time) <=17 THEN 'Afternoon'
ELSE 'Evening'
END AS shift,
count(customer_id)  AS 'count'
FROM
	retail_sales
GROUP BY
	shift;






