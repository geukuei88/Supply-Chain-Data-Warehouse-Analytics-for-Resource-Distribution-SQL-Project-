
/* =====================================================================================
Script Purpose: 
This script creates and loads data into the 'bronze' schema from external csv files.
It performs the following:
- Drops (if it exists) and recreates all tables.
- Truncates the bronze tables before loading data.
- UseS BULK INSERT command to load data from csv files to bronze tables
- Creates staging schema to load problematic orders csv file into bronze table
- Validates data completeness and schema checks
 ======================================================================================*/

-- ======================================================
-- SECTION 1: CREATE STAGING SCHEMA (if not exists)
-- ======================================================
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'staging')
BEGIN
    EXEC('CREATE SCHEMA staging');
END
GO

-- ======================================================
-- SECTION 2: CREATE BRONZE TABLES (DROP + RECREATE)
-- ======================================================

-- Bronze CRM Customers
IF OBJECT_ID ('bronze.Crm_Customers', 'U') IS NOT NULL
    DROP TABLE bronze.Crm_Customers;
GO

CREATE TABLE bronze.Crm_Customers (
    Customer_ID   NVARCHAR(50),
    Customer_Name NVARCHAR(50),
    Segment       NVARCHAR(50),
    Country       NVARCHAR(50),
    City          NVARCHAR(50),
    State         NVARCHAR(50),
    Postal_Code   INT,
    Region        NVARCHAR(50)
);
GO

-- Bronze ERP Products
IF OBJECT_ID ('bronze.Erp_Products', 'U') IS NOT NULL
    DROP TABLE bronze.Erp_Products;
GO

CREATE TABLE bronze.Erp_Products (
    Product_ID     NVARCHAR(50),
    Category       NVARCHAR(50),
    Sub_Category   NVARCHAR(50),
    Product_Name   NVARCHAR(255)
);
GO

-- Bronze ERP Orders
IF OBJECT_ID ('bronze.Erp_Orders', 'U') IS NOT NULL
    DROP TABLE bronze.Erp_Orders;
GO

CREATE TABLE bronze.Erp_Orders (
    Order_ID     NVARCHAR(50),
    Order_Date   DATE,
    Ship_Date    DATE,
    Ship_Mode    NVARCHAR(50),
    Customer_ID  NVARCHAR(50),
    Product_ID   NVARCHAR(50),
    Sales        DECIMAL(10, 3),
    Quantity     INT,
    Discount     DECIMAL(10, 1),
    Profit       DECIMAL(10, 4)
);
GO

-- ======================================================
-- SECTION 3: CREATE STAGING TABLE FOR ORDERS
-- ======================================================
IF OBJECT_ID ('staging.Erp_Orders', 'U') IS NOT NULL
    DROP TABLE staging.Erp_Orders;
GO

CREATE TABLE staging.Erp_Orders (
    Order_ID     NVARCHAR(50),
    Order_Date   NVARCHAR(20),
    Ship_Date    NVARCHAR(20),
    Ship_Mode    NVARCHAR(50),
    Customer_ID  NVARCHAR(50),
    Product_ID   NVARCHAR(50),
    Sales        NVARCHAR(20),
    Quantity     NVARCHAR(10),
    Discount     NVARCHAR(10),
    Profit       NVARCHAR(20)
);
GO

-- ======================================================
-- SECTION 4: LOAD DATA
-- ======================================================

-- Load Customers
TRUNCATE TABLE bronze.Crm_Customers;
BULK INSERT bronze.Crm_Customers
FROM 'C:\Sql\Dwh_Project\Datasets\Source_Crm\Customers.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

-- Load Products
TRUNCATE TABLE bronze.Erp_Products;
BULK INSERT bronze.Erp_Products
FROM 'C:\Sql\Dwh_Project\Datasets\Source_Erp\Products.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

-- Load Orders into staging
TRUNCATE TABLE staging.Erp_Orders;
BULK INSERT staging.Erp_Orders
FROM 'C:\Sql\Dwh_Project\Datasets\Source_Erp\Orders.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

-- Transform staging to bronze
TRUNCATE TABLE bronze.Erp_Orders;
INSERT INTO bronze.Erp_Orders
SELECT 
    Order_ID,
    CASE 
        WHEN Order_Date LIKE '%/%' THEN CONVERT(DATE, Order_Date, 101)
        WHEN Order_Date LIKE '%-%' THEN CONVERT(DATE, Order_Date, 105)
        ELSE NULL
    END,
    CASE 
        WHEN Ship_Date LIKE '%/%' THEN CONVERT(DATE, Ship_Date, 101)
        WHEN Ship_Date LIKE '%-%' THEN CONVERT(DATE, Ship_Date, 105)
        ELSE NULL
    END,
    Ship_Mode,
    Customer_ID,
    Product_ID,
    TRY_CAST(Sales AS DECIMAL(10,3)),
    TRY_CAST(Quantity AS INT),
    TRY_CAST(Discount AS DECIMAL(10,1)),
    TRY_CAST(Profit AS DECIMAL(10,4))
FROM staging.Erp_Orders;
GO

-- ======================================================
-- SECTION 5: VALIDATION
-- ======================================================

PRINT '--- ROW COUNTS ---';
SELECT 
    'bronze.Crm_Customers' as TableName, 
    COUNT(*) as [RowCount] 
FROM bronze.Crm_Customers
UNION ALL
SELECT 
    'bronze.Erp_Products', 
    COUNT(*) 
FROM bronze.Erp_Products
UNION ALL
SELECT 
    'bronze.Erp_Orders', 
    COUNT(*) 
FROM bronze.Erp_Orders;

PRINT '--- SAMPLE DATA (First 5 rows each) ---';
SELECT TOP 5 'Customers' as Source, * FROM bronze.Crm_Customers;
SELECT TOP 5 'Products' as Source, * FROM bronze.Erp_Products;
SELECT TOP 5 'Orders' as Source, * FROM bronze.Erp_Orders;

PRINT '--- DATE RANGE CHECK ---';
SELECT 
    MIN(Order_Date) as EarliestOrder,
    MAX(Order_Date) as LatestOrder,
    DATEDIFF(day, MIN(Order_Date), MAX(Order_Date)) as DaysSpan
FROM bronze.Erp_Orders;
GO

PRINT 'Bronze layer build completed successfully!';
