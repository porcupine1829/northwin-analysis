-- Query 1: Find the number of orders per country
-- (but only countries with ≥50 orders), ordered by count descending.
SELECT
  c.Country,
  COUNT(o.OrderID) AS OrderCount
FROM Orders o
JOIN Customers c
  ON o.CustomerID = c.CustomerID
GROUP BY
  c.Country
HAVING
  COUNT(o.OrderID) >= 50
ORDER BY
  OrderCount DESC;

-- Query 2: INNER JOIN – list all order details along with the product name
SELECT
  od.OrderID,
  p.ProductName,
  od.Quantity,
  od.UnitPrice
FROM [Order Details] od
INNER JOIN Products p
  ON od.ProductID = p.ProductID
LIMIT 10;

-- Query 3: LEFT JOIN – list every product and, if any, the supplier’s company name
SELECT
  p.ProductName,
  s.CompanyName AS Supplier
FROM Products p
LEFT JOIN Suppliers s
  ON p.SupplierID = s.SupplierID
LIMIT 10;

-- Query 4: RIGHT JOIN (SQLite doesn’t support it natively; emulating by swapping tables and using LEFT):
SELECT
  p.ProductName,
  s.CompanyName AS Supplier
FROM Suppliers s
LEFT JOIN Products p
  ON p.SupplierID = s.SupplierID
LIMIT 10;

-- Query 5: Write a Subquery to find all customers who have placed more orders than the average customer.
SELECT
  CustomerID,
  (SELECT COUNT(*) FROM Orders WHERE CustomerID = c.CustomerID) AS OrdersPlaced
FROM Customers c
WHERE
  (SELECT COUNT(*) FROM Orders WHERE CustomerID = c.CustomerID)
    > (
      SELECT AVG(order_ct)
      FROM (
        SELECT COUNT(*) AS order_ct
        FROM Orders
        GROUP BY CustomerID
      )
    );

-- Query 6: Compute, for each product, the total revenue (SUM) and average quantity per order (AVG)
SELECT
  p.ProductName,
  SUM(od.Quantity * od.UnitPrice)   AS TotalRevenue,
  AVG(od.Quantity)                  AS AvgQtyPerOrder
FROM [Order Details] od
JOIN Products p
  ON od.ProductID = p.ProductID
GROUP BY
  od.ProductID
ORDER BY
  TotalRevenue DESC
LIMIT 10;

--Query 7: Create a view giving each customer’s total number of orders and total spent
CREATE VIEW CustomerStats AS
SELECT
  c.CustomerID,
  c.CompanyName,
  COUNT(o.OrderID) AS OrdersCount,
  SUM(od.Quantity * od.UnitPrice) AS TotalSpent
FROM Customers c
LEFT JOIN Orders o
  ON c.CustomerID = o.CustomerID
LEFT JOIN [Order Details] od
  ON o.OrderID = od.OrderID
GROUP BY
  c.CustomerID;

--Displaying output from the view
SELECT * 
  FROM CustomerStats 
 ORDER BY TotalSpent DESC 
 LIMIT 5;

--Query 8: Speed up lookups on OrderDate in the Orders table using indexes
-- Check if index exists:
PRAGMA index_list('Orders');

-- Create an index on Orders(OrderDate):
CREATE INDEX IF NOT EXISTS idx_orders_orderdate
  ON Orders(OrderDate);

-- Now queries filtering or ordering by OrderDate will use this index:
SELECT OrderID, OrderDate
  FROM Orders
 WHERE OrderDate >= '1997-01-01'
 ORDER BY OrderDate;




