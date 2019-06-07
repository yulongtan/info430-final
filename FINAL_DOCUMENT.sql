/*
INFO 430 Final Project - TechStacks

Group 2

- Yulong Tan
- Kianna Hales
- Denny Wang
- Sruthi Dikkala
*/

-- create database techstacks_v2
-- use techstacks_v2

-- use master
-- drop database techstacks_v2

CREATE TABLE tblSUPPLIER
(
  SupplierID int IDENTITY(1,1) Primary Key NOT NULL,
  SupplierName varchar(30) NOT NULL,
  SupplierDesc varchar(500) NOT NULL
)

GO
CREATE TABLE tblPRODUCT_TYPE
(
  ProductTypeID int IDENTITY(1,1) Primary Key NOT NULL,
  ProductTypeName varchar(30) NOT NULL,
  ProductTypeDesc varchar(500) NOT NULL
)

GO
CREATE TABLE tblPRODUCT
(
  ProductID int IDENTITY(1,1) Primary Key NOT NULL,
  ProductTypeID int FOREIGN KEY REFERENCES tblPRODUCT_TYPE(ProductTypeID) NOT NULL,
  SupplierID int FOREIGN KEY REFERENCES tblSUPPLIER(SupplierID) NOT NULL,
  ProductName varchar(30) NOT NULL,
  ProductDesc varchar(500) NOT NULL,
  Price money NOT NULL
)

GO
CREATE TABLE tblCUSTOMER
(
  CustomerID int IDENTITY(1,1) Primary Key NOT NULL,
  CustFName varchar(50) NOT NULL,
  CustLName varchar(50) NOT NULL,
  CustDOB date NOT NULL,
  CustAddress varchar(50) NOT NULL,
  CustCity varchar(50) NOT NULL,
  CustState varchar(50) NOT NULL,
  CustZip varchar(50) NOT NULL
)

GO
CREATE TABLE tblORDER_TYPE
(
  OrderTypeID int IDENTITY(1,1) Primary Key NOT NULL,
  OrderTypeName varchar(30) NOT NULL,
  OrderTypeDesc varchar(500) NOT NULL
)

GO
CREATE TABLE tblEMPLOYEE
(
  EmployeeID int IDENTITY(1,1) Primary Key NOT NULL,
  EmpFName varchar(30) NOT NULL,
  EmpLName varchar(30) NOT NULL,
  EmpDOB date NOT NULL,
  EmpAddress varchar(30) NOT NULL,
  EmpCity varchar(30) NOT NULL,
  EmpState varchar(2) NOT NULL,
  EmpZip varchar(5) NOT NULL
)

GO
CREATE TABLE tblPOSITION
(
  PositionID int IDENTITY(1,1) Primary Key NOT NULL,
  PositionName varchar(30) NOT NULL,
  PositionDesc varchar(500) NOT NULL
)

GO
CREATE TABLE tblJOB
(
  JobID int IDENTITY(1,1) Primary Key NOT NULL,
  EmployeeID int FOREIGN KEY REFERENCES tblEMPLOYEE(EmployeeID) NOT NULL,
  PositionID int FOREIGN KEY REFERENCES tblPOSITION(PositionID) NOT NULL,
  Salary money NOT NULL,
  StartDate date NOT NULL,
  EndDate date
)

GO
CREATE TABLE tblSHIFT
(
  ShiftID int IDENTITY(1,1) Primary Key NOT NULL,
  ShiftName varchar(30) NOT NULL,
  ShiftDesc varchar(500) NOT NULL
)

GO
CREATE TABLE tblJOB_SHIFT
(
  JobShiftID int IDENTITY(1,1) Primary Key NOT NULL,
  ShiftID int FOREIGN KEY REFERENCES tblSHIFT (ShiftID) NOT NULL,
  JobID int FOREIGN KEY REFERENCES tblJOB(JobID) NOT NULL,
  JobShiftDate date NOT NULL,
  StartTime time NOT NULL,
  EndTime time NOT NULL
)

