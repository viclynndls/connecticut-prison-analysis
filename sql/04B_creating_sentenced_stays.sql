--04B_creating_sentenced_stays
CREATE OR REPLACE TABLE `connecticut.sentenced_stays` AS
SELECT
  * EXCEPT (
    download_date,
    latest_snapshot_per_stay,
    month_end_snapshot,
    month_end_flag,
    year_snapshot,
    days_served,
    days_remaining,
    time_remaining_buckets,
    download_date_rank,
    prev_rank_per_person,
    new_stay_flag
  ),
  days_remaining AS days_remaining_at_release,
  time_remaining_buckets AS time_remaining_at_release_buckets
FROM `connecticut.sentenced_final`
QUALIFY ROW_NUMBER() OVER (PARTITION BY stay_id ORDER BY download_date DESC) = 1;

SELECT COUNT(*) AS row_count, 
       COUNT(DISTINCT stay_id) AS stay_count
FROM `connecticut.sentenced_stays`;

