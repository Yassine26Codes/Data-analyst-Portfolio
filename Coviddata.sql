--select *
--From CovidDeaths
--order by 3,4

--Select * 
--From CovidVaccinations
--order by 3,4


--Selection of useful data from CovidDeaths Table

select location,date, population, total_cases, new_cases,total_deaths
From CovidDeaths
order by 1,2


--checking ration of Total death Vs Total cases
select 
Cd.location, Cd.date, Cd.total_cases , Cd.total_deaths, (cast(Cd.total_deaths as numeric)/Cd.total_cases)*100 as DeathRatio

From CovidDeaths Cd
where Cd.location in ( 'morocco', 'France')
order by 1,2


--Checking likelihood of contracting covid
select 
Cd.location, Cd.date, Cd.population, Cd.total_cases, (cast(Cd.total_cases as decimal)/Cd.Population)*100 as ContractionRate
From CovidDeaths Cd
--where Cd.location in ( 'morocco', 'France')
order by 1,2


--Looking at contries with Highest infection rate/population
select 
Cd.location, Cd.population, Max(cast(Cd.total_cases as decimal)) as Highestinfectioncount, (Max(cast(Cd.total_cases as decimal))/Cd.Population)*100 as MaxContractionRate
From CovidDeaths Cd
--where Cd.location in ( 'morocco', 'France')
group by location, population
order by 4 desc



--Showing the countries with highest deathcount

select 
Cd.location, Max(cast(Cd.total_deaths as decimal)) as Highestdeathcount
From CovidDeaths Cd
where Cd.continent is not null
group by location
order by Highestdeathcount desc

--Lets check Continent data


select 
Cd.continent , Max(cast(Cd.total_deaths as decimal)) as Highestdeathcount
From CovidDeaths Cd
where Cd.continent is not null 
group by Cd.continent 
order by Highestdeathcount desc


-- global numbers

select 
Cd.date, Sum(cast(new_cases as decimal)) as worldNewcases, 
Sum(cast(new_deaths as decimal)) as worldnewdeaths, 
Sum(cast(Cd.new_deaths as numeric))/sum(cast(Cd.new_cases as decimal))*100 as DeathRatio

From CovidDeaths Cd
where continent is not null
group by Cd.date
order by 1,2

-- total world cases and deaths since beginning
select 
--Cd.date,
Sum(cast(new_cases as decimal)) as worldNewcases, 
Sum(cast(new_deaths as decimal)) as worldnewdeaths, 
Sum(cast(Cd.new_deaths as numeric))/sum(cast(Cd.new_cases as decimal))*100 as DeathRatio

From CovidDeaths Cd
where continent is not null
--group by Cd.date
order by 1,2


--let's check the vaccination data

select*
from CovidVaccinations

--how many people are vaccinated per population

select 

Cd.continent,Cd.location, Cd.date, Cd.population, Cv.new_vaccinations
From CovidDeaths Cd
join CovidVaccinations Cv 
ON Cd.date= Cv.date and Cd.location=Cv.location 
where cd.continent is not null
order by 2,3


-- do a rolling count of Vaccination

With Prctvax( continent, location,date,population,new_vaccinations,RollingCountVaccination)
as(
select 

Cd.continent,Cd.location, Cd.date, Cd.population, Cv.new_vaccinations,
Sum(cast (Cv.new_vaccinations as decimal))  over (partition by Cd.location order by Cd.location, Cd.date) as RollingCountVaccination
From CovidDeaths Cd
join CovidVaccinations Cv 
ON Cd.date= Cv.date and Cd.location=Cv.location 
where cd.continent is not null
--order by 2,3
)
select continent,location,population, RollingCountVaccination/population*100 as prctvaxPop
from Prctvax
order by 2,3

--check max vaccination per contry

