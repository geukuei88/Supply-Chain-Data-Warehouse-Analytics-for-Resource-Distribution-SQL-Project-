/* ============================================================================
DATA QUALITY ASSESSMENT: CUSTOMERS
Project: Supply Chain Data Warehouse & Analytics for Resource Distribution
Description:

This script performs data quality checks and validation on the Customers tables 
to ensure consistency, reliability, and suitability for analytical reporting.

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

