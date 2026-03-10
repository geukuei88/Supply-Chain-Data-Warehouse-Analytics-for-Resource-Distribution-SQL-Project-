--Building T-SQL Object
IF OBJECT_ID ('bronze.Crm_Customers', 'U') IS NOT NULL
	DROP TABLE bronze.Crm_Customers;
CREATE TABLE bronze.Crm_Customers (
	Customer_ID NVARCHAR(50),
	Customer_Name NVARCHAR(50),
	Segment NVARCHAR(50),
	Country NVARCHAR(50),
	City NVARCHAR(50),
	State NVARCHAR(50),
	Postal_Code INT,
	Region NVARCHAR(50)
);

IF OBJECT_ID ('bronze.Erp_Orders', 'U') IS NOT NULL
	DROP TABLE bronze.Erp_Orders;
CREATE TABLE bronze.Erp_Orders (
	Order_ID NVARCHAR(50),
	Order_Date DATE,
	Ship_Date DATE,
	Ship_Mode NVARCHAR(50),
	Customer_ID NVARCHAR(50),
	Product_ID NVARCHAR(50),
	Sales DECIMAL(10, 3),
	Quantity INT,
	Discount DECIMAL(10, 1),
	Profit DECIMAL(10, 4)
);

IF OBJECT_ID ('bronze.Erp_Products', 'U') IS NOT NULL
	DROP TABLE bronze.Erp_Products;
CREATE TABLE bronze.Erp_Products (
	Product_ID NVARCHAR(50),
	Category NVARCHAR(50),
	Sub_Category NVARCHAR(50),
	Product_Name NVARCHAR(255)
);

BULK INSERT bronze.Crm_Customers
FROM 'C:\Sql\Dwh_Project\Datasets\Source_Crm\Customers.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	
	);

-- STEP 1: Drop and recreate staging table (staging schema already exists)
IF OBJECT_ID ('staging.Erp_Orders', 'U') IS NOT NULL
    DROP TABLE staging.Erp_Orders;

CREATE TABLE staging.Erp_Orders (
    Order_ID NVARCHAR(50),
    Order_Date NVARCHAR(20),
    Ship_Date NVARCHAR(20),
    Ship_Mode NVARCHAR(50),
    Customer_ID NVARCHAR(50),
    Product_ID NVARCHAR(50),
    Sales NVARCHAR(20),
    Quantity NVARCHAR(10),
    Discount NVARCHAR(10),
    Profit NVARCHAR(20)
);
GO

-- STEP 2: Bulk insert into staging
BULK INSERT staging.Erp_Orders
FROM 'C:\Sql\Dwh_Project\Datasets\Source_Erp\Orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

-- STEP 3: Check what we have
SELECT COUNT(*) as 'Rows in staging' FROM staging.Erp_Orders;
GO

-- STEP 4: Insert into bronze with all 10 columns matching
INSERT INTO bronze.Erp_Orders (
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Product_ID,
    Sales,
    Quantity,
    Discount,
    Profit
)
SELECT 
    Order_ID,
    -- Convert Order_Date
    CASE 
        WHEN Order_Date LIKE '%/%' THEN CONVERT(DATE, Order_Date, 101)
        WHEN Order_Date LIKE '%-%' THEN CONVERT(DATE, Order_Date, 105)
        ELSE NULL
    END,
    -- Convert Ship_Date
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

-- STEP 5: Verify
SELECT COUNT(*) as 'Rows in bronze.Erp_Orders' FROM bronze.Erp_Orders;
SELECT TOP 10 * FROM bronze.Erp_Orders;


BULK INSERT bronze.Erp_Products
FROM 'C:\Sql\Dwh_Project\Datasets\Source_Erp\Products.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	    );

SELECT *
FROM bronze.Erp_Products;
