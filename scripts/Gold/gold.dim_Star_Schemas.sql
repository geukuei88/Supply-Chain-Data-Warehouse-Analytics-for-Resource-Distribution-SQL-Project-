/* ============================================================
   GOLD LAYER: DIMENSION TABLE - CUSTOMERS
   ------------------------------------------------------------
   Purpose:
   - Create a customer dimension table for analytics
   - Generate surrogate key (Customer_Key)
   - Capture descriptive customer attributes

   Source:
   - silver.Crm_Customers
   ============================================================ */

IF OBJECT_ID('gold.dim_customers', 'U') IS NOT NULL
    DROP TABLE gold.dim_customers;

SELECT 
    ROW_NUMBER() OVER (ORDER BY Customer_ID) AS Customer_Key,
    Customer_ID,
    Customer_Name,
    Region,
    Segment
INTO gold.dim_customers
FROM silver.Crm_Customers;



/* ============================================================
   GOLD LAYER: DIMENSION TABLE - PRODUCTS
   ------------------------------------------------------------
   Purpose:
   - Create a product dimension table for analytics
   - Generate surrogate key (Product_Key)
   - Store product classification attributes

   Source:
   - silver.Erp_Products
   ============================================================ */

IF OBJECT_ID('gold.dim_products', 'U') IS NOT NULL
    DROP TABLE gold.dim_products;

SELECT 
    ROW_NUMBER() OVER (ORDER BY Product_ID) AS Product_Key,
    Product_ID,
    Product_Name,
    Category,
    Sub_Category
INTO gold.dim_products
FROM silver.Erp_Products;



/* ============================================================
   GOLD LAYER: FACT TABLE - ORDERS
   ------------------------------------------------------------
   Purpose:
   - Create central fact table for sales transactions
   - Link to dimension tables using surrogate keys
   - Store measurable business metrics

   Source:
   - silver.Erp_Orders

   Joins:
   - Customer_ID → dim_customers
   - Product_ID  → dim_products
   ============================================================ */

IF OBJECT_ID('gold.fact_orders', 'U') IS NOT NULL
    DROP TABLE gold.fact_orders;

SELECT 
    o.Order_ID,
    o.Order_Date,
    o.Ship_Date,
    o.Ship_Mode,

    dc.Customer_Key,
    dp.Product_Key,

    o.Sales,
    o.Quantity,
    o.Discount,
    o.Profit

INTO gold.fact_orders
FROM silver.Erp_Orders o

LEFT JOIN gold.dim_customers dc
    ON o.Customer_ID = dc.Customer_ID

LEFT JOIN gold.dim_products dp
    ON o.Product_ID = dp.Product_ID;

GO



/* ============================================================
   GOLD LAYER: ANALYTICAL VIEW - SALES ANALYSIS
   ------------------------------------------------------------
   Purpose:
   - Provide a business-friendly dataset
   - Combine fact and dimension tables
   - Enable reporting and dashboarding

   Output:
   - Flattened dataset for analysis (star schema view)
   ============================================================ */

CREATE OR ALTER VIEW gold.vw_sales_analysis AS
SELECT
    f.Order_ID,
    f.Order_Date,
    f.Ship_Date,
    f.Ship_Mode,

    c.Customer_Name,
    c.Region,
    c.Segment,

    p.Product_Name,
    p.Category,

    f.Sales,
    f.Quantity,
    f.Discount,
    f.Profit

FROM gold.fact_orders f
JOIN gold.dim_customers c
    ON f.Customer_Key = c.Customer_Key
JOIN gold.dim_products p
    ON f.Product_Key = p.Product_Key;



/* ============================================================
   PERFORMANCE OPTIMIZATION: INDEXING
   ------------------------------------------------------------
   Purpose:
   - Improve query performance on fact table joins
   - Optimize filtering and aggregation operations
   ============================================================ */

-- =====================================
-- INDEX: Customer_Key
-- =====================================
IF EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'idx_fact_customer_key'
      AND object_id = OBJECT_ID('gold.fact_orders')
)
DROP INDEX idx_fact_customer_key ON gold.fact_orders;

CREATE INDEX idx_fact_customer_key 
ON gold.fact_orders(Customer_Key);


-- =====================================
-- INDEX: Product_Key
-- =====================================
IF EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'idx_fact_product_key'
      AND object_id = OBJECT_ID('gold.fact_orders')
)
DROP INDEX idx_fact_product_key ON gold.fact_orders;

CREATE INDEX idx_fact_product_key 
ON gold.fact_orders(Product_Key);
