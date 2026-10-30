--01_exploring_offenses
--Exploring offense pretrial
--Distinct offenses
CREATE OR REPLACE TABLE `connecticut.pretrial_distinct_offense` AS
SELECT DISTINCT LOWER(TRIM(offense)) AS offense
FROM `connecticut.raw_pretrial`
ORDER BY offense;

--Offense class
SELECT *
FROM(
SELECT offense, 
       RIGHT(offense, 2) AS possible_class,
FROM `connecticut.pretrial_distinct_offense`
)
WHERE possible_class = 'af' OR
      possible_class = 'bf' OR
      possible_class = 'cf' OR
      possible_class = 'df' OR
      possible_class = 'ef' OR
      possible_class = 'am' OR
      possible_class = 'bm' OR
      possible_class = 'cm' OR
      possible_class = 'um' OR
      possible_class = ' f' OR
      possible_class = ' m'
ORDER BY possible_class;

--Row count by identifier and offense
SELECT TRIM(identifier) AS identifier, 
       LOWER(TRIM(offense)) AS offense,
       COUNT(*) AS row_count
FROM `connecticut.raw_pretrial`
GROUP BY offense, identifier
ORDER BY identifier, offense, COUNT(*) DESC;

--Number of unique offenses per person
SELECT identifier,
       COUNT(DISTINCT LOWER(TRIM(offense))) AS num_offenses
FROM `connecticut.raw_pretrial`
GROUP BY identifier
ORDER BY COUNT(DISTINCT LOWER(TRIM(offense))) DESC;


--Adding offenses from sentenced
CREATE OR REPLACE TABLE `connecticut.sentenced_distinct_offense` AS
SELECT DISTINCT LOWER(TRIM(offense)) AS offense
FROM `connecticut.raw_sentenced`
ORDER BY offense;



