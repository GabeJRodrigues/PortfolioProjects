--SELECT *
--FROM CovidDeaths

--SELECT *
--FROM CovidVaccinations

--SELECTING DATA THAT WE ARE GOING TO USE
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Brazil'
ORDER BY 1,2

--TOTAL CASES VS POPULATION
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopInfected
FROM CovidDeaths
WHERE location = 'Brazil'
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentPopInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

--COUNTRIES WITH HIGHEST DEATH COUNT
SELECT location, MAX(CAST(total_deaths AS int)) AS DeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--CONTINENTS WITH HIGHEST DEATH COUNT

SELECT continent, MAX(CAST(total_deaths AS int)) AS DeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

SELECT location, MAX(CAST(total_deaths AS int)) AS DeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercent
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 

-- TOTAL POP VS VACCINATION
-- WITH CTE
WITH PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, RollingPeopleVaccinated/population * 100
FROM PopvsVac

--WITH TEMP TABLE

DROP TABLE IF EXISTS #PercentPopVac
CREATE TABLE #PercentPopVac (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccinations int,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopVac 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, RollingPeopleVaccinated/population * 100
FROM #PercentPopVac

--CREATING VIEW

CREATE VIEW PercentPopVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopVac