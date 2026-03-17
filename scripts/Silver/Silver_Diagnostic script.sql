/* DIAGNOSING CUSTOMERS TABLE
COLUMN 1: Customer_ID: Primary Key Integrity:
-The Customer_ID should be unique and never null. 
-Why? Because it is the PK that links to Orders. Would break relationships with Orders*/

SELECT
Customer_ID,
COUNT(*) Total_Duplicates
FROM bronze.Crm_Customers
GROUP BY Customer_ID
HAVING COUNT(*) >1 OR Customer_ID IS NULL;

/* COLUMN 2: Customer_Name: String Quality - Hidden Characters
-Customer_Name should not have controlling charact6ers unwanted spaces. 
-The first letter of each name should also be UPPER CASE */

SELECT 
COUNT(*) Special_Characters
FROM bronze.Crm_Customers
WHERE Customer_Name LIKE '%[' + CHAR(0) + '-' + CHAR(31) + ']%' ESCAPE '\';


-- Find names starting with lowercase
SELECT 
    Customer_ID,
    Customer_Name,
    'Starts with lowercase' Issue
FROM bronze.Crm_Customers
WHERE ASCII(LEFT(Customer_Name, 1)) BETWEEN 97 AND 122;  -- a-z

-- Find names with uppercase in middle (camelCase)
SELECT 
    Customer_ID,
    Customer_Name,
    'Internal capital' Issue
FROM bronze.Crm_Customers
WHERE Customer_Name LIKE '%[a-z][A-Z]%' 
   OR Customer_Name LIKE '%[A-Z][A-Z][a-z]%';  -- Multiple caps in a row


-- Leading/trailing spaces cause mismatches in JOINs 

 SELECT 
 Customer_Name
 FROM bronze.Crm_Customers
 WHERE Customer_Name <> TRIM(Customer_Name);


 /* COLUMN 3: Segment: Domain Values - Segment
 - The first Letter of each segment should be UPPER CASE
 -Segment should only have 3 values: Consumer, Corporate, Home Office
 */

 SELECT 
 Segment,
 COUNT(*) Count_Values
 FROM bronze.Crm_Customers
 GROUP BY Segment;
 

 -- Leading/trailing spaces 
 SELECT 
 Segment
 FROM bronze.Crm_Customers
 WHERE Segment <> TRIM(Segment);

/* COLUMN 4: Geographic Consistency 
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

/* DATA PROFILE SUMMARY
-Understand the shape of your data
-Helps spot outliers and anomalies */

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
