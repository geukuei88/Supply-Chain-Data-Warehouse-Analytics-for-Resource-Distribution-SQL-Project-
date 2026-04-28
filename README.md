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

Full Data Warehouse Design available on [View Data Warehouse Design](Docs/data_warehouse_design.drawio.png)


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

Full Star Schema available on `[View Star Schema](Docs/star_schema.drawio.png) 

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

> Full data dictionary available on `[View Data Dictionary](Docs/data_dictionary.md)

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


## KPI Coverage & Analytics Roadmap

This section maps **Project 1 (Data Warehouse)** KPI questions to **Project 2 (Data Science Capstone)** deliverables. Business questions are explicitly answered using either **SQL/BI (Descriptive)** or **Machine Learning (Predictive)** methods.

**Current Status:** Project 2 is in **planning phase**. All items below are scoped and ready for implementation.

---

### Part A: SQL / Power BI Layer (Descriptive Analytics)

*These questions will be answered directly from the data warehouse using SQL queries and Power BI dashboards.*

| Project 1 KPI Question | Answer Method | Project 2 Artifact | Status |
|------------------------|---------------|---------------------|--------|
| **1a. Monthly/yearly sales trends** | SQL Aggregation | `gold.vw_sales_analysis` + Power BI line chart |  Planned |
| **1b. Regions with highest revenue** | SQL GROUP BY | `gold.vw_sales_analysis` + Power BI map |  Planned |
| **1c. Top 10 best-selling products** | SQL ORDER BY + LIMIT | `gold.vw_sales_analysis` + Power BI table |  Planned |
| **1d. Product categories contributing most to profit** | SQL SUM(profit) GROUP BY | `gold.vw_sales_analysis` + Power BI bar chart |  Planned |
| **1e. Average order value by segment** | SQL AVG(sales) GROUP BY | Calculated metric in `gold.vw_sales_analysis` |  Planned |
| **2a. Most profitable sub-categories** | SQL SUM(profit) GROUP BY | Power BI "Product Profitability" page |  Planned |
| **2c. Products with highest discount rates** | SQL ORDER BY discount DESC | `gold.vw_sales_analysis` + filter |  Planned |
| **2d. Profit margin by category** | SQL calculated column | `gold.vw_sales_analysis` |  Planned |
| **2e. Loss leaders (negative profit)** | SQL WHERE profit < 0 | Power BI "Loss-making Products" filter |  Planned |
| **3e. Ship mode most used by each segment** | SQL COUNT + GROUP BY | `gold.vw_sales_analysis` crosstab |  Planned |
| **4a. Cities with most profit** | SQL SUM(profit) GROUP BY city | `gold.vw_sales_analysis` + city aggregation |  Planned |
| **4b. Sales distribution across states** | SQL SUM(sales) GROUP BY state | Power BI "Regional Distribution" map |  Planned |
| **5b. Months with highest/lowest sales** | SQL EXTRACT(MONTH) + aggregation | `gold.vw_sales_analysis` + monthly view |  Planned |
| **5c. Discounts by time of year** | SQL EXTRACT(MONTH) + AVG(discount) | Power BI "Discount vs Time" scatter |  Planned |
| **Discount impact on profit** | SQL correlation query | Power BI "Discount vs Profit" scatter |  Planned |
| **Loss-making vs profitable segments** | SQL CASE WHEN profit < 0 THEN 'Loss' ELSE 'Profit' END | Power BI "Profitability Analysis" |  Planned |
| **Customer contribution to revenue** | SQL SUM(sales) GROUP BY customer + percent of total | Power BI Pareto chart |  Planned |

---

### Part B: Machine Learning Layer (Predictive Analytics)

*These questions require ML models to predict, forecast, or recommend.*

