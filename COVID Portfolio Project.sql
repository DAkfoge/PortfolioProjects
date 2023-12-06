SELECT *
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

--Looking at the total cases vs population
--Percentage of population contracted covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentageOfPopulation
FROM CovidDeaths
--WHERE Location like '%states%'
ORDER BY 1,2

-- Looking at highest infection rate vs population 

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentageOfPopulationInfection
FROM CovidDeaths
--WHERE Location like '%states%'
GROUP BY Location, population
ORDER BY PercentageOfPopulationInfection DESC

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(Total_deaths) AS TotalDeathCount
FROM CovidDeaths
--WHERE Location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT Location, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Above queries have been copied into document for tracking

--Break things down by continent
--Showing continents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global numbers

SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Total Population vs Vaccinations

SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS Running_Vac_total
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

WITH Pop_vs_Vac (continent, location, date, population, new_vaccinations, Running_Vac_total)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS Running_Vac_total
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (Running_Vac_total/population)*100 AS Pop_Vac_Percent
FROM Pop_vs_Vac



--TEMP TABLE

CREATE TABLE #Percent_Pop_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Running_Vac_total numeric
)

INSERT INTO #Percent_Pop_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS Running_Vac_total
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (Running_Vac_total/population)*100
FROM #Percent_Pop_Vaccinated


DROP TABLE if exists #Percent_Pop_Vaccinated
CREATE TABLE #Percent_Pop_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Running_Vac_total numeric
)

INSERT INTO #Percent_Pop_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS Running_Vac_total
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (Running_Vac_total/population)*100
FROM #Percent_Pop_Vaccinated


-- Creating View to store data for later visualizations

CREATE VIEW Percent_Pop_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS Running_Vac_total
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

