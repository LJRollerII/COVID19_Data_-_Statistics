/*Testing to make sure both tables are running successfully
SELECT *
FROM covid_vaccinations

SELECT *
FROM covid_deaths*/

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1, 2
-- Use 1, 2 to order by columns

--=======================================================================================================----

--Looking at Total cases vs Total deaths-- 
--This shows the likelihood of dying if a person were to contract COVID-19 in a specific country--
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage 
FROM covid_deaths
ORDER BY 1, 2

--Let's check this specifically for the United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage 
FROM covid_deaths
WHERE location = 'United States'
ORDER BY 1, 2

--By the end of 2020 over 20 million American were diagnosed with COVID-19 (20,099,363 to be sepecific).
-- 352,093 Americans died of COVID-19 by the end of 2020.
--By the end period of data collection (4/30/2021), 32,346,971 Americans had COVID.
--- 576,232 Americans died of COVID-19 by 4/30/2021.
---As of 4/30/2021 There was a 1.78% chance that a person could die from contracting COVID-19 in the US.

--Let's compare the US results to Canada, where healthcare is free and more restrictions were put in place.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage 
FROM covid_deaths
WHERE location = 'Canada'
ORDER BY 1, 2
--By the end of 2020 Canda had 584,409 total cases and 15,806 deaths.
--By 4/30/2021 Canada had 1,228,367 total cases and 24,220 deaths
--By 4/30/2021 There was a 1.97% chance that a person could die from contracting COVID-19 in the Canada.
-- The death rate in Cananda is most likely higher than the US due to Canada's smaller sample size.

--=======================================================================================================-------

--Let's compare Total Cases vs Population--
--This will show us what percentage of the population has contracted COVID-19--
--Let's check this specifically for the United States
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS covidpop_percentage 
FROM covid_deaths
WHERE location = 'United States'
ORDER BY 1, 2
--August od 2020 is when 1% of the population had COVID-19.
--By 4/30/2021 about 10% of the population was diagnosed with COVID-19 (9.77%)

--Running a query for Canada to confirm if they have a samller sample size--
SELECT location, population, date, total_cases, (total_cases/population) * 100 AS covidpop_percentage 
FROM covid_deaths
WHERE location = 'Canada'
ORDER BY 1, 2
--This confirms what I expected before about Canada's smaller sample size.

--========================================================================================================-----

--Investigating Population to countries with the highest Infection Rate--
SELECT location, 
		population, 
		MAX(total_cases) AS Highest_InfectionCount, 
		MAX((total_cases/population)) * 100 AS covidpop_percentage 
FROM covid_deaths
GROUP BY location, population
ORDER BY covidpop_percentage DESC

--Andorra has the highest infection rate at 17.13%
--US is ranked 9th

--Let's break this down by continent

SELECT location, MAX((total_cases/population)) * 100 AS covidpop_percentage 
FROM covid_deaths
WHERE continent IS NULL
GROUP BY location, population
ORDER BY covidpop_percentage DESC
--North America had the highest COVID population percentage
--Oceania (Australia) had the lowest COVID population percentage.

SELECT location, MAX(total_cases) AS Highest_InfectionCount
FROM covid_deaths
WHERE continent IS NULL
GROUP BY location, population
ORDER BY Highest_InfectionCount DESC
--Europe had the highest COVID infection count.
--Oceania (Australia) had the lowest infection count.

SELECT location, 
		population,
		date,
		MAX(total_cases) AS Highest_InfectionCount, 
		MAX((total_cases/population)) * 100 AS covidpop_percentage 
FROM covid_deaths
GROUP BY location, population, date
ORDER BY covidpop_percentage DESC


--======================================================================================================--

--Now let's look at countires with the Highest Death Count per Population--
SELECT location, MAX(total_deaths) AS total_deathcount		
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deathcount DESC
--The US has the highest death count per population

--Let's break this down by continent
/*Important: Do not use this query. Death count numbers are misleading. Use query after this:
SELECT continent, MAX(total_deaths) AS total_deathcount		
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deathcount DESC*/
--North America was the continent with the highest number of deaths.
--Oceania (Australia) was the continent with the lowest number of deaths.
--The death count looks a very low in this query let's try another query.

