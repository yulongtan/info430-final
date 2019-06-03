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

