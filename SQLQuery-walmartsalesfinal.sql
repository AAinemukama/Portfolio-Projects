select *
from walmartsales

----Performance of each product line based on total number of orders per product line using the field Quantity

---first we need to convert the quantity field to interger to ease calculation
alter table walmartsales
alter column Quantity int
go
--We shall use temp tables for this calculation

drop table if exists #TempSalesdata
create table #TempSalesdata
(Productline nvarchar(255), Quantity int)

--inserting data into the temp table

insert into #TempSalesdata
select Productline, Quantity
from walmartsales

----calculate total quantity for each product line

select Productline, sum(Quantity) as TotalQuantity
from #TempSalesdata
group by Productline


select Productline, TotalQuantity, cast((TotalQuantity*100.0)/sum(TotalQuantity) over() as decimal(5,2)) as Percentageqty
from(select Productline, sum(Quantity) as TotalQuantity
from #TempSalesdata
group by Productline) as subquery
order by Percentageqty desc

--Total revenue generated by each branch
select Branch, sum(Revenue) as Total_revenue
from walmartsales
group by Branch
order by Total_revenue desc


--Performance of each product line based on the total revenue generated

---We shall use CTE for this calculation
--define the CTE

With RevenueTotals as (select Productline, Sum(Revenue) as TotalRevenue
from walmartsales
group by Productline)

---Using the CTE to calculate the percentage revenue of each product line
select Productline, TotalRevenue, cast((TotalRevenue*100.0)/sum(TotalRevenue) over() as decimal(5,2)) as PercentageRevGenerated
from RevenueTotals
order by PercentageRevGenerated desc

----Performance per branch by Revenue
--using the CTE
With RevenueTotalsperBranch as (select Branch, Sum(Revenue) as TotalRevenueperBranch
from walmartsales
group by Branch)

---Using the CTE to calculate the percentage revenue of each product line
select Branch, TotalRevenueperBranch, cast((TotalRevenueperbranch*100.0)/sum(TotalRevenueperBranch) over() as decimal(5,2)) as PercentageRevenueperBranch
from RevenueTotalsperBranch
order by PercentageRevenueperBranch desc

--Now we will look at the performance of each product line per branch using Revenue
--For Branch A
select Productline,sum(Revenue) as Revenueperpdtline
from walmartsales
where Branch ='A'
group by Productline
order by Revenueperpdtline desc

--For branch B
select Productline,sum(Revenue) as Revenueperpdtline
from walmartsales
where Branch ='B'
group by Productline
order by Revenueperpdtline desc

--For branch C
select Productline,sum(Revenue) as Revenueperpdtline
from walmartsales
where Branch ='C'
group by Productline
order by Revenueperpdtline desc


---Now lets look at the payment type

With PaymenttypeTotals as (select Paymenttype, count(Paymenttype) as countofpaymenttype
from walmartsales
group by Paymenttype)

---Using the CTE to calculate the overall percentage of each payment type
select Paymenttype, countofpaymenttype, cast((countofpaymenttype*100.0)/sum(countofpaymenttype) over() as decimal(5,2)) as Percentageofpaymenttype
from PaymenttypeTotals
order by Percentageofpaymenttype desc

---Ewallet(34.5%) and cash(34.4%)  are the most popular payment types overall, followed by credit card(31.10)

--Payment type per branch
select Paymenttype,count(Paymenttype) as countofpaymenttype
from walmartsales
where Branch='A'
group by Paymenttype
order by countofpaymenttype desc

select Paymenttype,count(Paymenttype) as countofpaymenttype
from walmartsales
where Branch='B'
group by Paymenttype
order by countofpaymenttype desc

select Paymenttype,count(Paymenttype) as countofpaymenttype
from walmartsales
where Branch='C'
group by Paymenttype
order by countofpaymenttype desc

--Pick out the Cities in which the different branches are located
select distinct Branch, City
from walmartsales

----Customer type
select Customertype, count(Customertype) as countofcustomertype
from walmartsales
group by Customertype
order by countofcustomertype desc

---Gender
select Gender, Count(Gender)as countofgender
from walmartsales
group by gender
order by countofgender desc

---Ratings
--Maximum rating achieved by each product line
 select Productline, max(Rating) as maxpdtlinerating
 from walmartsales
 group by Productline
 order by maxpdtlinerating desc

 ---performance of each productline depending on how many ratings were 80% and above
 select Productline, count(Rating) as Rating80andabove
 from walmartsales
 where Rating>=8.0
 group by Productline 
 order by Rating80andabove desc

  ---performance of each productline depending on how many ratings were below 60%
 select Productline, count(Rating) as Ratingbelow60
 from walmartsales
 where Rating <6.0
 group by Productline 
 order by Ratingbelow60 desc
 
  ---performance of each productline depending on how many ratings were between 59% and 80%
  select Productline, count(Rating) as countofneutralratings
 from walmartsales
 where Rating >5.9 and Rating <8.0
 group by Productline 
 order by countofneutralratings desc

