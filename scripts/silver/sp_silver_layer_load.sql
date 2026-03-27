/*
 * silver.load_silver_layer()
 * 
 * Script purpose:
 * so to load silver layer tables from bronze layer tables.
 * 
 * Sample call:
 * call silver.load_silver_layer();
 * 
 * Parameters:
 * None
 * 
 * Return:
 * None
 */
create or replace procedure silver.load_silver_layer()
as 
$$
begin 
RAISE NOTICE 'Begin of Silver layer load';

raise NOTICE 'Truncating silver.crm_cust_info';
truncate table silver.crm_cust_info;

raise notice ' Loading silver.crm_cust_info';
insert into silver.crm_cust_info(
  cst_id 
  , cst_key 
  , cst_firstname 
  , cst_lastname 
  , cst_marital_status 
  , cst_gndr 
  , cst_create_date
)
with ranked_customer_info as(
select
	cci.cst_id,
	cci.cst_key,
	trim(cci.cst_firstname) as cst_firstname,
	trim(cci.cst_lastname) as cst_lastname,
	coalesce(case when upper(trim(cci.cst_marital_status)) = 'M' then 'Married'
	  when upper(trim(cci.cst_marital_status)) = 'S' then 'Single' end, 'N/A') as cst_marital_status,
	coalesce(case when upper(trim(cci.cst_gndr)) = 'F' then 'Female' 
	  when upper(trim(cci.cst_gndr)) = 'M' then 'Male' end, 'N/A') as cst_gndr,
	cst_create_date,
	row_number() over (partition by cst_id order by cst_create_date desc) as rn
FROM bronze.crm_cust_info cci 
where cci.cst_id is not null
)
select cst_id
  , cst_key
  , cst_firstname 
  , cst_lastname 
  , cst_marital_status 
  , cst_gndr 
  , cst_create_date
from ranked_customer_info
where rn = 1;


raise notice 'Truncating silver.cmr_prd_info';
truncate table silver.crm_prd_info;

Raise NOTICE 'Loading silver.crm_prd_info';
insert into silver.crm_prd_info (
  prd_id 
  , prd_cat
  , prd_key
  , prd_nm 
  , prd_cost 
  , prd_line 
  , prd_start_dt
  , prd_end_dt 
)
select 
  cpi.prd_id 
  , replace(substring(cpi.prd_key,0,6),'-','_') as cat_id
  , substring(cpi.prd_key,7,length(cpi.prd_key)) as prd_id
  , trim(cpi.prd_nm) as prd_nm
  , coalesce(cpi.prd_cost,0 ) as prd_cost
  , case when upper(trim(cpi.prd_line)) = 'M' then 'Mountain'
       when upper(trim(cpi.prd_line)) = 'R' then 'Road'
       when upper(trim(cpi.prd_line)) = 'S' then 'Other Sales'
       when upper(trim(cpi.prd_line)) = 'T' then 'Touring'
       else 'N/A'
    end as prd_line
  , cpi.prd_start_dt::date, lead(cpi.prd_start_dt::date) over (partition by cpi.prd_key order by cpi.prd_start_dt asc) - INTERVAL '1 day' as prd_end_dt_test
from bronze.crm_prd_info cpi;


Raise NOTICE 'Truncating silver.crm_sales_details';
truncate table silver.crm_sales_details ;

Raise NOTICE 'Loading silver.crm_sales_details';
insert into silver.crm_sales_details (
  sls_ord_num
  , sls_prd_key 
  , sls_cust_id 
  , sls_order_dt 
  , sls_ship_dt 
  , sls_due_dt 
  , sls_sales 
  , sls_quantity 
  , sls_price 
)
select
  csd.sls_ord_num 
  , csd.sls_prd_key 
  , csd.sls_cust_id 
  , case when csd.sls_order_dt = 0 or length(csd.sls_order_dt::varchar) != 8 then null 
  		else to_date(csd.sls_order_dt::varchar,'YYYYMMDD')
  	end as sls_order_dt
  , case when csd.sls_ship_dt = 0 or length(csd.sls_ship_dt::varchar) != 8 then null 
  		else to_date(csd.sls_ship_dt::varchar,'YYYYMMDD')
  	end as sls_ship_dt 
  , case when csd.sls_due_dt = 0 or length(csd.sls_due_dt::varchar) != 8 then null 
  		else to_date(csd.sls_due_dt::varchar,'YYYYMMDD')
  	end as sls_due_dt 
  , case when csd.sls_sales is null or csd.sls_sales <=0 or csd.sls_sales != csd.sls_quantity * ABS(csd.sls_price)
  		   then csd.sls_quantity * ABS(csd.sls_price)
  		else csd.sls_sales 
  	end as sls_sales
  , csd.sls_quantity 
  , case when csd.sls_price is null or sls_price <= 0 
           then csd.sls_price / nullif(csd.sls_quantity,0)
       else csd.sls_price
    end as sls_price
from bronze.crm_sales_details csd ;


Raise NOTICE 'Truncating silver.erp_cust_az12';
truncate table silver.erp_cust_az12;

Raise NOTICE ' Loading silver.erp_cust_az12';
insert into silver.erp_cust_az12(
   cid,
   bdate,
   gen
)
select 
   trim(case when eca.cid like 'NAS%' then substring(eca.cid,4,length(eca.cid)) else eca.cid end) as cid
   , case when bdate > now() then null
        else eca.bdate
     end bdate 
   , case when upper(trim(eca.gen)) in ( 'F','FEMALE') then 'Female'
          when upper(trim(eca.gen)) in ('M','MALE') then 'Male'
          else 'N/A'
     end gen 
from bronze.erp_cust_az12 eca;


Raise NOTICE 'Truncating silver.erp_loc_a101';
truncate table silver.erp_loc_a101;

Raise NOTICE 'Loading silver.erp_loc_a101';
insert into silver.erp_loc_a101 (
   cid
   , cntry
)
select 
  replace(ela.cid,'-','') cid
  , case when trim(upper(ela.cntry)) in ('USA','United States','US') then 'United States'
         when trim(upper(ela.cntry)) in ('DE','GERMANY') then 'Germany'
         when ela.cntry is null or trim(ela.cntry) = '' then 'N/A'
         else ela.cntry
    end as cntry
from bronze.erp_loc_a101 ela
;


Raise NOTICE 'Truncating silver.erp_px_cat_g1v2';
truncate table silver.erp_px_cat_g1v2 ;


Raise NOTICE 'Loading silver.erp_px_cat_g1v2';
insert into silver.erp_px_cat_g1v2(
  id
  , cat 
  , subcat 
  , maintenance
)
select 
  trim(id) as id 
  , trim(cat) as cat 
  , trim(subcat) as subcat  
  , trim(maintenance) as maintenance 
from bronze.erp_px_cat_g1v2 epcgv ;

end;

$$
language plpgsql;

