select * from city;
select * from customers;
select * from products;
select * from sales;


-- Q1. How many people in each city are estimated to consume coffee, given that 25% of the population does?

select city_name, round((population * 0.25) / 1000000 , 2) as coffee_consumers_in_millions
from city
order by coffee_consumers_in_millions desc;



-- Q2. What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select c.city_name, sum(s.total) as revenue
from sales as s
join customers as cu
on s.customer_id = cu.customer_id
join city as c
on c.city_id = cu.city_id
where sale_date >= '2023-10-01' and sale_date <= '2024-01-01'
group by city_name
order by revenue DESC;



-- Q3. How many units of each coffee product have been sold?

select p.product_name, count(s.sale_id) as units_sold
from products as p
left join sales as s
on p.product_id = s.product_id
group by p.product_name
order by units_sold DESC;



-- Q4. What is the average sales amount per customer in each city?
-- (1st, find city and total sale)
-- (2nd, find no. of customers in those city)

SELECT 
	ci.city_name,
	SUM(s.total) as total_revenue,
	COUNT(DISTINCT s.customer_id) as total_customers,
	ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id) ,2) as avg_sale_per_customer
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY total_revenue DESC;



-- Q5. Provide a list of cities along with their populations and estimated coffee consumers(25% of the population), and how many unique customers do we have per city?

with table_1 as
(
select city_name, population, ROUND((population * 0.25)/1000000, 2) as estimated_coffee_consumers
from city
),
table_2 as
(
select c.city_name, count(distinct cu.customer_id) as unique_number_of_customers
from city as c
join customers as cu
on c.city_id = cu.city_id
group by c.city_name
)
select table_2.city_name,
		table_1.population,
		table_1.estimated_coffee_consumers as estimated_coffee_consumers_in_millions,
		table_2.unique_number_of_customers
from table_1
join table_2
on table_1.city_name = table_2.city_name;



-- Q6. What are the top 3 selling products in each city based on sales volume?

select *
from (
select p.product_name, c.city_name, count(s.sale_id) as sales_volume,
		dense_rank() over(partition by c.city_name order by count(s.sale_id) DESC) as dense_rnk
from sales as s
join products as p
on s.product_id = p.product_id
join customers as cu
on cu.customer_id = s.customer_id
join city as c
on c.city_id = cu.city_id
group by p.product_name, c.city_name
) as xyz
where dense_rnk <= 3;



-- Q7. How many unique customers are there in each city who have purchased coffee products?

select c.city_name, count(distinct cu.customer_id) as unique_customers_count
from sales as s
join customers as cu
on s.customer_id = s.customer_id
join city as c
on c.city_id = cu.city_id
group by c.city_name
order by unique_customers_count DESC;



-- Q8. Find each city and their average sale per customer and avg rent per customer

select c.city_name,
	round(sum(s.total) / count(distinct cu.customer_id) ,2) as avg_sale_per_customer,
	round(c.estimated_rent / count(distinct cu.customer_id) , 2) as avg_rent_per_customer
from sales as s
join customers as cu
on s.customer_id = cu.customer_id
join city as c
on c.city_id = cu.city_id
group by c.city_name, c.estimated_rent
order by avg_sale_per_customer desc;



-- Q9. Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly) by each city		

with monthly_sales as
(
select
c.city_name, year(s.sale_date) as year, month(s.sale_date) as month, sum(s.total) as total_sales
from sales as s
join customers as cu
on s.customer_id = cu.customer_id
join city as c
on cu.city_id = c.city_id
group by c.city_name, year(s.sale_date), month(s.sale_date)
),
sales_growth as
(
select city_name, year, month, total_sales,
lag(total_sales) over (partition by city_name order by year, month) as previous_month_sales
from monthly_sales
)

select city_name, year, month, total_sales, previous_month_sales,
		round(((total_sales - previous_month_sales) / previous_month_sales) * 100, 2) as growth_percentage
from sales_growth
order by year, month desc;



-- Q 10. Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

select c.city_name,
		sum(s.total) as total_revenue,
        c.estimated_rent as total_rent,
		count(distinct cu.customer_id) as total_customers,
        round((c.population * 0.25) / 1000000, 2) as estimated_coffee_consumers_in_millions,
        round(sum(s.total) / count(distinct s.customer_id) ,2) as avg_sale_pr_customer,
        round(c.estimated_rent / count(distinct cu.customer_id) , 2) as avg_rent_per_cx
from sales as s
join customers as cu
on s.customer_id = cu.customer_id
join city as c
on cu.city_id = c.city_id
group by c.city_name, c.estimated_rent, c.population
order by total_revenue desc;