| Project 1 KPI Question | ML Task | Target Variable | Project 2 Artifact | Status |
|------------------------|---------|-----------------|---------------------|--------|
| **2b. Products frequently bought together** | Association Rule Mining / Market Basket Analysis | Product pairs | `04_recommendation_system.ipynb` |  Planned |
| **3a. Average shipping time by ship mode** | Regression / Classification | Shipping days | `05_shipping_classification.ipynb` |  Planned |
| **5a. Seasonal sales patterns** | Time Series Decomposition + Forecasting | Sales (next month/quarter) | `01_sales_forecasting.ipynb` |  Planned |
| **What will be sales for next quarter?** | Time Series Forecasting | Future Sales | `01_sales_forecasting.ipynb` |  Planned |
| **Which products will be top sellers next month?** | Time Series + Ranking | Product Sales Forecast | `01_sales_forecasting.ipynb` |  Planned |
| **Can we segment customers into distinct groups?** | Clustering (K-Means, DBSCAN) | Customer Segment Labels | `02_customer_segmentation.ipynb` |  Planned |
| **What are characteristics of high-value customers?** | Clustering + Profile Analysis | Customer Cluster Profiles | `02_customer_segmentation.ipynb` |  Planned |
| **Which customers are likely to churn?** | Binary Classification | Will Order Again? (Yes/No) | `07_churn_prediction.ipynb` |  Planned |
| **Can we predict if an order will be profitable?** | Classification (Binary) | Profit > 0 (Yes/No) | `03_profit_prediction.ipynb` |  Planned |
| **What factors most influence profit?** | Feature Importance (Random Forest / SHAP) | Profit Drivers | `03_profit_prediction.ipynb` |  Planned |
| **What is optimal discount for maximum profit?** | Optimization / Regression | Discount % | `06_discount_optimization.ipynb` |  Planned |
| **Can we predict profit margin by category?** | Regression | Profit Margin % | `03_profit_prediction.ipynb` |  Planned |
| **What products should we recommend to a customer?** | Collaborative Filtering / Association Rules | Product Recommendations | `04_recommendation_system.ipynb` |  Planned |
| **Can we predict which shipping mode a customer will choose?** | Multi-Class Classification | Ship Mode (Standard, Express, etc.) | `05_shipping_classification.ipynb` |  Planned |
| **What factors influence shipping mode selection?** | Feature Importance | Key Drivers | `05_shipping_classification.ipynb` |  Planned |
| **Which customers are at risk of not ordering again?** | Binary Classification | Will Order Again? (Yes/No) | `07_churn_prediction.ipynb` |  Planned |
| **What factors indicate a customer might churn?** | Feature Importance + Survival Analysis | Churn Signals | `07_churn_prediction.ipynb` |  Planned |
| **Can we identify churn signals early?** | Early Warning System | Days to Churn | `07_churn_prediction.ipynb` |  Planned |

---

### Part C: SQL Views Reference (To Be Created)

| View Name | Description | Answers These KPIs | Status |
|-----------|-------------|---------------------|--------|
| `gold.vw_sales_analysis` | Primary BI dataset with sales, profit, discount, product, region, segment, date | 1a, 1b, 1c, 1d, 1e, 2c, 2d, 2e, 3e, 4a, 4b, 5b, 5c |  To Be Created |
| `gold.vw_monthly_trends` | Monthly aggregated sales and profit | 1a, 5a, 5b |  To Be Created |
| `gold.vw_customer_metrics` | Customer lifetime value, order count, churn risk flags | Customer contribution, churn features |  To Be Created |
| `gold.vw_product_performance` | Product-level profit, discount, loss leader flags | 1c, 2a, 2c, 2d, 2e |  To Be Created |

---

### Part D: Power BI Dashboard Mapping (To Be Built)

| Dashboard Page | SQL View Used | Answers These KPIs (SQL Layer) | ML Models Referenced | Status |
|----------------|---------------|-------------------------------|----------------------|--------|
| **Executive Overview** | `vw_sales_analysis`, `vw_monthly_trends` | 1a, 1b, 1e, 5b | Forecasting (Notebook 01) |  Planned |
| **Product Performance** | `vw_sales_analysis`, `vw_product_performance` | 1c, 1d, 2a, 2c, 2d, 2e | Recommendation (Notebook 04) |  Planned |
| **Customer Insights** | `vw_sales_analysis`, `vw_customer_metrics` | 1e, 3e, customer contribution | Segmentation (02), Churn (07) |  Planned |
| **Profitability Analysis** | `vw_sales_analysis` | Discount impact, loss leaders | Profit Prediction (03), Discount Optimization (06) |  Planned |
| **Geographic Analysis** | `vw_sales_analysis` | 1b, 4a, 4b | None (pure SQL) |  Planned |
| **Shipping Insights** | `vw_sales_analysis` | 3e | Shipping Classification (05) |  Planned |

---

### Part E: Jupyter Notebooks (ML Layer - To Be Developed)

| Notebook | ML Task | Answers These KPIs (ML Layer) | SQL Input View | Status |
|----------|---------|-------------------------------|----------------|--------|
| `01_sales_forecasting.ipynb` | Time Series (ARIMA, Prophet, LSTM) | 5a, future sales, top sellers next month | `vw_monthly_trends` |  Planned |
| `02_customer_segmentation.ipynb` | Clustering (K-Means, PCA) | Customer segments, high-value profiles | `vw_customer_metrics` |  Planned |
| `03_profit_prediction.ipynb` | Regression + Classification | Profit prediction, feature importance, optimal discount | `vw_sales_analysis` |  Planned |
| `04_recommendation_system.ipynb` | Association Rules (Apriori) / Collaborative Filtering | 2b, product recommendations | `vw_sales_analysis` |  Planned |
| `05_shipping_classification.ipynb` | Multi-Class Classification | 3a, shipping mode prediction | `vw_sales_analysis` |  Planned |
| `06_discount_optimization.ipynb` | Optimization (Grid Search / Bayesian) | Optimal discount, profit maximization | `vw_sales_analysis` |  Planned |
| `07_churn_prediction.ipynb` | Binary Classification (XGBoost, Logistic) | Churn risk, early warning signals | `vw_customer_metrics` |  Planned |

---

### Part F: Implementation Roadmap

| Phase | Focus | Deliverables | Target KPIs |
|-------|-------|--------------|-------------|
| **Phase 1 (Week 1-2)** | SQL Views + Power BI | All `gold.*` views, Executive Overview dashboard | All SQL-based KPIs |
| **Phase 2 (Week 3-4)** | Forecasting + Segmentation | Notebooks 01, 02 | 5a, future sales, customer segments |
| **Phase 3 (Week 5-6)** | Profit + Discount Optimization | Notebooks 03, 06 | Profit prediction, optimal discount |
| **Phase 4 (Week 7-8)** | Recommendations + Shipping | Notebooks 04, 05 | 2b, 3a, shipping prediction |
| **Phase 5 (Week 9-10)** | Churn Prediction + Final Integration | Notebook 07, complete dashboards | Churn risk, early warning signals |


---

### Part G: Validation Checklist for Evaluators (Upon Completion)

**SQL / Power BI Layer (Descriptive)**
-  Every SQL-based KPI (1a,1b,1c,1d,1e,2a,2c,2d,2e,3e,4a,4b,5b,5c) has a corresponding view or dashboard
-  gold.vw_sales_analysis` contains all necessary columns (sales, profit, discount, product, region, segment, date)
-  Power BI dashboards are mapped to specific KPI questions

**Machine Learning Layer (Predictive)**
-  Each ML task has a dedicated Jupyter notebook
-  ML notebooks consume SQL views as input data
-  Models answer questions that SQL alone cannot (forecasting, recommendations, clustering, churn)
-  Optimal discount analysis is performed (Notebook 06)
-  Bought-together products are identified (Notebook 04)



---

### Note on Two-Project Harmony:  
- Project 1 delivered the data warehouse foundation. 
- Project 2 consumes that warehouse to answer descriptive KPIs (via SQL + Power BI)
 and adds predictive value (via ML models). 
- This README serves as the **single source of truth** connecting both projects.


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

- Project 1 is completed as a structured SQL Data Warehousing with ongoing enhancements for advanced
  analytics and BI integration.
- Project 2 is in **Planning Phase** - 0% complete, 100% scoped.

---

## Author
Geu Kuei

Data Analyst | Data Engineer (Aspiring) | Monitoring & Evaluation (M&E) | Public Health & Education Data | 
ALX Data Engineering Fellow

## License
This project is licensed under the MIT License. You are free to use, modify, and share this project with proper attribution.

