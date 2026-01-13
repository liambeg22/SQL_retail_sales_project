-- SQL Retain Sales Analysis -- P1
CREATE DATABASE sql_project_p1;

--Create TABLE--
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
(
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(15),
	age INT,
	category VARCHAR(15),
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
	);



SELECT COUNT(*) FROM [sql_project_p1].[dbo].[retail_sales];

SELECT TOP 10 * FROM [sql_project_p1].[dbo].[retail_sales];


-- Data Cleaning 

-- Checking for null values
SELECT * FROM [sql_project_p1].[dbo].[retail_sales]
WHERE 
	transactions_id IS NULL
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
	total_sale IS NULL;

-- Deleting null values
DELETE FROM [sql_project_p1].[dbo].[retail_sales]
WHERE 
	transactions_id IS NULL
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
	total_sale IS NULL;

--Data Exploration
SELECT TOP (10) * FROM [sql_project_p1].[dbo].[retail_sales];

-- How many total sales have we made?
SELECT COUNT(DISTINCT transactions_id) AS total_sale FROM [sql_project_p1].[dbo].[retail_sales];

-- How many unique customers do we have?
SELECT COUNT(DISTINCT customer_id) AS total_sale FROM [sql_project_p1].[dbo].[retail_sales];

--What unique categories are there?
SELECT DISTINCT category as unique_categories FROM [sql_project_p1].[dbo].[retail_sales];

-- Main Business Analysis
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

SELECT * FROM [sql_project_p1].[dbo].[retail_sales]
	WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022

SELECT
	*
FROM [sql_project_p1].[dbo].[retail_sales]
WHERE 
	category = 'Clothing'
	AND
	sale_date >= '2022-11-01' AND sale_date <'2022-12-01'
	AND
	quantity > 3;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT
	category,
	SUM(total_sale) as net_sale,
	COUNT (*) as total_orders
FROM [sql_project_p1].[dbo].[retail_sales]
GROUP BY category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT
	AVG(age) as average_age
FROM [sql_project_p1].[dbo].[retail_sales]
WHERE
	category = 'Beauty';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT
	*
FROM [sql_project_p1].[dbo].[retail_sales]
WHERE
	total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT 
	gender,
	category,
	COUNT(transactions_id) as Total_transactions
FROM [sql_project_p1].[dbo].[retail_sales]
GROUP BY 
	gender,
	category
ORDER BY category;

-- Q.7 Write a SQL query to calculate the average sales for each month. Find out best selling month in each year

-- Calculating average sale for each month

SELECT
    YEAR(sale_date)  AS sales_year,
    MONTH(sale_date) AS sales_month,
    AVG(total_sale)  AS avg_monthly_sale
FROM [sql_project_p1].[dbo].[retail_sales]
GROUP BY
    YEAR(sale_date),
    MONTH(sale_date)
ORDER BY
    sales_year,
    sales_month;

-- Best selling month by year

SELECT * FROM 
(
	SELECT
		YEAR(sale_date)  AS sales_year,
		MONTH(sale_date) AS sales_month,
		AVG(total_sale)  AS avg_monthly_sale,
		RANK() OVER (PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) AS rank
	FROM [sql_project_p1].[dbo].[retail_sales]
	GROUP BY
		YEAR(sale_date),
		MONTH(sale_date)
) AS t1
WHERE rank = 1;
	
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT DISTINCT 
	(customer_id),
	SUM(total_sale) AS sales_per_customer
FROM [sql_project_p1].[dbo].[retail_sales]
GROUP BY customer_id
ORDER BY sales_per_customer DESC
OFFSET 0 ROWS
FETCH NEXT 5 ROWS ONLY;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT 
	category,
	COUNT (DISTINCT customer_id) AS unique_customers
FROM [sql_project_p1].[dbo].[retail_sales]
GROUP BY category;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

WITH shift_sales
AS 
(
SELECT *,
	CASE
		WHEN (SELECT DATEPART(HOUR, sale_time) AS sale_hour) <=12 THEN 'Morning'
		WHEN (SELECT DATEPART(HOUR, sale_time) AS sale_hour) BETWEEN 12 AND 17 THEN 'Afternoon'
		WHEN (SELECT DATEPART(HOUR, sale_time) AS sale_hour) >17 THEN 'Evening'
	END AS shift
FROM [sql_project_p1].[dbo].[retail_sales]
)
SELECT
	shift,
	COUNT(*) AS total_orders
FROM shift_sales
GROUP BY shift;

-- End of project questions

-- My additional questions 

--What is our average cost per unit sold?

SELECT SUM(cogs)/SUM(quantity) FROM [sql_project_p1].[dbo].[retail_sales];

--What is our average price per unit sold?

SELECT SUM(price_per_unit)/SUM(quantity) FROM [sql_project_p1].[dbo].[retail_sales];

--What is our average return per unit?

SELECT
	(SELECT SUM(price_per_unit)/SUM(quantity) FROM [sql_project_p1].[dbo].[retail_sales]) -
	(SELECT SUM(cogs)/SUM(quantity) FROM [sql_project_p1].[dbo].[retail_sales])
AS avg_return;