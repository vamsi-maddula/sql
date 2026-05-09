create database cte;
use cte;

CREATE TABLE Customers (
    CustomerID VARCHAR(10),
    CustomerName VARCHAR(50),
    Region VARCHAR(50)
);

INSERT INTO Customers VALUES
('C001', 'Harry', 'UK'),
('C002', 'Alan', 'USA'),
('C003', 'Charlie', 'Brazil'),
('C004', 'Duffy', 'UK');

CREATE TABLE Orders (
    OrderID VARCHAR(10),
    CustomerID VARCHAR(10),
    OrderDate DATE
);

INSERT INTO Orders VALUES
('O101', 'C001', '2024-01-10'),
('O102', 'C002', '2024-01-12'),
('O103', 'C001', '2024-02-05'),
('O104', 'C003', '2024-02-10');

CREATE TABLE Transactions (
    TransactionID VARCHAR(10),
    OrderID VARCHAR(10),
    Amount DECIMAL(10,2)
);

INSERT INTO Transactions VALUES
('T001', 'O101', 1200),
('T002', 'O102', 300),
('T003', 'O103', 800),
('T004', 'O104', -50),   
('T005', 'O104', 700);

# Basic CTE for data cleaning 


with validtransaction as (
         select 
		  TransactionID,OrderID,Amount
		  from Transactions
		  where amount > 0 
)
select * from validtransaction;


# Validation check by using join function 

with validtransaction as (
         select 
		  TransactionID,OrderID,Amount
		  from Transactions
		  where amount > 0 
),
Ordersale as ( 
     select
	O.OrderID, O.CustomerID, O.OrderDate,VT.Amount from Orders O inner JOIN
	validtransaction VT ON O.OrderID = VT.OrderID
)
select * from Ordersale;


# Adding more tables to existing CTE 

with validtransaction as (
         select 
		  TransactionID,OrderID,Amount
		  from Transactions
		  where amount > 0 
),
Ordersale as ( 
     select
	O.OrderID, O.CustomerID, O.OrderDate,VT.Amount from Orders O inner JOIN
	validtransaction VT ON O.OrderID = VT.OrderID
),
CustomerSales as (
         select 
		 C.CustomerName,
		 C.Region,
		 OS.OrderDate,OS.Amount
		 FROM OrderSale OS INNER JOIN Customers C
		 ON OS.CustomerID = C.CustomerID
)
select * from CustomerSales;


# Aggreation BY revenue 

with validtransaction as (
         select 
		  TransactionID,OrderID,Amount
		  from Transactions
		  where amount > 0 
),
Ordersale as ( 
     select
	O.OrderID, O.CustomerID, O.OrderDate,VT.Amount from Orders O inner JOIN
	validtransaction VT ON O.OrderID = VT.OrderID
),
CustomerSales as (
         select 
		 C.CustomerName,
		 C.Region,
		 OS.OrderDate,OS.Amount
		 FROM OrderSale OS INNER JOIN Customers C
		 ON OS.CustomerID = C.CustomerID
),
CustomerRevenue as (
                  select 
				  CustomerName, Region, Sum(Amount) as TotalRevenue
				  From CustomerSales 
				  group by CustomerName,Region 
) 
Select * from CustomerRevenue;



#

with validtransaction as (
         select 
		  TransactionID,OrderID,Amount
		  from Transactions
		  where amount > 0 
),
Ordersale as ( 
     select
	O.OrderID, O.CustomerID, O.OrderDate,VT.Amount from Orders O inner JOIN
	validtransaction VT ON O.OrderID = VT.OrderID
),
CustomerSales as (
         select 
		 C.CustomerName,
		 C.Region,
		 OS.OrderDate,OS.Amount
		 FROM OrderSale OS INNER JOIN Customers C
		 ON OS.CustomerID = C.CustomerID
),
CustomerRevenue as (
                  select 
				  CustomerName, Region, Sum(Amount) as TotalRevenue
				  From CustomerSales 
				  group by CustomerName,Region 
) 
Select * from CustomerRevenue
where TotalRevenue > 1000;

# Analytical Dataset

