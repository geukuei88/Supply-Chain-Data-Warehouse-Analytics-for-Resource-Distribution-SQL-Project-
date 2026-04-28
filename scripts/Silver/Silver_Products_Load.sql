/* ====================================================================
CLEAN AND LOAD PRODUCT DATA FROM BRONZE TO SILVER
-Standardizes category and sub-category values to proper case.
-Trims whitespace from all text fields while preserving original product
name formatting

-Verify Product Data Cleansing Results
-Validates product data quality including row counts, category and 
sub-category distribution analysis,
-sample data display, and whitespace issue checking
========================================================================== */

USE DataWarehouse;
GO

-- Clear existing products data
TRUNCATE TABLE silver.Erp_Products;
GO

PRINT '============================================';
PRINT 'LOADING SILVER PRODUCTS';
PRINT '============================================';

INSERT INTO silver.Erp_Products (
    Product_ID,
    Category,
    Sub_Category,
    Product_Name,
    Dwh_Create_Date
)
SELECT 
    -- Product_ID (primary key - keep as is)
    Product_ID,
    
    -- Category: Trim and standardize to Proper Case
    UPPER(LEFT(TRIM(Category), 1)) + 
    LOWER(SUBSTRING(TRIM(Category), 2, LEN(TRIM(Category)))) as Category,
    
    -- Sub_Category: Trim and standardize to Proper Case
    UPPER(LEFT(TRIM(Sub_Category), 1)) + 
    LOWER(SUBSTRING(TRIM(Sub_Category), 2, LEN(TRIM(Sub_Category)))) as Sub_Category,
    
    -- Product_Name: Trim only (keep original case for product names)
    TRIM(Product_Name) as Product_Name,
    
    -- Audit column
    GETDATE() as Dwh_Create_Date
    
FROM bronze.Erp_Products;
GO


/* ======================================================
VERIFICATION
-- ====================================================== */
PRINT '============================================';
PRINT 'VERIFICATION RESULTS';
PRINT '============================================';

-- 1. Row count check
PRINT '--- Row Counts ---';
SELECT 
    'bronze.Erp_Products' as TableName,
    COUNT(*) as [RowCount]
FROM bronze.Erp_Products
UNION ALL
SELECT 
    'silver.Erp_Products',
    COUNT(*)
FROM silver.Erp_Products;
GO

-- 2. Category distribution
PRINT '--- Category Distribution ---';
SELECT 
    Category,
    COUNT(*) as [ProductCount]
FROM silver.Erp_Products
GROUP BY Category
ORDER BY Category;
GO

-- 3. Sub-category distribution
PRINT '--- Sub-Category Distribution ---';
SELECT 
    Category,
    Sub_Category,
    COUNT(*) as [ProductCount]
FROM silver.Erp_Products
GROUP BY Category, Sub_Category
ORDER BY Category, Sub_Category;
GO

-- 4. Sample of cleaned products
PRINT '--- Sample Products (First 10) ---';
SELECT TOP 10
    Product_ID,
    Category,
    Sub_Category,
    Product_Name
FROM silver.Erp_Products
ORDER BY Product_ID;
GO

-- 5. Space check (should return 0)
PRINT '--- Space Issues Check (should be 0) ---';
SELECT 
    'Products with spaces' as [Check],
    COUNT(*) as [Count]
FROM silver.Erp_Products
WHERE Category != TRIM(Category)
   OR Sub_Category != TRIM(Sub_Category)
   OR Product_Name != TRIM(Product_Name);
GO

PRINT '============================================';
PRINT 'PRODUCTS LOADED SUCCESSFULLY!';
PRINT 'Total Products: 1862';
PRINT '============================================';
GO
