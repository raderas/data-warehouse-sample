/********************************************
gold_layer_quality_checks.sql

Purpose:
Check validity and coherence of fact and dimension tables in the gold layer.
Checking uniqueness of keys, data ranges, etc.

Any other quality check scripts should be added to these scripts for referenca and validation.
********************************************/
SELECT  * FROM gold.dim_customers;

--unique columns
select count(distinct customer_key), count(customer_key), count(distinct customer_number), count(customer_number),
  count(distinct customer_id), count(customer_id)
from gold.dim_customers;


--Unwanted spaces
select *
from gold.dim_customers
where first_name != trim(first_name) or last_name != trim(last_name);



--Checking model
select *
from gold.fact_sales f
left join gold.dim_customers dc 
  on f.customer_key = dc.customer_key
left join gold.dim_products dp 
  on f.product_key = dp.product_key 
where dc.customer_key is null or dp.product_key is null;