GO
CREATE TABLE tblORDER
(
  OrderID int IDENTITY(1,1) Primary Key NOT NULL,
  CustomerID int FOREIGN KEY REFERENCES tblCUSTOMER (CustomerID) NOT NULL,
  JobShiftID int FOREIGN KEY REFERENCES tblJOB_SHIFT (JobShiftID) NOT NULL,
  OrderTypeID int FOREIGN KEY REFERENCES tblORDER_TYPE (OrderTypeID) NOT NULL,
  OrderDate date NOT NULL
)

GO
CREATE TABLE tblDISCOUNT_TYPE
(
  DiscountTypeID int IDENTITY(1,1) Primary Key NOT NULL,
  DiscountTypeName varchar(50) NOT NULL
)

GO
CREATE TABLE tblDISCOUNT
(
  DiscountID int IDENTITY(1,1) Primary Key NOT NULL,
  DiscountTypeID int FOREIGN KEY REFERENCES tblDISCOUNT_TYPE (DiscountTypeID) NOT NULL,
  DiscountName varchar(30) NOT NULL,
  DiscountDesc varchar(500) NOT NULL,
  DeductAmount int NOT NULL
)

GO
CREATE TABLE tblSERVICE_TYPE
(
  ServiceTypeID int IDENTITY(1,1) Primary Key NOT NULL,
  ServiceTypeName varchar(30) NOT NULL,
  ServiceTypeDesc varchar(500) NOT NULL
)

GO
CREATE TABLE tblSERVICE
(
  ServiceID int IDENTITY(1,1) Primary Key NOT NULL,
  ServiceTypeID int FOREIGN KEY REFERENCES tblSERVICE_TYPE(ServiceTypeID) NOT NULL,
  ServiceName varchar(30) NOT NULL,
  ServicePrice money NOT NULL,
  ServiceDesc varchar(500) NOT NULL
)

GO
CREATE TABLE tblCONDITION
(
  ConditionID int IDENTITY(1,1) Primary Key NOT NULL,
  Condition varchar(30) NOT NULL,
  PricePenalty money NOT NULL
)

GO
CREATE TABLE tblLINE_ITEM
(
  LineItemID int IDENTITY(1,1) Primary Key NOT NULL,
  ProductID int FOREIGN KEY REFERENCES tblPRODUCT(ProductID),
  ConditionID int FOREIGN KEY REFERENCES tblCONDITION(ConditionID) NOT NULL,
  ServiceID int FOREIGN KEY REFERENCES tblSERVICE(ServiceID),
  OrderID int FOREIGN KEY REFERENCES tblORDER(OrderID) NOT NULL,
  DiscountID int FOREIGN KEY REFERENCES tblDISCOUNT(DiscountID),
  Quantity int NOT NULL
)


go

-------------------------------------------- Stored Procedures --------------------------------------------


-- SupplierID
create proc usp_GetSupplierID
  @SupplierName varchar(30),
  @SupplierID int out
as
set @SupplierID = (
  select SupplierID
from tblSUPPLIER
where @SupplierName = SupplierName 
)
go

-- ProductTypeNameID
create proc usp_GetProductTypeID
  @ProductTypeName varchar(30),
  @ProductTypeID int out
as
set @ProductTypeID = (
  select ProductTypeID
from tblPRODUCT_TYPE
where ProductTypeName = @ProductTypeName
)
go

CREATE PROCEDURE uspGetServiceTypeID
  @ServTypeName VARCHAR(30),
  @ServTypeID INT OUTPUT
AS
SET @ServTypeID = (SELECT ServiceTypeID
FROM tblSERVICE_TYPE
WHERE ServiceTypeName = @ServTypeName)
GO

CREATE PROCEDURE uspGetDiscountTypeID
  @DiscTypeName VARCHAR(30),
  @DiscTypeID INT OUTPUT
AS
SET @DiscTypeID = (SELECT DiscountTypeID
FROM tblDISCOUNT_TYPE
WHERE DiscountTypeName = @DiscTypeName)
GO

-- GetEmployeeID
create proc usp_GetEmployeeID
  @EmpFname varchar(30),
  @EmpLname varchar(30),
  @EmpDOB date,
  @EmployeeID int output
as
set @EmployeeID = (
  select EmployeeID
from tblEMPLOYEE
where EmpFname = @EmpFname
  and EmpLname = @EmpLname
  and EmpDOB = @EmpDOB
)
go

