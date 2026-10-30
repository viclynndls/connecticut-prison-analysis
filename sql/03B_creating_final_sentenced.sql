--03B_creating_final_sentenced
--Creating final sentence table for looker
CREATE OR REPLACE TABLE `connecticut.sentenced_final` AS
WITH staywork1 AS (
  SELECT *,
         DENSE_RANK() OVER (ORDER BY download_date) AS download_date_rank
  FROM `connecticut.sentenced_cleaned`
)
, staywork2 AS (
  SELECT *,
         LAG(download_date_rank) OVER(PARTITION BY identifier ORDER BY download_date) AS prev_rank_per_person
  FROM staywork1
)
, staywork3 AS (
  SELECT *,
         CASE WHEN prev_rank_per_person IS NULL THEN 1
              WHEN download_date_rank - prev_rank_per_person > 2 THEN 1
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
         MAX(download_date) OVER (PARTITION BY DATE_TRUNC(download_date, MONTH)) AS month_end_snapshot,
         MIN(download_date) OVER (PARTITION BY stay_id) AS first_seen_per_stay
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
       dv_flag,
       CASE WHEN dv_flag = 'DV Likely' THEN 1
       ELSE 0 END AS num_dv_flag,
       detainer,
       CASE WHEN download_date = month_end_snapshot THEN 1
       ELSE 0 END AS month_end_flag,

       --Overall time
       DATE_DIFF(download_date, first_seen_per_stay, DAY) + 1 AS days_served,
       DATE_DIFF(end_sentence_date, download_date, DAY) AS days_remaining,
       CASE WHEN download_date > end_sentence_date AND last_seen_per_stay = MAX(download_date) OVER () THEN 1
       ELSE 0 END AS past_end_date,      
       
       --Per stay
       first_seen_per_stay,
       last_seen_per_stay,
       end_sentence_date,
       sentence_days,
       sentence_day_buckets,
       DATE_DIFF(last_seen_per_stay, first_seen_per_stay, DAY) + 1 AS length_of_stay,
       CASE WHEN last_seen_per_stay < MAX(download_date) OVER () THEN 1
       ELSE 0 END AS released_per_stay_flag,
       CASE WHEN last_seen_per_stay >= MAX(download_date) OVER () THEN NULL
            WHEN end_sentence_date IS NULL THEN 'Unknown'
            WHEN DATE_DIFF(last_seen_per_stay, end_sentence_date, DAY) < -10 THEN 'Released Early'
            WHEN DATE_DIFF(last_seen_per_stay, end_sentence_date, DAY) <= 10 THEN 'Released at End of Sentence'
            ELSE 'Released After End Date' END AS release_timing,

       --Snapshots
       CASE WHEN download_date = last_seen_per_stay THEN 1
       ELSE 0 END AS latest_snapshot_per_stay,
       month_end_snapshot,
       EXTRACT(YEAR FROM month_end_snapshot) AS year_snapshot,
       
       --First admitted, Last seen
       MIN(download_date) OVER (PARTITION BY identifier) AS first_seen_date,
       FIRST_VALUE(download_date) OVER (PARTITION BY identifier ORDER BY download_date DESC) AS last_seen_date,
       
       --Policy flags
       CASE WHEN off_category = 'Court/Supervision Violation' AND dv_flag IS NULL THEN 1
       ELSE 0 END AS court_violation_only,
       
       --Special parole
       special_parole_end_date,
       CASE WHEN special_parole_end_date IS NOT NULL THEN 1
       ELSE 0 END AS has_special_parole,
       DATE_DIFF(special_parole_end_date, end_sentence_date, DAY) AS special_parole_length_in_days,
       
       --Old data
       CASE WHEN first_seen_per_stay = MIN(download_date) OVER () THEN 1
       ELSE 0 END AS started_before_data,
       download_date_rank,
       prev_rank_per_person,
       new_stay_flag,
       stay_number
  FROM calculate1
)
SELECT *,
         CASE WHEN released_per_stay_flag = 1 THEN NULL
              WHEN length_of_stay < 183 THEN 'Under 6 months'
              WHEN length_of_stay < 366 THEN '6 months-1 year'
              WHEN length_of_stay < 1096 THEN '1-3 years'
              WHEN length_of_stay < 1826 THEN '3-5 years'
              WHEN length_of_stay < 3651 THEN '5-10 years'
              WHEN length_of_stay < 7301 THEN '10-20 years'
         ELSE '20+ years' END AS length_of_stay_not_released_buckets,
         CASE WHEN length_of_stay < 183 THEN 'Under 6 months'
              WHEN length_of_stay < 366 THEN '6 months-1 year'
              WHEN length_of_stay < 1096 THEN '1-3 years'
              WHEN length_of_stay < 1826 THEN '3-5 years'
              WHEN length_of_stay < 3651 THEN '5-10 years'
              WHEN length_of_stay < 7301 THEN '10-20 years'
              WHEN length_of_stay > 7300 THEN '20+ years'
         ELSE NULL END AS length_of_stay_buckets,
         CASE WHEN days_remaining < 0 THEN 'Past end date'
              WHEN days_remaining < 183 THEN 'Under 6 months'
              WHEN days_remaining < 366 THEN '6 months-1 year'
              WHEN days_remaining < 1096 THEN '1-3 years'
              WHEN days_remaining < 1826 THEN '3-5 years'
              WHEN days_remaining < 3651 THEN '5-10 years'
              WHEN days_remaining < 7301 THEN '10-20 years'
              WHEN days_remaining > 7300 THEN '20+ years'
         ELSE NULL END AS time_remaining_buckets,
         CASE WHEN special_parole_length_in_days >= 0 AND special_parole_length_in_days < 183 THEN 'Under 6 months'
              WHEN special_parole_length_in_days >= 0 AND special_parole_length_in_days < 366 THEN '6 months-1 year'
              WHEN special_parole_length_in_days >= 0 AND special_parole_length_in_days < 1096 THEN '1-3 years'
              WHEN special_parole_length_in_days >= 0 AND special_parole_length_in_days < 1826 THEN '3-5 years'
              WHEN special_parole_length_in_days >= 0 AND special_parole_length_in_days < 3651 THEN '5-10 years'
              WHEN special_parole_length_in_days >= 0 AND special_parole_length_in_days < 7301 THEN '10-20 years'
              WHEN special_parole_length_in_days >= 0 AND special_parole_length_in_days > 7300 THEN '20+ years'
         ELSE NULL END AS special_parole_length_in_days_buckets,
         CASE WHEN last_seen_date < MAX(download_date) OVER () THEN 1
         ELSE 0 END AS released,
         CASE WHEN special_parole_length_in_days < 0 THEN 1
         ELSE 0 END AS neg_special_parole_length
