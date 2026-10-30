--01_exploring_facility
--Exploring pretrial facility
--Distinct facilities
CREATE OR REPLACE TABLE `connecticut.pretrial_distinct_facility` AS
SELECT DISTINCT TRIM(INITCAP(facility)) AS facility
FROM `connecticut.raw_pretrial`
ORDER BY facility;

--Row count per facility
SELECT TRIM(INITCAP(facility)) AS facility,
       COUNT(*)
FROM `connecticut.raw_pretrial`
GROUP BY facility
ORDER BY COUNT(*) DESC;

--Number of unique facilities per person
SELECT identifier,
       COUNT(DISTINCT TRIM(INITCAP(facility))) AS num_facilities
FROM `connecticut.raw_pretrial`
GROUP BY identifier
ORDER BY COUNT(DISTINCT TRIM(INITCAP(facility))) DESC;

--Adding facility from sentenced
CREATE OR REPLACE TABLE `connecticut.sentenced_distinct_facility` AS
SELECT DISTINCT CASE WHEN TRIM(INITCAP(facility)) = '145' THEN 'Unknown'
                     ELSE TRIM(INITCAP(facility)) END AS facility
FROM `connecticut.raw_sentenced`
ORDER BY facility;