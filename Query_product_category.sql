with top as
(
select date_part('year', order_purchase_timestamp) as year,
	sum(rpo) as revenue
from(
	select 
		order_id, 
		sum(price+freight_value) as rpo
	from order_item
	group by 1
) subq
join orders o on subq.order_id = o.order_id
where o.order_status = 'delivered'
group by 1
),
cancelo as
(
select date_part('year', order_purchase_timestamp) as year,
count(1) as num_canceled_orders
from orders
where order_status = 'canceled'
group by 1
),
top2 as
(
select 
	year, 
	product_category_name, 
	revenue 
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		p.product_category_name,
		sum(oi.price + oi.freight_value) as revenue,
		rank() over(partition by 
				date_part('year', o.order_purchase_timestamp) 
 			order by 
				sum(oi.price + oi.freight_value) desc) as subs
from order_item oi
join orders o on o.order_id = oi.order_id
join products p on p.product_id = oi.product_id
where o.order_status = 'delivered'
group by 1,2) sq
where subs = 1
),
cat_cancel as
(
select 
	year, 
	product_category_name, 
	num_canceled 
from (
	  select date_part('year', o.order_purchase_timestamp) as year,
			 p.product_category_name,
		   	 count(1) as num_canceled,
			 rank() over(partition by 
						date_part('year', o.order_purchase_timestamp) 
			 		order by count(1) desc) as subs
from order_item oi
join orders o on o.order_id = oi.order_id
join products p on p.product_id = oi.product_id
where o.order_status = 'canceled'
group by 1,2) sq
where subs = 1
)
select 
	top2.year,
	top2.product_category_name as top_product_category_by_revenue,
	top2.revenue as category_revenue,
	top.revenue as year_total_revenue,
	cat_cancel.product_category_name as most_canceled_product_category,
	cat_cancel.num_canceled as category_num_canceled,
	cancelo.num_canceled_orders as year_total_num_canceled
from top2
join top on top2.year = top.year 
join cat_cancel on top2.year = cat_cancel.year 
join cancelo on cancelo.year = top2.year
;
with top3 as(
select 
	year, 
	product_category_name, 
	revenue 
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		p.product_category_name,
		sum(oi.price + oi.freight_value) as revenue,
		rank() over(partition by 
				date_part('year', o.order_purchase_timestamp) 
 			order by 
				sum(oi.price + oi.freight_value) desc) as subs
from order_item oi
join orders o on o.order_id = oi.order_id
join products p on p.product_id = oi.product_id
where o.order_status = 'delivered'
group by 1,2) sq
where subs = 1 or subs = 2 or subs = 3
order by 1, 3 desc
)
select
     product_category_name,
     sum(case when year = '2016' then revenue else 0 end) as year_2016,
     sum(case when year = '2017' then revenue else 0 end) as year_2017,
     sum(case when year = '2018' then revenue else 0 end) as year_2018
from top3
group by 1
order by 2 desc , 3 desc, 4 desc
;
