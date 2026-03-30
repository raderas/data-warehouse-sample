/**************************************************
ddl_gold.sql

Script purpose: Generate views for the gold layer integrating tables from the silver layer.
The gold layer represents the final dimension and fact tables (Star Schema).

Each view performs transformations and combines data from the silver layer to produce
a clean, enrcihed and business-ready dataset. 

Usage notes:
This script will rtecreate/replace all vies for the gold layer. No data is destroyed so any changes should only rebuild views and be notified downstream.
The views created by this script can be queried directly for reporting/analysis.
**************************************************/

--Product info
-- Product Dimension
create or replace view gold.dim_products as
select
  row_number() over (order by cpi.prd_start_dt, cpi.prd_key) as product_key
  , cpi.prd_id product_id
  , cpi.prd_key product_number
  , cpi.prd_nm product_name
  , cpi.prd_cat category_id
  , epcgv.cat product_category
  , epcgv.subcat subcategory
  , epcgv.maintenance maintenance
  , cpi.prd_cost cost
  , cpi.prd_line product_line
  , cpi.prd_start_dt start_date 
from silver.crm_prd_info cpi 
left join silver.erp_px_cat_g1v2 epcgv 
  on cpi.prd_cat = epcgv.id
where cpi.prd_end_dt is null -- only current records
;
 
  
 --- customer tables
 -- customer Dimension
 create or replace view gold.dim_customers as
 select
   row_number() over (order by cci.cst_id) customer_key
   , cci.cst_id customer_id
   , cci.cst_key customer_number
   , cci.cst_firstname first_name
   , cci.cst_lastname last_name
   , ela.cntry country
   , cci.cst_marital_status marital_status
   , case when cci.cst_gndr != 'n/a' then cci.cst_gndr -- CRM is the master for this definition
        else coalesce(eca.gen,'n/a')
     end as gender
   , eca.bdate birthdate
   , cci.cst_create_date create_date  
 from silver.crm_cust_info cci
 left join silver.erp_cust_az12 eca
   on cci.cst_key = eca.cid 
 left join silver.erp_loc_a101 ela
   on cci.cst_key = ela.cid
 ;


--- Fact table
--sales
create or replace view gold.fact_sales as
select
  csd.sls_ord_num order_number  
  , dc.customer_key 
  , dp.product_key 
  , csd.sls_order_dt order_date
  , csd.sls_ship_dt shipping_date
  , csd.sls_due_dt due_date
  , csd.sls_sales sales_amount
  , csd.sls_quantity quantity
  , csd.sls_price price
from silver.crm_sales_details csd 
left join gold.dim_products dp 
     on csd.sls_prd_key = dp.product_number 
left join gold.dim_customers dc 
     on csd.sls_cust_id = dc.customer_id  
;
