select 
    payment_type,
    count (1) as payment_used
from order_payment_dataset 
group by 1
order by 2 desc
;
with pay as(
    select
        date_part('year',o.order_purchase_timestamp) as year,
        py.payment_type,
        count (1) as payment_used
    from payments py
    join orders o on o.order_id = py.order_id
    group by 1,2
    order by 1
)
select
     payment_type,
     sum(case when year = '2016' then payment_used else 0 end) as year_2016,
     sum(case when year = '2017' then payment_used else 0 end) as year_2017,
     sum(case when year = '2018' then payment_used else 0 end) as year_2018
from pay
group by 1
order by 1
;