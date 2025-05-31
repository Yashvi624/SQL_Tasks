USE AdventureWorks2022;

/* STORED PROCEDURES */

/*InsertOrderDetails*/
GO

CREATE OR ALTER PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT,
    @Discount FLOAT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentStock INT;
    DECLARE @ReorderPoint INT;
    DECLARE @DefaultUnitPrice MONEY;

    SELECT 
        @CurrentStock = pi.Quantity,
        @ReorderPoint = p.ReorderPoint,
        @DefaultUnitPrice = p.ListPrice
    FROM Production.Product p
    JOIN Production.ProductInventory pi ON p.ProductID = pi.ProductID
    WHERE p.ProductID = @ProductID;

    IF @CurrentStock IS NULL
    BEGIN
        PRINT 'Invalid Product ID.';
        RETURN;
    END

    IF @UnitPrice IS NULL
    BEGIN
        SET @UnitPrice = @DefaultUnitPrice;
    END

    IF @CurrentStock < @Quantity
    BEGIN
        PRINT 'Not enough stock. Order aborted.';
        RETURN;
    END
    INSERT INTO Sales.SalesOrderDetail (
        SalesOrderID,
        ProductID,
        OrderQty,
        UnitPrice,
        UnitPriceDiscount,
        SpecialOfferID,
        rowguid,
        ModifiedDate
    )
    VALUES (
        @OrderID,
        @ProductID,
        @Quantity,
        @UnitPrice,
        @Discount,
        1,  
        NEWID(),
        GETDATE()
    );

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    
    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @Quantity
    WHERE ProductID = @ProductID;

    SELECT @CurrentStock = Quantity
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID;

    IF @CurrentStock < @ReorderPoint
    BEGIN
        PRINT 'Warning: Stock is below reorder level!';
    END

    PRINT 'Order placed successfully.';
END;
GO
EXEC InsertOrderDetails @OrderID = 75123, @ProductID = 776, @Quantity = 2;

SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID = 75123;

/*UpdateOrderDetails*/

GO

CREATE OR ALTER PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount FLOAT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @OldQuantity INT,
        @NewQuantity INT,
        @StockDifference INT,
        @CurrentStock INT;

    
    SELECT 
        @OldQuantity = OrderQty,
        @UnitPrice = ISNULL(@UnitPrice, UnitPrice),
        @Discount = ISNULL(@Discount, UnitPriceDiscount),
        @Quantity = ISNULL(@Quantity, OrderQty)
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    IF @OldQuantity IS NULL
    BEGIN
        PRINT 'Order not found for the given OrderID and ProductID.';
        RETURN;
    END

    UPDATE Sales.SalesOrderDetail
    SET 
        OrderQty = @Quantity,
        UnitPrice = @UnitPrice,
        UnitPriceDiscount = @Discount,
        ModifiedDate = GETDATE()
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    SET @StockDifference = @OldQuantity - @Quantity;  -- if positive, stock goes up; if negative, stock goes down

    UPDATE pi
    SET pi.Quantity = pi.Quantity + @StockDifference
    FROM Production.ProductInventory pi
    WHERE pi.ProductID = @ProductID;

    SELECT @CurrentStock = Quantity
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID;

    DECLARE @ReorderPoint INT;
    SELECT @ReorderPoint = ReorderPoint FROM Production.Product WHERE ProductID = @ProductID;

    IF @CurrentStock < @ReorderPoint
    BEGIN
        PRINT 'Warning: Stock is below reorder level!';
    END

    PRINT 'Order updated successfully.';
END;
GO
EXEC UpdateOrderDetails @OrderID = 75123, @ProductID = 776, @UnitPrice = 25.00, @Quantity = 3, @Discount = 0.05;
SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID = 75123 AND ProductID = 776;

/*GetOrderDetails*/

GO
CREATE OR ALTER PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 
        FROM Sales.SalesOrderDetail 
        WHERE SalesOrderID = @OrderID
    )
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist.';
        RETURN 1;
    END

    SELECT 
        sod.SalesOrderID,
        sod.ProductID,
        p.Name AS ProductName,
        sod.OrderQty,
        sod.UnitPrice,
        sod.UnitPriceDiscount,
        sod.LineTotal
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    WHERE sod.SalesOrderID = @OrderID;
END;
GO
EXEC GetOrderDetails @OrderID = 75123;


/*DeleteOrderDetails*/

GO
CREATE OR ALTER PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (
        SELECT 1 
        FROM Sales.SalesOrderDetail
        WHERE SalesOrderID = @OrderID AND ProductID = @ProductID
    )
    BEGIN
        PRINT 'Error: Invalid OrderID or ProductID. The given combination does not exist.';
        RETURN -1;
    END

    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    PRINT 'Order detail successfully deleted.';
END;
GO
EXEC DeleteOrderDetails @OrderID = 75123, @ProductID = 776;
SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID = 75123 AND ProductID = 776;




