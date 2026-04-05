/********************************************************
gold_layer_quality_checks.sql

Script purpose: Evaluate data quality upon gold layer objects. This script contains some data type checks and column checks that ensure that the gold layer 
complies with basic quality standards. It can be enriched with domain specific checks to ensure usability and coherence of the gold layer for downstream tasks.

Script usage: These scripts should be executed after any changes have been made to silver layer data, since gold layer is comprised of vies over the silver tables, any change
to those tables has to be checked so the gold layer is updated, coherent and usable (don't break).
********************************************************/

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