-- GetPositionID
create proc usp_GetPositionID
  @PositionName varchar(30),
  @PositionID int output
as
set @PositionID = (select PositionID
from tblPOSITION
where PositionName = @PositionName)
go

CREATE PROCEDURE GetProductID
  @ProdName varchar(30),
  @ProductID INT OUTPUT
AS
SET @ProductID = (SELECT ProductID
FROM tblPRODUCT
WHERE ProductName = @ProdName)

-- GetConditionID
Go
CREATE PROCEDURE GetConditionID
  @Con varchar(30),
  @ConditionID INT OUTPUT
AS
SET @ConditionID = (SELECT ConditionID
FROM tblCONDITION
WHERE Condition = @Con)

-- GetServiceID
Go
CREATE PROCEDURE GetServiceID
  @ServName varchar(30),
  @ServiceID INT OUTPUT
AS
SET @ServiceID = (SELECT ServiceID
FROM tblSERVICE
WHERE ServiceName = @ServName)

-- GetOrderID
Go
CREATE PROCEDURE GetOrderID
  @OrdDate date,
  @CustID int,
  @OrdTID int,
  @OrderID INT OUTPUT
AS
SET @OrderID = (SELECT OrderID
FROM tblORDER
WHERE CustomerID = @CustID AND OrderTypeID = @OrdTID AND OrderDate = @OrdDate)

-- GetDiscountID
Go
CREATE PROCEDURE GetDiscountID
  @DiscName varchar(30),
  @DiscountID INT OUTPUT
AS
SET @DiscountID = (SELECT DiscountID
FROM tblDISCOUNT
WHERE DiscountName = @DiscName)
go

-- 1) Insert a new item into product
create proc usp_InsertNewProduct
  @ProductName varchar(30),
  @ProductDesc varchar(500),
  @ProductTypeName varchar(30),
  @SupplierName varchar(30),
  @Price int
as
declare @PTID int, @SID int

exec usp_GetSupplierID
@SupplierName = @SupplierName,
@SupplierID = @SID output

if @SID is null 
  begin
  print('SupplierID is null')
  raiserror('SupplierID is null', 11, 1)
  return
end

exec usp_GetProductTypeID
@ProductTypeName = @ProductTypeName,
@ProductTypeID = @PTID output

if @PTID is null 
  begin
  print('ProductTypeID is null')
  raiserror('ProductTypeID is null', 11, 1)
  return
end

begin tran t1
insert into tblPRODUCT
  (ProductName, ProductDesc, ProductTypeID, SupplierID, Price)
values(@ProductName, @ProductDesc, @PTID, @SID, @Price)

if @@error <> 0
  rollback tran t1
else 
  commit tran t1

go


-- 2) Insert a new item into Job
create proc usp_InsertNewJob
  @EmpFname varchar(30),
  @EmpLname varchar(30),
  @EmpDOB date,
  @Salary money,
  @StartDate date,
  @EndDate date,
  @PositionName varchar(30)
as
declare @EID int, @PID int

exec usp_GetEmployeeID
@EmpFname = @EmpFname,
@EmpLname = @EmpLname,
@EmpDOB = @EmpDOB,
@EmployeeID = @EID output

if @EID is null 
  begin
  print('EID is null')
  raiserror('EID is null', 11, 1)
  return
end

exec usp_GetPositionID
@PositionName = @PositionName,
@PositionID = @PID output

if @PID is null 
  begin
  print('PID is null')
  raiserror('PID is null', 11, 1)
  return
end

begin tran t1
insert into tblJOB
  (Salary, StartDate, EndDate, EmployeeID, PositionID)
values(@Salary, @StartDate, @EndDate, @EID, @PID)

if @@error <> 0
  rollback tran t1
else 
  commit tran t1
go

CREATE PROCEDURE uspInsertIntoService
  @ServName VARCHAR(30),
  @ServPrice MONEY,
  @ServDesc VARCHAR(500),
  @STName VARCHAR(30)
AS
-- Declare variable(s) --
DECLARE @ST_ID INT
-- Set variable(s) to output --
EXEC uspGetServiceTypeID
@ServTypeName = @STName,
@ServTypeID = @ST_ID OUTPUT
-- Error handling to check if @ST_ID is NULL -- 
IF @ST_ID IS NULL
BEGIN
  RAISERROR('@ST_ID is NULL and the following transaction will fail', 11, 1)
  RETURN