FROM calculate2;

--Row count check
SELECT COUNT(*)
FROM `connecticut.sentenced_final`;

--Stay id check
SELECT identifier,
       download_date,
       download_date_rank,
       prev_rank_per_person,
       new_stay_flag,
       stay_number,
       stay_id
FROM `connecticut.sentenced_final`
ORDER BY identifier, download_date
LIMIT 1000;    
  

--last seen per stay check
SELECT COUNT(DISTINCT stay_id) 
FROM `connecticut.sentenced_final`
WHERE last_seen_per_stay IS NOT NULL;

SELECT COUNT(DISTINCT stay_id) AS id_count
FROM `connecticut.sentenced_final`
WHERE download_date = last_seen_per_stay;

--month snapshot check
SELECT DISTINCT month_end_snapshot
FROM `connecticut.sentenced_final`
ORDER BY month_end_snapshot;
--missing dates in data Oct 24-31 2017, May 31 2019, Mar 31 2020, Feb 28 2023

--Num dv flag check
SELECT COUNT(dv_flag)
FROM `connecticut.sentenced_final`
WHERE dv_flag IS NOT NULL;

SELECT COUNT(*)
FROM `connecticut.sentenced_final`
WHERE dv_flag = 'DV Likely' AND num_dv_flag = 1;

--Days since admission per stay check
SELECT DISTINCT stay_id,
       latest_admission_date,
       last_seen_per_stay,
       days_since_admission_per_stay
FROM `connecticut.sentenced_final`
LIMIT 1000;

SELECT DISTINCT days_since_admission_per_stay
FROM `connecticut.sentenced_final`
ORDER BY days_since_admission_per_stay;

--Released per stay flag check
SELECT COUNTIF(last_seen_per_stay < '2026-10-26')
FROM `connecticut.sentenced_final`;

SELECT COUNTIF(released_per_stay_flag = 1)
FROM `connecticut.sentenced_final`;

--Latest snapshot check
SELECT stay_id,
       SUM(latest_snapshot_per_stay)
FROM `connecticut.sentenced_final`
GROUP BY stay_id
LIMIT 1000;

--Year snapshot check
SELECT DISTINCT year_snapshot
FROM `connecticut.sentenced_final`
ORDER BY year_snapshot;

