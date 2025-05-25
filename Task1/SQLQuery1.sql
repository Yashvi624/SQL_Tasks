USE AdventureWorks2022;

-- List all the customers
SELECT 
    c.CustomerID,
    p.FirstName,
    p.LastName,
    c.StoreID,
    s.Name AS CompanyName
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID;


--List all the customers where company name ends with n 
SELECT 
    c.CustomerID,
    s.Name AS CompanyName
FROM Sales.Customer c
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE s.Name LIKE '%N';

--list of all customers who live in Berlin or London
SELECT DISTINCT
    c.CustomerID,
    p.FirstName,
    p.LastName,
    a.City
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City IN ('Berlin', 'London');

--List of all customers who live in UK or USA 

SELECT DISTINCT
    c.CustomerID,
    p.FirstName,
    p.LastName,
    cr.Name AS Country
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('United Kingdom', 'United States');

-- list of all products sorted by product name 
SELECT 
    ProductID,
    Name AS ProductName,
    ProductNumber,
    Color,
    ListPrice
FROM Production.Product
ORDER BY Name;

-- list of all products where product name starts with an A
SELECT 
    ProductID,
    Name AS ProductName,
    ProductNumber,
    Color,
    ListPrice
FROM Production.Product
WHERE Name LIKE 'A%';

-- List of Customers Who Ever Placed an Order
SELECT DISTINCT
    c.CustomerID,
    p.FirstName,
    p.LastName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID;

-- List of Customers Who Live in London and Have Bought 'Chai' 
SELECT DISTINCT
    c.CustomerID,
    p.FirstName,
    p.LastName,
    a.City,
    pr.Name AS ProductName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City = 'London' AND pr.Name = 'Chai';

-- List of Customers Who Never Placed an Order
SELECT 
    c.CustomerID,
    p.FirstName,
    p.LastName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE soh.SalesOrderID IS NULL;

-- List of Customers Who Ordered Tofu 
SELECT DISTINCT
    c.CustomerID,
    p.FirstName,
    p.LastName,
    pr.Name AS ProductName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
WHERE pr.Name = 'Tofu';

-- Details of the First Order in the System
SELECT TOP 1 *
FROM Sales.SalesOrderHeader
ORDER BY OrderDate ASC;

-- Find the Details of the Most Expensive Order Date
SELECT TOP 1 
    SalesOrderID,
    CustomerID,
    OrderDate,
    TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

-- For Each Order, Get the OrderID and Average Quantity of Items in That Order 
SELECT 
    SalesOrderID,
    AVG(OrderQty) AS AverageQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

-- For Each Order, Get the OrderID, Minimum Quantity, and Maximum Quantity for That Order
SELECT 
    SalesOrderID,
    MIN(OrderQty) AS MinQuantity,
    MAX(OrderQty) AS MaxQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

-- Get a List of All Managers and Total Number of Employees Who Report to Them
SELECT 
    mgr.BusinessEntityID AS ManagerID,
    pp.FirstName + ' ' + pp.LastName AS ManagerName,
    COUNT(emp.BusinessEntityID) AS NumberOfReports
FROM HumanResources.Employee emp
JOIN HumanResources.Employee mgr ON emp.OrganizationNode.GetAncestor(1) = mgr.OrganizationNode
JOIN Person.Person pp ON mgr.BusinessEntityID = pp.BusinessEntityID
GROUP BY mgr.BusinessEntityID, pp.FirstName, pp.LastName
ORDER BY NumberOfReports DESC;

