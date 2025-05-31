USE AdventureWorks2022;
GO
CREATE VIEW vwCustomerOrders AS
SELECT 
    s.Name AS CompanyName, 
    soh.SalesOrderID AS OrderID,
    soh.OrderDate,
    sod.ProductID,
    p.Name AS ProductName,
    sod.OrderQty AS Quantity,
    sod.UnitPrice,
    sod.OrderQty * sod.UnitPrice AS TotalPrice
FROM Sales.Customer c
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID -- only store customers
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID;
GO
SELECT * FROM vwCustomerOrders;


GO
CREATE VIEW vwCustomerOrders_Yesterday AS
SELECT 
    s.Name AS CompanyName, 
    soh.SalesOrderID AS OrderID,
    soh.OrderDate,
    sod.ProductID,
    p.Name AS ProductName,
    sod.OrderQty AS Quantity,
    sod.UnitPrice,
    sod.OrderQty * sod.UnitPrice AS TotalPrice
FROM Sales.Customer c
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID  -- Only store customers
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE CONVERT(date, soh.OrderDate) = CONVERT(date, DATEADD(day, -1, GETDATE()));
GO
SELECT * FROM vwCustomerOrders_Yesterday;


GO
CREATE VIEW MyProducts AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.Size AS QuantityPerUnit, 
    p.ListPrice AS UnitPrice,
    s.Name AS SupplierCompanyName,
    pc.Name AS CategoryName
FROM Production.Product p
JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor s ON pv.BusinessEntityID = s.BusinessEntityID
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE p.DiscontinuedDate IS NULL; 
GO
SELECT * FROM MyProducts;

