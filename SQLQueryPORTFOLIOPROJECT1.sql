--DATA EXPLORATION

select *
from coviddeaths
order by 3,4

select *
from covidvaccinations
order by 3,4

select *
from coviddeaths 
where continent is not null
order by 3,4

--Notice that the field total_cases and total_deaths are of data type nvarchar
--we need to convert them to float to enable the computations that will follow

alter table coviddeaths
alter column total_cases float
go

alter table coviddeaths
alter column total_deaths float
go

--GLOBAL NUMBERS

--world population
select distinct Location, max(population) as worldpopulation 
from coviddeaths
where location = 'World'
group by location

--Infection rate wourldwide 

select distinct Location, max(population) as worldpopulation, sum(new_cases) as totalcases, (sum(new_cases)/max(population))*100 as overollinfectionrate
from coviddeaths
where location = 'World'
group by location

--Death rate worldwide from 

select Location, sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, (sum(new_deaths)/sum(new_cases))*100 as overolldeathPercentage  
from coviddeaths
where Location = 'World'
group by Location

--LOOKING AT INCOME STATUS
--Infection rate by income status

select location, sum(new_cases) as totalcasesperincomelevel, max(population) as population, (sum(new_cases)/max(population))*100 infectionrateperincomelevel
from coviddeaths
where location =  'High income'
or location = 'Upper middle income'
or location = 'Lower middle income'
or location = 'Low income'
and continent is null
group by location
order by infectionrateperincomelevel desc

--death rate per income level

select location as Incomelevel, sum(new_deaths) as deathcountperincomelevel, max(population) as population, (sum(new_deaths)/max(population))*100 as deathrateperincomelevel
from coviddeaths
where location =  'High income'
or location = 'Upper middle income'
or location = 'Lower middle income'
or location = 'Low income'
and continent is null
group by location
order by deathrateperincomelevel desc



--NUMBERS BY CONTINENT


--Infection count by continent
select continent,  sum(new_cases) as totalcases
from coviddeaths
where continent is not null
group by continent
order by totalcases desc

--Death count by continent

select continent, sum(new_deaths) as totaldeathcount
from coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc



--NUMBERS PER COUNTRY

--Infection rate per Country

select Location, Population, max(total_cases) as totalcases, max((total_cases/Population)*100) as Percentofpopninfected
from coviddeaths
where continent is not null
group by location, population
order by Percentofpopninfected desc

--Countries with smaller populations tend to give the highest infection rate. 
--However, looking at the total number of cases per country gives a clearer insight on the infections

select Location,  max(total_cases) as totalcases
from coviddeaths
where continent is not null
group by location
order by totalcases desc

--Death count per country

select Location,  max(total_deaths) as totaldeathcount
from coviddeaths
where continent is not null
group by location
order by totaldeathcount desc


--Breaking it down to my Country
--Using Uganda as the case study

select Location, date, total_cases, new_cases, total_deaths, Population
from coviddeaths
where continent is not null
and Location like 'Uganda'
order by 1,2

--Infection rate in Uganda- Percentage of the population infected with covid

select Location, Population,  max(total_cases) as totalcasesUG, max(Population) as UGPopulation, (max(total_cases)/MAX(Population))*100 as UGInfectionrate
from coviddeaths
where continent is not null
and location like 'Uganda'
group by location, population


 --Likelihood of death if you contract covid in Uganda at this point in time

select Location, max(total_cases) as totalcasesUG, max(total_deaths) as totaldeathsUG, (max(total_deaths)/max(total_cases))*100 as UGDeathPercentage
from coviddeaths
where continent is not null
and Location like 'Uganda'
group by location

--Total cases Vs Population
--Shows percentage of the population that were infected with covid (probability of getting infected over the years)

select Location, date, Population, total_cases, (total_cases/Population)*100 as Popnpercentageinfected
from coviddeaths
where continent is not null
and Location like 'Uganda'
order by 1,2

--Looking at total population vs vaccinations

Alter table covidvaccinations
alter column total_vaccinations bigint
go



--Shows percentage of population that has received at least one covid vaccine by a particular date
--Using CTE

with PopVsVAcc (continent, location, date, population, new_vaccinations, Rollingsumofvaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(vacc.new_vaccinations) over (Partition by dea.Location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as Rollingsumofvaccinations
from coviddeaths dea
Join covidvaccinations vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
)
select*, (Rollingsumofvaccinations/population)*100 as percentppnvaccinated
from PopVsVAcc
order by location, percentppnvaccinated


--Using temp tables
drop table if exists #percentppnvaccinated
create table #percentppnvaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingsumofvaccinations numeric)

insert into #percentppnvaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(vacc.new_vaccinations) over (Partition by dea.Location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as Rollingsumofvaccinations
from coviddeaths dea
Join covidvaccinations vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
select*, (Rollingsumofvaccinations/population)*100  as percentppnvaccinated
from #percentppnvaccinated
order by location, percentppnvaccinated
