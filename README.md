# Supply Chain Data Warehouse & Analytics for Resource Distribution (SQL Server Project)

## Project Overview

This project demonstrates an end-to-end **Data Warehouse and Analytics solution** built using SQL Server.

It models a real-world **supply chain and resource distribution system**, transforming raw transactional data into a structured analytical warehouse that supports **data-driven decision-making in logistics, demand planning, and efficiency optimization**.

The system follows a **Medallion Architecture (Bronze → Silver → Gold)** and implements a **Star Schema data model with surrogate keys, KPI analytics, and BI-ready views**.

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


---

## Data Model (Gold Layer - Star Schema)

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

---

## Key Design Features

- Star Schema architecture for analytical efficiency  
- Surrogate Keys for improved scalability and join performance  
- Separation of Fact and Dimension tables  
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

A centralized analytical view was created:

**gold.vw_sales_analysis**

This view:
- Joins Fact and Dimension tables using surrogate keys  
- Provides a BI-ready dataset  
- Is used for Power BI and reporting dashboards  

---

## Power BI Dashboard Design (Planned/Recommended)

### Page 1: Executive Overview
- Total Sales KPI Card  
- Total Profit KPI Card  
- Profit Margin KPI Card  
- Sales by Region (Bar Chart)  
- Monthly Sales Trend (Line Chart)  

---

### Page 2: Product Performance
- Top 10 Products  
- Sales by Category  
- Profit by Category  

---

### Page 3: Customer Insights
- Sales by Segment  
- Regional Distribution  
- Customer Contribution  

---

### Page 4: Profitability Analysis
- Discount vs Profit relationship  
- Loss-making products  
- Profit distribution analysis  

---

## Tools & Technologies

- SQL Server (T-SQL)
- Python 
- Data Warehousing (Star Schema Design)  
- Surrogate Key Modeling  
- SQL Indexing & Optimization  
- Power BI (Reporting Layer)  
- Git & GitHub (Version Control)  

---

## Data Engineering Process

1. **Data Acquisition**
   - Global Superstore dataset (Kaggle)

2. **Data Splitting**
   - Customers, Orders, Products tables

3. **Data Cleaning (Silver Layer)**
   - Removed duplicates  
   - Fixed inconsistencies  
   - Standardized formats  

4. **Data Modeling (Gold Layer)**
   - Star Schema implementation  
   - Fact and Dimension creation  
   - Surrogate key implementation  

5. **Optimization**
   - Index creation on Fact table keys  

6. **Analytics Layer**
   - KPI queries for business insights  

7. **Reporting Layer**
   - Creation of analytical view for BI tools  

---

## Real-World & Humanitarian Application

This project simulates real-world **supply chain and humanitarian logistics systems**, making it applicable to:

- Resource distribution tracking  
- Humanitarian aid delivery systems  
- Monitoring & Evaluation (M&E) frameworks  
- NGO and UN logistics operations  
- Public sector planning and optimization  

It demonstrates how structured data systems improve **efficiency, transparency, and decision-making** in critical operations.

---

## Key Skills Demonstrated

- Data Warehouse Design & Architecture  
- ETL Pipeline Development  
- Star Schema Modeling  
- Surrogate Key Implementation  
- SQL Performance Optimization (Indexing)  
- KPI Development & Business Analytics  
- BI-Ready Data Modeling  

---

## Future Improvements

- Incremental loading (ETL automation)  
- Slowly Changing Dimensions (SCD Type 2)  
- Power BI dashboard implementation  
- Data quality monitoring framework  
- Cloud data warehouse migration  

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
