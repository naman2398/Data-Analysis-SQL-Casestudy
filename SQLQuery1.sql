select *
From CovidDeaths
Order by 3,5;

--Select data that is being used

select location,date, total_cases, new_cases, total_deaths, population
from Covid_Death_Analysis..CovidDeaths
order by 1,2;

--Looking at Total Cases vs Total Deaths(Percentage of people dying out of those infected)

select location,date, total_cases, total_deaths, (round((coalesce(total_deaths,0)/total_cases)*100,2)) as DeathPercentage
from Covid_Death_Analysis..CovidDeaths
order by 1,2;

--Looking at total cases vs population
select location,date, total_cases, population, (round((coalesce(total_cases,0)/population)*100,4)) as InfectedPercentage
from Covid_Death_Analysis..CovidDeaths
--where location like '%India%'
order by 1,2

--Countries with the highest infection rate compared to population
select location, (round((max(coalesce(total_cases,0))/max(population))*100,4)) as InfectionRate
from Covid_Death_Analysis..CovidDeaths
group by location
order by 2 desc

--Countries with the highest death rate compared to population
select location, population, max(cast(total_deaths as int)) as total_deaths, max((round((coalesce(cast(total_deaths as int),0)/population)*100,4))) as DeathPercentage
from Covid_Death_Analysis..CovidDeaths
where continent is not null
group by location,population
order by 4 desc

--Continents with the highest death rate compared to population
select location, population, max(cast(total_deaths as int)) as total_deaths, max((round((coalesce(cast(total_deaths as int),0)/population)*100,4))) as DeathPercentage
from Covid_Death_Analysis..CovidDeaths
where continent is null
group by location,population
order by 4 desc

--Total population vs new vaccinations per day
select death.continent,death.location, death.date,death.population,vacc.new_vaccinations
from Covid_Death_Analysis..CovidDeaths death join Covid_Death_Analysis..CovidVaccinations vacc
on death.location = vacc.location and death.date = vacc.date
where death.continent is not null
order by 2,3

-- Percentage of people vaccinated per population for every country
with total_vacc as (
	select death.continent,death.location, death.date,death.population,coalesce(vacc.new_vaccinations,0) as new_vaccinations,
	coalesce(sum(cast(vacc.new_vaccinations as int)) over (partition by death.location order by death.location,death.date),0) as total_vaccinated
	from Covid_Death_Analysis..CovidDeaths death join Covid_Death_Analysis..CovidVaccinations vacc
	on death.location = vacc.location and death.date = vacc.date
	where death.continent is not null 
	
	)
select tv.continent,tv.location, (max(tv.total_vaccinated)/tv.population)*100 as VaccinatedPercentage
from total_vacc as tv
group by tv.continent,tv.location,tv.population
order by 3 desc

--View to be used later

create view Total_Vaccinated as
	select death.continent,death.location, death.date,death.population,coalesce(vacc.new_vaccinations,0) as new_vaccinations,
	coalesce(sum(cast(vacc.new_vaccinations as int)) over (partition by death.location order by death.location,death.date),0) as total_vaccinated
	from Covid_Death_Analysis..CovidDeaths death join Covid_Death_Analysis..CovidVaccinations vacc
	on death.location = vacc.location and death.date = vacc.date
	where death.continent is not null
