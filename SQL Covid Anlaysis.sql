--Possibly use an updated dataset

--If I want to do more global data, just add a continent GROUP BY
SELECT * 
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4



--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4


--Selecting the data being used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Viewing total cases vs total deaths 
--Shows the probability of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%' 
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at total cases vs popultion
--Shows the percantage of population contracting covid 

SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' --AND  
WHERE continent IS NOT NULL
ORDER BY 1,2

--Viewing what countries had the highest infection rate compared to the population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY CasePercentage DESC

-- Viewing countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--Analyzing Continents 

--Continents with the highest death count 

SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--Global Numbers 

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Removing the date gives us the global totals

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent IS NOT NULL
ORDER BY CasePercentage DESC

--Viewing the Covid Vaccinations Data again 

SELECT * 
FROM CovidVaccinations$
ORDER BY 1,2

--Joining the two tables 

SELECT * 
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS RolligPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 

--USE CTE 

with PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS RolligPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 
FROM PopvsVac

--Temp Table

DROP TABLE IF EXISTS #PopulationPopulationVaccinated 
CREATE TABLE #PopulationPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PopulationPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS RolligPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 

SELECT *, (RollingPeopleVaccinated/Population) * 100 
FROM #PopulationPopulationVaccinated 

--Creating views for later visualizations 

--View 1

CREATE VIEW PopulationPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS RolligPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 

--View 2
--Shows the percantage of population contracting covid 

CREATE VIEW PercentOfCases AS 
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' --AND  
WHERE continent IS NOT NULL
--ORDER BY 1,2

--View 3
--Shows the probability of dying if you contract covid in your country 

CREATE VIEW RealPercentageOfDeaths AS 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent IS NOT NULL
--ORDER BY 1,2

--View 4
--Viewing what countries had the highest infection rate compared to the population

CREATE VIEW HighestInfectionRate AS
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent IS NOT NULL
GROUP BY population, location
--ORDER BY CasePercentage DESC

--View 5
-- Viewing countries with the highest death count per population

CREATE VIEW HighestDeatCount AS
SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY HighestDeathCount DESC

--View 6
--Continents with the highest death count 

CREATE VIEW ContinentDeathCount AS
SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent IS NULL
GROUP BY location

--View 7
--Global Deaths
CREATE VIEW GlobalDeaths AS
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent IS NOT NULL
--ORDER BY 1,2

--View 8 
--Global Cases 
CREATE VIEW GlobalCases AS
SELECT MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%' 
WHERE continent IS NOT NULL
--ORDER BY CasePercentage DESC

--View 9
--Global Population Vaccinations
CREATE VIEW GlobalVaccinations AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS RolligPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
--ORDER BY 2,3 