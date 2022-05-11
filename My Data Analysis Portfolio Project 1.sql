select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--select data we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--looking at total cases vs total deaths

select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentageNIG
from PortfolioProject..CovidDeaths$
where location like '%Nigeria%'
order by 1,2


--looking at total cases vs population
--shows waht percentage of population have got covid

select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfectedNIG
from PortfolioProject..CovidDeaths$
where location like '%Nigeria%'
order by 1,2


--looking at countries with highest infection rate compared to population

select location,MAX(total_cases) as HighestInfectionCount,population,max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%
where continent is not null
group by location,population
order by PercentPopulationInfected desc


--showing the countries with the highest death count per population

select location,MAX(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%
where continent is not null
group by location
order by TotalDeathCounts desc


--grouping by continent


--continents with the highest death count per population

select continent,MAX(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%
where continent is not null
group by continent
order by TotalDeathCounts desc


--GLOBAL NUMBERS

select date, SUM(new_cases)as total_cases,SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--OVERALL DEATH PERCENTAGE
select  SUM(new_cases)as total_cases,SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2


--total population vs vaccinations


select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
rollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated





--Creating view to store data for later viaualization

USE [PortfolioProject]

GO

Create View PercentPopulationVaccinated  
AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  

