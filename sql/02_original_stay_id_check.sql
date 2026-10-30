--02_original_stay_id_check
SELECT download_date, latest_admission_date, offense, facility
FROM `connecticut.pretrial_final`
WHERE identifier = 'ZZEBCRLB'
  AND download_date BETWEEN '2019-06-28' AND '2019-07-08'
ORDER BY download_date, latest_admission_date;

SELECT
  latest_admission_date,
  MIN(download_date) AS first_seen,
  MAX(download_date) AS last_seen,
  COUNT(DISTINCT download_date) AS days_observed,
  DATE_DIFF(MAX(download_date), MIN(download_date), DAY) + 1 AS days_spanned
FROM `connecticut.pretrial_final`
GROUP BY latest_admission_date
ORDER BY first_seen;