select * from products

select * from sales_pipeline

select * from sales_teams

---Joining the 3 tables

SELECT sp.*, st.*, p.*
from sales_pipeline sp
left join sales_teams st on sp.sales_agent=st.sales_agent
left join products p on sp.product=p.product

--We shall then create a table recognizable to the database for further manipulation

SELECT sp.*, st.sales_agent as salesagent_team, st.manager,st.regional_office, p.product as pdt, p.sales_price, p.series
INTO SALES_pip
FROM sales_pipeline sp
LEFT JOIN sales_teams st ON sp.sales_agent = st.sales_agent
LEFT JOIN products p ON sp.product = p.product

select * from SALES_pip
--we now need to drop the duplicate columns
alter table sales_pip
drop column salesagent_team,pdt

---standardizing the dates -remove the time stamp because it is irrelevant for this analysis
update SALES_pip
set engage_date = cast(engage_date as date)


select engage_date from SALES_pip

--DATA ANALYSIS

---What is the revenue collected by each team from won deals?
select manager, sum(close_value) as Revenue
from SALES_pip
where close_date is not null and deal_stage like 'Won'
group by manager
order by Revenue desc

--How many sales opportunities have been won for each sales manager? Whose team has won the most deals?

select manager, deal_stage, count(deal_stage) as count
from SALES_pip
where deal_stage like 'Won' and close_date is not null
group by manager,deal_stage
order by count desc

--whose team lost the most deals?

select manager, deal_stage, count(deal_stage) as count
from SALES_pip
where deal_stage like 'Lost' and close_date is not null
group by manager,deal_stage
order by count desc

--Which team still has the most deals still not concluded"

select manager, deal_stage, count(deal_stage) as count
from SALES_pip
where deal_stage like 'Engaging' and close_date is null
group by manager,deal_stage 
order by count desc

--Which team has the highest number of prospects?
select manager, deal_stage, count(deal_stage) as count
from SALES_pip
where deal_stage like 'Prospecting' and close_date is null and engage_date is null
group by manager,deal_stage 
order by count desc

-- now we want to look at the above numbers side by side
select manager, deal_stage, count(deal_stage) as count
from SALES_pip
group by manager,deal_stage
order by manager, count desc

---What product type has had the most successfull(won) deaals?
select product, count(product) as Count
from SALES_pip
where deal_stage like 'Won' and close_date is not null
group by product
order by count desc

--number of won product sales opportunities of each sales manager	
select manager, product, count(product) as count
from SALES_pip
where engage_date is not null and close_date is not null and deal_stage like 'Won'
group by manager, product
order by manager,count  desc

select * from SALES_pip

--How many sales were closed above the sales price per team?
select manager, count(close_value) as count
from SALES_pip
where sales_price < close_value and close_date is not null
group by manager
order by count desc

--How many sales were closed below sales perice for each team?
select manager, count(close_value) as count
from SALES_pip
where sales_price > close_value and close_date is not null
group by manager
order by count desc

--How has the count of won deals changed over time?
select engage_date, count(deal_stage) as count
from SALES_pip
where close_date is not null and deal_stage like 'Won'
group by engage_date, deal_stage
order by engage_date

--How has the count of lost deals changed overtime?
select engage_date, count(deal_stage) as count
from SALES_pip
where close_date is not null and deal_stage like 'Lost'
group by engage_date, deal_stage
order by engage_date

---Which regional office generated the highest revenue?
select regional_office, sum(close_value) as Revenue
from SALES_pip
where close_date is not null
group by regional_office
order by Revenue desc

--which teams generated the most revenue within each regional office?

select regional_office,manager, sum(close_value) as Revenue
from SALES_pip
where close_date is not null
group by regional_office,manager
order by Revenue desc

--Who are the top 5 sales agents overall?
select top 5 sales_agent, regional_office, manager, sum(close_value) as Revenue
from SALES_pip
where close_date is not null	
group by sales_agent,regional_office,manager
order by Revenue desc


--Who are the top 5 sales agents who had a close value higher than the sales price?
select top 5 sales_agent, regional_office, manager, sum(close_value) as Revenue
from SALES_pip
where close_date is not null and sales_price < close_value	
group by sales_agent,regional_office,manager
order by Revenue desc

---What is the general performance of each sales agent? How much Revenue was brough in by each agent?
select sales_agent, regional_office, manager, sum(close_value) as Revenue
from SALES_pip
where close_date is not null	
group by sales_agent,regional_office,manager
order by Revenue desc