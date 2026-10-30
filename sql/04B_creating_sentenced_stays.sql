--04B_creating_sentenced_stays
CREATE OR REPLACE TABLE `connecticut.sentenced_stays` AS
SELECT *
FROM `connecticut.sentenced_final`
QUALIFY ROW_NUMBER() OVER (PARTITION BY stay_id ORDER BY download_date DESC) = 1;

SELECT COUNT(*) AS row_count, 
       COUNT(DISTINCT stay_id) AS stay_count
FROM `connecticut.sentenced_stays`;
