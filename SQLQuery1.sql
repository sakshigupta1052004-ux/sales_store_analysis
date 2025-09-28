
drop table if exists sales_store;
create table sales_store (
transaction_id VARCHAR(15),
customer_id VARCHAR(15),
customer_name VARCHAR(30),
customer_age int,
gender VARCHAR(15),
product_id VARCHAR(15),
product_name VARCHAR(15),
product_category VARCHAR(15),
quantity int,
price float,
payment_mode VARCHAR(15),
purchase_date DATE,
time_of_purchase TIME,
status VARCHAR(15)
);

select * from sales_store

set dateformat dmy
BULK insert sales_store
from 'C:\Users\Sakshi Gupta\Downloads\archive (2)\sales_store_updated_allign_with_video.csv'
    with(
       firstrow=2,
       fieldterminator=',',
       rowterminator='\n'
    );

--DATA CLEANING

SELECT * FROM sales_store
drop table if exists sales;
SELECT * INTO SALES FROM sales_store
SELECT * FROM SALES

--step 1 - TO CHECK FOR DUPLICATE

SELECT transaction_id,COUNT(*)
from SALES
group by transaction_id
having count(transaction_id) >1

--window function

with cte as (
select *,
ROW_NUMBER()over (partition by transaction_id order by transaction_id)as row_num
from sales
)
--delete from cte
--where row_num=2

select * from cte
where transaction_id in ('TXN240646','TXN342128','TXN855235','TXN981773')




--step 2 - to check datatype

select column_name, data_type
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='sales'

--step 4 - To check null values

--to check null count

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, 
     COUNT(*) AS NullCount 
     FROM ' + QUOTENAME(TABLE_SCHEMA) + '.sales 
     WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL ' ,
    'UNION ALL '
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;

--treating null values

select *
from SALES
where transaction_id is null
or
customer_id is null
or
customer_name is null
or
customer_age is null
or
gender is null
or
product_id is null
or
product_name is null
or
product_category is null
or
quantity is null
or
price is null
or
payment_mode is null
or
purchase_date is null
or
time_of_purchase is null
or
status is null

delete from SALES where transaction_id is null

select * from SALES
where customer_name='Ehsaan Ram'

update SALES
set customer_id='CUST9494'
where transaction_id='TXN977900'

select * from SALES
where customer_name='Damini Raju'

update SALES
set customer_id='CUST1401'
where transaction_id='TXN985663'

select * from SALES
where customer_id='CUST1003'
update SALES
set customer_name='Mahika Saini',customer_age=35,gender='Male'
where transaction_id='TXN432798'

--data cleaning

select * from SALES

select distinct gender
from SALES

update SALES
set gender='M'
where gender = 'Male'

update SALES
set gender='F'
where gender = 'Female'

select distinct payment_mode from SALES
update SALES
set payment_mode='Credit Card'
where payment_mode = 'CC'

---DATA ANALAYSIS
--1. what are the top 5 most selling products by quantity?

select distinct status from SALES
select top 5 product_name, sum(quantity) as total_quantity_sold from SALES
where status='delivered'
group by product_name order by total_quantity_sold desc

--business problem: We don't know which products are most in demand.

--business impact: helps prioritize stock and boost sales through targeted promotions.


--2. which products are most frequently cnacelled?

select top 5 product_name,COUNT(*) as total_canceld from SALES
where status='cancelled'
group by product_name order by  total_canceld desc

--business problem: frequent cancellations affect revenue and customer trust.

--business impact: identify poor-performing products to improve quality or remove from catalog.

--3. What time of the day has the highest number of purchases?

select * from SALES

 select
  case
   when DATEPART(hour,time_of_purchase)between 0 and 5 then 'Night' 
   when DATEPART(hour,time_of_purchase)between 6 and 11 then 'Morning'
   when DATEPART(hour,time_of_purchase)between 12 and 17 then 'Afternoon'
   when DATEPART(hour,time_of_purchase)between 18 and 23 then 'Evening'
   END AS time_of_day,
   COUNT(*) as total_orders
from sales
group by
  case
   when DATEPART(hour,time_of_purchase)between 0 and 5 then 'Night' 
   when DATEPART(hour,time_of_purchase)between 6 and 11 then 'Morning'
   when DATEPART(hour,time_of_purchase)between 12 and 17 then 'Afternoon'
   when DATEPART(hour,time_of_purchase)between 18 and 23 then 'Evening'
   END
   order by total_orders desc

--business problem solved: find peak sales times.

--busniess impact: optimize staffing,promotion,and server loads.

--4 who are the top 5 highest spending customers?

select * from SALES

select top 5 customer_name,
   format(sum(price*quantity),'C0','en-IN') as total_spend
from SALES
group by customer_name
order by sum(price*quantity) desc

--business problem solved: identify VIP customers.

--business impact: Personalized offers, loyalty rewards,and retention.

--5. which product categories generate the highest revenue?

select * from SALES

select  product_category,
format(sum(price*quantity),'C0','en-IN') as total_revenu
from SALES
group by product_category
order by  sum(price*quantity) desc

-- 6. what is the return/cancellation rate per product category?
--cancellation
select * from SALES
select  product_category,
format(COUNT( case when status='cancelled' then 1 end)*100.0/COUNT(*),'N3')+ ' %'as cancelled_percent from SALES
group by product_category order by  cancelled_percent desc

--returned
select * from SALES
select product_category,
format(count(case when status='returned' then 1 end)*100.0/count(*),'N3')+ ' %' as returned_percent from SALES
group by product_category order by returned_percent desc

--business impact: reduce returns,improve productd descriptions/expectations.
--help identify and fix product or logistics issues.

--7. what is the most preferred payment mode?

select * from SALES
select payment_mode,count(*) as total_count from SALES 
group by payment_mode
order by total_count desc

--business problem solved: know with payment options customers prefer.

--business impact:streamline payment processing, priortize popular modes.

--8. how does age group affect purchasing behavior

select * from SALES
select min(customer_age),max(customer_age) from sales

select
case
when customer_age between 18 and 25 then '18-25'
when customer_age between 26 and 35 then '26-35'
when customer_age between 36 and 50 then '36-50'
else '51+'
end as customer_age,
format(sum(price*quantity) ,'C0','en-IN')as total_purchase
from sales
group by case
when customer_age between 18 and 25 then '18-25'
when customer_age between 26 and 35 then '26-35'
when customer_age between 36 and 50 then '36-50'
else '51+'
end 
order by sum(price*quantity) desc

--business problem solved: understand customer demographics.
--business impact: targeted maketing and product recommendations by age group

--9 what's the monthly sales trend?

select 
format(purchase_date,'yyyy-MM')as month_year,
format(sum(price*quantity),'C0','en-IN') as total_sales,
sum(quantity) as total_quantity
from sales
group by format(purchase_date,'yyyy-MM')

---bunsiness problem: sales fluctuations go unnoticed.
--busines impact: Plan inventory and marketing according to seasonal trends.

--10. are certain genders buying more specific product categories
 select * from SALES
 select gender,product_category,count(product_category) as total_purchase from SALES
 group by gender,product_category order by gender desc

 --business problem solved: gender-based product prefernces.
 --business impact: Personlized ads, gender-focused campaigns.
