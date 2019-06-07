USE TechStacks

----------------------------------------------- STORED PROCEDURES -----------------------------------------------

--- Stored Procedure 1: Insert new item into tblSUPPLIER
Go
CREATE PROCEDURE uspNewSupplier
@SName varchar(30),
@SDesc varchar(500)
AS

BEGIN TRAN T1
INSERT INTO tblSUPPLIER (SupplierName, SupplierDesc)
VALUES (@SName, @SDesc)

IF @@ERROR <> 0
ROLLBACK TRAN T1
ELSE
COMMIT TRAN T1

--- Stored Procedure 2: Insert new item into tblLINE_ITEM

-- GetProductID
Go
CREATE PROCEDURE GetProductID
@ProdName varchar(30),
@ProductID INT OUTPUT
AS
SET @ProductID = (SELECT ProductID FROM tblPRODUCT WHERE ProductName = @ProdName)

-- GetConditionID
Go
CREATE PROCEDURE GetConditionID
@Con varchar(30),
@ConditionID INT OUTPUT
AS
SET @ConditionID = (SELECT ConditionID FROM tblCONDITION WHERE Condition = @Con)

-- GetServiceID
Go
CREATE PROCEDURE GetServiceID
@ServName varchar(30),
@ServiceID INT OUTPUT
AS
SET @ServiceID = (SELECT ServiceID FROM tblSERVICE WHERE ServiceName = @ServName)

-- GetOrderID
Go
CREATE PROCEDURE GetOrderID
@OrdDate date,
@CustID int, 
@OrdTID int, 
@OrderID INT OUTPUT
AS
SET @OrderID = (SELECT OrderID FROM tblORDER WHERE CustomerID = @CustID AND OrderTypeID = @OrdTID AND OrderDate = @OrdDate)

-- GetDiscountID
Go
CREATE PROCEDURE GetDiscountID
@DiscName varchar(30), 
@DiscountID INT OUTPUT
AS
SET @DiscountID = (SELECT DiscountID FROM tblDISCOUNT WHERE DiscountName = @DiscName)

-- uspNewLineItem
Go
CREATE PROCEDURE uspNewLineItem
@PName varchar(30),
@C varchar(30),
@SName varchar(30),
@ODate date,
@CuID int, 
@OTID int,
@DName varchar(30),
@Q int
AS

DECLARE @PID INT
DECLARE @CID INT
DECLARE @SID INT
DECLARE @OID INT
DECLARE @DID INT

EXECUTE GetProductID
@ProdName = @PName,
@ProductID = @PID OUTPUT

EXECUTE GetConditionID
@Con = @C,
@ConditionID = @CID OUTPUT

IF @CID IS NULL
BEGIN
PRINT 'Condition ID cannot be NULL'
RAISERROR ('Condition ID is NULL', 11,1)
RETURN
END

EXECUTE GetServiceID
@ServName = @SName,
@ServiceID = @SID OUTPUT

EXECUTE GetOrderID
@OrdDate = @ODate,
@CustID = @CuID, 
@OrdTID = @OTID, 
@OrderID = @OID OUTPUT

IF @OID IS NULL
BEGIN
PRINT 'Order ID cannot be NULL'
RAISERROR ('Order ID is NULL', 11,1)
RETURN
END

EXECUTE GetDiscountID
@DiscName = @DName,
@DiscountID = @DID OUTPUT

BEGIN TRAN T1
INSERT INTO tblLINE_ITEM (ProductID, ConditionID, ServiceID, OrderID, DiscountID, Quantity)
VALUES (@PID, @CID, @SID, @OID, @DID, @Q)

IF @@ERROR <> 0
ROLLBACK TRAN T1
ELSE
COMMIT TRAN T1

------------------------------------------------ BUSINESS RULES ------------------------------------------------

