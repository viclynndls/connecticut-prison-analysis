--02_inspecting_cleaned_sentenced
SELECT MIN(download_date) AS start_date,
       MAX(download_date) AS end_date
FROM `connecticut.sentenced_cleaned`;

SELECT COUNTIF(download_date IS NULL) AS download_date,
       COUNTIF(identifier IS NULL) AS identifier,
       COUNTIF(latest_admission_date IS NULL) AS latest_admission_date,
       COUNTIF(race IS NULL) AS race,
       COUNTIF(gender IS NULL) AS gender,
       COUNTIF(age IS NULL) AS age,
       COUNTIF(age_bucket IS NULL) AS age_bucket,
       COUNTIF(class IS NULL) AS class,
       COUNTIF(offense IS NULL) AS offense,
       COUNTIF(off_category IS NULL) AS off_category,
       COUNTIF(dv_flag IS NULL) AS dv_flag,
       COUNTIF(facility IS NULL) AS facility,
       COUNTIF(fac_category IS NULL) AS fac_category,
       COUNTIF(detainer IS NULL) AS detainer,
       COUNTIF(end_sentence_date IS NULL) AS end_sentence_date,
       COUNTIF(sentence_days IS NULL) AS sentence_days,
       COUNTIF(sentence_day_buckets IS NULL) AS sentence_day_buckets,
       COUNTIF(special_parole_end_date IS NULL) AS special_parole_end_date
FROM `connecticut.sentenced_cleaned`;

SELECT DISTINCT download_date
FROM `connecticut.sentenced_cleaned`
ORDER BY download_date;

SELECT DISTINCT identifier 
FROM `connecticut.sentenced_cleaned`
ORDER BY identifier;

SELECT DISTINCT latest_admission_date
FROM `connecticut.sentenced_cleaned`
ORDER BY latest_admission_date;

SELECT DISTINCT race
FROM `connecticut.sentenced_cleaned`;

SELECT DISTINCT gender
FROM `connecticut.sentenced_cleaned`;

SELECT DISTINCT age
FROM `connecticut.sentenced_cleaned`
ORDER BY age;

SELECT DISTINCT age_bucket
FROM `connecticut.sentenced_cleaned`
ORDER BY age_bucket;

SELECT DISTINCT class
FROM `connecticut.sentenced_cleaned`
ORDER BY class;

SELECT DISTINCT offense
FROM `connecticut.sentenced_cleaned`
ORDER BY offense;

SELECT DISTINCT off_category
FROM `connecticut.sentenced_cleaned`
ORDER BY off_category;

SELECT DISTINCT facility
FROM `connecticut.sentenced_cleaned`
ORDER BY facility;

SELECT DISTINCT fac_category
FROM `connecticut.sentenced_cleaned`
ORDER BY fac_category;

SELECT DISTINCT detainer
FROM `connecticut.sentenced_cleaned`
ORDER BY detainer;

SELECT DISTINCT dv_flag
FROM `connecticut.sentenced_cleaned`;

SELECT DISTINCT end_sentence_date
FROM `connecticut.sentenced_cleaned`
ORDER BY end_sentence_date;

SELECT DISTINCT sentence_days
FROM `connecticut.sentenced_cleaned`
ORDER BY sentence_days;

SELECT DISTINCT sentence_day_buckets
FROM `connecticut.sentenced_cleaned`
ORDER BY sentence_day_buckets;

SELECT DISTINCT special_parole_end_date
FROM `connecticut.sentenced_cleaned`
ORDER BY special_parole_end_date;
