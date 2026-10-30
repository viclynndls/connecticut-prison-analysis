--01B_cleaning_sentenced_data
--Count raw sentence rows
SELECT COUNT(*)
FROM `connecticut.raw_sentenced`;

--Creating cleaned table
CREATE OR REPLACE TABLE `connecticut.sentenced_cleaned` AS
       --Clean1 CTE
       WITH sentence_clean1 AS (
              SELECT 
                     -- Correct data types
                     PARSE_DATE('%m/%d/%Y', download_date) AS download_date, 
                     PARSE_DATE('%m/%d/%Y', latest_admission_date) AS latest_admission_date,
                     CAST(TRIM(age) AS INT64) AS age,
                     CAST(REPLACE(TRIM(sentence_days), ',', '') AS INT64) AS sentence_days,

                     -- Trim and capitalization
                     TRIM(INITCAP(race)) AS race,
                     TRIM(LOWER(offense)) AS offense,
                     CASE WHEN TRIM(INITCAP(facility)) = '145' THEN 'Unknown'
                     ELSE TRIM(INITCAP(facility)) END AS facility,
                     TRIM(identifier) AS identifier,
                     TRIM(detainer) AS detainer,
                     TRIM(gender) AS gender,

                     -- Correct Nulls
                     CASE WHEN TRIM(end_sentence_date) = '' THEN NULL
                     ELSE TRIM(end_sentence_date) END AS end_sentence_date,
                     CASE WHEN TRIM(special_parole_end_date) = '' OR TRIM(special_parole_end_date) = '.' THEN NULL
                     ELSE TRIM(special_parole_end_date) END AS special_parole_end_date
              FROM `connecticut.raw_sentenced`
       )
       --Clean2 CTE
       , sentence_clean2 AS(
              SELECT *, 
                     RIGHT(offense, 2) AS possible_class,
              FROM sentence_clean1
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
              c.offense, 
              o.off_category,
              o.dv_flag,
              c.facility,
              f.fac_category,
              --change likely typos to unknown
              INITCAP(CASE WHEN c.detainer IN ('6', '9', 'H', 'T') THEN 'Unknown'
              ELSE c.detainer END) AS detainer,
              PARSE_DATE('%m/%d/%Y', c.end_sentence_date) AS end_sentence_date,
              c.sentence_days,
              CASE WHEN c.sentence_days < 183 THEN 'Under 6 months'
                   WHEN c.sentence_days < 366 THEN '6 months-1 year'
                   WHEN c.sentence_days < 1096 THEN '1-3 years'
                   WHEN c.sentence_days < 1826 THEN '3-5 years'
                   WHEN c.sentence_days < 3651 THEN '5-10 years'
                   WHEN c.sentence_days < 7301 THEN '10-20 years'
              ELSE '20+ years' END AS sentence_day_buckets,
              PARSE_DATE('%m/%d/%Y', special_parole_end_date) AS special_parole_end_date 
       FROM sentence_clean2 AS c
       --Join to offense and facility crosswalks
       LEFT JOIN `connecticut.offense_crosswalk` AS o
       ON c.offense = o.offense
       LEFT JOIN `connecticut.facility_crosswalk` AS f
       ON c.facility = f.facility;

--Count sentenced_cleaned rows
SELECT COUNT(*)
FROM `connecticut.sentenced_cleaned`;