END
-- Explicit transaction to insert into table -- 
BEGIN TRAN G1
INSERT INTO tblSERVICE
  (ServiceTypeID, ServiceName, ServicePrice, ServiceDesc)
VALUES
  (@ST_ID, @ServName, @ServPrice, @ServDesc)
IF @@ERROR <> 0
        ROLLBACK TRAN G1
    ELSE
        COMMIT TRAN G1
GO

CREATE PROCEDURE uspInsertIntoDiscount
  @DiscName VARCHAR(30),
  @DiscDescr VARCHAR(500),
  @DeductAmount INT,
  @DTName VARCHAR(30)
AS
-- Declare variable(s) --
DECLARE @DT_ID INT
-- Set variable(s) to output --
EXEC uspGetDiscountTypeID
@DiscTypeName = @DTName,
@DiscTypeID = @DT_ID OUTPUT
-- Error handling to check if @DT_ID is NULL -- 
IF @DT_ID IS NULL
BEGIN
  RAISERROR('@DT_ID is NULL and the following transaction will fail', 11, 1)
  RETURN
END
-- Explicit transaction to insert into table -- 
BEGIN TRAN G1
INSERT INTO tblDISCOUNT
  (DiscountTypeID, DiscountName, DiscountDesc, DeductAmount)
VALUES
  (@DT_ID, @DiscName, @DiscDescr, @DeductAmount)
IF @@ERROR <> 0
        ROLLBACK TRAN G1
    ELSE
        COMMIT TRAN G1
GO

-- New Customer
CREATE PROCEDURE sp_newCustomer
  @CustFname varchar(30),
  @CustLname varchar(30),
  @CustDOB date,
  @CustAddress varchar(500),
  @CustCity  varchar(30),
  @CustState varchar (30),
  @CustZip int
AS
BEGIN TRAN T1
INSERT INTO tblCUSTOMER
  (CustFname, CustLname, CustDOB, CustAddress, CustCity, CustState, CustZip)
VALUES
  (@CustFname, @CustLname, @CustDOB, @CustAddress, @CustCity, @CustState, @CustZip)
IF @@error <> 0
	ROLLBACK TRAN T1
ELSE
	COMMIT TRAN T1
GO

-- New Order
CREATE PROCEDURE newOrder
  @CustFname varchar(30),
  @CustLname varchar(30),
  @CustDOB date,
  @EmpFname varchar(30),
  @EmpLname varchar(30),
  @PositionName varchar(30),
  @ShiftName varchar(30),
  @OrderTypeName varchar(30)
AS
DECLARE @CustomerID INT, @JobShift INT, @OrderTypeID INT, @ShiftID INT, @JobID INT, @PositionID INT, @EmployeeID INT
SET @CustomerID = (SELECT CustomerID
FROM tblCUSTOMER
WHERE CustFname=@CustFname AND CustLname=@CustLname AND CustDOB=@CustDOB)
SET @OrderTypeID = (SELECT OrderTypeID
FROM tblORDER_TYPE
WHERE OrderTypeName=@OrderTypeName)
IF (@CustomerID IS NULL OR @OrderTypeName IS NULL)
	BEGIN
  PRINT 'Order Parameters Missing'
  RAISERROR ('Cannot process without order parameters', 11,1)
  RETURN
END
SET @EmployeeID=(SELECT EmployeeID
FROM tblEMPLOYEE
WHERE EmpFname=@EmpFname AND @EmpLname=@EmpLname)
SET @PositionID=(SELECT PositionID
FROM tblPOSITION
WHERE PositionName=@PositionName)
SET @ShiftID=(SELECT ShiftID
FROM tblSHIFT
WHERE ShiftName=@ShiftName)
SET @JobShift=(SELECT @JobShift
FROM tblJOB_SHIFT
WHERE JobShiftID = @ShiftID AND JobID = @JobID)
IF @JobShift IS NULL
	BEGIN
  PRINT 'Employee/Position/Shift Parameter Missing'
  RAISERROR ('Cannot process without Employee/Position/Shift parameters', 11,1)
  RETURN
