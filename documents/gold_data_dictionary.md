# Gold Layer Data Dictionary
## 1. gold.dim_customer
- **Purpose** : This view has customer attributes for analyzing demographics, geographics, etc.
- **Colums** :
---
|Column Name|Data Type|Description|
|---|---|---|
|customer_key|INT|Surrogate key uniquely identifying each customer record in the dimension table.|
|customer_id|VARCHAR(50)|Unique numerical identifier representing the customer in source system.|
|customer_number|VARCHAR(50)|Aplhanumeric identifier assigned to customer, used for tracking and referencing.|
|first_name|VARCHAR(50)|The customer's first name, as recorded in the system.|
|last_name|VARCHAR(50)|The customer's last name or family name|
|country|VARCHAR(50)|The customer's country of residence (e.g. 'United States')|
|marital_status|VARCHAR(50)|Customer marital status (e.g. 'Married','Single')|
|gender|VARCHAR(50)|The customer's gender (e.g. 'Male','Female','n/a')|
|birthdate|DATE|Customer's birth date formated as YYYY-MM-DD (e.g. '1984-06-15')|
|created_date|DATE|Date the customer was created in the system, formated as YYYY-MM-DD (e.g. '2015-06-08')|

## 2. gold.dim_products
- **Purpose** : This view has products definitions for analyzing categories, subcategories, product lines, etc.
---
|Column|Data Type|Description|
|---|---|---|
|product_key|INT||
|product_id|||
|product_number|||
|product_name|VARCHAR(50)||
|category_id|||
|product_category|VARCHAR(50)||
|subcategory|VARCHAR(50)||
|maintenance|||
|cost|INT||
|product_line|VARCHAR(50)||
|start_date|DATE|Effective date for this record definition.|
|end_date|DATE|Effective end date for this record definition. Since we are only considering active rows, all columns have NULL on this field.|
