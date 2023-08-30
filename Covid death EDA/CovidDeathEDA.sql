SELECT *
FROM PRACTICE..DEATH
ORDER BY 3,4;

SELECT *
FROM PRACTICE..VACCINE
ORDER BY 3,4;
--I HAVE ORDERED THEM BY LOCATION AND DATE
                  --OVER TO MAIN DATA IMMA GONNA BE USING

SELECT
	location,
	Date,
	Total_cases,
	New_cases,
	Total_deaths,
	Population
 FROM PRACTICE..DEATH
 WHERE continent IS NOT NULL
 ORDER BY 1,2;

 --FIND THE DEATH PERCENTAGE[(TOTAL DEATH/TOTAL CASE)*100] IN NIGERIA AS OF .2021
SELECT
	location,
	Date,
	Total_cases,
	Total_deaths,
	Population,
	(total_deaths/total_cases)*100 AS Death_percentage
 FROM PRACTICE..DEATH
 WHERE continent IS NOT NULL 
 --WHERE location = 'Nigeria'
 ORDER BY 1,2;

  --LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY(NIGERIA), 
  --WHAT PERCENTAGE OF POPULATION GOT COVID [(TOTAL CASE/POPULATION)*100]
SELECT 
	location,
	Date,
	Total_cases,
	Population,
	(total_cases/population)*100 AS CASES_percentage
 FROM PRACTICE..DEATH
 WHERE continent IS NOT NULL
-- WHERE location = 'Nigeria'
 ORDER BY 1,2;

 --COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPUPALTION, USE OFFSET AND FETCH TO LIMIT
 --FIRST FIVE
SELECT 
	location,
	MAX(Total_cases) AS MAX_INFECTED,
	Population,
	MAX((total_cases/population)*100) AS MAX_POPULATION_INFECTED_PERCENT
 FROM PRACTICE..DEATH
-- WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
 GROUP BY location,population
 ORDER BY 4 DESC
 OFFSET 0 ROWS
 FETCH FIRST 5 ROWS ONLY;

 --COUNTRIES WITH HIGHEST DEATH RECORD, USE OFFSET AND FETCH TO LIMIT
SELECT
	location,
	MAX(CAST(Total_deaths AS INT)) AS MaxDeath,
	Population
 FROM PRACTICE..DEATH
 WHERE continent IS NOT NULL
 GROUP BY location,population
 ORDER BY 2 DESC;

 --COUNTRIES WITH HIGHEST DEATH RATE COMPARED TO POPULATION, might not be visualized
SELECT
	location,
	MAX(CAST(Total_deaths AS INT)) AS MaxDeath,
	Population,
	MAX((total_deaths/population)*100) AS MaxPopulationDeathPercnt
 FROM PRACTICE..DEATH
 WHERE continent IS NOT NULL
 GROUP BY location,population
 ORDER BY 4 DESC;

 --CONTINENT WITH HIGHEST DEATH COUNT
SELECT DISTINCT
	CONTINENT,
	SUM(CAST(new_deaths AS int)) OVER(PARTITION BY CONTINENT) AS ContinentDeath
 FROM PRACTICE..DEATH
 WHERE continent IS NOT NULL
 ORDER BY 2 DESC;
 
 --OVERALL NECESSARY RECORDS
 SELECT 
	SUM(population)	WorldTotalPopulation,
	SUM(NEW_CASES) WorldTotalCases,
	SUM(CAST(NEW_DEATHS AS INT)) WorldTotalDeath,
	(SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES))*100 AS [World(InfectedDeathPercent)],
	(SUM(NEW_CASES)/SUM(population))*100 AS WorldPopulationInfectedPercent,
	(SUM(CAST(NEW_DEATHS AS INT))/SUM(population))*100 AS WorldPopulationDeathPercent
 FROM PRACTICE..DEATH
 WHERE continent IS NOT NULL;

 --VACCINATIONS TABLE
 --GlobalVaccinationCount, GLOBAL PATIENT VACCINATED
SELECT 
	SUM(CONVERT(bigint, new_vaccinations)) AS TOtalGlobalVaccinated
 FROM PRACTICE..VACCINE 
 WHERE continent IS NOT NULL;
 
 --CONTINENTS BY VACCINATION, USE OFFSET AND FETCH TO GET HIGHEST
SELECT DISTINCT
	CONTINENT,
	SUM(CAST(new_vaccinations AS bigint)) OVER(PARTITION BY CONTINENT) AS ContinentVaccination
 FROM PRACTICE..VACCINE
 WHERE continent IS NOT NULL
 ORDER BY 2 DESC;
/*new_vacc* datatype had to be converted cos of the sum(AGGREGate function effect, converted it to int but kept showing arithemetic overfllow.
Only bigint,numeric and float worked.*/

--GLOBAL PERCENT OF  VACCINATED PATIENT IN THE WORLD. 0.0274 BY NORMAL CALC
 SELECT 
	(SUM(CONVERT(bigint,V.new_vaccinations))/SUM(D.population))*100  GlobalPercentVaccinated
	FROM
	(SELECT
		location,
		new_vaccinations,
		continent
	 FROM PRACTICE..VACCINE ) V
 ,
	(SELECT
		population,
		location,
		continent
	FROM PRACTICE..DEATH) D
  WHERE V.location = D.location
  AND V.continent IS NOT NULL
  AND D.continent IS NOT NULL;

  --OR, I CAN USE THIS TOO

/*  SELECT 
	SUM(CONVERT(bigint,V.new_vaccinations))/SUM(D.population)
	FROM
	(SELECT
		location,
		new_vaccinations,
		continent
	 FROM PRACTICE..VACCINE 
	 WHERE continent IS NOT NULL) V
 ,
	(SELECT
		population,
		location,
		continent
	FROM PRACTICE..DEATH
	WHERE continent IS NOT NULL) D
  WHERE V.location = D.location  */

  --LOCATION by vaccination and then continent by vaccination(%OF THE COUNTRY/LOCATION AND CONTINENT VACCINATED)

  --CREATE VIEW TO STORE FOR TABLEAU AND BI VISUALIZATION

CREATE VIEW NIGDEATHPERCENT

  AS
  SELECT
	location,
	Date,
	Total_cases,
	Total_deaths,
	Population,
	(total_deaths/total_cases)*100 AS Death_percentage
 FROM PRACTICE..DEATH
 WHERE continent IS NOT NULL 
 --WHERE location = 'Nigeria'
 ORDER BY 1,2;
