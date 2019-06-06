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
    INSERT INTO tblSERVICE (ServiceTypeID, ServiceName, ServicePrice, ServiceDesc)
    VALUES (@ST_ID, @ServName, @ServPrice, @ServDesc)
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

----- COMPUTED COLUMNS -----
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

----- VIEWS -----
-- The top 10 most ‘profitable’ product or product that generates the most revenue --
CREATE VIEW TopTenBestProducts AS
SELECT TOP 10 P.ProductID, P.ProductName, SUM(P.Price * LI.Quantity) AS [Total Sales]
FROM tblPRODUCT P 
JOIN tblLINE_ITEM LI ON P.ProductID = LI.ProductID
GROUP BY P.ProductID, P.ProductName
ORDER BY [Total Sales] DESC
GO

-- All employees who have worked at their job for more than 5 years and earn more than $50,000 -- 
CREATE VIEW SeniorEmployees AS 
SELECT E.EmployeeID, E.EmpFname, E.EmpLname
FROM tblEMPLOYEE E 
JOIN tblJOB J ON E.EmployeeID = J.EmployeeID
WHERE DATEDIFF(YEAR, J.EndDate, J.StartDate) > 5
AND J.Salary > 50000
GO



