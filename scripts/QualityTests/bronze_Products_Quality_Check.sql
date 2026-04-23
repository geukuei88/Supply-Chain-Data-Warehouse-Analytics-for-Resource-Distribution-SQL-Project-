/* ============================================================================
PRODUCTS TABLE QUALITY ASSESSMENT
This script performs data quality checks and validation on the Products table.
Focus areas include:
- Key integrity
- Text standardization
- Domain validation
- Category relationships
- Data profiling
============================================================================ */


/* ----------------------------------------------------------------------------
1. PRIMARY KEY VALIDATION: Product_ID
- Ensure uniqueness and non-null values
- Critical for joins with fact tables
---------------------------------------------------------------------------- */

SELECT
    Product_ID,
    COUNT(*) AS Duplicate_Count
FROM bronze.Erp_Products
GROUP BY Product_ID
HAVING COUNT(*) > 1 OR Product_ID IS NULL;


/* ----------------------------------------------------------------------------
2. STRING QUALITY CHECK: Product_Name
- Detect hidden characters, unwanted spaces, and anomalies
---------------------------------------------------------------------------- */

-- Hidden/non-printable characters
SELECT 
    COUNT(*) AS Special_Characters
FROM bronze.Erp_Products
WHERE Product_Name LIKE '%[' + CHAR(0) + '-' + CHAR(31) + ']%';

-- Leading/trailing spaces
SELECT 
    Product_ID,
    Product_Name
FROM bronze.Erp_Products
WHERE Product_Name <> TRIM(Product_Name);

-- Extremely short or suspicious names
SELECT 
    Product_ID,
    Product_Name,
    LEN(Product_Name) AS Name_Length
FROM bronze.Erp_Products
WHERE LEN(Product_Name) < 3;


/* ----------------------------------------------------------------------------
3. CATEGORY VALIDATION
- Ensure Category values are clean and consistent
---------------------------------------------------------------------------- */

-- Distribution overview
SELECT 
    Category,
    COUNT(*) AS Product_Count
FROM bronze.Erp_Products
GROUP BY Category
ORDER BY Product_Count DESC;

-- Leading/trailing spaces
SELECT 
    Category
FROM bronze.Erp_Products
WHERE Category <> TRIM(Category);

-- Case inconsistency check
SELECT 
    Category
FROM bronze.Erp_Products
WHERE Category != UPPER(LEFT(TRIM(Category),1)) + 
                  LOWER(SUBSTRING(TRIM(Category),2,LEN(TRIM(Category))));


/* ----------------------------------------------------------------------------
4. SUB-CATEGORY VALIDATION
- Ensure Sub_Category consistency and cleanliness
---------------------------------------------------------------------------- */

-- Distribution
SELECT 
    Sub_Category,
    COUNT(*) AS Product_Count
FROM bronze.Erp_Products
GROUP BY Sub_Category
ORDER BY Product_Count DESC;

-- Leading/trailing spaces
SELECT 
    Sub_Category
FROM bronze.Erp_Products
WHERE Sub_Category <> TRIM(Sub_Category);

-- Case inconsistency
SELECT 
    Sub_Category
FROM bronze.Erp_Products
WHERE Sub_Category != UPPER(LEFT(TRIM(Sub_Category),1)) + 
                      LOWER(SUBSTRING(TRIM(Sub_Category),2,LEN(TRIM(Sub_Category))));


/* ----------------------------------------------------------------------------
5. CATEGORY–SUBCATEGORY RELATIONSHIP CHECK
- Detect inconsistent mappings (data integrity issue)
---------------------------------------------------------------------------- */

SELECT 
    Category,
    Sub_Category,
    COUNT(*) AS Occurrences
FROM bronze.Erp_Products
GROUP BY Category, Sub_Category
ORDER BY Category, Sub_Category;


/* ----------------------------------------------------------------------------
6. NULL & COMPLETENESS CHECK
- Identify missing critical fields
---------------------------------------------------------------------------- */

SELECT 
    COUNT(*) AS Missing_Category
FROM bronze.Erp_Products
WHERE Category IS NULL OR Category = '';

SELECT 
    COUNT(*) AS Missing_Sub_Category
FROM bronze.Erp_Products
WHERE Sub_Category IS NULL OR Sub_Category = '';

SELECT 
    COUNT(*) AS Missing_Product_Name
FROM bronze.Erp_Products
WHERE Product_Name IS NULL OR TRIM(Product_Name) = '';


/* ----------------------------------------------------------------------------
7. DUPLICATE BUSINESS LOGIC CHECK
- Detect possible duplicate products
---------------------------------------------------------------------------- */

SELECT 
    Product_Name,
    Category,
    Sub_Category,
    COUNT(*) AS Duplicate_Count
FROM bronze.Erp_Products
GROUP BY Product_Name, Category, Sub_Category
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;


/* ----------------------------------------------------------------------------
8. DATA PROFILING SUMMARY
- Provides overall structure and variability insights
---------------------------------------------------------------------------- */

SELECT 
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Product_ID) AS Unique_Products,
    COUNT(DISTINCT Category) AS Unique_Categories,
    COUNT(DISTINCT Sub_Category) AS Unique_Sub_Categories,
    MIN(LEN(Product_Name)) AS Min_Name_Length,
    MAX(LEN(Product_Name)) AS Max_Name_Length
FROM bronze.Erp_Products;
