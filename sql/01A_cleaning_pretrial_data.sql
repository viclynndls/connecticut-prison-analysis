--Cleaning pretrial data
--Count raw pretrial rows
SELECT COUNT(*)
FROM `connecticut.raw_pretrial`;

--Creating cleaned table
CREATE OR REPLACE TABLE `connecticut.pretrial_cleaned` AS
       --Clean1 CTE
       WITH pretrial_clean1 AS (
              SELECT 
                     -- Correct data types
                     PARSE_DATE('%m/%d/%Y', download_date) AS download_date, 
                     PARSE_DATE('%m/%d/%Y', latest_admission_date) AS latest_admission_date,
                     CAST(TRIM(age) AS INT64) AS age,
                     CAST(REPLACE(TRIM(bond_amount), ',', '') AS INT64) AS bond_amount,

                     -- Trim and capitalization
                     TRIM(INITCAP(race)) AS race,
                     TRIM(LOWER(offense)) AS offense,
                     TRIM(INITCAP(facility)) AS facility,
                     TRIM(identifier) AS identifier,
                     TRIM(detainer) AS detainer,
                     TRIM(gender) AS gender
              FROM `connecticut.raw_pretrial`
       )
       --Clean2 CTE
       , pretrial_clean2 AS(
              SELECT *, 
                     RIGHT(offense, 2) AS possible_class,
              FROM pretrial_clean1
       )
       --Main
       SELECT c.download_date,
              c.identifier,
              c.latest_admission_date,
              c.race,
              c.gender,
              --Get rid of outliers
              CASE WHEN c.age < 14 OR c.age > 100 THEN NULL
              ELSE c.age END AS age,
              --age buckets
              CASE WHEN age < 18 THEN 'Under 18'
              WHEN c.age < 25 THEN '18-24'
              WHEN c.age < 35 THEN '25-34'
              WHEN c.age < 45 THEN '35-44'
              WHEN c.age < 55 THEN '45-54'
              ELSE '55+' END AS age_bucket,
              --Class definitions
              CASE WHEN c.possible_class = 'af' THEN 'Class A Felony'
              WHEN c.possible_class = 'bf' THEN 'Class B Felony'
              WHEN c.possible_class = 'cf' THEN 'Class C Felony'
              WHEN c.possible_class = 'df' THEN 'Class D Felony'
              WHEN c.possible_class = 'ef' THEN 'Class E Felony'
              WHEN c.possible_class = 'am' THEN 'Class A Misdemeanor'
              WHEN c.possible_class = 'bm' THEN 'Class B Misdemeanor'
              WHEN c.possible_class = 'cm' THEN 'Class C Misdemeanor'
              WHEN c.possible_class = 'um' THEN 'Unclassified Misdemeanor'
              WHEN c.possible_class = ' f' THEN 'Felony'
              WHEN c.possible_class = ' m' THEN 'Misdemeanor'
              ELSE NULL END AS class,
              c.bond_amount,
              --bond buckets
              CASE WHEN c.bond_amount < 100 THEN 'Under $100'
                   WHEN c.bond_amount < 5000 THEN '$100-$4,999'
                   WHEN c.bond_amount < 20000 THEN '$5,000-$19,999'
                   WHEN c.bond_amount < 50000 THEN '$20,000-$49,999'
                   WHEN c.bond_amount < 100000 THEN '$50,000-$99,999'
                   WHEN c.bond_amount < 500000 THEN '$100,000-$499,999'
                   ELSE '$500,000+' END AS bond_bucket,
              c.offense, 
              o.off_category,
              o.dv_flag,
              c.facility,
              f.fac_category,
              --change likely typos to unknown
              INITCAP(CASE WHEN c.detainer IN ('6', '9', 'H', 'T') THEN 'Unknown'
              ELSE c.detainer END) AS detainer 
       FROM pretrial_clean2 AS c
       --Join to offense and facility crosswalks
       LEFT JOIN `connecticut.offense_crosswalk` AS o
       ON c.offense = o.offense
       LEFT JOIN `connecticut.facility_crosswalk` AS f
       ON c.facility = f.facility;

--Count pretrial_cleaned rows
SELECT COUNT(*)
FROM `connecticut.pretrial_cleaned`;



