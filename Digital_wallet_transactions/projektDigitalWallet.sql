-- Link to dataset:
-- https://www.kaggle.com/datasets/harunrai/digital-wallet-transactions/data


-- Adding a column with only date

ALTER TABLE ProjektDigitalWallet..digital_wallet_transactions ADD tr_date DATE;
UPDATE ProjektDigitalWallet..digital_wallet_transactions
SET tr_date = CONVERT(DATE, transaction_date);

-- Data i will use

Select *
From ProjektDigitalWallet..digital_wallet_transactions
order by 3

-- Finding out fee percentage for every sale

Select tr_date, product_category, product_name, merchant_name, product_amount, transaction_fee, (transaction_fee/product_amount)*100 as [fee_percentage(%)]
From ProjektDigitalWallet..digital_wallet_transactions
order by 7 DESC


-- Checking which device have highest fees

SELECT device_type, AVG(transaction_fee/product_amount) as [fee_percentage_mean(%)]
FROM ProjektDigitalWallet..digital_wallet_transactions
GROUP BY device_type
ORDER by 2 DESC

-- Finding out cashback percentage for every sale

Select tr_date, product_category, product_name, merchant_name, product_amount, cashback, (cashback/product_amount)*100 as [cashback_percentage(%)]
From ProjektDigitalWallet..digital_wallet_transactions
order by 7 DESC

-- Getting sum of all sales every day

Select tr_date,  SUM(product_amount) as sum_of_amount
From ProjektDigitalWallet..digital_wallet_transactions
group by tr_date
order by 1

-- Getting sum of all sales for every category 

Select product_category,  SUM(product_amount) as sum_of_amount
From ProjektDigitalWallet..digital_wallet_transactions
group by product_category
order by 2 desc

-- Checking how many transactions was successfully

SELECT COUNT(*) AS success_count
FROM ProjektDigitalWallet..digital_wallet_transactions
WHERE transaction_status = 'Successful'


-- Checking succes ratio for every device type and every payment method 

SELECT device_type, payment_method,(CAST(COUNT(CASE WHEN transaction_status = 'Successful' THEN 1 END) AS FLOAT) / COUNT(*)*100) AS [success_ratio(%)]
FROM ProjektDigitalWallet..digital_wallet_transactions
GROUP BY device_type, payment_method
ORDER BY 1,2

-- Checking number of sales for every merchant

SELECT merchant_name, COUNT(*) AS number_of_transactions
FROM ProjektDigitalWallet..digital_wallet_transactions
GROUP BY merchant_name
ORDER BY 2 DESC

-- Checking sum of all sales by day of the week

SELECT DATEPART(WEEKDAY, tr_date) AS day_of_week, ROUND(SUM(product_amount),2) AS sum_of_transactions_per_week_day
FROM ProjektDigitalWallet..digital_wallet_transactions
GROUP BY DATEPART(WEEKDAY, tr_date)
order by 1

-- Checking number of transactions and sum of all sales for every product type and every product name

SELECT product_category, product_name, COUNT(product_amount) AS Number_of_transactions, SUM(product_amount) as sum_of_transactions
FROM ProjektDigitalWallet..digital_wallet_transactions
GROUP BY product_category, product_name
order by 1

-- Checking number of transactions and sum of all sales for every device type and every payment method

SELECT device_type, payment_method, count(*) AS Number_of_transactions, SUM(product_amount) as sum_of_transactions
FROM ProjektDigitalWallet..digital_wallet_transactions
GROUP BY device_type, payment_method
order by 4

-- Checking number of sales for every individual merchant

SELECT merchant_name, merchant_id, count(*) AS number_of_transactions
FROM ProjektDigitalWallet..digital_wallet_transactions
GROUP BY merchant_name, merchant_id
order by 3 desc


-- Checking number of sales by hour and location

SELECT 
    DATEPART(HOUR, transaction_date) AS hour_of_day,
    [location],
    COUNT(*) AS numbers_of_transactions
FROM ProjektDigitalWallet..digital_wallet_transactions
GROUP BY DATEPART(HOUR, transaction_date), [location]
ORDER BY 1,2

--Checking number of sales by product category and product name where percentage fee is higher than 5%

SELECT product_category, product_name, count(*) AS number_of_transactions
FROM ProjektDigitalWallet..digital_wallet_transactions
WHERE (transaction_fee/product_amount)>0.005
GROUP BY product_category, product_name
ORDER BY 1,2

--Checking sum of sales by product category and product name where device type is iOS

SELECT product_category, product_name, SUM(transaction_fee) AS sum_of_fees
FROM ProjektDigitalWallet..digital_wallet_transactions
WHERE device_type LIKE 'iOS'
GROUP BY product_category, product_name
ORDER BY 1,3 DESC

-- Finding out monthly change for sum of all sales

WITH monthly_revenue AS (
    SELECT 
        DATEADD(MONTH, DATEDIFF(MONTH, 0, tr_date), 0) AS month,  
        ROUND(SUM(product_amount),2) AS total_revenue  
    FROM 
        ProjektDigitalWallet..digital_wallet_transactions
    GROUP BY 
        DATEADD(MONTH, DATEDIFF(MONTH, 0, tr_date), 0)  
)
SELECT 
    month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY month) AS previous_month_revenue,
    ROUND(total_revenue - LAG(total_revenue) OVER (ORDER BY month),2) AS revenue_growth
FROM 
    monthly_revenue;