-- Get the OrderID and the Total Quantity for Each Order That Has a Total Quantity Greater Than 300
SELECT 
    SalesOrderID,
    SUM(OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;

-- List of All Orders Placed On or After '1996-12-31'
SELECT 
    SalesOrderID,
    OrderDate,
    CustomerID,
    TotalDue
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';

-- List of All Orders Shipped to Canada
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    a.City,
    cr.Name AS Country
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'Canada';

-- List of All Orders With Order Total > 200
SELECT 
    SalesOrderID,
    OrderDate,
    CustomerID,
    TotalDue
FROM Sales.SalesOrderHeader
WHERE TotalDue > 200;

-- List of Countries and Sales Made in Each Country
SELECT 
    cr.Name AS Country,
    SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;

-- List of Customer Contact Name and Number of Orders They Placed
SELECT 
    p.FirstName + ' ' + p.LastName AS ContactName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName
ORDER BY NumberOfOrders DESC;

-- List of Customer Contact Names Who Have Placed More Than 3 Orders
SELECT 
    p.FirstName + ' ' + p.LastName AS ContactName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(soh.SalesOrderID) > 3
ORDER BY NumberOfOrders DESC;

-- List of Discontinued Products Which Were Ordered Between '1997-01-01' and '1998-01-01'
SELECT DISTINCT
    pr.ProductID,
    pr.Name AS ProductName,
    pr.SellEndDate
FROM Production.Product pr
JOIN Sales.SalesOrderDetail sod ON pr.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE pr.SellEndDate IS NOT NULL
  AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

-- List of Employee FirstName, LastName, Supervisor FirstName, LastName
SELECT 
    e.BusinessEntityID AS EmployeeID,
    ep.FirstName AS EmployeeFirstName,
    ep.LastName AS EmployeeLastName,
    sp.FirstName AS SupervisorFirstName,
    sp.LastName AS SupervisorLastName
FROM HumanResources.Employee e
JOIN Person.Person ep ON e.BusinessEntityID = ep.BusinessEntityID
LEFT JOIN HumanResources.Employee s ON e.BusinessEntityID = s.BusinessEntityID
LEFT JOIN Person.Person sp ON s.BusinessEntityID = sp.BusinessEntityID;

-- List of Employee IDs and Total Sales Conducted by Each Employee
SELECT 
    sp.BusinessEntityID AS EmployeeID,
    SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesPerson sp
JOIN Sales.SalesOrderHeader soh ON sp.BusinessEntityID = soh.SalesPersonID
GROUP BY sp.BusinessEntityID
ORDER BY TotalSales DESC;

-- List of Employees Whose FirstName Contains the Character 'a'
SELECT 
    e.BusinessEntityID,
    p.FirstName,
    p.LastName
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.FirstName LIKE '%a%';

-- List of Managers Who Have More Than Four People Reporting to Them
SELECT 
    m.BusinessEntityID AS ManagerID,
    p.FirstName + ' ' + p.LastName AS ManagerName,
    COUNT(e.BusinessEntityID) AS NumOfReports
FROM HumanResources.Employee e
JOIN HumanResources.Employee m ON e.BusinessEntityID = m.BusinessEntityID
JOIN Person.Person p ON m.BusinessEntityID = p.BusinessEntityID
GROUP BY m.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(e.BusinessEntityID) > 4
ORDER BY NumOfReports DESC;

-- List of Orders and Product Names
SELECT 
    sod.SalesOrderID,
    p.Name AS ProductName
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
ORDER BY sod.SalesOrderID;

-- List of Orders Placed by the Best Customer

SELECT *
FROM Sales.SalesOrderHeader
WHERE CustomerID = (
    SELECT TOP 1 CustomerID
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
    ORDER BY SUM(TotalDue) DESC
);

-- List of Orders Placed by Customers Who Do Not Have a Fax Number
SELECT 
    soh.SalesOrderID,
    p.FirstName + ' ' + p.LastName AS CustomerName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.PersonPhone pe ON p.BusinessEntityID = pe.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE pe.PhoneNumber IS NULL OR pe.PhoneNumber = '';

-- List of Postal Codes Where the Product ‘Tofu’ Was Shipped
SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE p.Name = 'Tofu';

-- List of Product Names That Were Shipped to France
SELECT DISTINCT p.Name AS ProductName
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France';

--List of Product Names and Categories for the Supplier 'Specialty Biscuits, Ltd.'
SELECT 
    p.Name AS ProductName,
    pc.Name AS CategoryName
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
WHERE v.Name = 'Specialty Biscuits, Ltd.';

-- List of Products That Were Never Ordered
SELECT 
    p.ProductID,
    p.Name AS ProductName
FROM Production.Product p
WHERE p.ProductID NOT IN (
    SELECT DISTINCT ProductID
    FROM Sales.SalesOrderDetail
);
--List of Products Where Units in Stock < 10 and Units on Order = 0
SELECT 
    p.ProductID,
    p.Name,
    pi.Quantity AS UnitsInStock,
    pi.Shelf
FROM Production.Product p
JOIN Production.ProductInventory pi ON p.ProductID = pi.ProductID
WHERE pi.Quantity < 10;

-- List of Top 10 Countries by Sales
SELECT TOP 10 
    cr.Name AS Country,
    SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;

--Number of Orders Each Employee Has Taken for Customers with CustomerIDs Between 'A' and 'AO'
SELECT 
    soh.SalesPersonID AS EmployeeID,
    COUNT(*) AS NumOfOrders
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE p.LastName BETWEEN 'A' AND 'AO'
GROUP BY soh.SalesPersonID;

-- Order Date of the Most Expensive Order
SELECT TOP 1 
    SalesOrderID,
    OrderDate,
    TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

--Produ ct Name and Total Revenue from That Product
SELECT 
    p.Name AS ProductName,
    SUM(sod.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalRevenue DESC;

-- Supplier ID and Number of Products Offered
SELECT 
    v.BusinessEntityID AS SupplierID,
    COUNT(pv.ProductID) AS NumberOfProducts
FROM Purchasing.Vendor v
JOIN Purchasing.ProductVendor pv ON v.BusinessEntityID = pv.BusinessEntityID
GROUP BY v.BusinessEntityID
ORDER BY NumberOfProducts DESC;

-- Top Ten Customers Based on Their Business (Highest Total Orders)
SELECT TOP 10 
    c.CustomerID,
    SUM(soh.TotalDue) AS TotalSpent
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
ORDER BY TotalSpent DESC;

-- What is the Total Revenue of the Company
SELECT 
    SUM(TotalDue) AS TotalCompanyRevenue
FROM Sales.SalesOrderHeader;
