END
BEGIN TRAN T1
INSERT INTO tblORDER
  (CustomerID, JobShiftID, OrderTypeID, OrderDate)
VALUES(@CustomerID, @JobShift, @OrderTypeID, GETDATE())
IF @@error <> 0
		ROLLBACK tran T1
ELSE
		COMMIT tran T1
GO

-- Insert item into Supplier
CREATE PROCEDURE uspNewSupplier
  @SName varchar(30),
  @SDesc varchar(500)
AS

BEGIN TRAN T1
INSERT INTO tblSUPPLIER
  (SupplierName, SupplierDesc)
VALUES
  (@SName, @SDesc)

IF @@ERROR <> 0
ROLLBACK TRAN T1
ELSE
COMMIT TRAN T1
GO

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
INSERT INTO tblLINE_ITEM
  (ProductID, ConditionID, ServiceID, OrderID, DiscountID, Quantity)
VALUES
  (@PID, @CID, @SID, @OID, @DID, @Q)

IF @@ERROR <> 0
ROLLBACK TRAN T1
ELSE
COMMIT TRAN T1
GO


-------------------------------------------- Business Rules --------------------------------------------

-- No product of type “phone” or "tv" may be sold if the condition is "terrible" (yt)
create function fn_NoTerriblePhoneOrTV()
returns int 
as 
begin
  declare @ret int = 1
  if exists (
    select *
  from tblPRODUCT P
    join tblLINE_ITEM LI on P.ProductID = LI.ProductID
    join tblPRODUCT_TYPE PT on P.ProductTypeID = PT.ProductTypeID
    join tblCONDITION C on LI.ConditionID = C.ConditionID
  where C.Condition = 'Terrible'
    and (PT.ProductTypeName = 'Phone' or PT.ProductTypeName = 'TV')
  )
  set @ret = 0
  return @ret
end 
go

alter table tblLINE_ITEM
add constraint CK_NoTerriblePhoneOrTV
check (dbo.fn_NoTerriblePhoneOrTV() = 1)
go

-- No employee can offer the service of "tech repair" within their first month of starting (yt)
create function fn_NoTechRepairFromNewEmployees()
returns int 
as  
begin
  declare @ret int = 1
  if exists (
    select *
  from tblEMPLOYEE E
    join tblJOB J on E.EmployeeID = J.EmployeeID
    join tblJOB_SHIFT EPS on J.JobID = EPS.JobID
    join tblORDER O on EPS.JobShiftID = O.JobShiftID
    join tblLINE_ITEM LI on O.OrderID = LI.OrderID
    join tblSERVICE S on LI.ServiceID = S.ServiceID
    join tblSERVICE_TYPE ST on S.ServiceTypeID = ST.ServiceTypeID
  where ST.ServiceTypeName = 'Tech Repair'
    and J.StartDate < dateadd(m, -1, getdate())
  )
  set @ret = 0
  return @ret
end
go

alter table tblLINE_ITEM
add constraint CK_NoTechRepairFromNewEmployees
check (dbo.fn_NoTechRepairFromNewEmployees() = 1)
go

-- No discount over 50% for ‘NEW’ phones -- 
CREATE FUNCTION fn_NoDiscountOver50ForNewPhones()
RETURNS INT
AS
BEGIN
  DECLARE @Ret INT = 0
  IF EXISTS (SELECT *
  FROM tblDISCOUNT_TYPE DT
    JOIN tblDISCOUNT D ON DT.DiscountTypeID = D.DiscountTypeID
    JOIN tblLINE_ITEM LI ON D.DiscountID = LI.DiscountID
    JOIN tblCONDITION C ON LI.ConditionID = C.ConditionID
    JOIN tblPRODUCT P ON LI.ProductID = P.ProductID
    JOIN tblPRODUCT_TYPE PT ON P.ProductTypeID = PT.ProductTypeID
  WHERE ProductTypeName = 'Phone'
    AND Condition = 'New'
    AND DiscountTypeName = 'Percentage'
    AND DeductAmount > 50)
BEGIN
    SET @Ret = 1
  END
  RETURN @Ret
END
GO

