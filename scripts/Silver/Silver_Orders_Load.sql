/* ===============================================================================
CLEAN AND LOAD ORDER DATA FROM BRONZE TO SILVER LAYER
-Performs complex data cleansing including fixing future dates, 
capping impossible profits at 30% of sales, removing exact duplicates
and combining split orders (same product within same order)
and fixes reversed dates (Ship_Date < Order_Date) which was 18% of the data

-Verify Order Data Cleansing Results
-Comprehensive validation including row count comparison, checking for 
duplicate products in same order, future dates, impossible profits, exact duplicates
and displaying fixed orders
=====================================================================================*/

USE DataWarehouse;
GO

-- Clear existing orders data
TRUNCATE TABLE silver.Erp_Orders;
GO

PRINT 'Loading silver.Erp_Orders...';

WITH CleanedOrders AS (
    SELECT 
        Order_ID,
        Customer_ID,
        Product_ID,
        Ship_Mode,
        Sales,
        Quantity,
        Discount,

        -- FIX 1: Future Order Dates
        CASE 
            WHEN Order_Date > GETDATE() THEN DATEADD(YEAR, -1, Order_Date)
            ELSE Order_Date
        END AS Cleaned_Order_Date,

        -- FIX 2: Fix reversed dates
        CASE 
            WHEN Ship_Date < Order_Date THEN Order_Date
            ELSE Ship_Date
        END AS Cleaned_Ship_Date,

        -- FIX 3: Cap impossible profits
        CASE 
            WHEN Profit > Sales AND Sales > 0 THEN Sales * 0.3
            WHEN Profit > Sales AND Sales <= 0 THEN 0
            ELSE Profit
        END AS Cleaned_Profit,

        -- FIX 4: Exact duplicate detection
        ROW_NUMBER() OVER (
            PARTITION BY 
                Order_ID, 
                Product_ID,
                Order_Date,
                Customer_ID,
                Sales,
                Quantity,
                Discount,
                Profit
            ORDER BY Order_ID
        ) AS ExactDup_rn

    FROM bronze.Erp_Orders
),

-- FIX 5: Combine split orders
CombinedOrders AS (
    SELECT 
        Order_ID,
        Customer_ID,
        Product_ID,
        MAX(Cleaned_Order_Date) AS Order_Date,
        MAX(Cleaned_Ship_Date) AS Ship_Date,
        MAX(Ship_Mode) AS Ship_Mode,
        SUM(Sales) AS Sales,
        SUM(Quantity) AS Quantity,
        AVG(Discount) AS Discount,
        SUM(Cleaned_Profit) AS Profit,
        MIN(ExactDup_rn) AS KeepRow
    FROM CleanedOrders
    GROUP BY 
        Order_ID,
        Customer_ID,
        Product_ID
)

INSERT INTO silver.Erp_Orders (
    Order_ID,
    Customer_ID,
    Product_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Sales,
    Quantity,
    Discount,
    Profit,
    Dwh_Create_Date
)
SELECT 
    Order_ID,
    Customer_ID,
    Product_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Sales,
    Quantity,
    Discount,
    Profit,
    GETDATE()
FROM CombinedOrders
WHERE KeepRow = 1
ORDER BY Order_ID, Product_ID;

GO

/* ======================================================
VERIFICATION QUERIES
========================================================= */

PRINT '============================================';
PRINT 'ORDERS - VERIFICATION RESULTS';
PRINT '============================================';

-- 1. Row count comparison
SELECT 'bronze' AS Source, COUNT(*) FROM bronze.Erp_Orders
UNION ALL
SELECT 'silver', COUNT(*) FROM silver.Erp_Orders;

-- 2. Duplicate products in same order (should be 0)
SELECT Order_ID, Product_ID, COUNT(*) AS cnt
FROM silver.Erp_Orders
GROUP BY Order_ID, Product_ID
HAVING COUNT(*) > 1;