--*****Use this query to break down death count by continent*****--
SELECT location, MAX(total_deaths) AS total_deathcount		
FROM covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_deathcount DESC
--These the death count for each continent in this query are more accurate. We will use this query instead.
--Europe was the continent with the highest number of deaths.
--Oceania (Australia) was the continent with the lowest number of deaths.

--======================================================================================================--

--Global Numbers--

SELECT date,
	   SUM(new_cases) AS total_cases, 
	   SUM(new_deaths) AS total_deaths, 
	   SUM(new_deaths)/SUM(new_cases) * 100 AS death_percentage 
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2
--Now we have our total number of global cases and deaths by date.

--Let's look total global numbers
SELECT SUM(new_cases) AS total_cases, 
	   SUM(new_deaths) AS total_deaths, 
	   SUM(new_deaths)/SUM(new_cases) * 100 AS death_percentage 
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2
--Globally there were 150,574,977 cases, 3,180,206 deaths, and 2.11 death percentage

--======================================================================================================--

--Let's join the COVID deaths and vaccinations tables together

SELECT *
FROM covid_deaths AS cd
JOIN covid_vaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date

--======================================================================================================--


--We are going to compare Total Population vs Vaccination
SELECT cd.continent,
	   cd.location,
	   cd.date,
	   cd.population,
	   cv.new_vaccinations
FROM covid_deaths AS cd
JOIN covid_vaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3
--This query will give you the number of vaccinations administered per country by day.

--We'll use partition to break the data up by country (location)
-- This means the sum will start over after each country
--Using date the over/partition statement will help us get a rolling count.
SELECT cd.continent,
	   cd.location,
	   cd.date,
	   cd.population,
	   cv.new_vaccinations,
	   SUM(cv.new_vaccinations) OVER (PARTITION BY cd.Location Order BY cd.location, cd.date) AS rolling_peoplevax
FROM covid_deaths AS cd
JOIN covid_vaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3

--To see how many people in each country were vaccinated there are multiple methods we can use to find this out.

-- USE A CTE (Method #1)
--Remember the number of columns in the CTE has to be the same as the select statement.

WITH PopvsVax(continent, location, date, population, new_vaccinations, rolling_peoplevax)
AS
(
SELECT cd.continent,
	   cd.location,
	   cd.date,
	   cd.population,
	   cv.new_vaccinations,
	   SUM(cv.new_vaccinations) OVER (PARTITION BY cd.Location Order BY cd.location, cd.date) AS rolling_peoplevax
FROM covid_deaths AS cd
JOIN covid_vaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date	
WHERE cd.continent IS NOT NULL
)
SELECT *, (rolling_peoplevax/population) * 100 AS percent_vaccinated
FROM PopvsVax

--Temp Table (Method #2)

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_peoplevax numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent,
	   cd.location,
	   cd.date,
	   cd.population,
	   cv.new_vaccinations,
	   SUM(cv.new_vaccinations) OVER (PARTITION BY cd.Location Order BY cd.location, cd.date) AS rolling_peoplevax
FROM covid_deaths AS cd
JOIN covid_vaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date

SELECT *, (rolling_peoplevax/population) * 100 AS percent_vaccinated
FROM #PercentPopulationVaccinated
--======================================================================================================--

-- Let's Create Views to store data for later visualizations--

CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent,
	   cd.location,
	   cd.date,
	   cd.population,
	   cv.new_vaccinations,
	   SUM(cv.new_vaccinations) OVER (PARTITION BY cd.Location Order BY cd.location, cd.date) AS rolling_peoplevax
FROM covid_deaths AS cd
JOIN covid_vaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

CREATE VIEW GlobalCasesANDDeaths AS
SELECT date,
	   SUM(new_cases) AS total_cases, 
	   SUM(new_deaths) AS total_deaths, 
	   SUM(new_deaths)/SUM(new_cases) * 100 AS death_percentage 
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

CREATE VIEW TotalDeathsByContinent AS
SELECT location, MAX(total_deaths) AS total_deathcount		
FROM covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_deathcount DESC

CREATE VIEW GlobalCasesAndDeathsByDate AS
SELECT date,
	   SUM(new_cases) AS total_cases, 
	   SUM(new_deaths) AS total_deaths, 
	   SUM(new_deaths)/SUM(new_cases) * 100 AS death_percentage 
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2