With Prctvax( continent, location,date,population,new_vaccinations,RollingCountVaccination)
as(
select 

Cd.continent,Cd.location, Cd.date, Cd.population, Cv.new_vaccinations,
Sum(cast (Cv.new_vaccinations as decimal))  over (partition by Cd.location order by Cd.location, Cd.date) as RollingCountVaccination
From CovidDeaths Cd
join CovidVaccinations Cv 
ON Cd.date= Cv.date and Cd.location=Cv.location 
where cd.continent is not null
--order by 2,3
)
select continent,location,population, max(RollingCountVaccination)/population*100 as MaxprctvaxPop
from Prctvax
gROUP By continent, location, population
order by MaxprctvaxPop desc


-- Temp table technic
drop table prctpopvaccinated
Create table prctpopvaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric ,
RollingCountVaccination numeric)

insert into prctpopvaccinated
select 

Cd.continent,Cd.location, Cd.date, Cd.population, Cv.new_vaccinations,
Sum(cast (Cv.new_vaccinations as decimal))  over (partition by Cd.location order by Cd.location, Cd.date) as RollingCountVaccination
From CovidDeaths Cd
join CovidVaccinations Cv 
ON Cd.date= Cv.date and Cd.location=Cv.location 
where cd.continent is not null

select continent,location,population, RollingCountVaccination/population*100 as prctvaxPop
from prctpopvaccinated
order by 2,3






--- check fullvaccination rate /contry

select 
Cd.continent,Cd.location, Cd.population, max( cast(Cv.people_fully_vaccinated as decimal))as maxvax, 
max( cast(Cv.people_fully_vaccinated as decimal))/population as Maxvaxprct
From CovidDeaths Cd
join CovidVaccinations Cv 
ON Cd.date= Cv.date and Cd.location=Cv.location 
where cd.continent is not null
group by Cd.continent,Cd.location, Cd.population
order by location


--Creating views


--View current fullvaccinated count/ contry

create view fullyvaccinatedpeople as 
select 
Cd.continent,Cd.location, Cd.population, max( cast(Cv.people_fully_vaccinated as decimal))as maxvax, 
max( cast(Cv.people_fully_vaccinated as decimal))/population as Maxvaxprct
From CovidDeaths Cd
join CovidVaccinations Cv 
ON Cd.date= Cv.date and Cd.location=Cv.location 
where cd.continent is not null
group by Cd.continent,Cd.location, Cd.population
--order by location


--View  of rolling count of vaccinations

create view Rollingcountvax as
With Prctvax( continent, location,date,population,new_vaccinations,RollingCountVaccination)
as(
select 

Cd.continent,Cd.location, Cd.date, Cd.population, Cv.new_vaccinations,
Sum(cast (Cv.new_vaccinations as decimal))  over (partition by Cd.location order by Cd.location, Cd.date) as RollingCountVaccination
From CovidDeaths Cd
join CovidVaccinations Cv 
ON Cd.date= Cv.date and Cd.location=Cv.location 
where cd.continent is not null
--order by 2,3
)
select continent,location,population, RollingCountVaccination/population*100 as prctvaxPop
from Prctvax


-- view of world death ratio

create view Worlddeathratio as 
select 
Cd.date, Sum(cast(new_cases as decimal)) as worldNewcases, 
Sum(cast(new_deaths as decimal)) as worldnewdeaths, 
Sum(cast(Cd.new_deaths as numeric))/sum(cast(Cd.new_cases as decimal))*100 as DeathRatio

From CovidDeaths Cd
where continent is not null
group by Cd.date
--order by 1,2


--view about deathcount per continent

create view globaldeathcount as
select 
Cd.continent , Max(cast(Cd.total_deaths as decimal)) as Highestdeathcount
From CovidDeaths Cd
where Cd.continent is not null 
group by Cd.continent




--view about infection rate /contries

create view infectionrate as 
select 
Cd.location, Cd.population, Max(cast(Cd.total_cases as decimal)) as Highestinfectioncount, (Max(cast(Cd.total_cases as decimal))/Cd.Population)*100 as MaxContractionRate
From CovidDeaths Cd
--where Cd.location in ( 'morocco', 'France')
group by location, population

