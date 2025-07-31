 SELECT *
 FROM coviddeaths..CovidDeaths_table
 WHERE continent is not null
 ORDER BY 3,4
 
-- shows likelihood of dying if you get infected in your country (DeathPercentage)
SELECT location, date, total_cases ,total_deaths, (total_deaths/total_cases)*100 AS Death_percentage
FROM coviddeaths..CovidDeaths_table
WHERE location LIKE '%states%' and continent is not null
ORDER BY 1,2

-- total cases vs population (infection rate)
SELECT location, date, total_cases , population , (total_cases/population)*100 AS Infection_Rate
FROM coviddeaths..CovidDeaths_table
WHERE location LIKE '%states%' and continent is not null
ORDER BY 1,2

-- countries with highest infection rate 
SELECT location ,population , MAX(total_cases) as Highestinaday , MAX((total_cases/population)*100) AS highestinfectionpercentage
FROM coviddeaths..CovidDeaths_table
WHERE continent is not null
GROUP by location , population 
ORDER BY highestinfectionpercentage desc

-- countries with highest death count per population 
SELECT location ,population , MAX(CAST(total_deaths AS int)) AS deathinaday , MAX((total_deaths/population)*100) AS deathperpop
FROM coviddeaths..CovidDeaths_table
WHERE continent is not null
GROUP BY location , population 
ORDER BY deathinaday DESC

-- Continent wise data
SELECT continent , MAX(CAST(total_deaths AS int)) AS Deathcount
FROM coviddeaths..CovidDeaths_table
WHERE continent is not null
GROUP BY continent
ORDER BY Deathcount DESC 

-- Global numbers 
SELECT SUM(new_cases) as total_cases , SUM(CAST(new_deaths as int)) as total_deaths , (SUM(CAST(new_deaths as int))/SUM(new_cases)*100) as Deathpercent
FROM coviddeaths..CovidDeaths_table
WHERE continent is not null

-- vaccination exploration
-- total population vs vaccinated ppl

SELECT dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations , SUM(CAST(new_vaccinations as int)) OVER(PARTITION by dea.location order by dea.date) AS rollingvaccinations
FROM coviddeaths..CovidDeaths_table dea
JOIN coviddeaths..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- using a CTE 
WITH popvsvac AS
(
SELECT dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations , SUM(CAST(new_vaccinations as int)) OVER (PARTITION by dea.location order by dea.date) AS rollingvaccinations
FROM coviddeaths..CovidDeaths_table dea
JOIN coviddeaths..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT * , (rollingvaccinations/population)*100 
FROM popvsvac

--views for later visualization
CREATE VIEW percentpopulationvaccinated AS
SELECT dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations , SUM(CAST(new_vaccinations as int)) OVER (PARTITION by dea.location order by dea.date) AS rollingvaccinations
FROM coviddeaths..CovidDeaths_table dea
JOIN coviddeaths..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
