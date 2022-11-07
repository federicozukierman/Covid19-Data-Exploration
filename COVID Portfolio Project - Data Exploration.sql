SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE location IS NOT NULL
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Spain%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of population got Covid 
SELECT location, date, population, total_cases, (total_cases / population) *100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%Spain%' AND continent IS NOT NULL 
order by 1,2

--Looking at countries with Higher Infection rates compared to Population
SELECT location, population, MAX (total_cases) AS HighestInfectionCount, MAX ((total_cases / population)) *100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
Group by Location, Population 
order by PercentPopulationInfected DESC 

-- Showing Countries with Highest Death Count Per Population 
SELECT location, MAX (cast (total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
Group by Location
order by TotalDeathCount DESC 

-- Showing continents with highest death count per population
SELECT continent, MAX (cast (total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
Group by continent
order by TotalDeathCount DESC 

-- GLOBAL NUMBERS 
SELECT date, SUM (new_cases) as total_cases, SUM (cast(new_deaths as int)) as total_deaths, SUM (cast(new_deaths as int)) / SUM (new_cases) *100 AS DeathPercentage -- total_deaths, (total_deaths / total_cases)*100 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date
order by 1,2

SELECT SUM (new_cases) as total_cases, SUM (cast(new_deaths as int)) as total_deaths, SUM (cast(new_deaths as int)) / SUM (new_cases) *100 AS DeathPercentage -- total_deaths, (total_deaths / total_cases)*100 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
-- GROUP BY date
order by 1,2

-- Looking at Total Population vs New Vaccinations per day  
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and	dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopvsVac


-- TEMP TABLE 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and	dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *,(RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated

-- Creating view to store date for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and	dea.date = vac.date 
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated


