# 📘 Data Dictionary

## Overview

This document provides a detailed description of all tables and columns in the data warehouse.

The system follows a **Medallion Architecture**:
- Bronze → Raw data
- Silver → Cleaned data
- Gold → Analytics-ready data

> ℹ️ Note: While the Silver layer can be queried for validation and intermediate analysis, the Gold layer is the **primary source for business analytics and reporting**.

---

# 🟦 GOLD LAYER (Analytics Layer)

## 🧾 fact_orders

**Description:**  
Central fact table capturing transactional sales data.

**Grain:**  
One row per order line (each product within an order)

| Column Name   | Data Type       | Description |
|--------------|----------------|------------|
| Order_ID     | NVARCHAR(50)   | Unique identifier for each order |
| Order_Date   | DATE           | Date the order was placed |
| Ship_Date    | DATE           | Date the order was shipped |
| Ship_Mode    | NVARCHAR(50)   | Shipping method (First Class, Second Class, Standard Class) |
| Customer_Key | INT            | Foreign key linking to dim_customers |
| Product_Key  | INT            | Foreign key linking to dim_products |
| Sales        | DECIMAL(10,3)  | Revenue generated (Quantity × Price) |
| Quantity     | INT            | Number of units sold |
| Discount     | DECIMAL(10,1)  | Discount applied to the sale |
| Profit       | DECIMAL(10,4)  | Profit or loss (can be negative) |

---

## 🧑‍💼 dim_customers

**Description:**  
Stores customer-related attributes for segmentation and regional analysis.

| Column Name    | Data Type      | Description |
|---------------|---------------|------------|
| Customer_Key  | INT           | Surrogate primary key |
| Customer_ID   | NVARCHAR(50)  | Business identifier from source system |
| Customer_Name | NVARCHAR(50)  | Name of the customer |
| Region        | NVARCHAR(50)  | Geographic region |
| Segment       | NVARCHAR(50)  | Customer classification (Consumer, Corporate, Home Office) |

---

## 📦 dim_products

**Description:**  
Stores product attributes for categorization and performance analysis.

| Column Name   | Data Type       | Description |
|--------------|----------------|------------|
| Product_Key  | INT            | Surrogate primary key |
| Product_ID   | NVARCHAR(50)   | Business identifier from source system |
| Product_Name | NVARCHAR(255)  | Name of the product |
| Category     | NVARCHAR(50)   | High-level category (Furniture, Technology, Office Supplies) |
| Sub_Category | NVARCHAR(50)   | Detailed product classification |

---

## 📊 vw_sales_analysis

**Description:**  
A denormalized analytical view combining fact and dimension tables.

**Purpose:**
- Simplifies querying
- Supports BI tools (e.g., dashboards)
- Provides a business-friendly dataset

---

# 🟨 SILVER LAYER (Cleaned Data Layer)

## 🧾 Erp_Orders

| Column Name  | Data Type       |
|-------------|----------------|
| Order_ID    | NVARCHAR(50)   |
| Order_Date  | DATE           |
| Ship_Date   | DATE           |
| Ship_Mode   | NVARCHAR(50)   |
| Customer_ID | NVARCHAR(50)   |
| Product_ID  | NVARCHAR(50)   |
| Sales       | DECIMAL(10,3)  |
| Quantity    | INT            |
| Discount    | DECIMAL(10,1)  |
| Profit      | DECIMAL(10,4)  |

---

## 🧑‍💼 Crm_Customers

| Column Name    | Data Type      |
|---------------|---------------|
| Customer_ID   | NVARCHAR(50)  |
| Customer_Name | NVARCHAR(50)  |
| Segment       | NVARCHAR(50)  |
| Country       | NVARCHAR(50)  |
| City          | NVARCHAR(50)  |
| State         | NVARCHAR(50)  |
| Postal_Code   | INT           |
| Region        | NVARCHAR(50)  |

---

## 📦 Erp_Products

| Column Name   | Data Type       |
|--------------|----------------|
| Product_ID   | NVARCHAR(50)   |
| Category     | NVARCHAR(50)   |
| Sub_Category | NVARCHAR(50)   |
| Product_Name | NVARCHAR(255)  |

---

# 📌 Business Rules & Assumptions

- **Sales** = Quantity × Price *(Price not explicitly stored)*  
- **Profit** may be positive or negative (indicating gain or loss)  
- **Discount** is assumed to be applied per transaction  
- **Customer Segments:**
  - Consumer → Individual buyers  
  - Corporate → Business purchases  
  - Home Office → Small office users  

---

# 🔗 Data Relationships

- fact_orders.Customer_Key → dim_customers.Customer_Key  
- fact_orders.Product_Key → dim_products.Product_Key  

---

# 🎯 Summary

The Gold layer serves as the **single source of truth for analytics**, while the Silver layer provides **clean, validated data for transformation and intermediate analysis**.
