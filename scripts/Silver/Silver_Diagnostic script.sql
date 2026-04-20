/* ============================================================================
DATA QUALITY ASSESSMENT: CUSTOMERS, PRODUCTS AND ORDERS TABLES
Project: Supply Chain Data Warehouse & Analytics for Resource Distribution
Description:

This script performs data quality checks and validation on the Customers, Products
and Orders tables to ensure consistency, reliability, and suitability for analytical reporting.

These checks are essential for building a robust data warehouse and supporting
Monitoring & Evaluation (M&E) processes in data-driven environments.
============================================================================ */

/* ----------------------------------------------------------------------------
1. PRIMARY KEY VALIDATION: Customer_ID
- Ensure uniqueness and non-null values
- Critical for maintaining relationships with Orders table
---------------------------------------------------------------------------- */

SELECT
    Customer_ID,
    COUNT(*) AS Duplicate_Count
FROM bronze.Crm_Customers
GROUP BY Customer_ID
HAVING COUNT(*) > 1 OR Customer_ID IS NULL;


/* ----------------------------------------------------------------------------
2. STRING QUALITY CHECK: Customer_Name
- Detect hidden characters, improper casing, and unwanted spaces
---------------------------------------------------------------------------- */

-- Hidden/non-printable characters
SELECT 
    COUNT(*) AS Special_Characters
FROM bronze.Crm_Customers
WHERE Customer_Name LIKE '%[' + CHAR(0) + '-' + CHAR(31) + ']%';

-- Names starting with lowercase
SELECT 
    Customer_ID,
    Customer_Name,
    'Starts with lowercase' AS Issue
FROM bronze.Crm_Customers
WHERE ASCII(LEFT(Customer_Name, 1)) BETWEEN 97 AND 122;

-- Improper casing
SELECT 
    Customer_ID,
    Customer_Name,
    'Internal capital' AS Issue
FROM bronze.Crm_Customers
WHERE Customer_Name LIKE '%[a-z][A-Z]%'
  AND Customer_Name NOT LIKE '% %'
  AND Customer_Name NOT LIKE '%-%';

-- Leading/trailing spaces
SELECT
    Customer_Name
FROM bronze.Crm_Customers
WHERE Customer_Name <> TRIM(Customer_Name);


/* ----------------------------------------------------------------------------
3. DOMAIN VALIDATION: Segment
- Ensure values fall within expected categories
---------------------------------------------------------------------------- */

SELECT 
    Segment,
    COUNT(*) AS Occurrences
FROM bronze.Crm_Customers
WHERE Segment NOT IN ('Consumer', 'Corporate', 'Home Office')
GROUP BY Segment;

-- Check for unwanted spaces
SELECT 
    Segment
FROM bronze.Crm_Customers
WHERE Segment <> TRIM(Segment);


/* ----------------------------------------------------------------------------
4. DOMAIN VALIDATION: Country
- Validate expected geographic consistency
---------------------------------------------------------------------------- */

SELECT 
    Country,
    COUNT(*) AS Occurrences
FROM bronze.Crm_Customers
WHERE Country != 'United States'
  AND Country IS NOT NULL
GROUP BY Country;

-- Full distribution overview
SELECT 
    Country,
    COUNT(*) AS Occurrences
FROM bronze.Crm_Customers
GROUP BY Country
ORDER BY Occurrences DESC;


/* ----------------------------------------------------------------------------
5. GEOGRAPHIC CONSISTENCY CHECK
- Validate logical City-State combinations
---------------------------------------------------------------------------- */

SELECT 
    City,
    State,
    COUNT(*) AS Occurrences
FROM bronze.Crm_Customers
GROUP BY City, State
HAVING COUNT(*) > 1
ORDER BY City, State;


/* ----------------------------------------------------------------------------
6. POSTAL CODE VALIDATION
- Ensure numeric and valid values
---------------------------------------------------------------------------- */

SELECT 
    COUNT(*) AS Invalid_Postal_Codes
FROM bronze.Crm_Customers
WHERE TRY_CAST(Postal_Code AS INT) IS NULL
   OR Postal_Code < 0;


/* ----------------------------------------------------------------------------
7. DATA PROFILING SUMMARY
- Provides an overview of dataset structure and variability
---------------------------------------------------------------------------- */

SELECT 
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Customer_ID) AS Unique_Customers,
    COUNT(DISTINCT Segment) AS Unique_Segments,
    COUNT(DISTINCT Country) AS Unique_Countries,
    COUNT(DISTINCT City) AS Unique_Cities,
    COUNT(DISTINCT State) AS Unique_States,
    COUNT(DISTINCT Region) AS Unique_Regions,
    MIN(LEN(Customer_Name)) AS Min_Name_Length,
    MAX(LEN(Customer_Name)) AS Max_Name_Length
FROM bronze.Crm_Customers;


/* ============================================================================
B. PRODUCTS TABLE
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


/* ============================================================================
NEXT STEP:
Proceed to Silver layer validation (post-cleaning checks)
============================================================================ */
