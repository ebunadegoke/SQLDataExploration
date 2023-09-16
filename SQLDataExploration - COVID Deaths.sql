--Data Exploration in SQL

select *
from sql..CovidDeaths$
order by 3,4

--select *
--from sql..CovidVaccinations$
--order by 3,4

--Select the data we'll be using
select location, date, total_cases, new_cases, total_deaths, population
from sql..CovidDeaths$
order by 1,2

--Total cases VS Total deaths
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) AS death_percentage
from sql..CovidDeaths$
where location = 'Nigeria'
order by 1,2

--Total cases vs population
select location, date, total_cases, population, round((total_cases/population)*100,2) AS case_percentage
from sql..CovidDeaths$
--where location = 'Nigeria'
order by 1,2

--Country with highest infection rate compared to population
select location, population, MAX(total_cases) totalinfections, MAX(round((total_cases/population)*100,2)) AS case_percentage
from sql..CovidDeaths$
group by location, population
order by 4 desc

--Countries with highest death count per population
select location, MAX(cast(total_deaths as int)) totaldeaths
from sql..CovidDeaths$
where continent is not NULL
group by location
order by 2 desc

--By Continent
select continent, MAX(cast(total_deaths as int)) totaldeaths
from sql..CovidDeaths$
where continent is not NULL
group by continent
order by 2 desc

--***
select continent, location, population, MAX(total_cases) totalinfections, MAX(round((total_cases/population)*100,2)) AS case_percentage
from sql..CovidDeaths$
where continent is not null
group by location, population, continent
order by 1,5 desc

--Global numbers
select SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 death_percentage
from sql..CovidDeaths$ 
where continent is not null
--where location = 'Nigeria'
--group  by date
order by 1,2

--Total population VS Total vaccination
SELECT *, (rolling_people_vac/population)*100
FROM (
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
			SUM(cast(v.new_vaccinations as int)) OVER (partition by d.location order by d.location, d.date) rolling_people_vac
	FROM sql..CovidDeaths$ d
	JOIN sql..CovidVaccinations$ v
	ON d.location = v.location
	AND d.date = v.date
	where d.continent is not null) tab
order by 2,3

WITH tab as (
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
			SUM(cast(v.new_vaccinations as int)) OVER (partition by d.location order by d.location, d.date) rolling_people_vac
	FROM sql..CovidDeaths$ d
	JOIN sql..CovidVaccinations$ v
	ON d.location = v.location
	AND d.date = v.date
	where d.continent is not null) 

SELECT *, (rolling_people_vac/population)*100
FROM tab
order by 2,3


--temp table
drop table if exists #percentofpeoplevaccinated
create table #percentofpeoplevaccinated
(continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vac numeric)

insert into #percentofpeoplevaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
			SUM(cast(v.new_vaccinations as int)) OVER (partition by d.location order by d.location, d.date) rolling_people_vac
	FROM sql..CovidDeaths$ d
	JOIN sql..CovidVaccinations$ v
	ON d.location = v.location
	AND d.date = v.date
	--where d.continent is not null

SELECT *, (rolling_people_vac/population)*100
FROM #percentofpeoplevaccinated



--creating a view to store data for later visualization
create view peoplevaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
			SUM(cast(v.new_vaccinations as int)) OVER (partition by d.location order by d.location, d.date) rolling_people_vac
	FROM sql..CovidDeaths$ d
	JOIN sql..CovidVaccinations$ v
	ON d.location = v.location
	AND d.date = v.date
	where d.continent is not null

select *
from peoplevaccinated