-- Amazons Questions

-- 1. Find out the top 5 sellers who made the highest profits.

select * from customers
select * from orders
select * from products

select s.seller_id, round(round(sum(o.sale)::numeric,2) - (sum(p.cogs * o.quantity))::numeric,2)  as profit
from orders o
join sellers s 
on o.seller_id = s.seller_id
join products p
on o.product_id = p.product_id
group by 1
order by 2 desc limit 5


-- 2. Find out the average quantity ordered per category.

select category,round(avg(quantity)::numeric,2) as average_quantity
from orders
where category is not null
group by 1;

-- 3. Identify the top 5 products that have generated the highest revenue.

with revenue_rank as
(
select p.product_name, sum(o.sale) as total_revenue,
	dense_rank() over(order by sum(o.sale) desc) as rank
from orders o
JOIN products p 
on p.product_id = o.product_id
group by p.product_name
	)
select product_name, total_revenue
from revenue_rank
where rank < 6
order by 2 desc;


-- 4. Determine the top 5 products whose revenue has decreased compared to the previous year.

select * from orders;

with sale_previous_year as
(
select product_id, extract(year from order_date) as previous_year , round(sum(sale)::numeric,2) as previous_sale
from orders
where extract(year from order_date) =2023
group by 1,2
),
sale_current_year as
(
select product_id, extract(year from order_date) as previous_year , round(sum(sale)::numeric,2) as current_sale
from orders
where extract(year from order_date) =2024
group by 1,2
)
select spy.product_id,p.product_name,previous_sale, current_sale, previous_sale - current_sale as decrease_sale
from sale_previous_year as spy
join sale_current_year as scy
on spy.product_id = scy.product_id
join products p 
on spy.product_id = p.product_id
order by decrease_sale desc limit 5
-- group by spy.product_id


-- 5. Identify the highest profitable sub-category.
select * from orders;
select o.sub_category, sum(o.sale) - sum(o.quantity * p.cogs) as profit
from orders o
join products p
on o.product_id = p.product_id
where sub_category is not null
group by 1
order by 2 desc limit 1
;


-- 6. Find out the states with the highest total orders.
with state_rank as
(
select state,count(order_id) as total_orders,
dense_rank() over(order by count(order_id) desc) as rank
from orders
group by 1
)
select state, total_orders
from state_rank
where rank = 1

-- 7. Determine the month with the highest number of orders.
select * from orders;
-- highest order in month's partitoning by every year
with rank_month_orders as
(
select 
	extract(year from order_date),
	extract(month from order_date),
	count(order_id),
	dense_rank() over(partition by extract(month from order_date) order by count(order_id) desc) as dr
from orders
group by 1,2
)
select *
from rank_month_orders
where dr =1

-- highest order by month not considering year
with rank_month_orders as
(
select 
	extract(month from order_date) as month,
	count(order_id) as total_orders,
	dense_rank() over(order by count(order_id) desc) as dr
from orders
group by 1
)
select month, total_orders
from rank_month_orders
where dr =1


-- 8. Calculate the profit margin percentage for each sale (Profit divided by Sales).

select o.order_id, ((sum(o.sale) - sum(o.quantity * p.cogs))/sum(o.quantity * p.cogs))*100 as profit_percentage
from orders o
join products p
on p.product_id = o.product_id
group by 1;


-- 9. Calculate the percentage contribution of each sub-category
with sub_category_sale as
(
select sub_category, sum(sale) as total_sales
from orders
group by 1
)
select sub_category, total_sales, 
(total_sales/(select sum(sale)from orders))*100 as sub_category_percentage
from sub_category_sale
order by 3 desc
;

-- 10.Identify top 2 category that has received maximum returns and their return %

select o.category, count(r.return_id) as total_returns, 
		round(count(r.return_id)/(select count(*)from orders)::numeric,2) *100 as return_percentage
from orders o
right join returns r
on r.order_id = o.order_id
group by 1
order by 2 desc limit 2


