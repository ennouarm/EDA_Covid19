SELECT *
  FROM [PortfolioProject].[dbo].[CovidDeaths$]
order by 3,4
--SELECT *
--  FROM [PortfolioProject].[dbo].[CovidVaccinations$]
--order by 3,4
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
order by 1,2

-- death pourcentage

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as The_Death_Pourcentage
FROM PortfolioProject..CovidDeaths$
order by 1,2

--Location	date	total_cases	total_deaths	The_Death_Pourcentage
-- Afghanistan	2021-04-30 00:00:00.000	59745	2625	4.39367311072056  there is a 4.3% that you will die if you get covid infection.

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as The_Death_Pourcentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%states%'
order by 5 desc

--Location	date	total_cases	total_deaths	The_Death_Pourcentage
-- United States	2020-03-02 00:00:00.000	55	6	10.9090909090909, if you get infected on this day, there is a 10.9% that you will die.

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as The_Death_Pourcentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%states%'
order by 3 asc
-- Location	             date	            total_cases	total_deaths	The_Death_Pourcentage
-- United States	2021-04-30 00:00:00.000	32346971	576232	1.78140945561796  The likelihood that you will die is 1.78% if you get infected on this date

-- Total cases vs population

SELECT Location, date, total_cases, total_deaths, population, (total_cases/population)*100 as Total_Cases_Per_population
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%morocco%'
order by 1,2 asc
--Location	date	total_cases	total_deaths	population	Total_Cases_Per_population
--Morocco	2021-04-30 00:00:00.000	511249	9023	36910558	1.38510233305061 on April 30th, 1.38% of the population tested positive to covid19

SELECT Location, date, total_cases, total_deaths, population, (total_cases/population)*100 as Total_Cases_Per_population
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%states%'
order by 1,2 asc

-- Location	date	total_cases	total_deaths	population	Total_Cases_Per_population
-- United States	2021-04-30 00:00:00.000	32346971	576232	331002647	9.77242064169958, on April 30th, 9.77% of the US population tested positive for covid19

-- country with the highest rate of infection compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
Group by Location, population
order by PercentPopulationInfected desc

-- showing the countries with the highest death counts

SELECT Location, population, MAX(cast(total_deaths as bigint)) as HighestDeathsCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
group by location, population
order by HighestDeathsCount desc

-- let's break things down by continent
SELECT continent, MAX(cast(total_deaths as bigint)) as HighestDeathsCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
group by continent
order by HighestDeathsCount desc

--
SELECT location, aged_65_older
FROM PortfolioProject..CovidDeaths$
WHERE location like '%togo%'
order by 2 desc


SELECT Location, date, total_cases, total_deaths, population, (total_cases/population)*100 as Total_Cases_Per_population
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%cote%'
order by 1,2 asc


SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
group by location
order by TotalDeathCount desc

--  showing the continents with the highest death count

SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
group by continent
order by TotalDeathCount desc

-- global numbers across the world
-- pourcentage of deaths per new cases
Select date, SUM(new_cases) as totalNewCases, SUM(CAST(new_deaths as int)) as totalNewDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as deathsperc
from [PortfolioProject].[dbo].[CovidDeaths$]
where continent is not null
Group by date
order by 1,2 asc

-- Total Deaths and pourcentage of new deaths divided by new cases across the world
Select  SUM(new_cases) as totalNewCases, SUM(CAST(new_deaths as int)) as totalNewDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as deathsperc
from [PortfolioProject].[dbo].[CovidDeaths$]
where continent is not null
order by 1,2 asc

-- let's work on the vaccination table
Select*
From PortfolioProject..CovidVaccinations$

--- let's join the two tables
Select*
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date

--looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3

--- CTE

with PopvsVac (continent, location, Date, Population, New_Vaccinations,TotalPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)

Select * , (TotalPeopleVaccinated/Population) * 100
from PopvsVac

-- TEMP Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalPeopleVaccinated numeric,
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select * , (TotalPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated1 as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated1