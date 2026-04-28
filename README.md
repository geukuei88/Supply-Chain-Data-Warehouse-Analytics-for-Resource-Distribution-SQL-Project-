# Supply Chain Data Warehouse & Analytics for Resource Distribution (SQL Server Project)

## Project Overview

This project demonstrates an end-to-end **Data Warehouse and Analytics solution** built using SQL Server.

It models a real-world **supply chain and resource distribution system**, transforming raw transactional data into a structured analytical warehouse that supports **data-driven decision-making in logistics, demand planning, and efficiency optimization**.

The system follows a **Medallion Architecture (Bronze → Silver → Gold)** and implements a **Star Schema data model with surrogate keys, KPI analytics, and BI-ready views**.

---

## Why This Project Matters

This project demonstrates how raw operational data can be transformed into a structured analytics system that supports real-world decision-making.

It reflects real industry practices used in:
- Supply chain systems  
- E-commerce analytics  
- Humanitarian logistics platforms  

---

## Project Objectives

- Design and implement a scalable data warehouse using SQL Server  
- Clean, transform, and structure raw supply chain data  
- Build a **Star Schema (Fact & Dimension model)**  
- Implement **Surrogate Keys for optimized relational integrity**  
- Develop a **KPI Analytical Layer for business insights**  
- Create **BI-ready views for reporting tools (Power BI)**  
- Support decision-making in **resource distribution and logistics**  

---

## Data Architecture
![Data Architecture Approach](Docs/data_architecture_approach.png) 

[View Data Warehouse Layers](Docs/data_warehouse_layers.png)

### Data Flow
Source Data → Bronze Layer → Silver Layer → Gold Layer → Analytics & BI

### Layer Description

- **Bronze Layer**  
  Raw ingested data from source systems with no transformations.

- **Silver Layer**  
  Cleaned and standardized data.  
  Data quality issues such as duplicates and inconsistencies are resolved.

- **Gold Layer**  
  Business-ready data modeled using a Star Schema (Fact & Dimension tables) optimized for analytics and reporting.

> Note: While the Silver layer can be queried for validation and intermediate analysis, the **Gold layer serves as the single source of truth for reporting and analytics**.

---

## Data Model (Gold Layer - Star Schema)

Full Star Schema Available on `/Docs/Star Schema.png

### Fact Table

**fact_orders**
- Order_ID  
- Order_Date  
- Ship_Date  
- Ship_Mode  
- Sales  
- Quantity  
- Discount  
- Profit  
- Customer_Key (FK)  
- Product_Key (FK)  

---

### Dimension Tables

**dim_customers**
- Customer_Key (PK - Surrogate Key)  
- Customer_ID (Business Key)  
- Customer_Name  
- Region  
- Segment  

**dim_products**
- Product_Key (PK - Surrogate Key)  
- Product_ID (Business Key)  
- Product_Name  
- Category  
- Sub_Category  

---

## Data Dictionary (Summary)

> Full data dictionary available in `/docs/Data Dictionary.md`

### fact_orders
- Sales → Revenue per transaction  
- Quantity → Number of items sold  
- Discount → Discount applied  
- Profit → Profit or loss (can be negative)  

### dim_customers
- Segment → Consumer, Corporate, Home Office  
- Region → Geographic classification  

### dim_products
- Category → High-level grouping  
- Sub_Category → Detailed product classification  

---

## Key Design Features

- Star Schema architecture for analytical efficiency  
- Surrogate Keys for improved scalability and join performance  
- Separation of Fact and Dimension tables  
- Separation of storage (Silver) and analytics (Gold)  
- Fully structured Gold layer for analytics  
- Reusable BI-ready views  

---

## Performance Optimization

Indexes implemented on Fact table:

- Customer_Key  
- Product_Key  

These indexes improve:
- Join performance between Fact and Dimensions  
- KPI query execution speed  
- Dashboard responsiveness  

---

## KPI Analytical Layer

The following business questions are answered:

### Business Performance
- Total Sales, Profit, Quantity, and Orders  
- Profit Margin analysis  

### Geographic Analysis
- Sales by Region  
- Profit by Region  

### Product Performance
- Sales by Category  
- Top 10 Products by Revenue  
- Product Profitability  

### Customer Analysis
- Sales by Customer Segment  
- Customer contribution to revenue  

### Pricing & Efficiency
- Discount impact on Profit  
- Loss-making vs profitable segments  

### Time-Based Trends
- Monthly Sales and Profit trends  

---

## Reporting Layer (Views)

**gold.vw_sales_analysis**

This view:
- Joins Fact and Dimension tables using surrogate keys  
- Provides a BI-ready dataset  
- Supports dashboards and reporting  

---

## Power BI Dashboard Design (Planned)

### Page 1: Executive Overview
- Total Sales KPI Card  
- Total Profit KPI Card  
- Profit Margin KPI Card  
- Sales by Region  
- Monthly Sales Trend  

### Page 2: Product Performance
- Top 10 Products  
- Sales by Category  
- Profit by Category  

### Page 3: Customer Insights
- Sales by Segment  
- Regional Distribution  
- Customer Contribution  

### Page 4: Profitability Analysis
- Discount vs Profit  
- Loss-making products  
- Profit distribution  

---

## Tools & Technologies

- SQL Server (T-SQL)  
- Python  
- Data Warehousing (Star Schema Design)  
- Surrogate Key Modeling  
- SQL Indexing & Optimization  
- Power BI  
- Git & GitHub  

---

## Data Engineering Process

1. Data Acquisition (Global Superstore dataset)  
2. Data Splitting (Customers, Orders, Products)  
3. Data Cleaning (Silver Layer)  
4. Data Modeling (Gold Layer)  
5. Performance Optimization (Indexing)  
6. Analytics Layer (KPI queries)  
7. Reporting Layer (Views for BI tools)  

---

## Real-World & Humanitarian Application

This project simulates real-world **supply chain and humanitarian logistics systems**, applicable to:

- Resource distribution tracking  
- Humanitarian aid delivery  
- Monitoring & Evaluation (M&E)  
- NGO and UN logistics operations  
- Public sector planning  

---

## Key Skills Demonstrated

- Data Warehouse Design & Architecture  
- ETL Pipeline Development  
- Star Schema Modeling  
- Surrogate Key Implementation  
- SQL Performance Optimization  
- KPI Development & Analytics  
- BI-Ready Data Modeling  

---

## Future Improvements

- Incremental loading (ETL automation)  
- Slowly Changing Dimensions (SCD Type 2)  
- Power BI dashboard implementation  
- Data quality monitoring  
- Cloud migration (Azure/AWS)  

---

## Project Status

Completed as a structured SQL Data Warehousing and Analytics project with ongoing enhancements for advanced analytics and BI integration.

---

## Author
Geu Kuei

Data Analyst | Data Engineer (Aspiring) | Monitoring & Evaluation (M&E) | Public Health & Education Data  
ALX Data Engineering Fellow

## License
This project is licensed under the MIT License. You are free to use, modify, and share this project with proper attribution.
