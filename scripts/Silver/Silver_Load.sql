scriptsscripts-- ======================================================
-- SILVER LAYER: Clean and Load Customers
-- ======================================================

-- Clear existing customers data (if any)
TRUNCATE TABLE silver.Crm_Customers;
GO

-- ======================================================
-- LOAD & CLEAN CUSTOMERS
-- ======================================================
INSERT INTO silver.Crm_Customers (
    Customer_ID,
    Customer_Name,
    Segment,
    Country,
    City,
    State,
    Postal_Code,
    Region,
    Dwh_Create_Date
)
SELECT 
    -- 1. Customer_ID (no cleaning needed - primary key)
    Customer_ID,
    
    -- 2. Customer_Name: REMOVE CONTROL CHARACTERS
    -- This fixes the \h, \f, \b issues found in your data
    REPLACE(REPLACE(REPLACE(REPLACE(
        Customer_Name, 
        CHAR(8), ''),   -- \b (backspace) - found in your data
        CHAR(12), ''),  -- \f (form feed) - found in your data
        CHAR(10), ' '), -- \n (new line) - replace with space
        CHAR(13), ''    -- \r (carriage return)
    ) as Customer_Name,
    
    -- 3. Segment: STANDARDIZE TO PROPER CASE
    CASE UPPER(TRIM(Segment))
        WHEN 'CONSUMER' THEN 'Consumer'
        WHEN 'CORPORATE' THEN 'Corporate'
        WHEN 'HOME OFFICE' THEN 'Home Office'
        ELSE Segment  -- Keep as-is if unexpected
    END as Segment,
    
    -- 4. Country (all USA - no cleaning needed)
    Country,
    
    -- 5. City: TRIM WHITESPACE
    TRIM(City) as City,
    
    -- 6. State (no cleaning needed)
    State,
    
    -- 7. Postal_Code (no cleaning needed)
    Postal_Code,
    
    -- 8. Region (no cleaning needed for now)
    Region,
    
    -- 9. Audit column
    GETDATE() as Dwh_Create_Date
    
FROM bronze.Crm_Customers;
GO

-- ======================================================
-- VERIFY THE CLEANING WORKED
-- ======================================================

-- 1. Check that special characters are GONE (should return 0)
PRINT '--- CHECK 1: Special Characters Removed ---';
SELECT 'Special Characters Check' as CheckName,
       COUNT(*) as IssueCount
FROM silver.Crm_Customers
WHERE Customer_Name LIKE '%[' + CHAR(0) + '-' + CHAR(31) + ']%' ESCAPE '\';

-- 2. Verify the 6 problem customers are now clean
PRINT '--- CHECK 2: Previously Problematic Customers ---';
SELECT 
    Customer_ID,
    Customer_Name as Cleaned_Name,
    'Should now be clean' as Status
FROM silver.Crm_Customers
WHERE Customer_ID IN ('RF-19840', 'RP-19390', 'PB-19105', 'BF-11020', 'AH-10690', 'NF-18475');

-- 3. Check Segment standardization
PRINT '--- CHECK 3: Segment Distribution ---';
SELECT 
    Segment,
    COUNT(*) as CustomerCount
FROM silver.Crm_Customers
GROUP BY Segment
ORDER BY Segment;

-- 4. Compare row counts (should match)
PRINT '--- CHECK 4: Row Count Comparison ---';
SELECT 
    'bronze.Crm_Customers' as TableName,
    COUNT(*) as [RowCount]
FROM bronze.Crm_Customers
UNION ALL
SELECT 
    'silver.Crm_Customers',
    COUNT(*)
FROM silver.Crm_Customers;

-- 5. Show sample of cleaned data
PRINT '--- CHECK 5: Sample Cleaned Data ---';
SELECT TOP 10 
    Customer_ID,
    Customer_Name,
    Segment,
    City,
    Region
FROM silver.Crm_Customers
ORDER BY Customer_ID;
GO

PRINT '============================================';
PRINT 'Customers cleaned and loaded successfully!';
PRINT '============================================';
