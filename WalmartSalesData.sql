SELECT * FROM walmart.sales;

-- How many unique cities does the data have? Ans: 995

select distinct count(city) from sales;

-- How many branches does each city has?
select city, count(Branch) from sales group by city;

-- How many unique product lines does the data have?
select Product_line, count(Product_line) from sales group by Product_line;

-- What is the most common payment method?
with countpayments_cte as (select Payment, count(Payment) as payment_method_count from sales group by Payment)
select *, rank() over(order by payment) as top_rank from countpayments_cte limit 1;
select Payment, count(Payment) as payment_method_count from sales group by Payment order by payment_method_count desc limit 1;

-- What is the most selling product line and where? Ans: Product_line: Home and lifestyle | total_ordered_quantity: 371 | city: Yangon
select 
	row_number() over(order by city) as sr_no, 
    city, 
    Product_line,
    sum(Quantity) as total_ordered_quantity 
from sales
group by City, Product_line
order by total_ordered_quantity desc limit 1;

-- What is the total revenue by month?
SELECT 
    MONTH(Date) AS month_number,
    concat(monthname(Date), " ", year(Date)),
    SUM(Quantity * Unit_price) AS revenue
FROM
    sales
GROUP BY MONTH(Date) , concat(monthname(Date), " ", year(Date))
ORDER BY month_number;

-- What month had the highest COGS?
SELECT 
    MONTH(Date) AS month_number,
    concat(monthname(Date), " ", year(Date)),
    round(SUM(COGS),2) as COGS
FROM
    sales
GROUP BY MONTH(Date) , concat(monthname(Date), " ", year(Date))
ORDER BY month_number;

-- What product line had the largest revenue?
with cte_1 as (SELECT 
    Product_line,
    SUM(Quantity * Unit_price) AS revenue
FROM
    sales
GROUP BY Product_line)
select *, rank() over(order by revenue desc) as rankperrev
from cte_1;

-- Which is the city with the largest revenue?
with cte_1 as (SELECT 
    City,
    SUM(Quantity * Unit_price) AS revenue
FROM
    sales
GROUP BY City)
select *, rank() over(order by revenue desc) as rankperrev
from cte_1;

-- What product line had the largest VAT?
SELECT 
    City,
    SUM(Quantity * VAT) AS total_vat
FROM
    sales
GROUP BY City
order by total_vat desc;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
with cte_2 as (SELECT 
    Product_line,
    round(SUM(Total)/sum(Quantity),2) AS average_revenue
FROM
    sales
GROUP BY Product_line
order by Product_line desc)
select Product_line,average_revenue, case when average_revenue >= 59.8 then "Good" else "bad" end as result from cte_2;

select 
	Product_line, 
    case 
		when round(SUM(sales.Total)/sum(sales.Quantity),2) >= (SELECT round(SUM(Total)/sum(Quantity),2) AS rev_average FROM sales) 
then "Good" else "Bad" 
end as result
FROM
    sales
group by Product_line
Order by Product_line desc;

-- Which branch sold more products than average product sold?

select City, Branch, avg(Quantity) as avg_q
from sales
group by City, Branch
order by avg_q desc limit 1;

-- What is the most common product line by gender?

with cte_3 as (select Gender, Product_line, sum(Quantity) as total_q, rank() over(partition by Gender order by Product_line) as rank_by_gender
from sales
group by Gender, Product_line
order by Gender, total_q desc)

select * from cte_3
order by rank_by_gender limit 2;

-- What is the average rating of each product line?

select Product_line, round(avg(Rating),2) as average_rating
from sales
group by Product_line
order by average_rating desc;

-- Sales related question -- Number of sales made in each time of the day per weekday

With a as (select *, dayname(Date) as day_name
from sales)
SELECT
	Time,
	COUNT(*) AS total_sales
FROM a
WHERE day_name <> 'Sunday'
GROUP BY Time
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?

SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?

SELECT
	city,
    ROUND(AVG(VAT), 2) AS avg_tax_pct
FROM sales
GROUP BY city
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?

SELECT
	customer_type,
	AVG(VAT) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;

-- Customers
-- Which customer type buys the most?

SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;

-- What is the gender of most of the customers?

SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Which time of the day do customers give most ratings?
SELECT
	Time,
	AVG(Rating) AS avg_rating
FROM sales
GROUP BY Time
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT
	Time,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY Time
ORDER BY avg_rating DESC;


-- Which day fo the week has the best avg ratings?
SELECT
	dayname(Date) as day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT 
	dayname(Date) as day_name,
	COUNT(dayname(Date)) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;
