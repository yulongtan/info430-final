USE TechStacks
GO

----- STORED PROCEDURES ----- 
CREATE PROCEDURE uspGetServiceTypeID
@ServTypeName VARCHAR(30),
@ServTypeID INT OUTPUT
AS
SET @ServTypeID = (SELECT ServiceTypeID FROM tblSERVICE_TYPE WHERE ServiceTypeName = @ServTypeName)
GO

CREATE PROCEDURE uspGetDiscountTypeID
@DiscTypeName VARCHAR(30),
@DiscTypeID INT OUTPUT
AS
SET @DiscTypeID = (SELECT DiscountTypeID FROM tblDISCOUNT_TYPE WHERE DiscountTypeName = @DiscTypeName)
GO

CREATE PROCEDURE uspInsertIntoService
@ServName VARCHAR(30),
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
    INSERT INTO tblSERVICE (ServiceTypeID, ServiceName, ServiceDesc)
    VALUES (@ST_ID, @ServName, @ServDesc)
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
    INSERT INTO tblDISCOUNT (DiscountTypeID, DiscountName, DiscountDesc, DeductAmount)
    VALUES (@DT_ID, @DiscName, @DiscDescr, @DeductAmount)
    IF @@ERROR <> 0
        ROLLBACK TRAN G1
    ELSE
        COMMIT TRAN G1
GO

----- CHECK CONSTRAINT -----
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
