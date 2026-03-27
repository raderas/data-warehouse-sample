

---QUality checks for silver tables
select * from silver.crm_prd_info;

--Checking prd_id
--Expectation: equal numbers
select count(prd_id), count(distinct prd_id)
from silver.crm_prd_info;

--Checking prd_nm
--Expectation: None
select *
from silver.crm_prd_info cpi 
where prd_nm != trim(prd_nm);

--Checking prd_cost
--Expectation: None
select *
from silver.crm_prd_info cpi 
where cpi.prd_cost < 0 or prd_cost is null

--Checking prd_cat, prd_key and prd_line
--Expectation: None
select *
from silver.crm_prd_info cpi 
where cpi.prd_cat is null or cpi.prd_cat = ''
  or cpi.prd_key is null or cpi.prd_key = ''
  or cpi.prd_line is null or cpi.prd_line = ''

--Checking start and end dates
--Expectation: None
  select *
from silver.crm_prd_info cpi
where cpi.prd_start_dt > prd_end_dt ;



select * from silver.erp_cust_az12 eca ;

select bdate from silver.erp_cust_az12 eca 
where bdate > now()

select distinct cid from silver.erp_cust_az12 eca 
where cid not in (select cci.cst_key from silver.crm_cust_info cci)



select distinct cntry from silver.erp_loc_a101 ela
--where cid not in (select cst_key from silver.crm_cust_info cci );


