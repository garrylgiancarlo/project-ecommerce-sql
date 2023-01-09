with mau as
(	
select 
	year,
	round(avg(maus), 2) as avg_mau
from(
	 select
		date_part ('year', order_purchase_timestamp) as year,
		date_part ('month', order_purchase_timestamp) as month,
		count(distinct c.customer_unique_id) as maus
	 from orders o
	 join customers c on c.customer_id = o.customers_id
	 group by 1,2
	) sub1
group by 1
),
new_cust as
(
select date_part('year', first_buy) as year,
	   count(1) as new_customers
from(
	 select 
		c.customer_unique_id,
	 	min(order_purchase_timestamp) as first_buy
	 from orders o
	 join customers c on c.customer_id = o.customers_id
	 group by 1
	)subs
group by 1
),
rep_ord as
(
select
	year,
	count(distinct customer_unique_id) as repeating_cust
from(
	 select 
	 	date_part('year', order_purchase_timestamp) as year,
		c.customer_unique_id,
		count(1) as buy_freq
	from orders o
	join customers c on c.customer_id = o.customers_id
	group by 1,2
	having count(1) > 1
	) subs
group by 1
),
avg_freq as
(
select 
	year,
	round(avg(buy_freq),2) as avg_order_customers
from(
	select
	date_part('year', order_purchase_timestamp) as year,
		c.customer_unique_id,
		count(1) as buy_freq
	from orders o
	join customers c on c.customer_id = o.customers_id
	group by 1,2
	) subs
group by 1
)
select
	mau.year,
	mau.avg_mau,
	new_cust.new_customers,
	rep_ord.repeating_cust,
	avg_freq.avg_order_customers
from mau
join new_cust on new_cust.year = mau.year
join rep_ord on rep_ord.year = mau.year
join avg_freq on avg_freq.year = mau.year
