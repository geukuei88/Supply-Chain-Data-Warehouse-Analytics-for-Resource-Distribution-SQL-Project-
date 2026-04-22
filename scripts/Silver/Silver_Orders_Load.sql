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