ALTER TABLE tblLINE_ITEM
ADD CONSTRAINT CK_NoDiscountOver50PercentOnNewPhones
CHECK (dbo.fn_NoDiscountOver50ForNewPhones() = 0)
GO

-- All employees must be 16 or older --
CREATE FUNCTION fn_EmployeeMustBeAtLeast16()
RETURNS INT
AS
BEGIN
  DECLARE @Ret INT = 0
  IF EXISTS (SELECT *
  FROM tblEMPLOYEE
  WHERE EmpDOB > (SELECT GETDATE() - (365.25 * 16)))
BEGIN
    SET @Ret = 1
  END
  RETURN @Ret
END
GO

ALTER TABLE tblEMPLOYEE
ADD CONSTRAINT CK_EmployeeAgeMustBeAtLeast16
CHECK (dbo.fn_EmployeeMustBeAtLeast16() = 0)
GO

-- No product can have a negative price
ALTER TABLE tblPRODUCT
ADD CONSTRAINT CHK_NoNegativePrices CHECK(Price>=0)
GO

-- No customer data can be stored about a person under 13
ALTER TABLE tblCUSTOMER
ADD CONSTRAINT CHK_CustOlderThan13 CHECK (CustDOB < DATEADD(year, -13, GETDATE()));
GO

--- Rule 1: No discount can be greater than the price of a lineitem
GO
CREATE FUNCTION fnDiscountPriceLimit()
RETURNS INT
AS
BEGIN
  DECLARE @return int = 1
  IF EXISTS (
    SELECT *
  FROM tblLINE_ITEM L
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
    SELECT *
  FROM tblJOB_SHIFT
  WHERE Datediff(Hour, EndTime, StartTime) > 12)
	SET @return = 0
  RETURN @return
END

GO
ALTER TABLE tblJOB_SHIFT
	ADD CONSTRAINT fn_EmpShift
	CHECK (dbo.fnEmpShift() = 1)
GO

-------------------------------------------- Computed Columns --------------------------------------------

-- Calculate total price as TotalCost in Line_Item
create function fn_CalculateTotalCost(@PK int)
returns money 
as 
begin
  declare @ret money = (
    select (LI.Quantity * P.Price) + S.ServicePrice
  from tblLINE_ITEM LI
    join tblPRODUCT P on LI.ProductID = P.ProductID
    join tblSERVICE S on LI.ServiceID = S.ServiceID
  where LineItemID = @PK
  )
  return @ret
end 
go

alter table tblLINE_ITEM
add TotalCost AS (dbo.fn_CalculateTotalCost(LineItemID))
go

-- Calculate total discounts for an employee as TotalDiscounts
create function fn_CalculateEmployeeTotalDiscounts(@PK int)
returns money 
as 
begin
  declare @ret money = (
    select count(D.DiscountID)
  from tblEMPLOYEE E
    join tblJOB J on E.EmployeeID = J.EmployeeID
    join tblJOB_SHIFT EPS on J.JobID = EPS.JobID
    join tblORDER O on EPS.JobShiftID = O.JobShiftID
    join tblLINE_ITEM LI on O.OrderID = LI.OrderID
    join tblDISCOUNT D on LI.DiscountID = D.DiscountID
  )
  return @ret
end 
go

alter table tblEMPLOYEE
add TotalDiscounts as (dbo.fn_CalculateEmployeeTotalDiscounts(EmployeeID))
go

-- Calculate total time (days) at job as JobLength in Job Table --
CREATE FUNCTION fn_TotalTimeAtJob_Days(@PK INT)
RETURNS INT
AS
BEGIN
  DECLARE @Ret INT = (
        SELECT DATEDIFF(DAY, EndDate, StartDate)
  FROM tblJOB
  WHERE JobID = @PK
    )
  RETURN @Ret
END
GO

ALTER TABLE tblJOB
ADD JobLengthInDays AS (dbo.fn_TotalTimeAtJob_Days(JobID))
GO

-- Calculate total time (hours) at shift as ShiftLength in Employee_Shift_Position Table --
CREATE FUNCTION fn_TotalTimeAtShift_Hours(@PK INT)
RETURNS INT
AS
BEGIN
  DECLARE @Ret INT = (
        SELECT DATEDIFF(HOUR, EndTime, StartTime)
  FROM tblJOB_SHIFT
  WHERE JobShiftID = @PK
    )
  RETURN @Ret