--first admitted date check
SELECT identifier,
       latest_admission_date,
       first_admitted_date
FROM `connecticut.sentenced_final`
ORDER BY identifier, latest_admission_date
LIMIT 1000;

--Last seen date check
SELECT identifier,
       download_date,
       last_seen_date
FROM `connecticut.sentenced_final`
ORDER BY identifier, download_date DESC
LIMIT 1000;

--Court violation check
SELECT DISTINCT stay_id,
       off_category,
       dv_flag,
       court_violation_only
FROM `connecticut.sentenced_final`
WHERE off_category = 'Court/Supervision Violation'
LIMIT 1000;

--Admitted before data check
SELECT DISTINCT stay_id,
       latest_admission_date,
       admitted_before_data
FROM `connecticut.sentenced_final`
WHERE latest_admission_date > '2017-06-01'
ORDER BY latest_admission_date
LIMIT 5000;

--Old admission check
SELECT DISTINCT stay_id,
       latest_admission_date,
       download_date,
       old_admission
FROM `connecticut.sentenced_final`
WHERE latest_admission_date > '2025-10-01' AND download_date = '2026-10-26'
ORDER BY latest_admission_date
LIMIT 1000;

--Days since admission per stay bucket check
SELECT days_since_admission_per_stay,
       time_since_admission_per_stay_buckets
FROM `connecticut.sentenced_final`
LIMIT 1000;

--Released check
SELECT COUNT(released)
FROM `connecticut.sentenced_final`
WHERE released = 1;

SELECT COUNT(*)
FROM `connecticut.sentenced_final`
WHERE last_seen_date < '2026-10-26';

--Days served
SELECT DISTINCT stay_id,
       download_date,
       latest_admission_date,
       days_served
FROM `connecticut.sentenced_final`
LIMIT 1000;

--Days remaining
SELECT DISTINCT stay_id,
       latest_admission_date,
       end_sentence_date,
       days_remaining
FROM `connecticut.sentenced_final`
LIMIT 1000;

--Past end date
SELECT DISTINCT stay_id,
       end_sentence_date,
       download_date,
       past_end_date
FROM `connecticut.sentenced_final`
WHERE past_end_date = 1
LIMIT 1000;

--Release timing
SELECT DISTINCT stay_id,
       download_date,
       last_seen_per_stay,
       end_sentence_date,
       release_timing
FROM `connecticut.sentenced_final`
WHERE release_timing IS NOT NULL
LIMIT 1000;

SELECT DISTINCT release_timing
FROM `connecticut.sentenced_final`;
--No releases shortly after end date or on end date

--Special parole length in days
SELECT DISTINCT stay_id,
       end_sentence_date,
       special_parole_end_date,
       special_parole_length_in_days
FROM `connecticut.sentenced_final`
WHERE special_parole_end_date IS NOT NULL
LIMIT 1000;
--check on the negatives

--Special parole length in days buckets
SELECT DISTINCT stay_id,
       special_parole_length_in_days,
       special_parole_length_in_days_buckets
FROM `connecticut.sentenced_final`
WHERE special_parole_end_date IS NOT NULL
LIMIT 1000;


SELECT DISTINCT special_parole_length_in_days
FROM `connecticut.sentenced_final`
ORDER BY special_parole_length_in_days;


--Time remaining buckets
SELECT DISTINCT stay_id,
       days_remaining,
       time_remaining_buckets
FROM `connecticut.sentenced_final`
LIMIT 1000;

SELECT DISTINCT time_remaining_buckets
FROM `connecticut.sentenced_final`;

--Negative special parole length
SELECT DISTINCT stay_id,
       special_parole_length_in_days,
       neg_special_parole_length
FROM `connecticut.sentenced_final`
WHERE special_parole_length_in_days IS NOT NULL
LIMIT 1000;

--Days served not released buckets
SELECT DISTINCT stay_id,
       days_served,
       days_served_not_released_buckets
FROM `connecticut.sentenced_final`
WHERE download_date = '2026-10-26'
LIMIT 1000;


--Breaks between stays
SELECT
  download_date_rank - prev_rank_per_person AS rank_gap,
  COUNT(*) AS new_stays
FROM `connecticut.sentenced_final`
WHERE new_stay_flag = 1
  AND prev_rank_per_person IS NOT NULL
GROUP BY rank_gap
ORDER BY rank_gap
LIMIT 30;

--Total stays
SELECT
  COUNT(DISTINCT stay_id) AS total_stays,
  COUNT(DISTINCT identifier) AS total_people
FROM `connecticut.sentenced_final`;
