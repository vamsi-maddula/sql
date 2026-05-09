use db;

select name from sys.tables;

select * from YEAR;


#Filtering 

SELECT *
FROM YEAR
WHERE Country = 'United Kingdom';

SELECT *
FROM YEAR
WHERE Quantity > 0;

SELECT *
FROM YEAR
WHERE InvoiceDate >= '2009-01-01'
  AND InvoiceDate < '2009-02-01';

# SORTING 
SELECT *
FROM YEAR
ORDER BY InvoiceDate DESC;


SELECT *
FROM YEAR
ORDER BY Quantity DESC;


# AGGREGATION

SELECT SUM(Quantity) AS TotalQuantity
FROM YEAR
WHERE Quantity > 0;

SELECT COUNT(*) AS TotalTransactions
FROM YEAR;

# GROUPING


SELECT Country,
       SUM(Quantity) AS TotalQuantity
FROM YEAR
WHERE Quantity > 0
GROUP BY Country
ORDER BY TotalQuantity DESC;

SELECT StockCode,
       Description,
       SUM(Quantity) AS TotalQuantity
FROM YEAR
WHERE Quantity > 0
GROUP BY StockCode, Description
ORDER BY TotalQuantity DESC;


# CASE WHEN 

SELECT Invoice,
       StockCode,
       Quantity,
       CASE
           WHEN Quantity > 0 THEN 'Sale'
           WHEN Quantity < 0 THEN 'Return'
           ELSE 'Other'
       END AS TransactionType
FROM YEAR;


SELECT Invoice,
       CASE
           WHEN Quantity >= 50 THEN 'Bulk Order'
           WHEN Quantity BETWEEN 10 AND 49 THEN 'Medium Order'
           ELSE 'Small Order'
       END AS OrderSize
FROM YEAR 
WHERE Quantity > 0;

# DATE BASED 
# DAILYSALES 
SELECT CAST(InvoiceDate AS DATE) AS SalesDate,
       SUM(Quantity) AS TotalQuantity
FROM YEAR
WHERE Quantity > 0
GROUP BY CAST(InvoiceDate AS DATE)
ORDER BY SalesDate;

#MONTHLY
SELECT YEAR(InvoiceDate) AS SalesYear,
       MONTH(InvoiceDate) AS SalesMonth,
       SUM(Quantity) AS TotalQuantity
FROM YEAR
WHERE Quantity > 0
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY SalesYear, SalesMonth;

#HOURLY
SELECT DATEPART(HOUR, InvoiceDate) AS SalesHour,
       SUM(Quantity) AS TotalQuantity
FROM YEAR
WHERE Quantity > 0
GROUP BY DATEPART(HOUR, InvoiceDate)
ORDER BY SalesHour;



SELECT Country,
       YEAR(InvoiceDate) AS Year,
       SUM(Quantity * Price) AS Revenue,
       CASE
           WHEN SUM(Quantity * Price) > 10000 THEN 'High'
           ELSE 'Low'
       END AS RevenueCategory
FROM YEAR
WHERE Quantity > 0
GROUP BY Country, YEAR(InvoiceDate)
ORDER BY Revenue DESC;