/***********************************************
Advancesd Analytics.sql

Script purpose: Generate advanced metrics, KPIS or indicators from the existing gold layer.

Script usage: This script contains select statements tha perform transformations and prepares gold leyer data for reporting.
Any additional business rules or newly defined metrics can be added to this script to enrich reporting and further analysis downstream.
***********************************************/

-- Sales performance over time
SELECT 
  date_trunc('month',fs2.order_date) as order_month
  , sum(fs2.sales_amount) as total_sales
  , count(distinct fs2.customer_key) as total_customers
  , sum(fs2.quantity) as total_quantity
FROM gold.fact_sales fs2
where fs2.order_date is not null
group by date_trunc('month',fs2.order_date)
order by date_trunc('month',fs2.order_date)
;


---- CUMULATIVE ANALYSIS
-- Calculate total sales per month and 
-- running total of sales over time
with monthly_sales as(
	select 
  	date_trunc('month',fs2.order_date ) as order_month
  	, sum(fs2.sales_amount) as monthly_sales
  	, avg(fs2.price) as avg_price
	from gold.fact_sales fs2
	where order_date is not null
	group by 1
	order by 1 asc
)
select
  order_month
  , monthly_sales
  , sum(monthly_sales) over (partition by order_month order by order_month asc rows unbounded preceding) as rsum_monthly_sales
  , avg(avg_price) over (order by order_month) as moving_average_price
from monthly_sales;




---- PERFORMANCE ANALYSIS
select distinct extract('month' from order_date) as year_range
from gold.fact_sales
where extract(year from order_date) = 2014;

-- Analyze the yearly performance of products by comparing each product's sales to both its average sales performance and the previous year's sales
with yearly_product_sales as(
	select
	  date_trunc('year',f.order_date) as order_year
	  , p.product_name
	  , sum(f.sales_amount) as current_sales
	  , lag(sum(f.sales_amount)) over (partition by p.product_name order by date_trunc('year', f.order_date) asc) as prev_year_sales
	from gold.fact_sales f
	left join gold.dim_products p
	  on f.product_key = p.product_key
	where f.order_date is not null
	group by 1,2
)
select
  order_year
  , product_name
  , current_sales
  , avg(current_sales) over (partition by product_name) as average_yearly_sales
  , current_sales -  avg(current_sales) over (partition by product_name) diff_avg
  , case when current_sales -  avg(current_sales) over (partition by product_name) > 0 then 'above average'
       when current_sales -  avg(current_sales) over (partition by product_name) < 0 then 'below average'
       else 'Avg'
  end avg_change
  ---- Year on Year Analysis (YoY) can be changed to month easily.
  , lag(current_sales) over (partition by product_name order by order_year) as previous_year_sales
  , case when lag(current_sales) over (partition by product_name order by order_year) is null then 'No sales last year'
         when current_sales - lag(current_sales) over (partition by product_name order by order_year) > 0 then 'Above last year sales'
         when current_sales - lag(current_sales) over (partition by product_name order by order_year) < 0 then 'Below last year sales'
         else 'Same as last year sales'
    end as yearly_sales_comparison
from yearly_product_sales
order by product_name, order_year;



---- Part To Whole Analysis
-- Which categories contribute the most to the overall sales
-- Can change to analyze customers by orders to have a different view of the data.
with sales_by_category as(
	select 
	  dp.product_category 
	  , sum(fs2.sales_amount) cat_sales
	from gold.fact_sales fs2 
	left join gold.dim_products dp 
	  on fs2.product_key = dp.product_key
	group by 1
)
select
  product_category
  , round(cat_sales * 100 / (sum(cat_sales) over()),2) as pct_contribution
from sales_by_category
;


-- Segmentation
--- Groups a measure with another measure to create new insights
-- Example: Segment products into cost ranges and
-- count how many products fall into each segment

with categorized_products as(
	select
	   dp.product_key 
	   , dp.product_name 
	   , case  
	         when dp.cost < 100 then 'Below 100'
	         when dp.cost between 100 and 500 then '100-500'
	         when dp.cost between 500 and 1000 then '500-1000'
	         else 'Above 1000'
	     end as cost_category
	from gold.dim_products dp
)
select 
  cost_category
  , count(product_key) as product_count
from categorized_products
group by cost_category
;


/*
 * Group customers into three segments based on their spending behaviour
 * VIP: at least 12 months of history and spending more than 5000
 * Regular: at least 10 months of history but spending 5000 or less
 * New: lifespan of les than 12 months
 * and find the total number of customers by each group
*/
with customer_sales_lifespan as(
select 
   dc.customer_key 
   , extract(year from age(max(fs2.order_date),min(fs2.order_date))) * 12 + 
      extract(month from age(max(fs2.order_date),min(fs2.order_date))) as lifespan
   , sum(fs2.sales_amount) as total_sales
from gold.fact_sales fs2 
  left join gold.dim_customers dc 
    on fs2.customer_key = dc.customer_key
group by dc.customer_key
),
categorized_customers as(
	select
	  customer_key
	  , case when lifespan < 12 then 'New'
	        when total_sales <= 5000 then 'Regular'
	        else 'VIP'
	    end as customer_category
	from customer_sales_lifespan
)
select
  customer_category
  , count(customer_key) as customer_count
from categorized_customers
group by customer_category
order by count(customer_key);
