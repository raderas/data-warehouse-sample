/*
 * Customer Report
 * ===========================
 * Purpose: This report	 consolidates key customer metrics and behaviors
 * 
 * Highlights:
 * 1- Gather essential fields such as names, ages and transaction details.
 * 2- Segments customer into categories (VIP, Regular, New) and age groups.
 * 3- Aggregates customer level metrics:
 *    - total orders
 *    - total sales
 *    - total quantity purchased
 *    - total products
 *    - lifespan (in months)
 * 4- Calculates valuable KPIs
 *    - recency (months since last order)
 *    - average order value
 *    - average monthly spend
 * =============================
*/
create or replace view gold.report_customers as
with base_query as(
	select
	  fs2.order_number
	  , fs2.product_key
	  , fs2.order_date
	  , fs2.sales_amount
	  , fs2.quantity
	  , dc.customer_key
	  , dc.customer_number
	  , concat(concat(dc.first_name,  ' '), dc.last_name) as customer_name
	  , extract(year from age(now(),dc.birthdate)) as customer_age
	FROM gold.fact_sales fs2
	LEFT JOIN gold.dim_customers dc 
	  on fs2.customer_key = dc.customer_key 
	where fs2.order_date is not null
),
customer_aggregations as(
	select
		customer_key
		, customer_number
		, customer_name
		, customer_age
		, count(distinct order_number) as total_orders
		, max(order_date) as last_order
		, extract(year from age(max(order_date),min(order_date))) * 12 + extract(month from age(max(order_date),min(order_date))) as lifespan
		, sum(sales_amount) as total_sales
		, sum(quantity) as total_quantity
		, count(distinct product_key) as total_products
	from base_query
	group by 1,2,3,4
)
select
  customer_key
  , customer_number
  , customer_name
  , customer_age
  , case when customer_age < 20 then 'Under 20'
        when customer_age between 20 and 29 then ' 20-29'
        when customer_age between 30 and 39 then '30-39'
        when customer_age between 40 and 49 then '40-49'
        else '50 and above'
    end as age_group
  , case when lifespan < 12 then 'New'
        when total_sales <= 5000 then 'Regular'
        else 'VIP'
    end customer_segment
  , total_orders
  , last_order
  , age(now(), last_order) as recency
  , lifespan
  , total_sales
  , total_quantity
  , total_products
  -- Compute average order value
  , case when total_orders = 0 then 0 else total_sales/total_orders end as avg_order_value
  -- Compute average monthly spend
  -- Be careful of not dividing by zero. If customer has only one month, take total sales as the value
  , case when lifespan = 0 then total_sales else total_sales / lifespan end as average_monthly_spend
from customer_aggregations
;

select * from gold.report_customers;
