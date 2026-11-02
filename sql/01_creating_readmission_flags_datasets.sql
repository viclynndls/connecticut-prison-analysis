--01_creating_readmission_flags_datasets
CREATE OR REPLACE TABLE `connecticut.pretrial_readmission_flags` AS
SELECT *,
       CASE WHEN readmission_365 = TRUE THEN 1
       ELSE 0 END AS readmission_365_flag,
       CASE WHEN eligibility_365 = TRUE THEN 1
       ELSE 0 END AS eligibility_365_flag,
       CASE WHEN readmission_30 = TRUE THEN 1
       ELSE 0 END AS readmission_30_flag,
       CASE WHEN eligibility_30 = TRUE THEN 1
       ELSE 0 END AS eligibility_30_flag,
       CASE WHEN readmission_90 = TRUE THEN 1
       ELSE 0 END AS readmission_90_flag,
       CASE WHEN eligibility_90 = TRUE THEN 1
       ELSE 0 END AS eligibility_90_flag
FROM `connecticut.pretrial_readmission`;

SELECT readmission_30,
       readmission_90,
       readmission_365,
       readmission_30_flag,
       readmission_90_flag,
       readmission_365_flag
FROM `connecticut.pretrial_readmission_flags`
WHERE readmission_30 = TRUE
LIMIT 1000;

SELECT eligibility_30,
       eligibility_90,
       eligibility_365,
       eligibility_30_flag,
       eligibility_90_flag,
       eligibility_365_flag
FROM `connecticut.pretrial_readmission_flags`
WHERE readmission_30 = TRUE
LIMIT 1000;

CREATE OR REPLACE TABLE `connecticut.sentenced_readmission_flags` AS
SELECT *,
       CASE WHEN readmission_365 = TRUE THEN 1
       ELSE 0 END AS readmission_365_flag,
       CASE WHEN eligibility_365 = TRUE THEN 1
       ELSE 0 END AS eligibility_365_flag,
       CASE WHEN readmission_30 = TRUE THEN 1
       ELSE 0 END AS readmission_30_flag,
       CASE WHEN eligibility_30 = TRUE THEN 1
       ELSE 0 END AS eligibility_30_flag,
       CASE WHEN readmission_90 = TRUE THEN 1
       ELSE 0 END AS readmission_90_flag,
       CASE WHEN eligibility_90 = TRUE THEN 1
       ELSE 0 END AS eligibility_90_flag,
       CASE WHEN readmission_1095 = TRUE THEN 1
       ELSE 0 END AS readmission_1095_flag,
       CASE WHEN eligibility_1095 = TRUE THEN 1
       ELSE 0 END AS eligibility_1095_flag
FROM `connecticut.sentenced_readmission`;

SELECT readmission_30,
       readmission_90,
       readmission_365,
       readmission_1095,
       readmission_30_flag,
       readmission_90_flag,
       readmission_365_flag,
       readmission_1095_flag
FROM `connecticut.sentenced_readmission_flags`
WHERE readmission_30 = TRUE
LIMIT 1000;

SELECT eligibility_30,
       eligibility_90,
       eligibility_365,
       eligibility_1095,
       eligibility_30_flag,
       eligibility_90_flag,
       eligibility_365_flag,
       eligibility_1095_flag
FROM `connecticut.sentenced_readmission_flags`
WHERE readmission_30 = TRUE
LIMIT 1000;