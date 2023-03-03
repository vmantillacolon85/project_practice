--SQL REVIEW--

--Yvette Thomas is one of the investors at Northwind. She has some requests for you about the opperations of
--her business. 

--The names and descriptions of all our product categoreies

select category_name, description 
from categories c ;

--What are the regions where our suppliers are located? -- WHERE CLAUSE NOT NULL, DISTINCT
select distinct region
from suppliers s
where region is not null;

--The names of all discontinued products -- WHERE CLAUSE FILTER
select product_name
from products p 
where discontinued = 1;

--What categories do these discontiued products fall under? --INNER JOIN
select c.category_name, p.product_name 
from products p 
inner join categories c on p.category_id = c.category_id 
where discontinued = 1

--What discontinued products are in Meat/Poultry or Beverages? --WHERE CLAUSE USING IN, AND
select c.category_name, p.product_name 
from products p 
join categories c on p.category_id = c.category_id 
where discontinued = 1 and c.category_name in ('Beverages', 'Meat/Poultry')


--How many units of the discontinued products did we sell?  -- Aggregate using Group By
select p.product_name, SUM(od.quantity) as TotalQuantitySold
from products p 
join order_details od on p.product_id = od.product_id 
where discontinued = 1
group by p.product_name 
order by TotalQuantitySold desc

--Which discontinued products had less than 1000 units sold? --GROUP BY WITH HAVING
select product_name, sum(od.quantity) as TotalQuantitySold
from products p 
inner join order_details od on p.product_id = od.product_id 
where p.discontinued = 1 
group by product_name 
having sum(od.quantity) < 1000
order by TotalQuantitySold desc

--Yvette wants all the information about all of our customers, but wants to eaisly read if they are 
--international or domestic. Northwind is based in the USA --CASE/WHEN
select *,
case when country != 'USA' then 'International'
else 'Domestic ' end as CustomerLocation
from customers c 

--Yvette wants to know what states Northwind's customers are based in. Show their name, their company's name
-- and full state name. If they are based outside of the US it can be left blank   --LEFT JOIN

select c.contact_name, c.company_name, us.state_name as STATE
from customers c 
left join us_states us on c.region = us.state_abbr 
order by STATE

--Which shipping company has the most deliveries? -- COMMON TABLE EXPRESSIONS AND SUBQUERY 
with CompanyDel as (
select s.company_name, count(o.order_id) as NumDeliveries
from orders o 
join shippers s on o.ship_via = s.shipper_id 
group by s.company_name)
select *
from CompanyDel c
where NumDeliveries = (select Max(NumDeliveries) from CompanyDel) 

--What are the product's indivudual unit price's and how do they compare to the average unit price of their category?
--WINDOW FUNCTION
SELECT p.product_name, p.unit_price, c.category_name , avg(unit_price) OVER(PARTITION BY p.category_id)
FROM products p
JOIN categories c ON c.category_id = p.category_id



























--Great! I want to know about the suplier(s) of our coffee. What are their names and where are they based?
select s.company_name, s.city 
from products p 
join suppliers s ON p.supplier_id = s.supplier_id 
where product_name like '%Coffee%'

--Cool! How much coffee are we selling? What are our total sales?
select p.product_name as ProductName, SUM(od.quantity), Round(cast(SUM((od.quantity*od.unit_price)*(1-od.discount)) as numeric),2) as TotalSales
from products p 
join order_details od on p.product_id = od.product_id
where product_name  like '%Coffee%'
group by product_name