with validtransaction as (
          select 
		  TransactionID,OrderID,Amount
		  from Transactions
		  where amount > 0 
),
Ordersale as ( 
     select
	 O.OrderID, O.CustomerID, O.OrderDate,VT.Amount from Orders O inner JOIN
	 validtransaction VT ON O.OrderID = VT.OrderID
),
CustomerSales as (
         select 
		 C.CustomerName,
		 C.Region,
		 OS.OrderDate,OS.Amount
		 FROM OrderSale OS INNER JOIN Customers C
		 ON OS.CustomerID = C.CustomerID
),
CustomerRevenue as (
                  select 
				  CustomerName, Region, Sum(Amount) as TotalRevenue
				  From CustomerSales 
				  group by CustomerName,Region 
),
AnalyticsDataset AS (
        SELECT
        OrderDate,
        CustomerName,
        Region,
        SUM(Amount) AS Revenue
        FROM CustomerSales
        GROUP BY OrderDate, CustomerName, Region
)
SELECT *
FROM AnalyticsDataset
ORDER BY OrderDate;


### Montly revenue summary


WITH CleanTransactions AS (
    SELECT OrderID, Amount
    FROM Transactions
    WHERE Amount > 0
),
MonthlyRevenue AS (
        SELECT
        YEAR(O.OrderDate) AS Year,
        MONTH(O.OrderDate) AS Month,
        SUM(CT.Amount) AS Revenue
        FROM Orders O
        JOIN CleanTransactions CT
        ON O.OrderID = CT.OrderID
        GROUP BY YEAR(O.OrderDate), MONTH(O.OrderDate)
)
SELECT *
FROM MonthlyRevenue
ORDER BY Year, Month;


# Customer level performance summary 

WITH CleanTransactions AS (
    SELECT OrderID, Amount
    FROM Transactions
    WHERE Amount > 0
),
CustomerPerformance AS (
    SELECT
        C.CustomerID,
        C.CustomerName,
        COUNT(DISTINCT O.OrderID) AS OrderCount,
        SUM(CT.Amount) AS TotalRevenue
        FROM Customers C
        JOIN Orders O ON C.CustomerID = O.CustomerID
        JOIN CleanTransactions CT ON O.OrderID = CT.OrderID
        GROUP BY C.CustomerID, C.CustomerName
)
SELECT *
FROM CustomerPerformance;

## Regional sales summary 

WITH CleanTransactions AS (
    SELECT OrderID, Amount
    FROM Transactions
    WHERE Amount > 0
),
RegionalSales AS (
        SELECT
        C.Region,
        SUM(CT.Amount) AS Revenue
        FROM Orders O
        JOIN Customers C ON O.CustomerID = C.CustomerID
        JOIN CleanTransactions CT ON O.OrderID = CT.OrderID
        GROUP BY C.Region
)
SELECT *
FROM RegionalSales
ORDER BY Revenue DESC;

# EXception report
SELECT *
FROM Orders
WHERE OrderDate IS NULL OR CustomerID IS NULL;  # THere is no values for our table

# Reconcilation mismatch Report

WITH OrderTotals AS (
        SELECT
        O.OrderID,
        SUM(T.Amount) AS TransactionAmount
        FROM Orders O
        LEFT JOIN Transactions T ON O.OrderID = T.OrderID
        GROUP BY O.OrderID
)
SELECT *
FROM OrderTotals
WHERE TransactionAmount IS NULL OR TransactionAmount <= 0;

# Duplicate transcation report 

SELECT
    OrderID,
    Amount,
    COUNT(*) AS DuplicateCount
    FROM Transactions
    GROUP BY OrderID, Amount
    HAVING COUNT(*) > 1;

# SLA breach report 
WITH OrderPayments AS (
        SELECT
        O.OrderID,
        O.OrderDate,
        MIN(T.TransactionID) AS FirstTransaction
        FROM Orders O
        JOIN Transactions T ON O.OrderID = T.OrderID
        GROUP BY O.OrderID, O.OrderDate
)
SELECT *
FROM OrderPayments WHERE DATEDIFF(DAY, OrderDate, GETDATE()) > 2;

# Customer Retention Base table 

WITH FirstOrder AS (
    SELECT
        CustomerID,
        MIN(OrderDate) AS FirstOrderDate
    FROM Orders
    GROUP BY CustomerID
),
RetentionBase AS (
    SELECT
        O.CustomerID,
        F.FirstOrderDate,
        O.OrderDate
    FROM Orders O
    JOIN FirstOrder F
        ON O.CustomerID = F.CustomerID
)
SELECT *
FROM RetentionBase;

# Dashboard ready KPI  TABLE 

WITH KPIs AS (
    SELECT
        COUNT(DISTINCT O.OrderID) AS TotalOrders,
        COUNT(DISTINCT O.CustomerID) AS TotalCustomers,
        SUM(T.Amount) AS TotalRevenue,
        AVG(T.Amount) AS AvgTransactionValue
        FROM Orders O
        JOIN Transactions T
        ON O.OrderID = T.OrderID
        WHERE T.Amount > 0
)
SELECT *
FROM KPIs;

