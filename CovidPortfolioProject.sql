--Inspecting my data

SELECT *
FROM dbo.CovidDeaths
ORDER BY 1,2

--SELECT *
--FROM dbo.CovidVaccinations
--ORDER BY 1,2

SELECT*
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

---select he data that we are going to be using

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--This shows the likelihood of dying if you contract covid in Kenya

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
--WHERE location Like 'Kenya'
ORDER BY 1,2


--Looking at Total Cases vs Popuation
--Shows what percentage has gotten covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS TotalCasesPercentage
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
--WHERE location Like 'Kenya'
ORDER BY 1,2

--Looking at Countries with the Highest percentage compared to Population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentageInfected
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location,population,continent
ORDER BY PercentageInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, continent
ORDER BY TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing Continents with the Highest Death Count

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
--Shows the likelihood of dying if one contacts covid
--Query for a Tableau visualiation
  

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2


--As a double check
  
 --Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--where location = 'World'
----Group By date
--order by 1,2
 
--Looking at Total Population vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location,dea.date) AS CumulativeVaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

With PopvsVac (continent,location,date,population,new_vaccinations,CumulativeVaccinations) as(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location,dea.date) AS CumulativeVaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
)

SELECT*, (CumulativeVaccinations/population)*100 AS PopulationVaccinated
FROM PopvsVac


--TEMP TABLES
CREATE TABLE #PercentPopulationVaccinated(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
CumulativeVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location,dea.date) AS CumulativeVaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL

--ORDER BY 2,3

SELECT*, (CumulativeVaccinations/population)*100 
FROM #PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location,dea.date) AS CumulativeVaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL

--ORDER BY 2,3


  

--Queries for my Tableau visualisation project

--1.

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2

--2.
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc


-- 5.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3




-- 6.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 7.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 8.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 9.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 10. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 11. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc










