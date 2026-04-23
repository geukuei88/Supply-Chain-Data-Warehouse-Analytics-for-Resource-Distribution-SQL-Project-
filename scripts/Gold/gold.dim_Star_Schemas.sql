IF OBJECT_ID('gold.dim_Customers', 'U') IS NOT NULL
    DROP TABLE gold.dim_customers;

SELECT DISTINCT
    Customer_ID,
    Customer_Name,
    Region,
    Segment
INTO gold.dim_Customers
FROM silver.Crm_Customers
WHERE Customer_ID IS NOT NULL;

IF OBJECT_ID('gold.dim_Products', 'U') IS NOT NULL
    DROP TABLE gold.dim_products;

SELECT 
    ROW_NUMBER() OVER (ORDER BY Product_ID) AS Product_Key,
    Product_ID,
    Product_Name,
    Category,
    Sub_Category
INTO gold.dim_Products
FROM silver.Erp_Products
WHERE Product_ID IS NOT NULL;

IF OBJECT_ID('gold.fact_Orders', 'U') IS NOT NULL
    DROP TABLE gold.fact_orders;

SELECT 
    o.Order_ID,
    o.Order_Date,
    o.Ship_Date,
    o.Ship_Mode,

    o.Customer_ID,
    o.Product_ID,

    o.Sales,
    o.Quantity,
    o.Discount,
    o.Profit

INTO gold.fact_Orders
FROM silver.Erp_Orders o
WHERE o.Customer_ID IS NOT NULL
  AND o.Product_ID IS NOT NULL;
                                        
VIEWS
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
    ON f.Customer_ID = c.Customer_ID
JOIN gold.dim_products p
    ON f.Product_ID = p.Product_ID;

-- =====================================
-- CUSTOMER INDEX
-- =====================================
IF EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'idx_fact_customer'
      AND object_id = OBJECT_ID('gold.fact_orders')
)
DROP INDEX idx_fact_customer ON gold.fact_orders;

CREATE INDEX idx_fact_customer 
ON gold.fact_orders(Customer_ID);


-- =====================================
-- PRODUCT INDEX
-- =====================================
IF EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'idx_fact_product'
      AND object_id = OBJECT_ID('gold.fact_orders')
)
DROP INDEX idx_fact_product ON gold.fact_orders;

CREATE INDEX idx_fact_product 
ON gold.fact_orders(Product_ID);
