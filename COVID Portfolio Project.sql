-- A study of Data of How covid 19 affecte countries between the year 2020 and 2022
SELECT *
From PortfolioProject..CovidDeaths

order by 3,4

--SELECT *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at the total cases vs Total Deaths
-- Shows likelihood of dying if you were to get covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%south Africa%'
and continent is not null
order by 1,2

-- Looking at te total cases vs The Population (what percentage of the population has gotten covid)

SELECT Location, date, total_cases, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%south Africa%'
order by 1,2


-- Which Countries have the highest infection rate compared to population 

SELECT Location,  Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
 PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%south Africa%'
Group by Location, Population
order by  PercentPopulationInfected desc 

-- Showing the countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as INT)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%south Africa%'
where continent is not null
Group by Location
order by  TotalDeathCount desc 

--LETS BREAK THINGS DOWN BY CONTINENT

--Showing the continent with the highest death count

SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%south Africa%'
where continent is not null
Group by continent
order by  TotalDeathCount desc 


-- GLOBAL NUMBERS

SELECT   SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM
(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%south Africa%'
where continent is not null
--Group By date
order by 1,2

-- looking at total population vs Vaccination 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by  2, 3

-- Using a CTE to find total amount of peole vaccinated in a country, baring in mind the 
--new vaccinations and RollinPeopleVaccinated

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeoppleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by  2, 3
)
Select * , (RollingPeoppleVaccinated/Population)*100 as PercentageOfPeopleVaccinated
From PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Locaton nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by  2, 3

Select * , (RollingPeopleVaccinated/Population)*100 as PercentageOfPeopleVaccinated
From #PercentPopulationVaccinated


-- Creating view to store data for later visualization

Create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by  2, 3


Select *
From PercentPopulationVaccinated