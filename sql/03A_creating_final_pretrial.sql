--03A_creating_final_pretrial
--Creating final pretrial table for looker
CREATE OR REPLACE TABLE `connecticut.pretrial_final` AS
WITH staywork1 AS (
  SELECT *,
         DENSE_RANK() OVER (ORDER BY download_date) AS download_date_rank
  FROM `connecticut.pretrial_cleaned`
)
, staywork2 AS (
  SELECT *,
         LAG(download_date_rank) OVER(PARTITION BY identifier ORDER BY download_date) AS prev_rank_per_person
  FROM staywork1
)
, staywork3 AS (
  SELECT *,
         CASE WHEN prev_rank_per_person IS NULL THEN 1
              WHEN download_date_rank - prev_rank_per_person > 1 THEN 1
         ELSE 0 END AS new_stay_flag
  FROM staywork2
)
, staywork4 AS (
  SELECT *,
         SUM(new_stay_flag) OVER (PARTITION BY identifier ORDER BY download_date) AS stay_number
  FROM staywork3
)
, stays AS (
  --Create unique identifier
  SELECT CONCAT(identifier, '_', CAST(stay_number AS STRING)) AS stay_id,
  *
  FROM staywork4
)
, calculate1 AS (
  SELECT *,
         --Dates per stay
         FIRST_VALUE(download_date) OVER (PARTITION BY stay_id ORDER BY download_date DESC) AS last_seen_per_stay,
         --Month snapshot
         MAX(download_date) OVER (PARTITION BY DATE_TRUNC(download_date, MONTH)) AS month_end_snapshot
  FROM stays
)
, calculate2 AS (
  SELECT download_date,
       identifier,
       stay_id,
       latest_admission_date,
       race,
       gender,
       age,
       age_bucket,
       facility,
       fac_category,
       offense,
       off_category,
       class,
       bond_amount,
       bond_bucket,
       dv_flag,
       CASE WHEN dv_flag = 'DV Likely' THEN 1
       ELSE 0 END AS num_dv_flag,
       detainer,
       CASE WHEN download_date = month_end_snapshot THEN 1
       ELSE 0 END AS month_end_flag,

       --Per stay
       last_seen_per_stay,
       DATE_DIFF(last_seen_per_stay, latest_admission_date, DAY) AS days_since_admission_per_stay,
       CASE WHEN last_seen_per_stay < MAX(download_date) OVER () THEN 1
       ELSE 0 END AS released_per_stay_flag,
       
       --Snapshots
       CASE WHEN download_date = last_seen_per_stay THEN 1
       ELSE 0 END AS latest_snapshot_per_stay,
       month_end_snapshot,
       EXTRACT(YEAR FROM month_end_snapshot) AS year_snapshot,
       
       --First admitted, Last seen
       MIN(latest_admission_date) OVER (PARTITION BY identifier ORDER BY latest_admission_date) AS first_admitted_date,
       FIRST_VALUE(download_date) OVER (PARTITION BY identifier ORDER BY download_date DESC) AS last_seen_date,

       --Policy flags
       CASE WHEN bond_amount <= 5000 AND bond_amount >= 100 AND detainer = 'None' THEN 1
       ELSE 0 END AS low_bond_no_detainer,
       CASE WHEN off_category = 'Court/Supervision Violation' AND dv_flag IS NULL THEN 1
       ELSE 0 END AS court_violation_only,
       
       --Old data
       CASE WHEN latest_admission_date < '2016-07-01' THEN 1
       ELSE 0 END AS admitted_before_data,
       CASE WHEN DATE_DIFF(download_date, latest_admission_date, DAY) >= 365 THEN 1
       ELSE 0 END AS old_admission,
       download_date_rank,
       prev_rank_per_person,
       new_stay_flag,
       stay_number     
  FROM calculate1
)
, calculate3 AS (
  SELECT *,
         CASE WHEN days_since_admission_per_stay < 183 THEN 'Under 6 months'
              WHEN days_since_admission_per_stay < 366 THEN '6 months-1 year'
              WHEN days_since_admission_per_stay < 1096 THEN '1-3 years'
              WHEN days_since_admission_per_stay < 1826 THEN '3-5 years'
              WHEN days_since_admission_per_stay < 3651 THEN '5-10 years'
              WHEN days_since_admission_per_stay < 7301 THEN '10-20 years'
              WHEN days_since_admission_per_stay > 7300 THEN '20+ years'
         ELSE NULL END AS time_since_admission_per_stay_buckets,
         CASE WHEN last_seen_date < MAX(download_date) OVER () THEN 1
         ELSE 0 END AS released,
         CASE WHEN latest_snapshot_per_stay = 1 AND download_date = MAX(download_date) OVER () THEN DATE_DIFF(download_date, latest_admission_date, DAY)
         ELSE NULL END AS days_since_admission_not_released
FROM calculate2
)
SELECT *,
       CASE WHEN days_since_admission_per_stay > 3650 THEN 1
       ELSE 0 END AS over_ten_year_stay,
       CASE WHEN days_since_admission_not_released < 183 THEN 'Under 6 months'
            WHEN days_since_admission_not_released < 366 THEN '6 months-1 year'
            WHEN days_since_admission_not_released < 1096 THEN '1-3 years'
            WHEN days_since_admission_not_released < 1826 THEN '3-5 years'
            WHEN days_since_admission_not_released < 3651 THEN '5-10 years'
            WHEN days_since_admission_not_released < 7301 THEN '10-20 years'
            WHEN days_since_admission_not_released > 7300 THEN '20+ years'
         ELSE NULL END AS time_since_admission_not_released
FROM calculate3;


--Row count check
SELECT COUNT(*)
FROM `connecticut.pretrial_final`;

--Stay id check
SELECT identifier,
       download_date,
       download_date_rank,
       prev_rank_per_person,
       new_stay_flag,
       stay_number,
       stay_id
FROM `connecticut.pretrial_final`
ORDER BY identifier, download_date
LIMIT 1000;    

--last seen per stay check
SELECT COUNT(DISTINCT stay_id) 
FROM `connecticut.pretrial_final`
WHERE last_seen_per_stay IS NOT NULL;

SELECT COUNT(DISTINCT stay_id) AS id_count
FROM `connecticut.pretrial_final`
WHERE download_date = last_seen_per_stay;

--month snapshot check
SELECT DISTINCT month_end_snapshot
FROM `connecticut.pretrial_final`
ORDER BY month_end_snapshot;
--missing dates in data Aug 20-31, Sep 20-30, Nov 22-30 2016, Oct 24-31 2017, May 31 2019, Mar 31 2020, Feb 28 2023

--Num dv flag check
SELECT COUNT(dv_flag)
FROM `connecticut.pretrial_final`
WHERE dv_flag IS NOT NULL;

SELECT COUNT(*)
FROM `connecticut.pretrial_final`
WHERE dv_flag = 'DV Likely' AND num_dv_flag = 1;

--Days since admission per stay check
SELECT DISTINCT stay_id,
       latest_admission_date,
       last_seen_per_stay,
       days_since_admission_per_stay
FROM `connecticut.pretrial_final`
LIMIT 1000;

SELECT DISTINCT days_since_admission_per_stay
FROM `connecticut.pretrial_final`
ORDER BY days_since_admission_per_stay;
--need to figure out -3, 0 and need to flag longer times

--Released per stay flag check
SELECT COUNTIF(last_seen_per_stay < '2026-10-26')
FROM `connecticut.pretrial_final`;

SELECT COUNTIF(released_per_stay_flag = 1)
FROM `connecticut.pretrial_final`;

--Latest snapshot check
SELECT stay_id,
       SUM(latest_snapshot_per_stay)
FROM `connecticut.pretrial_final`
GROUP BY stay_id
LIMIT 1000;

--Year snapshot check
SELECT DISTINCT year_snapshot
FROM `connecticut.pretrial_final`
ORDER BY year_snapshot;

--first admitted date check
SELECT identifier,
       latest_admission_date,
       first_admitted_date
FROM `connecticut.pretrial_final`
ORDER BY identifier, latest_admission_date
LIMIT 1000;

--Last seen date check
SELECT identifier,
       download_date,
       last_seen_date
FROM `connecticut.pretrial_final`
ORDER BY identifier, download_date DESC
LIMIT 1000;

--low bond no detainer check
SELECT DISTINCT stay_id,
       bond_amount,
       detainer,
       low_bond_no_detainer
FROM `connecticut.pretrial_final`
WHERE bond_amount > 100
ORDER BY bond_amount
LIMIT 1000;

--Court violation check
SELECT DISTINCT stay_id,
       off_category,
       dv_flag,
       court_violation_only
FROM `connecticut.pretrial_final`
WHERE off_category = 'Court/Supervision Violation'
LIMIT 1000;

--Admitted before data check
SELECT DISTINCT stay_id,
       latest_admission_date,
       admitted_before_data
FROM `connecticut.pretrial_final`
WHERE latest_admission_date > '2016-06-01'
ORDER BY latest_admission_date
LIMIT 1000;

--Old admission check
SELECT DISTINCT stay_id,
       latest_admission_date,
       download_date,
       old_admission
FROM `connecticut.pretrial_final`
WHERE latest_admission_date > '2025-10-01' AND download_date = '2026-10-26'
ORDER BY latest_admission_date
LIMIT 1000;

--Days since admission per stay bucket check
SELECT days_since_admission_per_stay,
       days_since_admission_per_stay_buckets
FROM `connecticut.pretrial_final`
LIMIT 1000;

--Released check
SELECT COUNT(released)
FROM `connecticut.pretrial_final`
WHERE released = 1;

--Over ten year stay check
SELECT DISTINCT days_since_admission_per_stay_buckets,
       over_ten_year_stay
FROM `connecticut.pretrial_final`;

--Days since admission not released
SELECT DISTINCT stay_id,
       latest_admission_date,
       download_date,
       days_since_admission_not_released
FROM `connecticut.pretrial_final`
WHERE download_date = '2026-10-26';

--Time since admission not released
SELECT DISTINCT stay_id,
       days_since_admission_not_released,
       time_since_admission_not_released
FROM `connecticut.pretrial_final`
WHERE download_date = '2026-10-26'

