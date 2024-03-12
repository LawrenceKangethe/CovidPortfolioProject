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

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2

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


