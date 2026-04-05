/*
 * ============================================
 * Product Report
 * ============================================
 * Purpose:
 * 	- This report consolidates key product metrics and behaviors
 * 
 * Highligts:
 * 1. Gathers essentiald fields such as product name , category, subcategory and cost.
 * 2. Segments products by revenue to identify High Performers, Mid-Range, or Low Performers.
 * 3. Aggregates product level metrics:
 *     - total orders
 *     - total sales
 *     - total quantity sold
 *     - total customers (unique)
 *     - lifespan (in months)
 * 4. Calculates valuable KPIs:
 *     - recency (months since last sale)
 *     - average order revenue (AOR)
 *     - average monthly revenue
 */
create or replace view gold.report_products as
with base_query as(
	select 
	  fs2.product_key 
	  , fs2.order_number 
	  , fs2.order_date
	  , fs2.sales_amount
	  , fs2.quantity
	  , fs2.customer_key
	  , dp.product_id 
	  , dp.product_number 
	  , dp.product_name 
	  , dp.product_category 
	  , dp.subcategory 
	  , dp.product_line
	  , dp.cost
	from gold.fact_sales fs2 
	left join gold.dim_products dp 
	  on fs2.product_key = dp.product_key 
	where fs2.order_date is not null 
),
aggregated_table as(
	select
	  product_key
	  , product_number
	  , product_name
	  , product_category
	  , subcategory
	  , product_line
	  , cost 
	  , count(distinct order_number) as total_orders
	  , sum(sales_amount) as total_sales
	  , sum(quantity) as total_quantity_sold
	  , min(order_date) as first_placed_order
	  , max(order_date) as latest_placed_order
	  , extract(year from age(max(order_date),min(order_date))) * 12 + extract(month from age(max(order_date),min(order_date))) as lifespan
	  , count(distinct customer_key) as unique_customers
	from base_query
	group by 1,2,3,4,5,6,7
)
select
  product_key
  , product_number
  , product_name
  , product_category
  , subcategory
  , product_line
  , lifespan
  , case when total_sales > 50000 then 'High Performer'
        when total_sales >= 10000 then 'Mid-Range'
        else 'Low-Performer'
     end as product_segment
  , age(now(),latest_placed_order) as recency
  , case when total_orders = 0 then 0 else total_sales / total_orders end as average_order_revenue
  , round(case when lifespan = 0 then total_sales else total_sales / lifespan end,2) as average_monthly_revenue
from aggregated_table
;

select * from gold.report_products;
