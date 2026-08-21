Zepto Sales Analysis

📌 Project Overview

This project analyzes Zepto’s sales, customer, product, delivery, and inventory data to identify business performance trends and operational opportunities.

The analysis was performed using SQL in Google BigQuery, with the results prepared for visualization and business reporting in Power BI.

The project focuses on answering practical business questions around revenue, customer behavior, product performance, delivery efficiency, discounts, and inventory management.

⸻

🎯 Business Objectives

The analysis aims to answer questions such as:

* How is overall sales performance?
* Which cities generate the most revenue?
* Which product categories and products perform best?
* How does customer loyalty affect revenue and order frequency?
* Are deliveries meeting the expected SLA?
* Are discounts improving sales without significantly reducing profitability?
* Which products require inventory attention?
* How dependent is revenue on repeat customers?
* Which products represent growth opportunities?

⸻

🗂️ Data Model

The analysis uses four primary tables:

Table	Purpose
Zepto_Orders	Order-level sales, customer, product, delivery, and payment information
Zepto_Products	Product, category, price, and margin information
Zepto_Customers	Customer and loyalty information
Zepto_Inventory	Product stock, reorder level, warehouse, and capacity information

Table Relationships

Zepto_Customers
       │
       │ CustomerID
       ▼
Zepto_Orders
       │
       │ ProductID
       ▼
Zepto_Products
       │
       │ ProductID
       ▼
Zepto_Inventory

⸻

🛠️ Tools & Technologies

* SQL
* Google BigQuery
* Power BI
* GitHub

SQL Environment

All SQL queries in this project were executed using Google BigQuery.

⸻

🔍 Analysis Performed

1. Data Validation & Quality

The project includes checks for:

* Missing values
* Invalid quantities
* Invalid prices
* Negative or zero sales
* Net sales calculation consistency
* Delivery-time issues
* Customer data quality
* Product price and margin validation
* Inventory status and stock risks

2. Data Modeling & Relationship Validation

The analysis validates relationships between:

* Customers and Orders
* Products and Orders
* Products and Inventory

This helps ensure that joins do not introduce missing records or unexpected duplication.

3. Business Analysis

Key analytical areas include:

* Overall business KPIs
* City performance
* Category performance
* Product performance
* Customer and loyalty performance
* Monthly sales trends
* Delivery SLA performance
* On-time delivery by city
* Discount performance
* Inventory versus sales
* Customer segmentation
* Product opportunity analysis

⸻

📊 Key KPIs

The analysis evaluates metrics such as:

* Total Orders
* Delivered Orders
* Units Sold
* Total Revenue
* Average Order Value (AOV)
* Average Delivery Time
* Return Rate
* Cancellation Rate
* On-Time Delivery %
* Gross Profit
* Gross Margin
* Customer Revenue
* Orders per Customer

⸻

📁 Repository Structure

Zepto-Sale-Analytics/
│
├── README.md
│
├── SQL/
│   ├── Zepto_Sales_Analysis.sql
│   ├── Zepto_Schema.csv
│   │
│   └── outputs/
│       ├── 01_Customer_Order_Match.csv
│       ├── 02_Product_Order_Match.csv
│       ├── 03_Product_Inventory_Match.csv
│       ├── ...
│       └── 30_Product_Opportunity_Analysis.csv
│
└── PowerBI/
    └── Zepto_Sales_Dashboard.pbix

⸻

📈 Dashboard

The SQL analysis is further developed into an interactive Power BI dashboard to visualize:

* Sales performance
* Revenue trends
* City and category performance
* Product performance
* Customer behavior
* Delivery performance
* Inventory risks

The dashboard is designed to convert SQL analysis into actionable business insights.

⸻

💡 Business Insights

The final analysis is intended to identify:

* High-performing cities and categories
* Revenue-driving products
* Products with strong profit potential
* Delivery and operational issues
* Customer segments contributing most to revenue
* Discount strategies that may require optimization
* Products with potential inventory risks
* Opportunities for improving revenue and profitability

⸻

🚀 Project Outcome

This project demonstrates an end-to-end analytics workflow:

Data → Data Validation → SQL Analysis → Business KPIs → Insights → Power BI Dashboard

It showcases practical skills in SQL, Google BigQuery, data quality analysis, business analysis, and data visualization.

⸻

👤 Author

Mani Rachamallu

Data Analyst | SQL | Power BI | Google BigQuery