-- 3. Future dates (should be 0)
SELECT COUNT(*) AS FutureDates
FROM silver.Erp_Orders
WHERE Order_Date > GETDATE();

-- 4. Ship_Date before Order_Date (should be 0)
SELECT COUNT(*) AS BadDates
FROM silver.Erp_Orders
WHERE Ship_Date < Order_Date;

-- 5. Profit > Sales (should be 0)
SELECT COUNT(*) AS BadProfit
FROM silver.Erp_Orders
WHERE Profit > Sales AND Sales > 0;

-- 6. Exact duplicates (should be 0)
WITH DupCheck AS (
    SELECT 
        Order_ID, Product_ID, Order_Date, Customer_ID,
        Sales, Quantity, Discount, Profit,
        COUNT(*) AS cnt
    FROM silver.Erp_Orders
    GROUP BY 
        Order_ID, Product_ID, Order_Date, Customer_ID,
        Sales, Quantity, Discount, Profit
    HAVING COUNT(*) > 1
)
SELECT COUNT(*) AS RemainingDuplicates FROM DupCheck;

PRINT '============================================';
PRINT 'ORDERS CLEANING COMPLETED SUCCESSFULLY!';
PRINT '============================================';












/* ================================================================================
CLEAN AND LOAD ORDER DATA FROM BRONZE TO SILVER LAYER
-Performs complex data cleansing including fixing future dates, 
capping impossible profits at 30% of sales, removing exact duplicates
and combining split orders (same product within same order)
and fixes reversed dates (Ship_Date < Order_Date) which was 18% of the data

-Verify Order Data Cleansing Results
-Comprehensive validation including row count comparison, checking for 
duplicate products in same order, future dates, impossible profits, exact duplicates
and displaying fixed orders
=====================================================================================*/

USE DataWarehouse;
GO

-- Clear existing orders data
TRUNCATE TABLE silver.Erp_Orders;
GO

-- ======================================================
-- LOAD & CLEAN ORDERS (with all fixes)
-- ======================================================
PRINT 'Loading silver.Erp_Orders...';

WITH CleanedOrders AS (
    SELECT 
        Order_ID,
        Order_Date,
        Ship_Date,
        Ship_Mode,
        Customer_ID,
        Product_ID,
        Sales,
        Quantity,
        Discount,
        Profit,
        
        -- FIX 1: Handle future dates (assume year off by 1)
        CASE 
            WHEN Order_Date > GETDATE() THEN DATEADD(YEAR, -1, Order_Date)
            ELSE Order_Date
        END as Cleaned_Order_Date,
        
        -- FIX 2: Handle impossible profits (cap at 30% of sales)
        CASE 
            WHEN Profit > Sales AND Sales > 0 THEN Sales * 0.3
            WHEN Profit > Sales AND Sales <= 0 THEN 0
            ELSE Profit
        END as Cleaned_Profit,
        
        -- Identify exact duplicates (same everything)
        ROW_NUMBER() OVER (
            PARTITION BY 
                Order_ID, 
                Product_ID,
                Order_Date,
                Customer_ID,
                Sales,
                Quantity,
                Discount,
                Profit
            ORDER BY Order_Date
        ) as ExactDup_rn
        
    FROM bronze.Erp_Orders
),
-- FIX 3: Combine same product within same order
-- This fixes cases like CA-2013-137043 (3 units + 6 units = 9 units)
CombinedOrders AS (
    SELECT 
        Order_ID,
        MAX(Cleaned_Order_Date) as Order_Date,
        MAX(Ship_Date) as Ship_Date,
        MAX(Ship_Mode) as Ship_Mode,
        Customer_ID,
        Product_ID,
        SUM(Sales) as Sales,              -- Add them together
        SUM(Quantity) as Quantity,         -- Add quantities
        AVG(Discount) as Discount,         -- Average discount
        SUM(Cleaned_Profit) as Profit,     -- Add profits
        COUNT(*) as RowsCombined,
        MIN(ExactDup_rn) as KeepRow
    FROM CleanedOrders
    GROUP BY 
        Order_ID,
        Customer_ID,
        Product_ID
)
INSERT INTO silver.Erp_Orders (
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Product_ID,
    Sales,
    Quantity,
    Discount,
    Profit,
    Dwh_Create_Date
)
SELECT 
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Product_ID,
    Sales,
    Quantity,
    Discount,
    Profit,
    GETDATE() as Dwh_Create_Date
FROM CombinedOrders
WHERE KeepRow = 1  -- This ensures we only take one row per group
ORDER BY Order_ID, Product_ID;
GO

/* ======================================================
VERIFICATION QUERIES
========================================================= */
PRINT '============================================';
PRINT 'ORDERS - VERIFICATION RESULTS';
PRINT '============================================';

-- 1. Row count comparison
PRINT '--- Row Count Comparison ---';
SELECT 
    'bronze.Erp_Orders' as Source,
    COUNT(*) as [RowCount]
FROM bronze.Erp_Orders
UNION ALL
SELECT 
    'silver.Erp_Orders',
    COUNT(*)
FROM silver.Erp_Orders;
GO

-- 2. Check for same product in same order (should be 0)
PRINT '--- Same Product in Same Order (should be 0) ---';
SELECT 
    Order_ID,
    Product_ID,
    COUNT(*) as Occurrences
FROM silver.Erp_Orders
GROUP BY Order_ID, Product_ID
HAVING COUNT(*) > 1;
GO

-- 3. Check future dates (should be 0)
PRINT '--- Future Dates (should be 0) ---';
SELECT COUNT(*) as FutureDates
FROM silver.Erp_Orders
WHERE Order_Date > GETDATE();
GO

-- 4. Check impossible profits (should be 0)
PRINT '--- Profit > Sales (should be 0) ---';
SELECT COUNT(*) as ImpossibleProfits
FROM silver.Erp_Orders
WHERE Profit > Sales AND Sales > 0;
GO

-- 5. Check exact duplicates (should be 0)
PRINT '--- Exact Duplicate Rows (should be 0) ---';
WITH DupCheck AS (
    SELECT 
        Order_ID, Product_ID, Order_Date, Customer_ID,
        Sales, Quantity, Discount, Profit,
        COUNT(*) as Occurrences
    FROM silver.Erp_Orders
    GROUP BY 
        Order_ID, Product_ID, Order_Date, Customer_ID,
        Sales, Quantity, Discount, Profit
    HAVING COUNT(*) > 1
)
SELECT COUNT(*) as ExactDuplicatesRemaining
FROM DupCheck;
GO

-- 6. Show the problematic orders that were fixed
PRINT '--- Previously Problematic Orders (Now Fixed) ---';
SELECT * FROM silver.Erp_Orders
WHERE Order_ID IN (
    'US-2011-150119',    -- Exact duplicate
    'CA-2013-137043',    -- Same product split (3 + 6 units)
    'CA-2012-103135',    -- Varying quantities
    'CA-2013-140571',    -- Varying quantities
    'CA-2013-129714',    -- Varying quantities
    'CA-2014-152912',    -- Varying quantities
    'CA-2014-118017',    -- Varying quantities
    'US-2013-123750'     -- Varying quantities
)
ORDER BY Order_ID, Product_ID;
GO

-- 7. Show orders with multiple products (healthy line items)
PRINT '--- Sample Orders with Multiple Products (Healthy) ---';
SELECT TOP 5
    Order_ID,
    COUNT(*) as ProductCount,
    SUM(Sales) as TotalSales,
    SUM(Quantity) as TotalQuantity
FROM silver.Erp_Orders
GROUP BY Order_ID
HAVING COUNT(*) > 1
ORDER BY TotalSales DESC;
GO

PRINT '============================================';
PRINT 'ORDERS CLEANING COMPLETED SUCCESSFULLY!';
PRINT '============================================';
