--*************************************************************************--
-- Title: Assignment06
-- Author: gparker
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,gparker,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_gparker')
	 Begin 
	  Alter Database [Assignment06DB_gparker] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_gparker;
	 End
	Create Database Assignment06DB_gparker;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_gparker;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
SELECT * FROM Categories

CREATE VIEW vCategories
WITH SCHEMABINDING -- binding
AS
	SELECT 
		C.CategoryID,
		C.CategoryName
		FROM dbo.Categories AS C -- added alias and schema (binding)
GO

SELECT * FROM vCategories
GO

SELECT * FROM dbo.Products

CREATE VIEW vProducts
WITH SCHEMABINDING --binding
AS
	SELECT 
		P.ProductID,
		P.ProductName,
		P.CategoryID,
		P.UnitPrice
		FROM dbo.Products AS P -- added alias and schema (binding)
GO

SELECT * FROM vProducts
GO

SELECT * FROM Employees

CREATE VIEW vEmployees
WITH SCHEMABINDING -- Binding
AS
	SELECT 
		E.EmployeeID,
		E.EmployeeFirstName,
		E.EmployeeLastName,
		E.ManagerID
		FROM dbo.Employees AS E -- added alias and schema (binding)
GO

SELECT * FROM vEmployees
GO

SELECT * FROM Inventories

CREATE VIEW vInventories
WITH SCHEMABINDING -- binding
AS
	SELECT 
		I.dbo.InventoryID,
		I.dbo.InventoryDate,
		I.dbo.EmployeeID,
		I.dbo.ProductID,
		I.dbo.Count
		FROM dbo.Inventories AS I -- added alias and schema (binding)
GO

SELECT * FROM vInventories
GO


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Use Assignment06DB_gparker;
DENY SELECT ON dbo.Products TO PUBLIC; -- Denies select for the table
GRANT SELECT ON vProducts TO PUBLIC; -- Give access to the the view
GO

DENY SELECT ON dbo.Categories TO PUBLIC;
GRANT SELECT ON vCategories TO PUBLIC;
GO

DENY SELECT ON dbo.Employees TO PUBLIC;
GRANT SELECT ON vEmployees TO PUBLIC;
GO

DENY SELECT ON dbo.Inventories TO PUBLIC;
GRANT SELECT ON vInventories TO PUBLIC;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

CREATE VIEW vProductsByCategories
WITH SCHEMABINDING -- added binding for safety
AS
	SELECT TOP 10000 -- have to trick the system into letting us sort in a view
		CategoryName, 
		ProductName, 
		UnitPrice 
	FROM dbo.Categories AS C INNER JOIN dbo.Products AS P -- added alias and schema (binding)
	ON P.CategoryID = C.CategoryID
	ORDER BY CategoryName, ProductName;
GO

SELECT * FROM vProductsByCategories


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByDates
WITH SCHEMABINDING -- added binding for safety
AS
	SELECT TOP 10000 -- have to trick the system into letting us sort in a view
		ProductName, 
		InventoryDate, 
		Count  
	FROM dbo.Inventories AS I INNER JOIN dbo.Products AS P -- add alias and schema for binding
		ON P.ProductID = I.ProductID
			ORDER BY ProductName, InventoryDate, Count;
GO

SELECT * FROM vInventoriesByProductsByDates -- check to make sure it works


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

CREATE VIEW vInventoriesByEmployeesByDates
WITH SCHEMABINDING -- added binding for safety
AS
	SELECT DISTINCT TOP 10000 -- have to trick the system into letting us sort in a view
		I.InventoryDate,
		[EmployeeName] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
	FROM dbo.Inventories AS I -- schema and alias
		INNER JOIN dbo.Employees AS E ON I.EmployeeID = E.EmployeeID -- schema and alias
	ORDER BY 1,2;
GO

SELECT * FROM vInventoriesByEmployeesByDates

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByCategories
WITH SCHEMABINDING -- added binding for safety
AS
	SELECT TOP 10000 -- have to trick the system into letting us sort in a view
		C.CategoryName, 
		P.ProductName, 
		I.InventoryDate,
		I.Count
	FROM dbo.Categories AS C -- schema and alias
		INNER JOIN dbo.Products AS P ON C.CategoryID = P.ProductID-- schema and alias
		INNER JOIN dbo.Inventories AS I	ON I.ProductID = P.ProductID-- schema and alias
	ORDER BY 1, 2, 3, 4;
GO

SELECT * FROM vInventoriesByProductsByCategories


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE VIEW vInventoriesByProductsByEmployees
WITH SCHEMABINDING -- added binding for safety
AS
	SELECT TOP 10000 -- have to trick the system into letting us sort in a view
		C.CategoryName,
		P.ProductName,
		I.InventoryDate,
		I.Count,
		[EmployeeName] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
	FROM dbo.Categories AS C-- schema and alias
		INNER JOIN dbo.Products AS P ON C.CategoryID = P.CategoryID-- schema and alias
		INNER JOIN dbo.Inventories AS I ON P.ProductID = I.ProductID-- schema and alias
		INNER JOIN dbo.Employees AS E ON I.EmployeeID = E.EmployeeID-- schema and alias
	ORDER BY 3, 1, 2, 5;
GO

SELECT * FROM vInventoriesByProductsByEmployees

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

CREATE VIEW vInventoriesForChaiAndChangByEmployees
WITH SCHEMABINDING -- added binding for safety
AS
	SELECT TOP 10000 -- have to trick the system into letting us sort in a view
		C.CategoryName,
		P.ProductName,
		I.InventoryDate,
		I.Count,
		[EmployeeName] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
	FROM dbo.Categories AS C-- schema and alias
		INNER JOIN dbo.Products AS P ON C.CategoryID = P.CategoryID-- schema and alias
		INNER JOIN dbo.Inventories AS I ON P.ProductID = I.ProductID-- schema and alias
		INNER JOIN dbo.Employees AS E ON I.EmployeeID = E.EmployeeID-- schema and alias
	WHERE I.ProductID IN (SELECT P.ProductID WHERE P.ProductName IN ('Chang', 'Chai'))--subquery
	ORDER BY 3, 1, 2, 4;
GO

SELECT * FROM vInventoriesForChaiAndChangByEmployees


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

CREATE VIEW vEmployeesByManager
WITH SCHEMABINDING -- added binding for safety
AS
	SELECT TOP 10000 -- have to trick the system into letting us sort in a view
		[Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName,
		[Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
	FROM dbo.Employees AS E-- schema and alias
		INNER JOIN dbo.Employees AS M ON M.EmployeeID = E.ManagerID-- schema and alias
	ORDER BY 1, 2;
GO

SELECT * FROM vEmployeesByManager

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
	SELECT TOP 10000 -- have to trick the system into letting us sort in a view
		C.CategoryName, C.CategoryID, -- sorted out columns by tables
		P.ProductID, P.ProductName, P.UnitPrice, 
		I.InventoryID, I.InventoryDate, I.Count, 
		E.EmployeeID, [Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName, [EmployeeName] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
	FROM vCategories AS C
		INNER JOIN vProducts AS P ON C.CategoryID = P.CategoryID-- schema and alias
		INNER JOIN vInventories AS I ON P.ProductID = I.ProductID-- schema and alias
		INNER JOIN vEmployees AS E ON I.EmployeeID = E.EmployeeID-- schema and alias
		INNER JOIN vEmployees AS M ON M.EmployeeID = E.ManagerID-- schema and alias
	ORDER BY C.CategoryName, P.ProductName, I.InventoryID, EmployeeName
GO

SELECT * FROM vInventoriesByProductsByCategoriesByEmployees

--


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/