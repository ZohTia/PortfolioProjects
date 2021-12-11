
--Covid 19 Data Exploration Project
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

SELECT *
FROM COVIDDEATHS$
ORDER BY 3,4


-- Select Data that we are going to be using in COVIDDEATHS$

SELECT LOCATION, DATE, NEW_CASES, TOTAL_DEATHS, POPULATION
FROM COVIDDEATHS$
ORDER BY 1,2

-- Death percentage in the Cote d'Ivoire

SELECT Location, Date, Population, Total_Cases, ROUND ((Total_Deaths/Total_Cases) * 100, 2) as DeathPercentage
FROM COVIDDEATHS$
WHERE Location like '%Cote%'


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(Total_Cases) as HighestInfectionCount, MAX(Total_Cases/Population) * 100 as PercentPopulationInfected
FROM COVIDDEATHS$
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_Deaths as bigint)) as DeathCount
FROM COVIDDEATHS$
WHERE Continent is not null
GROUP BY Location
ORDER BY DeathCount desc

-- Global Number

SELECT SUM(cast(new_cases as bigint)) as TotalCases , SUM(cast(new_deaths as bigint)) as TotalDeaths, ROUND (SUM(cast(new_deaths as bigint))/SUM(New_Cases)*100,2) as DeathPercentage
FROM COVIDDEATHS$
WHERE Continent is not null

-- Join COVIDDEATHS$ to COVIDVACCINATION$

SELECT *		
FROM COVIDDEATHS$ JOIN COVIDVACCINATION$ 
	ON COVIDDEATHS$.Location = COVIDVACCINATION$.Location
	AND COVIDDEATHS$.Date = COVIDVACCINATION$.Date

-- Total population vs Vaccinations

SELECT COVIDDEATHS$.continent, COVIDDEATHS$.location, COVIDDEATHS$.date, COVIDDEATHS$.population, COVIDVACCINATION$.new_vaccinations,
		SUM(CONVERT(bigint,COVIDVACCINATION$.new_vaccinations)) OVER (Partition by COVIDDEATHS$.Location Order by COVIDDEATHS$.location, COVIDDEATHS$.Date) as PeopleVaccinated
FROM COVIDDEATHS$ JOIN COVIDVACCINATION$ 
	ON COVIDDEATHS$.Location = COVIDVACCINATION$.Location
	AND COVIDDEATHS$.Date = COVIDVACCINATION$.Date
WHERE COVIDDEATHS$.continent is not null
ORDER BY 3,4

 -- Using CTE to perform Calculation on Partition By in previous query

 
With pop_vac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT COVIDDEATHS$.continent, COVIDDEATHS$.location, COVIDDEATHS$.date, COVIDDEATHS$.population, COVIDVACCINATION$.new_vaccinations,
		SUM(CONVERT(bigint,COVIDVACCINATION$.new_vaccinations)) OVER (Partition by COVIDDEATHS$.Location Order by COVIDDEATHS$.location, COVIDDEATHS$.Date) as PeopleVaccinated
FROM COVIDDEATHS$ JOIN COVIDVACCINATION$ 
	ON COVIDDEATHS$.Location = COVIDVACCINATION$.Location
	AND COVIDDEATHS$.Date = COVIDVACCINATION$.Date
WHERE COVIDDEATHS$.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From pop_vac

-- Creating View to store data for data visualisation

Create View pop_vac as
SELECT COVIDDEATHS$.continent, COVIDDEATHS$.location, COVIDDEATHS$.date, COVIDDEATHS$.population, COVIDVACCINATION$.new_vaccinations,
		SUM(CONVERT(bigint,COVIDVACCINATION$.new_vaccinations)) OVER (Partition by COVIDDEATHS$.Location Order by COVIDDEATHS$.location, COVIDDEATHS$.Date) as PeopleVaccinated
FROM COVIDDEATHS$ JOIN COVIDVACCINATION$ 
	ON COVIDDEATHS$.Location = COVIDVACCINATION$.Location
	AND COVIDDEATHS$.Date = COVIDVACCINATION$.Date
WHERE COVIDDEATHS$.continent is not null


-- Create View for countries with Highest Death Count per Population for later visualization

CREATE VIEW DeathCount AS
SELECT Location, MAX(cast(Total_Deaths as bigint)) as DeathCount
FROM COVIDDEATHS$
WHERE Continent is not null
GROUP BY Location

--Testing View

--SELECT * 
--FROM DeathCount
--WHERE Location IN ('France', 'Brazil', 'South Africa')


