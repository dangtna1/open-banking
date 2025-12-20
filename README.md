# UK Open Banking Data Engineering Project (Azure End-to-End)

## Abstract
Hi, I'm Dang
An aspiring data engineer who loves fintech.
This project is a fun yet practical dive into building real-world data pipelines inspired by financial systems. Stay tune with me till the end!!!

## Project Overview

This project demonstrates an **end-to-end data engineering pipeline on Microsoft Azure**, designed to ingest, transform, model, and serve UK Open Banking–style transaction data for downstream analytics and reporting.

The primary focus of this project is **data engineering best practices**, including:

- Cloud-native data ingestion
- Lakehouse-style data zoning (Raw → Curated)
- Deterministic transformation logic
- Analytics-oriented star schema modelling
- Type-safe data serving
- Downstream consumption enablement

A Power BI report is included **only as a downstream consumer** to validate data quality, model usability, and analytical readiness.

---

## High-Level Architecture

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

**Design philosophy**

- Raw data is immutable
- Transformations are reproducible and deterministic
- Business logic is applied upstream
- SQL layer is analytics-ready
- BI layer remains lightweight and semantic-only

---

## Data Architecture (Star Schema)

The data warehouse follows a **classic dimensional (Kimball-style) star schema**, optimised for analytical workloads.

### Fact Table

**fact_transactions**  
Grain: **one row per financial transaction**

- TransactionID
- AccountID
- CustomerID
- TransactionDate
- Amount
- BalanceAfter
- Currency
- MerchantName
- MCC
- City
- Category
- Channel
- IsRecurring
- IsSalary
- IsRefund
- RegionCode

### Dimension Tables

- **dim_customers**
  - Customer demographics
  - Persona classification (student, grad, family, contractor)
  - Income bands
- **dim_accounts**
  - Account type
  - Student / joint account flags
- **dim_region**
  - ONS Deprivation Index
  - Median income
  - Median rent
- **dim_date**
  - Calendar attributes (derived in Power BI)

**Star Schema Model**

![Star Schema](docs/images/star_schema.png)

---

## Data Engineering Pipeline

### 1. Synthetic Data Generation

- Python-based data generator
- Simulates UK Open Banking behaviour:
  - Monthly salary inflows
  - Subscription-based recurring spend
  - Regional cost-of-living variation
  - Realistic transaction frequency distributions
- Customer personas embedded at source

Generated datasets:

- `customers.csv`
- `accounts.csv`
- `transactions_YYYYMM.csv`
- `region_enrichment.csv`

**Purpose:**
Provides controlled, repeatable data to validate pipeline logic and modelling decisions.

---

### 2. Raw Data Ingestion (Azure Data Factory)

- Azure Data Factory Copy pipelines
- Parameterised ingestion by month
- Files landed in ADLS Gen2 `/raw/` zone
- Schema-on-read ingestion pattern

**Engineering techniques demonstrated**

- Dataset parameters
- ForEach loops
- Dynamic file paths
- Metadata-driven ingestion design
- No schema enforcement at raw layer

---

### 3. Data Transformation (ADF Mapping Data Flows)

Transformations applied in the **curated layer**:

- Explicit type casting (string → INT / DECIMAL / BIT)
- Boolean standardisation (`true` / `false`)
- Derived business flags:
  - `IsSalary`
  - `IsRecurring`
  - `IsRefund`
- Category standardisation
- Region code normalisation
- Basic data quality validation:
  - Null handling
  - Invalid value filtering

Curated outputs written to:

- `/curated/customers/`
- `/curated/accounts/`
- `/curated/transactions/`
- `/curated/ons/`

**Design choice**

All transformation and business logic is applied **before the warehouse**, ensuring the SQL layer remains clean, deterministic, and reusable.

---

### 4. Data Serving Layer (Azure SQL Database)

- Azure SQL Database used as the analytical serving layer
- Star schema implemented with pre-defined tables
- Data loaded from curated zone via ADF Copy activities
- Strict schema enforcement using native SQL types

**Engineering considerations**

- CSV booleans (`true/false`) converted to `BIT`
- Numeric precision enforced (`DECIMAL(10,2)`)
- Referential integrity via surrogate joins
- Fact grain carefully preserved
- Warehouse optimised for BI-style queries

---

### 5. Analytics Consumption (Power BI Desktop)

Power BI Desktop is used **only as a consumer** of the engineered data model.

Its purpose is to:

- Validate dimensional design
- Confirm transformation correctness
- Demonstrate analytical usability

**Important**

- No heavy transformations in Power BI
- No data cleansing in the BI layer
- All metrics calculated from the engineered star schema

**Executive Overview**

![Executive Overview](docs/images/executive_overview.png)

**Customer Behaviour**

![Customer Behaviour](docs/images/customer_behaviour.png)

**Finacial Risk & Stability**

![Finacial Risk & Stability](docs/images/financial_risk_stability.png)

---

## Example Metrics Enabled

The engineered model supports:

- Monthly Active Customers (MAC)
- Transactions per Active Customer (TPAC)
- Savings Rate
- Recurring Spend Ratio
- Spend Volatility Index
- Regional affordability analysis (ONS overlay)
- Customer behavioural segmentation
- Financial risk indicators
- etc (see the Measures table above)
---

## Governance & Engineering Best Practices

- Clear Raw vs Curated zone separation
- Schema-on-read → schema-on-write progression
- Deterministic, reproducible transformations
- Type-safe warehouse layer
- No hardcoded file paths
- Analytics-ready star schema
- BI layer isolated from engineering logic

---

## Tech Stack

- **Azure Data Factory** – orchestration & transformation
- **Azure Data Lake Storage Gen2** – raw & curated zones
- **Azure SQL Database** – dimensional warehouse
- **Power BI Desktop** – semantic model & reporting
- **Python** – synthetic data generation
- **SQL** – schema design & data serving

---

## Key Takeaway

This project demonstrates how **raw financial transaction data can be engineered into an analytics-ready warehouse** using Azure-native services.

The emphasis is on:

- pipeline design
- transformation logic
- schema modelling
- downstream usability

---

## Author

**Dang Vu**  
Aspiring Data Engineer / Data Scientist  
UK-based | Azure | SQL | Data Engineering
