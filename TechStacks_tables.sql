--- Create Database TechStacks
Use TechStacks

GO
CREATE TABLE tblSUPPLIER (
	SupplierID int IDENTITY(1,1) Primary Key NOT NULL,
	SupplierName varchar(30) NOT NULL,
	SupplierDesc varchar(50) NOT NULL)

GO
CREATE TABLE tblPRODUCT_TYPE (
	ProductTypeID int IDENTITY(1,1) Primary Key NOT NULL,
	ProductTypeName varchar(30) NOT NULL,
	ProductTypeDesc varchar(30) NOT NULL)

GO
CREATE TABLE tblPRODUCT (
	ProductID int IDENTITY(1,1) Primary Key NOT NULL,
	ProductTypeID int FOREIGN KEY REFERENCES tblPRODUCT_TYPE(ProductTypeID) NOT NULL,
	SupplierID int FOREIGN KEY REFERENCES tblSUPPLIER(SupplierID) NOT NULL,
	ProductName varchar(30) NOT NULL, 
	ProductDesc varchar(50) NOT NULL,
	Price money NOT NULL)

GO
CREATE TABLE tblCUSTOMER (
	CustomerID int IDENTITY(1,1) Primary Key NOT NULL,
	CustFName varchar(30) NOT NULL,
	CustLName varchar(30) NOT NULL,
	CustDOB date NOT NULL)

GO
CREATE TABLE tblORDER_TYPE (
	OrderTypeID int IDENTITY(1,1) Primary Key NOT NULL,
	OrderTypeName varchar(30) NOT NULL,
	OrderTypeDesc varchar(50) NOT NULL)

GO
CREATE TABLE tblEMPLOYEE (
	EmployeeID int IDENTITY(1,1) Primary Key NOT NULL,
	EmpFName varchar(30) NOT NULL,
	EmpLName varchar(30) NOT NULL,
	EmpDOB date NOT NULL)

GO
CREATE TABLE tblPOSITION (
	PositionID int IDENTITY(1,1) Primary Key NOT NULL,
	PositionName varchar(30) NOT NULL,
	PositionDesc varchar(50) NOT NULL)

GO
CREATE TABLE tblEMPLOYEE_POSITION (
	EmpPosID int IDENTITY(1,1) Primary Key NOT NULL,
	EmployeeID int FOREIGN KEY REFERENCES tblEMPLOYEE(EmployeeID) NOT NULL,
	PositionID int FOREIGN KEY REFERENCES tblPOSITION(PositionID) NOT NULL,
	Salary money NOT NULL,
	StartDate date NOT NULL,
	EndDate date NOT NULL)

GO
CREATE TABLE tblSHIFT (
	ShiftID int IDENTITY(1,1) Primary Key NOT NULL,
	ShiftName varchar(30) NOT NULL, 
	ShiftDesc varchar(50) NOT NULL)

GO
CREATE TABLE tblEMPLOYEE_POSITION_SHIFT (
	EmpPosShiftID int IDENTITY(1,1) Primary Key NOT NULL,
	ShiftID int FOREIGN KEY REFERENCES tblSHIFT (ShiftID) NOT NULL,
	EmployeePositionID int FOREIGN KEY REFERENCES tblEMPLOYEE_POSITION(EmpPosID) NOT NULL,
	Date date NOT NULL,
	StartTime time NOT NULL,
	EndTime time NOT NULL)

GO
CREATE TABLE tblORDER (
	OrderID int IDENTITY(1,1) Primary Key NOT NULL,
	CustomerID int FOREIGN KEY REFERENCES tblCUSTOMER (CustomerID) NOT NULL,
	EmpPosShiftID int FOREIGN KEY REFERENCES tblEMPLOYEE_POSITION_SHIFT (EmpPosShiftID) NOT NULL,
	OrderTypeID int FOREIGN KEY REFERENCES tblORDER_TYPE (OrderTypeID) NOT NULL,
	OrderDate date NOT NULL)

GO 
CREATE TABLE tblDISCOUNT_TYPE (
	DiscountTypeID int IDENTITY(1,1) Primary Key NOT NULL,
	DiscountTypeName varchar(50) NOT NULL)

GO 
CREATE TABLE tblDISCOUNT (
	DiscountID int IDENTITY(1,1) Primary Key NOT NULL,
	DiscountTypeID int FOREIGN KEY REFERENCES tblDISCOUNT_TYPE (DiscountTypeID) NOT NULL,
	DiscountName varchar(30) NOT NULL,
	DiscountDesc varchar(50) NOT NULL, 
	DeductAmount int NOT NULL)

GO 
CREATE TABLE tblSERVICE_TYPE (
	ServiceTypeID int IDENTITY(1,1) Primary Key NOT NULL,
	ServiceTypeName varchar(30) NOT NULL,
	ServiceTypeDesc varchar(50) NOT NULL)

GO 
CREATE TABLE tblSERVICE (
	ServiceID int IDENTITY(1,1) Primary Key NOT NULL,
	ServiceTypeID int FOREIGN KEY REFERENCES tblSERVICE_TYPE(ServiceTypeID) NOT NULL,
	ServiceName varchar(30) NOT NULL,
	ServiceDesc varchar(50) NOT NULL)

GO 
CREATE TABLE tblCONDITION (
	ConditionID int IDENTITY(1,1) Primary Key NOT NULL,
	Condition varchar(30) NOT NULL,
	PricePenalty money NOT NULL)

GO
CREATE TABLE tblLINE_ITEM (
	LineItemID int IDENTITY(1,1) Primary Key NOT NULL,
	ProductID int FOREIGN KEY REFERENCES tblPRODUCT(ProductID) NOT NULL,
	ConditionID int FOREIGN KEY REFERENCES tblCONDITION(ConditionID) NOT NULL,
	ServiceID int FOREIGN KEY REFERENCES tblSERVICE(ServiceID) NOT NULL,
	OrderID int FOREIGN KEY REFERENCES tblORDER(OrderID) NOT NULL,
	PriceExtended money NOT NULL)