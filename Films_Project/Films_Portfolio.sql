-- General Information that we are going to use
SELECT *
FROM FilmProject..Films_Info

-- The total Oscar Wins per Country
SELECT country, SUM([Oscar Wins])
FROM FilmProject..Films_Info
GROUP BY country
ORDER BY 2 DESC

-- Oscar Wins based on Genre per Country
SELECT genre, country, SUM([Oscar Wins]) GenreOscarWins
FROM FilmProject..Films_Info
GROUP BY genre, country
ORDER BY 2, 3 DESC

-- Percent Oscar Wins of each Genre per Country - INNER JOIN & SUBQUERY

SELECT genre, f1.country, SUM(f1.[Oscar Wins]) GenreOscarWins, CountryOscarWins, (SUM(f1.[Oscar Wins])/CountryOscarWins)*100 AS PercentGenreOscarWins
FROM FilmProject..Films_Info AS f1
INNER JOIN (SELECT country, SUM([Oscar Wins]) AS CountryOscarWins FROM FilmProject..Films_Info GROUP BY country) AS f2
ON f1.country = f2.country
WHERE f1.country != 'NULL'
GROUP BY genre, f1.country, CountryOscarWins
HAVING SUM(f1.[Oscar Wins]) != 0
ORDER BY 2, 3 DESC

-- Looking at films with Nominations and Oscar Wins
SELECT Title, Nominations, [Oscar Wins]
FROM FilmProject..Films_Info
WHERE Nominations >  1 AND [Oscar Wins] > 1

-- Looking at films with Nominations and without Oscar Wins
SELECT Title, Nominations, [Oscar Wins]
FROM FilmProject..Films_Info
WHERE Nominations >  1 AND [Oscar Wins] = 0

-- Looking at films without Nominations
SELECT Title, Nominations, [Oscar Wins]
FROM FilmProject..Films_Info
WHERE Nominations = 0

-- Average budget per genre per country

SELECT fi.Genre, fi.Country, AVG(Budget) AverageBudget
FROM FilmProject..Films_Info AS fi
INNER JOIN FilmProject..Films_Budget AS fb
ON fi.[Film ID] = fb.[Film ID]
GROUP BY fi.Genre, fi.Country
ORDER BY 2, 3

-- Looking at Countries with Highest-Oscar-Wins Rate based on Nominations - USING CTE
WITH OscarWinsRate AS
(SELECT Country, SUM(Nominations) AS TotalNominations, SUM([Oscar Wins]) AS TotalOscar
FROM FilmProject..Films_Info
GROUP BY Country)

SELECT *, CAST((TotalOscar/TotalNominations)*100 AS numeric(10,2)) AS Wins_Rate
FROM OscarWinsRate
WHERE TotalNominations != 0 AND Country != 'NULL'
ORDER BY 4 DESC

-- TEMP TABLE
DROP TABLE IF exists #OscarWinsRate
CREATE TABLE #OscarWinsRate
(Country nvarchar(255),
TotalNominations numeric,
TotalOscar numeric,
Wins_Rate numeric)

INSERT INTO #OscarWinsRate
SELECT Country, SUM(Nominations) AS TotalNominations, SUM([Oscar Wins]) AS TotalOscar, CAST((SUM([Oscar Wins])/SUM(Nominations))*100 AS numeric(10,2)) AS Wins_Rate
FROM FilmProject..Films_Info
WHERE Country != 'NULL'
GROUP BY Country
HAVING SUM(Nominations) != 0
--ORDER BY 4 DESC

SELECT *
FROM #OscarWinsRate

-- Creating View to store data
CREATE VIEW Oscar_Wins_Rate AS
SELECT Country, SUM(Nominations) AS TotalNominations, SUM([Oscar Wins]) AS TotalOscar, CAST((SUM([Oscar Wins])/SUM(Nominations))*100 AS numeric(10,2)) AS Wins_Rate
FROM FilmProject..Films_Info
WHERE Country != 'NULL'
GROUP BY Country
HAVING SUM(Nominations) != 0
--ORDER BY 4 DESC