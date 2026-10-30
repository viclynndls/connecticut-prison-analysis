--02A_inspecting_cleaned_pretrial
SELECT MIN(download_date) AS start_date,
       MAX(download_date) AS end_date
FROM `connecticut.pretrial_cleaned`;

SELECT COUNTIF(download_date IS NULL) AS download_date,
       COUNTIF(identifier IS NULL) AS identifier,
       COUNTIF(latest_admission_date IS NULL) AS latest_admission_date,
       COUNTIF(race IS NULL) AS race,
       COUNTIF(gender IS NULL) AS gender,
       COUNTIF(age IS NULL) AS age,
       COUNTIF(age_bucket IS NULL) AS age_bucket,
       COUNTIF(class IS NULL) AS class,
       COUNTIF(bond_amount IS NULL) AS bond_amount,
       COUNTIF(bond_bucket IS NULL) AS bond_bucket,
       COUNTIF(offense IS NULL) AS offense,
       COUNTIF(off_category IS NULL) AS off_category,
       COUNTIF(dv_flag IS NULL) AS dv_flag,
       COUNTIF(facility IS NULL) AS facility,
       COUNTIF(fac_category IS NULL) AS fac_category,
       COUNTIF(detainer IS NULL) AS detainer
FROM `connecticut.pretrial_cleaned`;

SELECT DISTINCT download_date
FROM `connecticut.pretrial_cleaned`
ORDER BY download_date;

SELECT DISTINCT identifier 
FROM `connecticut.pretrial_cleaned`
ORDER BY identifier;

SELECT DISTINCT latest_admission_date
FROM `connecticut.pretrial_cleaned`
ORDER BY latest_admission_date;

SELECT DISTINCT race
FROM `connecticut.pretrial_cleaned`;

SELECT DISTINCT gender
FROM `connecticut.pretrial_cleaned`;

SELECT DISTINCT age
FROM `connecticut.pretrial_cleaned`
ORDER BY age;

SELECT DISTINCT age_bucket
FROM `connecticut.pretrial_cleaned`
ORDER BY age_bucket;

SELECT DISTINCT class
FROM `connecticut.pretrial_cleaned`
ORDER BY class;

SELECT DISTINCT bond_amount
FROM `connecticut.pretrial_cleaned`
ORDER BY bond_amount;

SELECT DISTINCT bond_bucket
FROM `connecticut.pretrial_cleaned`
ORDER BY bond_bucket;

SELECT DISTINCT offense
FROM `connecticut.pretrial_cleaned`
ORDER BY offense;

SELECT DISTINCT off_category
FROM `connecticut.pretrial_cleaned`
ORDER BY off_category;

SELECT DISTINCT facility
FROM `connecticut.pretrial_cleaned`
ORDER BY facility;

SELECT DISTINCT fac_category
FROM `connecticut.pretrial_cleaned`
ORDER BY fac_category;

SELECT DISTINCT detainer
FROM `connecticut.pretrial_cleaned`
ORDER BY detainer;

SELECT DISTINCT dv_flag
FROM `connecticut.pretrial_cleaned`