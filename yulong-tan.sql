use techstacks
go

-- Stored Procedures

-- GetID Helpers

-- SupplierID
create proc usp_GetSupplierID
@SupplierName varchar(30),
@SupplierID int out 
as 
set @SupplierID = (
  select SupplierID from tblSUPPLIER where @SupplierName = SupplierName 
)

go

-- ProductTypeNameID
create proc usp_GetProductTypeID
@ProductTypeName varchar(30),
@ProductTypeID int out
as 
set @ProductTypeID = (
  select ProductTypeID from tblPRODUCT_TYPE where ProductTypeName = @ProductTypeName
)

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
insert into tblPRODUCT(ProductName, ProductDesc, ProductTypeID, SupplierID, Price)
values(@ProductName, @ProductDesc, @PTID, @SID, @Price)

if @@error <> 0
  rollback tran t1
else 
  commit tran t1

go


-- 2) Insert a new item into Job

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
set @PositionID = (select PositionID from tblPOSITION where PositionName = @PositionName)

go 

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
insert into tblJOB(Salary, StartDate, EndDate, EmployeeID, PositionID)
values(@Salary, @StartDate, @EndDate, @EID, @PID)

if @@error <> 0
  rollback tran t1
else 
  commit tran t1

go

--------------------------------------------------------------------------------------------------------------------------

-- Business Rules

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
add constraint fn_NoTerriblePhoneOrTV
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
add constraint fn_NoTechRepairFromNewEmployees
check (dbo.fn_NoTechRepairFromNewEmployees() = 1)

go
--------------------------------------------------------------------------------------------------------------------------

-- Computed Columns

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

--------------------------------------------------------------------------------------------------------------------------

-- Views

-- The most frequent phone-buying customer in Washington
create view FrequentWashingtonPhoneBuyer as
select top 1 count(*) as TotalItemsBought, C.CustFname, C.CustLname
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
create view iPhoneSuppliers as
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

exec usp_InsertNewProduct
@ProductName = 'Second Best iPhone Ever',
@ProductDesc = 'This is the second best iPhone ever!!!!',
@ProductTypeName = 'Phone',
@SupplierName = 'Apple',
@Price = 600

insert into tblSUPPLIER
values ('Apple', 'This is a fruit company'),
('Microsoft', 'This is a window cleaning company'),
('Google', 'This is an alphabet company'),
('Amazon', 'THis company is dedicated to saving the Amazon rainforest')

insert into tblPRODUCT_TYPE
values ('Phone', 'Used to call people, I guess'),
('Tablet', 'Big phone without call functionality'),
('Laptop', 'Procrastination machine'),
('TV', 'Watch movies'),
('Camera', 'The product that is dying because of smart phones')

insert into tblSHIFT
values ('Morning Shift', 'Rise and shine'),
('Shitty Shift', 'The shitty one'),
('Noon Shift', 'No lunch for u'),
('Afternoon Shift', 'Lazy time'),
('Night Shift', 'Are you a vampite?'),
('Graveyard Shift', 'Existence is pain')

insert into tblPOSITION
values ('Clerk', 'Handles sales things'),
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