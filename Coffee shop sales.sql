#### COFFEE SHOP SALES PROJECT
use  coffee_shop_sales_db;
--- Viewing the data
Select count(*) from `coffee shop`;

SELECT `coffee shop`.`transaction_id`,
    `coffee shop`.`transaction_date`,
    `coffee shop`.`transaction_time`,
    `coffee shop`.`transaction_qty`,
    `coffee shop`.`store_id`,
    `coffee shop`.`store_location`,
    `coffee shop`.`product_id`,
    `coffee shop`.`unit_price`,
    `coffee shop`.`product_category`,
    `coffee shop`.`product_type`,
    `coffee shop`.`product_detail`
FROM `coffee_shop_sales_db`.`coffee shop`;

DESCRIBE `coffee shop`;

SET SQL_SAFE_UPDATES = 0;
--- CONVERT DATE (transaction_date) COLUMN TO PROPER DATE FORMAT

UPDATE `coffee shop`
SET transaction_date = str_to_date(transaction_date, '%d-%m-%Y');

--- ALTER DATE (transaction_date) COLUMN TO DATE DATA TYPE
ALTER table `coffee shop`
MODIFY COLUMN transaction_date DATE;

--- CONVERT TIME (transaction_time)  COLUMN TO PROPER DATE FORMAT
UPDATE `coffee shop`
SET transaction_time = str_to_date(transaction_time, '%H:%i:%s');

--- ALTER TIME (transaction_time) COLUMN TO DATE DATA TYPE
ALTER table `coffee shop`
MODIFY COLUMN transaction_time TIME;

--- DATA TYPES OF DIFFERENT COLUMNS
DESCRIBE `coffee shop`;

SELECT * from `coffee shop`;

--- TOTAL SALES
select round(sum(unit_price * transaction_qty)) as Total_sales
from `coffee shop`
Where month(transaction_date)= 5; #--May month sales

select round(sum(unit_price * transaction_qty)) as Total_sales
from `coffee shop`
Where month(transaction_date)= 3; -- March month sales

--- TOTAL SALES KPI - MOM DIFFERENCE & MOM GROWTH

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    `coffee shop`
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

--- Total Orders
select count(transaction_id) as Total_orders
from  `coffee shop`
where 
Month(transaction_date)= 3;  ##March month orders

--- TOTAL Orders KPI -  MOM DIFFERENCE AND MOM GROWTH
select MONTH(transaction_date) AS month,
round(count(transaction_id)) AS total_orders,
(count(transaction_id) -LAG(count(transaction_id),1)
over(order by month(transaction_date)))/lag(count(transaction_id),1)
over(order by month(transaction_date))*100 as mom_increase_percentage
from `coffee shop`
where month(transaction_date) in (4,5)
group by month(transaction_date)
order by month(transaction_date);

select * from `coffee shop`;

--- Total quantity sold
select sum(transaction_qty) as Total_qty_sold
from `coffee shop`
where 
month(transaction_date) = 6;

--- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE & MOM GROWTH
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    `coffee shop`
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
--- Metrics for dashboard date wise
--- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS

SELECT 
	concat(ROUND(sum(unit_price * transaction_qty)/1000,1),'k') AS Total_sales,
    concat(round(sum(transaction_qty)/1000,1),'k') AS Total_quantity_sold,
    concat(round(count(transaction_id)/1000,1),'k') AS Total_orders
FROM `coffee shop`
WHERE 
	transaction_date = '2023-05-18';
    
--- SALES BY WEEKDAY / WEEKEND:
--- sat-sun (weekends), Mon-Fri (weekdays) sun=1, mon=2 .... sat=7

SELECT
	CASE when dayofweek(transaction_date) in (1,7) then 'Weekends'
    ELSE 'Weekdays'
    END AS Day_type,
   concat(round(sum(unit_price * transaction_qty)/1000,1),'k') AS Total_Sales
FROM  `coffee shop`
WHERE month(transaction_date) = 6
group by 
	Day_type;

--- sales by Store location 
select 
	store_location,
    concat(round(sum(unit_price*transaction_qty)/1000,1),'k') as Total_sales
FROM `coffee shop`
Where month(transaction_date)= 5
Group by store_location
order by Total_sales desc;

--- SALES TREND OVER PERIOD

select concat(round(AVG(total_sales)/1000,1),'k') as Avg_sales
FROM(
	select sum(transaction_qty * unit_price) as total_sales
    from `coffee shop`
    WHERE month(transaction_date)= 5
    GROUP BY transaction_date) as inner_querry ;
    
    --- DAILY SALES FOR MONTH SELECTED
    
    SELECT 
		day(transaction_date) AS day_of_month,
        concat(round(sum(transaction_qty * unit_price)/1000,1),'k') as total_sales
	FROM `coffee shop`
    where month(transaction_date)= 5
    group by day(transaction_date)
    order by day(transaction_date);

--- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”

SELECT 
	day_of_month,
		CASE
        when total_sales > avg_sales then 'Above average'
        when total_sales < avg_sales then 'Below average'
        ELSE 'Average'
        END as Sales_status,
        total_sales
        from(
        select day(transaction_date) as day_of_month,
        sum(unit_price * transaction_qty) as total_sales,
        avg(sum(unit_price * transaction_qty)) OVER() as avg_sales
        FROM `coffee shop`
        WHERE month(transaction_date) = 5
        GROUP BY day(transaction_date)
        ) As sales_data
        order by day_of_month;
			
select * from `coffee shop`;

--- sales by product category

SELECT 
	product_category,
	concat(round(sum(transaction_qty * unit_price)/1000,1),'k')as total_sales
from `coffee shop`
where month(transaction_date)= 5
group by product_category
order by sum(transaction_qty * unit_price) DESC;

---  Top 10 products by sales
SELECT 
	product_type,
	concat(round(sum(transaction_qty * unit_price)/1000,1),'k')as total_sales
from `coffee shop`
where month(transaction_date)= 5
group by product_type
order by sum(transaction_qty * unit_price) DESC
limit 10;

--- Top 10 by product category
SELECT 
	product_type,
	concat(round(sum(transaction_qty * unit_price)/1000,1),'k')as total_sales
from `coffee shop`
where month(transaction_date)= 5 and product_category='Coffee'
group by product_type
order by sum(transaction_qty * unit_price) DESC
limit 10;

--- SALES BY DAY | HOUR 
select
	concat(round(sum(transaction_qty * unit_price)/1000,1),'k')as total_sales,
    sum(transaction_qty) as total_qty,
    count(*)
from `coffee shop`
Where month(transaction_date)= 5 #---may
AND dayofweek(transaction_date) = 2 #--- Monday
AND HOUR(transaction_time)= 8; #-- hour 8

--- hourly sales
select
	hour(transaction_time),
	concat(round(sum(transaction_qty * unit_price)/1000,1),'k')as total_sales
FROM `coffee shop`
WHERE month(transaction_date) = 5
group by hour(transaction_time)
order by hour(transaction_time);

--- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    concat(round(sum(transaction_qty * unit_price)/1000,1),'k')as total_sales
FROM 
    `coffee shop`
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;

--- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    `coffee shop`
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);









