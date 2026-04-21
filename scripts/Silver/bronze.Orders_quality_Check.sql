
  /* ============================================================================
DATA QUALITY ASSESSMENT: ORDERS TABLE
Project: Data Warehouse Development (Bronze → Silver Layer)
Description:
This script performs data quality checks and validation on the Orders table
to ensure consistency, integrity, and readiness for analytical reporting.

Focus areas:
- Key integrity
- Date validation
- Numeric consistency
- Referential integrity
- Business rule validation
============================================================================ */


/* ----------------------------------------------------------------------------
1. PRIMARY KEY VALIDATION: Order_ID
- Ensure uniqueness and non-null values
---------------------------------------------------------------------------- */

SELECT
    Order_ID,
    COUNT(*) AS Duplicate_Count
FROM bronze.Erp_Orders
GROUP BY Order_ID
HAVING COUNT(*) > 1 OR Order_ID IS NULL;


/* ----------------------------------------------------------------------------
2. FOREIGN KEY VALIDATION
- Ensure Orders correctly reference Customers and Products
---------------------------------------------------------------------------- */

-- Missing Customer_IDs
SELECT 
    COUNT(*) AS Missing_Customers
FROM bronze.Erp_Orders
WHERE Customer_ID IS NULL;

-- Orphan Customer_IDs (not in Customers table)
SELECT 
    o.Customer_ID
FROM bronze.Erp_Orders o
LEFT JOIN bronze.Crm_Customers c 
    ON o.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;

-- Missing Product_IDs
SELECT 
    COUNT(*) AS Missing_Products
FROM bronze.Erp_Orders
WHERE Product_ID IS NULL;

-- Orphan Product_IDs
SELECT 
    o.Product_ID
FROM bronze.Erp_Orders o
LEFT JOIN bronze.Erp_Products p 
    ON o.Product_ID = p.Product_ID
WHERE p.Product_ID IS NULL;


/* ----------------------------------------------------------------------------
3. DATE VALIDATION
- Ensure logical consistency of Order_Date and Ship_Date
---------------------------------------------------------------------------- */

-- Null dates
SELECT 
    COUNT(*) AS Missing_Order_Dates
FROM bronze.Erp_Orders
WHERE Order_Date IS NULL;

SELECT 
    COUNT(*) AS Missing_Ship_Dates
FROM bronze.Erp_Orders
WHERE Ship_Date IS NULL;

-- Ship date before order date (critical issue)
SELECT 
    Order_ID,
    Order_Date,
    Ship_Date
FROM bronze.Erp_Orders
WHERE Ship_Date < Order_Date;

-- Future dates (suspicious)
SELECT 
    COUNT(*) AS Future_Orders
FROM bronze.Erp_Orders
WHERE Order_Date > GETDATE();


/* ----------------------------------------------------------------------------
4. NUMERIC VALIDATION
- Validate Quantity, Sales, Discount, Profit
---------------------------------------------------------------------------- */

-- Negative or zero Quantity
SELECT 
    COUNT(*) AS Invalid_Quantity
FROM bronze.Erp_Orders
WHERE Quantity <= 0;

-- Negative sales
SELECT 
    COUNT(*) AS Negative_Sales
FROM bronze.Erp_Orders
WHERE Sales < 0;

-- Discount outside valid range (0–1)
SELECT 
    COUNT(*) AS Invalid_Discount
FROM bronze.Erp_Orders
WHERE Discount < 0 OR Discount > 1;

-- Profit anomalies (optional but useful)
SELECT 
    COUNT(*) AS Extreme_Profit_Values
FROM bronze.Erp_Orders
WHERE Profit > Sales OR Profit < -Sales;

/* ----------------------------------------------------------------------------
5. BUSINESS RULE VALIDATION
- Ensure logical financial relationships
---------------------------------------------------------------------------- */

-- Sales vs Quantity mismatch (basic sanity check)
SELECT 
    Order_ID,
    Quantity,
    Sales
FROM bronze.Erp_Orders
WHERE Quantity > 0 AND Sales = 0;

-- High discount but still high profit (suspicious)
SELECT 
    Order_ID,
    Discount,
    Profit
FROM bronze.Erp_Orders
WHERE Discount > 0.8 AND Profit > 0;


/* ----------------------------------------------------------------------------
6. DUPLICATE ORDER CHECK
- Detect potential duplicate transactions and bad repetitions
---------------------------------------------------------------------------- */


WITH RankedOrders AS (
    SELECT *,
           COUNT(*) OVER (
               PARTITION BY Customer_ID, Product_ID, Order_Date,
                            Quantity, Sales, Discount, Profit
           ) AS Duplicate_Count
    FROM bronze.Erp_Orders
)
SELECT *
FROM RankedOrders
WHERE Duplicate_Count > 1;


/* ----------------------------------------------------------------------------
7. STRING QUALITY CHECK (if applicable)
- Validate textual fields like Ship_Mode or Order_Priority
---------------------------------------------------------------------------- */

-- Leading/trailing spaces
SELECT 
    Ship_Mode
FROM bronze.Erp_Orders
WHERE Ship_Mode <> TRIM(Ship_Mode);

-- Unexpected values
SELECT 
    Ship_Mode,
    COUNT(*) AS Occurrences
FROM bronze.Erp_Orders
GROUP BY Ship_Mode
ORDER BY Occurrences DESC;


/* ----------------------------------------------------------------------------
8. DATA PROFILING SUMMARY
- Overview of dataset structure and variability
---------------------------------------------------------------------------- */

SELECT 
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Order_ID) AS Unique_Orders,
    COUNT(DISTINCT Customer_ID) AS Unique_Customers,
    COUNT(DISTINCT Product_ID) AS Unique_Products,
    MIN(Order_Date) AS Earliest_Order,
    MAX(Order_Date) AS Latest_Order,
    MIN(Sales) AS Min_Sales,
    MAX(Sales) AS Max_Sales,
    AVG(Sales) AS Avg_Sales
FROM bronze.Erp_Orders;

/* ============================================================================
NEXT STEP:
Proceed to Silver layer transformation and validation
============================================================================ */
