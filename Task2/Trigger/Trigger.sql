CREATE DATABASE SampleOrders;

USE SampleOrders;

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(50),
    UnitsInStock INT
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

INSERT INTO Products (ProductID, ProductName, UnitsInStock)
VALUES
(1, 'Oreo', 100),
(2, 'Cake', 50),
(3, 'Brownie', 10);

SET IDENTITY_INSERT Orders ON;

INSERT INTO Orders (OrderID, OrderDate)
VALUES
(1, GETDATE()),
(2, GETDATE());

INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
VALUES
(1, 1, 5),
(1, 2, 10),
(2, 3, 5);

SELECT * FROM Products;

SELECT * FROM Orders;

SELECT * FROM OrderDetails;
GO
CREATE TRIGGER trg_DeleteOrderWithDetails
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM OrderDetails WHERE OrderID IN (SELECT OrderID FROM DELETED);
    DELETE FROM Orders WHERE OrderID IN (SELECT OrderID FROM DELETED);
END;

GO
CREATE TRIGGER trg_CheckStockBeforeInsert
ON OrderDetails
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @ProductID INT, @OrderID INT, @Quantity INT, @Stock INT;

    SELECT @ProductID = ProductID, @OrderID = OrderID, @Quantity = Quantity FROM INSERTED;

    SELECT @Stock = UnitsInStock FROM Products WHERE ProductID = @ProductID;

    IF @Stock IS NULL OR @Stock < @Quantity
    BEGIN
        PRINT 'Insufficient stock. Order cannot be placed.';
        RETURN;
    END

    -- Insert into OrderDetails
    INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
    SELECT OrderID, ProductID, Quantity FROM INSERTED;

    -- Update Product Stock
    UPDATE Products
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID;
END;
GO

INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES (2, 1, 10);
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES (2, 3, 100);



DELETE FROM Orders WHERE OrderID = 1;