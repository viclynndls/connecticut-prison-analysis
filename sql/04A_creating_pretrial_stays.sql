--04A_creating_pretrial_stays
CREATE OR REPLACE TABLE `connecticut.pretrial_stays` AS
SELECT * EXCEPT(download_date,
                latest_snapshot_per_stay,
                month_end_snapshot,
                month_end_flag,
                year_snapshot)
FROM `connecticut.pretrial_final`
QUALIFY ROW_NUMBER() OVER (PARTITION BY stay_id ORDER BY download_date DESC) = 1;

SELECT COUNT(*) AS row_count, 
       COUNT(DISTINCT stay_id) AS stay_count
FROM `connecticut.pretrial_stays`;