--- Rule 1: No discount can be greater than the price of a lineitem
GO
CREATE FUNCTION fnDiscountPriceLimit()
RETURNS INT
AS
BEGIN 
DECLARE @return int = 1
  IF EXISTS (
    SELECT * FROM tblLINE_ITEM L 
		JOIN tblPRODUCT P ON L.ProductID = P.ProductID
		JOIN tblSERVICE S ON L.ServiceID = S.ServiceID
		JOIN tblDISCOUNT D ON D.DiscountID = L.DiscountID
	WHERE (S.ServicePrice * L.Quantity) > D.DeductAmount OR 
		  (P.Price * L.Quantity) > D.DeductAmount)
	SET @return = 0
RETURN @return
END

GO
ALTER TABLE tblLINE_ITEM
	ADD CONSTRAINT fnDiscount_PriceLimit
	CHECK (dbo.fnDiscountPriceLimit() = 1)

--- Rule 2: No employee shift can be longer than 12 hours
GO
CREATE FUNCTION fnEmpShift()
RETURNS INT
AS
BEGIN 
DECLARE @return int = 1
  IF EXISTS (
    SELECT * FROM tblJOB_SHIFT
	WHERE Datediff(Hour, EndTime, StartTime) > 12)
	SET @return = 0
RETURN @return
END

GO
ALTER TABLE tblJOB_SHIFT
	ADD CONSTRAINT fn_EmpShift
	CHECK (dbo.fnEmpShift() = 1)

----------------------------------------------- COMPUTED COLUMNS -----------------------------------------------

--- Column 1: Calculate the number of sales made till date for a given product type
GO
CREATE FUNCTION fnProdTypeSales(@PK INT)
RETURNS INT
AS
BEGIN
DECLARE @return int = (
	SELECT Count(LineItemID)
        FROM tblLINE_ITEM L
		JOIN tblPRODUCT P on P.ProductID = L.ProductID
		JOIN tblPRODUCT_TYPE PT on P.ProductTypeID = PT.ProductTypeID
        WHERE PT.ProductTypeID = @PK
		GROUP BY ProductTypeName)
RETURN @return
END

GO
ALTER TABLE tblPRODUCT_TYPE
	ADD ProductTypeSales AS (dbo.fnProdTypeSales(ProductTypeID))

--- Column 2: Calculate the number of sales made by an employee
GO
CREATE FUNCTION fnEmpSales(@PK INT)
RETURNS INT
AS
BEGIN
DECLARE @return int = (
	SELECT Count(OrderID)
        FROM tblORDER O
		JOIN tblJOB_SHIFT JS on JS.JobShiftID = O.JobShiftID
		JOIN tblJOB J on J.JobID = JS.JobID
		JOIN tblEMPLOYEE E on J.EmployeeID = E.EmployeeID
        WHERE E.EmployeeID = @PK)
RETURN @return
END

GO
ALTER TABLE tblEMPLOYEE
	ADD EmployeeSales AS (dbo.fnEmpSales(EmployeeID))

---------------------------------------------------- VIEWS ----------------------------------------------------

--- Most popular service type bought by customers between the ages of 20 and 30
GO
CREATE VIEW popularServiceType 
AS
SELECT TOP 1 Count(*) AS TotalSales, ST.ServiceTypeName
	FROM tblLINE_ITEM L
	JOIN tblSERVICE S ON L.ServiceID = S.ServiceID
	JOIN tblSERVICE_TYPE ST ON S.ServiceTypeID = ST.ServiceTypeID
	JOIN tblORDER O ON O.OrderID = L.OrderID
	JOIN tblCUSTOMER C ON C.CustomerID = O.CustomerID
	WHERE CustDOB >= GetDate() - (365.25 * 30) AND CustDOB <= GetDate() - (365.25 * 20)	
	GROUP BY ST.ServiceTypeName
	ORDER BY TotalSales DESC 

--- Products ranked by total price penalty charged based on all sales made till date
GO
CREATE VIEW productPricePenalty
AS 
SELECT TOP 10 P.ProductID, P.ProductName, SUM(C.PricePenalty) AS TotalPricePenalty
	FROM tblPRODUCT P
	JOIN tblLINE_ITEM L ON P.ProductID = L.ProductID
	JOIN tblCONDITION C ON L.ConditionID = C.ConditionID
	GROUP BY P.ProductID, P.ProductName, C.ConditionID
	ORDER BY TotalPricePenalty DESC	