/* =======================================================================
PART A: DIAGONISIS OF CUSTOMERS TABLE
===========================================================================*/

/* DIAGNOSING CUSTOMERS TABLE
COLUMN 1: Customer_ID: Primary Key Integrity:
-The Customer_ID should be unique and never null. 
-Why? Because it is the PK that links to Orders. Would break relationships with Orders*/

SELECT
Customer_ID,
COUNT(*) as Total_Duplicates
FROM bronze.Crm_Customers
GROUP BY Customer_ID
HAVING COUNT(*) >1 OR Customer_ID IS NULL;

/* COLUMN 2: Customer_Name: String Quality - Hidden Characters
-Customer_Name should not have controlling charact6ers unwanted spaces. 
-The first letter of each name should also be UPPER CASE */

SELECT 
COUNT(*) as Special_Characters
FROM bronze.Crm_Customers
WHERE Customer_Name LIKE '%[' + CHAR(0) + '-' + CHAR(31) + ']%' ESCAPE '\';

-- Find names starting with lowercase
SELECT 
    Customer_ID,
    Customer_Name,
    'Starts with lowercase' Occurrence
FROM bronze.Crm_Customers
WHERE ASCII(LEFT(Customer_Name, 1)) BETWEEN 97 AND 122;  -- a-z

-- Find names with uppercase in middle (camelCase)
SELECT 
    Customer_ID,
    Customer_Name,
    'Internal capital' occurrence
FROM bronze.Crm_Customers
WHERE Customer_Name LIKE '%[a-z][A-Z]%' 
   OR Customer_Name LIKE '%[A-Z][A-Z][a-z]%';  -- Multiple caps in a row

-- Leading/trailing spaces cause mismatches in JOINs 

 SELECT 
 Customer_Name
 FROM bronze.Crm_Customers
 WHERE Customer_Name <> TRIM(Customer_Name);


 /* COLUMN 3: Segment: Domain Value Validation
 - The first Letter of each segment should be UPPER CASE
 -Check Segment against expected values (Consumer, Corporate, Home Office)
 */

SELECT 'Invalid Segment Values' as Check_Name,
       Segment,
       COUNT(*) as Occurrences
FROM bronze.Crm_Customers
WHERE Segment NOT IN ('Consumer', 'Corporate', 'Home Office')
GROUP BY Segment;
 
 -- Leading/trailing spaces 
 SELECT 
 Segment
 FROM bronze.Crm_Customers
 WHERE Segment <> TRIM(Segment);

/* COLUMN 4: Country: Domain Validation
- Check Country against expected country (United States) */

SELECT 
    'Invalid Country Values' as Check_Name,
    Country,
    COUNT(*) as Occurrence
FROM bronze.Crm_Customers
WHERE Country != 'United States'
  AND Country IS NOT NULL
GROUP BY Country;

-- Or See exactly what's in my Country column
SELECT 
    Country,
    COUNT(*) as Occurrence
FROM bronze.Crm_Customers
GROUP BY Country
ORDER BY Occurrence DESC;



/* COLUMN 5: Geographic Consistency 
City and State combinations should make sense
-"Springfield" exists in multiple states - that's OK!
-But "Los Angeles, Texas" would be wrong */ 

SELECT 
    City,
    State,
    COUNT(*) Occurrences
FROM bronze.Crm_Customers
GROUP BY City, State
HAVING COUNT(*) > 1
ORDER BY City, State;


/* COLUMN 7: Postal Code: Data Type and Format Validation
-Check if Postal_Code contains non-numeric values */

SELECT 'Invalid Postal_Code' as CheckName,
       COUNT(*) Occurrence
FROM bronze.Crm_Customers
WHERE TRY_CAST(Postal_Code AS INT) IS NULL
   OR Postal_Code < 0;  -- Negative postal codes?


/* DATA PROFILE SUMMARY
-Understand the data shape to help me spot outliers and anomalies */

SELECT 
    COUNT(*) as TotalRows,
    COUNT(DISTINCT Customer_ID) UniqueCustomers,
    COUNT(DISTINCT Segment) UniqueSegments,
    COUNT(DISTINCT Country) UniqueCountries,
    COUNT(DISTINCT City) UniqueCities,
    COUNT(DISTINCT State) UniqueStates,
    COUNT(DISTINCT Region) UniqueRegions,
    MIN(LEN(Customer_Name)) MinNameLength,
    MAX(LEN(Customer_Name)) MaxNameLength
FROM bronze.Crm_Customers;

/* =======================================================================
PART B: DIAGONISIS OF ORDERS TABLE
===========================================================================*/
