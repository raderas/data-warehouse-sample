# Data Warehouse Project 
This is a sample Data Warehouse Project built from the course *Build a modern Data Warehouse* on Udemy. It comprises two sections:

1. [Building the Data Warehouse](#building-the-data-warehouse-(data-engineering))
1. [BI: Analytics & Reporting](#bi-analytics--reporting-(data-analysis))

## Building the Data Warehouse (Data Engineering)

### Objective

Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytcal reporting and informed decision-making.

### Specifications

- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integreation**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historyzation of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

## BI: Analytics & Reporting (Data Analysis)

### Objective

Develop SQL-based analytics to deliver detailed insifgths into:

- Customer Behavior
- Product Performance
- Sales Trends

These insights empower stakeholders with key business metrics, enabling strategic decision-making.

---

## High Level Architecture
The data warehouse project comprises a medallion architecture with the following layers:
- **Bronze** : Raw data as obtained form the source systems.
- **Silver** : Cleaned and enriched data with data type and value checks.
- **Gold** : Business ready datasets to serve users downstream.

<img width="775" height="621" alt="high level architecture" src="https://github.com/user-attachments/assets/9c5c0c50-f75e-4252-ba28-85197692ed0c" />

---
## About Me:
I'm Rafael Deras. An IT Professional specialized in Data Engineering/Data Analytics with 10+ years of experience delivering value translating Data into business ingishts and knowledge.
