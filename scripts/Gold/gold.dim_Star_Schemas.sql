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
