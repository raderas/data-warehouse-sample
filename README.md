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


### High Level Architecture
The data warehouse project comprises a medallion architecture with the following layers:
- **Bronze** : Raw data as obtained form the source systems.
- **Silver** : Cleaned and enriched data with data type and value checks.
- **Gold** : Business ready datasets to serve users downstream.

<img width="775" height="621" alt="high level architecture" src="https://github.com/user-attachments/assets/9c5c0c50-f75e-4252-ba28-85197692ed0c" />


### Tools used
We have deployed the database in Cloud SQL Postgres instance on GCP.
Data load has been performed using DBeaver bulk data import to load the csv files into the bronze layer tables. For a continuos data load, cloud functions overGCP should be used to integrate data from GCP buckets.
The data load into the silver layer has been coded as a sp inside the Postgres database. 
Gold layer objects are dynamic views whicn generate the enriched business-ready data at runtime. Special consideration should be taken when generating the gold layer objects. In case querying takes too long, materialized views should be implemented or physical tables refreshed by means of a stored procedure to speedup queries for reporting.

---

## BI: Analytics & Reporting (Data Analysis)

### Objective

Develop SQL-based analytics to deliver detailed insifgths into:

- Customer Behavior
- Product Performance
- Sales Trends

These insights empower stakeholders with key business metrics, enabling strategic decision-making.

---
## About Me:
I'm Rafael Deras. An IT Professional specialized in Data Engineering/Data Analytics with 10+ years of experience delivering value translating Data into business ingishts and knowledge.
