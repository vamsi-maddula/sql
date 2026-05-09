create database windows
use windows;

create table 
Customers (
    CustomerID VARCHAR(10),
    CustomerName VARCHAR(50),
    Region VARCHAR(50)
);

INSERT INTO Customers VALUES
('C001','Harry','UK'),
('C002','Mike','USA'),
('C003','Mithun','India'),
('C004','Jenny','UK'),
('C005','Adlof','Germany');
select * from Customers;

CREATE TABLE Orders (
    OrderID VARCHAR(10),
    CustomerID VARCHAR(10),
    OrderDate DATE
);

INSERT INTO Orders VALUES
('O101','C001','2024-01-05'),
('O102','C002','2024-01-10'),
('O103','C001','2024-02-03'),
('O104','C003','2024-02-15'),
('O105','C001','2024-03-01'),
('O106','C002','2024-03-12'),
('O107','C004','2024-03-20'),
('O108','C003','2024-04-05');
select * from Orders;


CREATE TABLE Transactions (
    TransactionID VARCHAR(10),
    OrderID VARCHAR(10),
    Amount DECIMAL(10,2)
);

INSERT INTO Transactions VALUES
('T001','O101',500),
('T002','O102',800),
('T003','O103',1200),
('T004','O104',400),
('T005','O105',1500),
('T006','O106',700),
('T007','O107',200),
('T008','O108',600);

select * from Transactions;

# Using CTE to create a table which joins three table 

with Basesales as(
               select 
			   O.OrderID,
			   O.OrderDate,
			   C.CustomerID,
			   C.CustomerName,
			   C.Region,
			   T.Amount
      From Orders O JOIN Transactions T  ON O.OrderID = T.OrderID JOIN Customers C ON O.CustomerID = C.CustomerID
)
select * from Basesales;


# Ranking  ( Customers by revenue  )
with Basesales as(
               select 
			   O.OrderID,
			   O.OrderDate,
			   C.CustomerID,
			   C.CustomerName,
			   C.Region,
			   T.Amount
      From Orders O JOIN Transactions T  ON O.OrderID = T.OrderID JOIN Customers C ON O.CustomerID = C.CustomerID
),
CustomerRevenue as(
             SELECT
			  CustomerID,
			  CustomerName,
			  SUM(Amount) as TotalRevenue
			  FROM Basesales Group by CustomerID,CustomerName
)
SELECT *, RANK() OVER(ORDER BY TotalRevenue DESC) AS RevenueRank
FROM CustomerRevenue;

#  Running  Tool (cumulative Revenue over time)

with Basesales as(
               select 
			   O.OrderID,
			   O.OrderDate,
			   C.CustomerID,
			   C.CustomerName,
			   C.Region,
			   T.Amount
      From Orders O JOIN Transactions T  ON O.OrderID = T.OrderID JOIN Customers C ON O.CustomerID = C.CustomerID
)
Select
  OrderDate,
  Sum(Amount) as DailyRevenue,
  Sum(Sum(Amount)) OVER (Order by OrderDate ROWS UNBOUNDED PRECEDING) AS RunningRevenue  'calculating every row adding into next day record'
  From Basesales
  Group by OrderDate
  Order by OrderDate;

# MONTH on MONTH revenue (MOM) 

with Basesales as(
               select 
			   O.OrderID,
			   O.OrderDate,
			   C.CustomerID,
			   C.CustomerName,
			   C.Region,
			   T.Amount
      From Orders O JOIN Transactions T  ON O.OrderID = T.OrderID JOIN Customers C ON O.CustomerID = C.CustomerID
),
MontlyRevenue as(
     select 
	 Year(OrderDate) as YEAR,
	 Month(OrderDate) as MONTH,
	 sum(Amount) as Revenue
From Basesales Group by Year(OrderDate), Month(OrderDate)
)
Select * from MontlyRevenue Order by YEAR,MONTH; 

# Customer Purchase sequence 


