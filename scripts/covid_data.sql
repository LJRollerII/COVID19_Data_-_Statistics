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