END
GO

ALTER TABLE tblJOB_SHIFT
ADD ShiftLengthInHours AS (dbo.fn_TotalTimeAtShift_Hours(JobShiftID))
GO

-- Calculate the total price of an order before discounts as OrderCostNoDiscount in Order
CREATE FUNCTION dbo.OrderPriceNoDiscount(@OrderID int)
RETURNS money
AS
begin 
  declare @ret int = (
    SELECT SUM(Price)
    FROM tblPRODUCT AS P
      JOIN tblLINE_ITEM AS L ON P.ProductID=L.ProductID
    WHERE L.OrderID=@OrderID)
  return @ret
  end
GO
ALTER TABLE dbo.tblORDER ADD OrderCostNoDiscount AS dbo.OrderPriceNoDiscount(OrderID)
GO

-- Calculate the price of a product after discount as ProductPriceWithDiscount in Line_item
CREATE FUNCTION dbo.LineItemPriceWithDiscount(@LineItemID int)
RETURNS money
AS
begin 
  declare @ret int = (SELECT Price
    FROM tblPRODUCT AS P
      JOIN tblLINE_ITEM AS L ON P.ProductID=L.ProductID
    WHERE L.LineItemID= @LineItemID ) - 
  (SELECT DeductAmount
    FROM tblDISCOUNT AS D
      JOIN tblLINE_ITEM AS L ON D.DiscountID=L.DiscountID
      JOIN tblPRODUCT AS P ON L.ProductID=P.ProductID
    WHERE L.LineItemID=@LineItemID)
  return @ret 
end
GO

ALTER TABLE dbo.tblLINE_ITEM ADD LineItemCostWithDiscount AS dbo.LineItemPriceWithDiscount(LineItemID)
GO


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
GO

-------------------------------------------- Views --------------------------------------------

-- The most frequent phone-buying customer in Washington
create view FrequentWashingtonPhoneBuyer
as
  select top 1
    count(*) as TotalItemsBought, C.CustFname, C.CustLname
  from tblLINE_ITEM LI
    join tblORDER O on LI.OrderID = O.OrderID
    join tblCUSTOMER C on O.CustomerID = C.CustomerID
    join tblPRODUCT P on LI.ProductID = P.ProductID
    join tblPRODUCT_TYPE PT on P.ProductTypeID = PT.ProductTypeID
  where PT.ProductTypeName = 'Phone' and C.CustState = 'Washington'
  group by C.CustFname, C.CustLname
  order by TotalItemsBought desc
go

-- All suppliers that have had 8 'iPhone 8' sold within last month
create view iPhoneSuppliers
as
  select S.SupplierID, S.SupplierName, count(*) as ItemsSold
  from tblSupplier S
    join tblPRODUCT P on P.SupplierID = S.SupplierID
    join tblPRODUCT_TYPE PT on P.ProductTypeID = PT.ProductTypeID
    join tblLINE_ITEM LI on P.ProductID = LI.ProductID
    join tblOrder O on LI.OrderID = O.OrderID
  where P.ProductName = 'iPhone 8'
    and O.OrderDate > dateadd(m, -1, getdate())
  group by S.SupplierID, S.SupplierName
  having count(*) > 8
go


-- The top 10 most ‘profitable’ product or product that generates the most revenue --
CREATE VIEW TopTenBestProducts
AS
  SELECT TOP 10
    P.ProductID, P.ProductName, SUM(P.Price * LI.Quantity) AS [Total Sales]
  FROM tblPRODUCT P
    JOIN tblLINE_ITEM LI ON P.ProductID = LI.ProductID
  GROUP BY P.ProductID, P.ProductName
  ORDER BY [Total Sales] DESC
GO

-- All employees who have worked at their job for more than 5 years and earn more than $50,000 -- 
CREATE VIEW SeniorEmployees
AS
  SELECT E.EmployeeID, E.EmpFname, E.EmpLname
  FROM tblEMPLOYEE E
    JOIN tblJOB J ON E.EmployeeID = J.EmployeeID
  WHERE DATEDIFF(YEAR, J.EndDate, J.StartDate) > 5
    AND J.Salary > 50000
