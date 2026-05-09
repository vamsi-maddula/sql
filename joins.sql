use db;
select name from sys.tables;
CREATE TABLE Customers (
    CustomerID VARCHAR(10) PRIMARY KEY,
    CustomerName VARCHAR(50),
    Region VARCHAR(50)
);

INSERT INTO Customers VALUES
('C001', 'Alice', 'UK'),
('C002', 'Bob', 'USA'),
('C003', 'Charlie', 'India'),
('C004', 'Diana', 'UK'),
('C005', 'Ethan', 'Germany');

CREATE TABLE Orders (
    OrderID VARCHAR(10) PRIMARY KEY,
    CustomerID VARCHAR(10),
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

INSERT INTO Orders VALUES
('O101', 'C001', '2024-01-10'),
('O102', 'C002', '2024-01-12'),
('O103', 'C003', '2024-01-15'),
('O104', 'C001', '2024-02-01');

CREATE TABLE Payments (
    PaymentID VARCHAR(10) PRIMARY KEY,
    OrderID VARCHAR(10),
    PaymentStatus VARCHAR(20),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

INSERT INTO Payments VALUES
('P9001', 'O101', 'Paid'),
('P9002', 'O102', 'Paid');

CREATE TABLE Categories (
    CategoryID VARCHAR(10) PRIMARY KEY,
    CategoryName VARCHAR(50)
);

INSERT INTO Categories VALUES
('CAT01', 'Electronics'),
('CAT02', 'Accessories');


CREATE TABLE Products (
    ProductID VARCHAR(10) PRIMARY KEY,
    ProductName VARCHAR(50),
    CategoryID VARCHAR(10),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

INSERT INTO Products VALUES
('P01', 'Laptop', 'CAT01'),
('P02', 'Mouse', 'CAT02'),
('P03', 'Keyboard', NULL),
('P04', 'Monitor', 'CAT01');


CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID VARCHAR(10),
    ProductID VARCHAR(10),
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

INSERT INTO OrderItems (OrderID, ProductID, Quantity) VALUES
('O101','P01',1),
('O101','P02',2),
('O102','P03',1),
('O103','P04',1);


CREATE TABLE Transactions (
    TransactionID VARCHAR(10) PRIMARY KEY,
    InvoiceNo VARCHAR(20),
    OrderID VARCHAR(10),
    Amount DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

INSERT INTO Transactions VALUES
('T001', 'INV1001', 'O101', 1200),
('T002', 'INV1002', 'O102', 50),
('T003', 'INV1002', 'O102', 50),  
('T004', 'INV1003', 'O103', 700);


CREATE TABLE Settlements (
    SettlementID VARCHAR(10) PRIMARY KEY,
    InvoiceNo VARCHAR(20),
    SettlementDate DATE
);

INSERT INTO Settlements VALUES
('S5001', 'INV1001', '2024-01-11'),
('S5002', 'INV1002', '2024-01-13');


SELECT name FROM sys.tables;

# Customers + order join

select * from Customers;
select * from Orders;
SELECT * from Customers C INNER JOIN Orders O ON C.CustomerID = O.CustomerID;

# Orders + product JOIN

SELECT * FROM Orders;
SELECT * FROM Products;

SELECT
    O.OrderID,
    P.ProductName,
    OI.Quantity
FROM Orders O
INNER JOIN OrderItems OI
    ON O.OrderID = OI.OrderID
INNER JOIN Products P
    ON OI.ProductID = P.ProductID;


# Products + Categories 
select * from products;
select * from Categories;

SELECT ProductName, CategoryName FROM Products P Inner JOIN  Categories C ON P.CategoryID = C.CategoryID;

# Transcation + Payment status join

SELECT * FROM Transactions;
Select * from Payments;
select TransactionID, Amount, PaymentStatus FROM Transactions T INNER JOIN Payments P ON T.OrderID = P.OrderID;

# Left JOIN for missing records 

select * from Products P left join OrderItems OI on P.OrderID = OI.OrderID;

Select * from Orders;

Select * from Payments;

Select * from Categories;

Select * from Products;

Select * from Transactions;

Select * from Settlements;

Select * from OrderItems;

Select * from Customers;

# Anti join logic for unmatched reccords

SELECT T.InvoiceNo FROM Transactions T LEFT JOIN Settlements S
    ON T.InvoiceNo = S.InvoiceNo
WHERE S.InvoiceNo IS NULL;


# Never ordered
SELECT
    C.CustomerID,
    C.CustomerName,
    C.Region
FROM Customers C
LEFT JOIN Orders O
    ON C.CustomerID = O.CustomerID
WHERE O.OrderID IS NULL;

# orders not having matching records 

SELECT
    O.OrderID,
    O.OrderDate
FROM Orders O
LEFT JOIN Payments P
    ON O.OrderID = P.OrderID
WHERE P.OrderID IS NULL;

# Products sold but missing category mapping 

SELECT
    ProductID,
    ProductName
FROM Products
WHERE CategoryID IS NULL;

# Transaction are duplicated
select 
    InvoiceNo,
    COUNT(*) AS DuplicateCount
FROM Transactions
GROUP BY InvoiceNo
HAVING COUNT(*) > 1;

# No matching records invoice & settlements 
SELECT
    T.InvoiceNo
FROM Transactions T
LEFT JOIN Settlements S
    ON T.InvoiceNo = S.InvoiceNo
WHERE S.InvoiceNo IS NULL;
