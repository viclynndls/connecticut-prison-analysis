--Inspecting raw pretrial data
SELECT MIN(download_date) AS start_date,
       MAX(download_date) AS end_date
FROM `connecticut.raw_pretrial`;

SELECT COUNTIF(download_date IS NULL) AS download_date,
       COUNTIF(identifier IS NULL) AS identifier,
       COUNTIF(latest_admission_date IS NULL) AS latest_admission_date,
       COUNTIF(race IS NULL) AS race,
       COUNTIF(gender IS NULL) AS gender,
       COUNTIF(age IS NULL) AS age,
       COUNTIF(bond_amount IS NULL) AS bond_amount,
       COUNTIF(offense IS NULL) AS offense,
       COUNTIF(facility IS NULL) AS facility,
       COUNTIF(detainer IS NULL) AS detainer
FROM `connecticut.raw_pretrial`;

SELECT DISTINCT PARSE_DATE('%m/%d/%Y', download_date) AS download_date
FROM `connecticut.raw_pretrial`
ORDER BY download_date;

SELECT DISTINCT identifier 
FROM `connecticut.raw_pretrial`
ORDER BY identifier;

SELECT DISTINCT PARSE_DATE('%m/%d/%Y', latest_admission_date) AS latest_admission_date
FROM `connecticut.raw_pretrial`
ORDER BY latest_admission_date;

SELECT DISTINCT race AS race
FROM `connecticut.raw_pretrial`;

SELECT DISTINCT gender AS gender
FROM `connecticut.raw_pretrial`;

SELECT DISTINCT CAST(age AS INT64) AS age
FROM `connecticut.raw_pretrial`
ORDER BY age;
--121 outside of range, most likely a typo

SELECT DISTINCT bond_amount AS bond_amount
FROM `connecticut.raw_pretrial`
ORDER BY bond_amount;
--need to get rid of commas and turn into int 

SELECT DISTINCT CAST(REPLACE(bond_amount, ',', '') AS INT64) AS bond_amount
FROM `connecticut.raw_pretrial`
ORDER BY bond_amount;

SELECT DISTINCT offense AS offense
FROM `connecticut.raw_pretrial`
ORDER BY offense;
--very distinct labels, need to figure out groupings

SELECT DISTINCT facility AS facility
FROM `connecticut.raw_pretrial`
ORDER BY facility;
--need to determine definitions, possibly group certain places

SELECT DISTINCT detainer AS detainer
FROM `connecticut.raw_pretrial`
ORDER BY detainer;
--both numerical and string, need to find definitions