GO

-- All customers who have shopped in the last year
CREATE VIEW V_CustomersThisYear
AS
  SELECT CustFname, CustLname
  FROM tblCUSTOMER AS C
    JOIN tblORDER AS O ON C.CustomerID=O.CustomerID
  WHERE OrderDate > DATEADD(year,-1,GETDATE())
GO

-- The products which have not been ordered in the past year
CREATE VIEW V_NotSoldThisYear
AS (
  SELECT P.ProductName, P.Price
  FROM tblPRODUCT AS P
    LEFT JOIN (SELECT PP.ProductName, PP.Price, O.OrderID, PP.ProductID
    FROM tblPRODUCT AS PP
      JOIN tblLINE_ITEM AS L ON PP.ProductID=L.ProductID
      JOIN tblORDER AS O ON L.OrderID=O.OrderID
    WHERE OrderDate > DATEADD(year,-1,GETDATE())) AS J ON P.ProductID=J.ProductID
  WHERE J.OrderID IS NULL
)
GO

--- Most popular service type bought by customers between the ages of 20 and 30
GO
CREATE VIEW popularServiceType
AS
  SELECT TOP 1
    Count(*) AS TotalSales, ST.ServiceTypeName
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
  SELECT TOP 10
    P.ProductID, P.ProductName, SUM(C.PricePenalty) AS TotalPricePenalty
  FROM tblPRODUCT P
    JOIN tblLINE_ITEM L ON P.ProductID = L.ProductID
    JOIN tblCONDITION C ON L.ConditionID = C.ConditionID
  GROUP BY P.ProductID, P.ProductName, C.ConditionID
  ORDER BY TotalPricePenalty DESC	
GO

-------------------------------------------- Insertions --------------------------------------------

insert into tblSUPPLIER
values
  ('Apple', 'This is a fruit company'),
  ('Microsoft', 'This is a window cleaning company'),
  ('Google', 'This is an alphabet company'),
  ('Amazon', 'THis company is dedicated to saving the Amazon rainforest')

insert into tblPRODUCT_TYPE
values
  ('Phone', 'Used to call people, I guess'),
  ('Tablet', 'Big phone without call functionality'),
  ('Laptop', 'Procrastination machine'),
  ('TV', 'Watch movies'),
  ('Camera', 'The product that is dying because of smart phones')

insert into tblSHIFT
values
  ('Morning Shift', 'Rise and shine'),
  ('Shitty Shift', 'The shitty one'),
  ('Noon Shift', 'No lunch for u'),
  ('Afternoon Shift', 'Lazy time'),
  ('Night Shift', 'Are you a vampite?'),
  ('Graveyard Shift', 'Existence is pain')

insert into tblPOSITION
values
  ('Clerk', 'Handles sales things'),
  ('Technician', 'Does techy stuff'),
  ('Boss man', 'You are in charge')

insert into tblEMPLOYEE
values('Obi-Wan', 'Kenobi', '1979-01-01', '1111', 'Seattle', 'WA', '98109'),
  ('Anakin', 'Skywalker', '1985-01-01', '1111', 'Seattle', 'WA', '98109'),
  ('Greg', 'Hay', '1970-01-01', '1111', 'Seattle', 'WA', '98109')

insert into tblJOB
values(1, 1, 85000, '2005-01-01', '2050-01-01'),
  (2, 2, 75000, '2012-01-01', '2050-01-01'),
  (3, 3, 100000, '2018-01-01', '2050-01-01')

-- Insert into tblCUSTOMER with sample data --
INSERT INTO tblCUSTOMER
  (CustFName, CustLName, CustDOB, CustAddress, CustCity, CustState, CustZip)
SELECT TOP 1000
  CustomerFname, CustomerLname, DateOfBirth, CustomerAddress, CustomerCity, CustomerState, CustomerZip
FROM CUSTOMER_BUILD.dbo.tblCUSTOMER

exec usp_InsertNewProduct
@ProductName = 'Second Best iPhone Ever',
@ProductDesc = 'This is the second best iPhone ever!!!!',
@ProductTypeName = 'Phone',
@SupplierName = 'Apple',
@Price = 600