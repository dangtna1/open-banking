# UK Open Banking Data Engineering Project (Azure End-to-End)

## 📌 Project Overview

This project demonstrates an **end-to-end data engineering pipeline on Azure**, designed to ingest, transform, model, and serve UK Open Banking–style transaction data for downstream analytics and reporting.

The focus of this project is **data engineering best practices**, including:
- cloud-native ingestion
- lakehouse-style storage
- transformation logic
- star-schema modeling
- automated refresh patterns
- analytics-ready data serving

A Power BI report is included **only as a downstream consumer** to validate data quality and usability.

---

## 🏗️ High-Level Architecture

**Pipeline flow**

```
Synthetic Open Banking Data (CSV)
        ↓
Azure Data Lake Storage Gen2 (Raw Zone)
        ↓
Azure Data Factory (Mapping Data Flows)
        ↓
Azure Data Lake Storage Gen2 (Curated Zone)
        ↓
Azure SQL Database (Star Schema)
        ↓
Power BI Desktop (Semantic Model & Reporting)
```

📌 **Design philosophy**
- Raw data is immutable
- Transformations are reproducible
- SQL layer is analytics-ready
- BI layer contains no heavy logic

---

## 🧱 Data Architecture (Star Schema)

### Fact Table
- **fact_transactions**
  - TransactionID
  - AccountID
  - CustomerID
  - TransactionDate
  - Amount
  - BalanceAfter
  - Category
  - Channel
  - IsRecurring
  - IsSalary
  - IsRefund
  - RegionCode

### Dimension Tables
- **dim_customers** – demographics, persona, income bands
- **dim_accounts** – product type, student/joint flags
- **dim_region** – ONS deprivation index, median income & rent
- **dim_date** – calendar attributes (derived in Power BI)

📷 **Star Schema Model**
![Star Schema](docs/images/star_schema.png)

---

## 🔄 Data Engineering Pipeline

### 1️⃣ Data Generation (Synthetic)
- Python-based generator simulating UK Open Banking patterns
- Monthly salary cycles
- Subscription / recurring spend
- Regional cost-of-living variation
- Customer personas (student, grad, family, contractor)

Generated files:
- customers.csv
- accounts.csv
- transactions_YYYYMM.csv
- ons_region.csv

---

### 2️⃣ Raw Data Ingestion (ADF)
- Azure Data Factory Copy pipelines
- Parameterised ingestion by month
- Stored in ADLS Gen2 `/raw/` zone
- Schema-on-read approach

📌 **Techniques demonstrated**
- Dataset parameters
- ForEach loops
- Dynamic file paths
- Metadata-driven ingestion

---

### 3️⃣ Data Transformation (ADF Mapping Data Flows)

Transformations include:
- Type casting (string → numeric / boolean)
- Business rule derivation:
  - `IsSalary`
  - `IsRecurring`
- Standardised category mapping
- Region code normalization
- Data quality checks (nulls, invalid values)

Curated outputs written to:
- `/curated/customers/`
- `/curated/accounts/`
- `/curated/transactions/`
- `/curated/region/`

📌 **Design choice**
All business logic lives **before SQL**, keeping the warehouse clean.

---

### 4️⃣ Data Serving Layer (Azure SQL Database)

- Star schema implemented in Azure SQL
- Fact & dimension tables pre-created
- Data loaded via ADF Copy activities
- Type-safe schema enforcement (INT, DECIMAL, BIT)

Example engineering considerations:
- Boolean handling from CSV (`true/false` → BIT)
- Referential integrity via surrogate joins
- Warehouse-ready grain definition

---

### 5️⃣ Analytics Consumption (Power BI Desktop)

Power BI is used to:
- Validate schema usability
- Confirm data correctness
- Demonstrate downstream analytics enablement

📌 **Important**
No heavy transformation logic in Power BI.
All metrics are computed from the engineered model.

📷 **Executive Overview Example**
![Executive Overview](docs/images/executive_overview.png)

---

## 📊 Example Metrics Enabled

- Monthly Active Customers (MAC)
- Transactions per Active Customer (TPAC)
- Savings Rate
- Recurring Spend Ratio
- Spend Volatility Index
- Regional affordability comparison (ONS overlay)
- Customer behavioural segmentation

---

## 🔐 Governance & Engineering Best Practices

- Clear Raw vs Curated zone separation
- Schema enforcement at SQL layer
- Reproducible transformations
- No hardcoded file paths
- Analytics-ready star schema
- BI layer isolated from engineering logic

---

## 🧰 Tech Stack

- **Azure Data Factory** – orchestration & transformation
- **Azure Data Lake Storage Gen2** – raw & curated zones
- **Azure SQL Database** – dimensional warehouse
- **Power BI Desktop** – semantic model & reporting
- **Python** – synthetic data generation
- **SQL** – schema design & data serving

---

<!-- ## 📁 Repository Structure

```
.
├── adf/
|   ├── datasets/
│   ├── pipelines/
│   └── dataflows/
├── sql_scripts/
│   ├── dim_tables.sql
│   └── fact_tables.sql
├── powerbi/
│   └── OpenBankingInsights.pbix
├── images/
│   ├── star_schema.png
│   └── executive_overview.png
└── README.md
```

--- -->

## 🎯 Key Takeaway

This project showcases how **raw financial data can be engineered into an analytics-ready warehouse** using Azure-native tools.

The emphasis is on:
- data pipeline design
- transformation logic
- schema modeling
- downstream usability

Please note: Power BI serves only as proof that the engineered data can support real business analytics.

---

## 📌 Author

**Dang Vu**  
Aspiring Data Engineer / Data Scientist  
UK-based | Azure | SQL | Data Engineering