with Basesales as(
               select 
			   O.OrderID,
			   O.OrderDate,
			   C.CustomerID,
			   C.CustomerName,
			   C.Region,
			   T.Amount
      From Orders O JOIN Transactions T  ON O.OrderID = T.OrderID JOIN Customers C ON O.CustomerID = C.CustomerID
)
select
CustomerID,
CustomerName,
OrderDate,
ROW_NUMBER() OVER( PARTITION BY CustomerID order by OrderDate) AS Purchasesequence
from Basesales 
Order by CustomerID,CustomerName;

# First Purchase Date

with Basesales as(
               select 
			   O.OrderID,
			   O.OrderDate,
			   C.CustomerID,
			   C.CustomerName,
			   C.Region,
			   T.Amount
      From Orders O JOIN Transactions T  ON O.OrderID = T.OrderID JOIN Customers C ON O.CustomerID = C.CustomerID
)
select 
CustomerID,
CustomerName,
MIN(OrderDate) as FirstPurchase
from Basesales group by CustomerID,CustomerName;

# Last Purchase Date


with Basesales as(
               select 
			   O.OrderID,
			   O.OrderDate,
			   C.CustomerID,
			   C.CustomerName,
			   C.Region,
			   T.Amount
      From Orders O JOIN Transactions T  ON O.OrderID = T.OrderID JOIN Customers C ON O.CustomerID = C.CustomerID
)
select 
CustomerID,
CustomerName,
Max(OrderDate) as LastPurchase
from Basesales group by CustomerID,CustomerName;

# Previous Month revenue


with Basesales as(
               select 
			   O.OrderID,
			   O.OrderDate,
			   C.CustomerID,
			   C.CustomerName,
			   C.Region,
			   T.Amount
      From Orders O JOIN Transactions T  ON O.OrderID = T.OrderID JOIN Customers C ON O.CustomerID = C.CustomerID
),

MonthlyRevenue AS (
    SELECT
        YEAR(OrderDate) AS YEAR,
        MONTH(OrderDate) AS MONTH,
        SUM(Amount) AS Revenue
    FROM Basesales
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
Select YEAR, MONTH, Revenue, LAG(Revenue) over( order by YEAR, MONTH) AS PreviousMonthRevenue
From MonthlyRevenue;

# Revenue change % 


with Basesales as(
               select 
			   O.OrderID,
			   O.OrderDate,
			   C.CustomerID,
			   C.CustomerName,
			   C.Region,
			   T.Amount
      From Orders O JOIN Transactions T  ON O.OrderID = T.OrderID JOIN Customers C ON O.CustomerID = C.CustomerID
),

MonthlyRevenue AS (
    SELECT
        YEAR(OrderDate) AS YEAR,
        MONTH(OrderDate) AS MONTH,
        SUM(Amount) AS Revenue
    FROM Basesales
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
Select YEAR, MONTH, Revenue, LAG(Revenue) over( order by YEAR, MONTH) AS PreviousMonthRevenue,
((Revenue - LAG(Revenue) over(order by YEAR,MONTH)) / NULLIF(LAG(Revenue) over(order by YEAR, MONTH),0)) * 100 AS Revenuechangeper 
FROM MonthlyRevenue;

# Rollling Revenue 

with Basesales as(
               select 
			   O.OrderID,
			   O.OrderDate,
			   C.CustomerID,
			   C.CustomerName,
			   C.Region,
			   T.Amount
      From Orders O JOIN Transactions T  ON O.OrderID = T.OrderID JOIN Customers C ON O.CustomerID = C.CustomerID
),

MonthlyRevenue AS (
    SELECT
        YEAR(OrderDate) AS YEAR,
        MONTH(OrderDate) AS MONTH,
        SUM(Amount) AS Revenue
    FROM Basesales
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
Select YEAR, MONTH,Revenue, AVG(Revenue) over (order by YEAR,MONTH ) as Rollingaverage from MonthlyRevenue;

# KPIs


with Basesales as(
               select 
			   O.OrderID,
			   O.OrderDate,
			   C.CustomerID,
			   C.CustomerName,
			   C.Region,
			   T.Amount
      From Orders O JOIN Transactions T  ON O.OrderID = T.OrderID JOIN Customers C ON O.CustomerID = C.CustomerID
)
SELECT
    COUNT(DISTINCT OrderID) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    SUM(Amount) AS TotalRevenue,
    AVG(Amount) AS AvgOrderValue
FROM BaseSales;


