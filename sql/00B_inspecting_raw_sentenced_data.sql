--Inspecting raw sentenced data
SELECT MIN(PARSE_DATE('%m/%d/%Y', download_date)) AS start_date,
       MAX(PARSE_DATE('%m/%d/%Y', download_date)) AS end_date
FROM `connecticut.raw_sentenced`;

SELECT COUNT(*)
FROM `connecticut.raw_sentenced`;

SELECT COUNTIF(TRIM(download_date) IS NULL) AS download_date,
       COUNTIF(TRIM(identifier) IS NULL) AS identifier,
       COUNTIF(TRIM(latest_admission_date) IS NULL) AS latest_admission_date,
       COUNTIF(TRIM(race) IS NULL) AS race,
       COUNTIF(TRIM(gender) IS NULL) AS gender,
       COUNTIF(TRIM(age) IS NULL) AS age,
       COUNTIF(TRIM(end_sentence_date) IS NULL) AS end_sentence_date,
       COUNTIF(TRIM(offense) IS NULL) AS offense,
       COUNTIF(TRIM(facility) IS NULL) AS facility,
       COUNTIF(TRIM(detainer) IS NULL) AS detainer,
       COUNTIF(TRIM(sentence_days) IS NULL) AS sentence_days,
       COUNTIF(TRIM(special_parole_end_date) IS NULL) AS special_parole_end_date
FROM `connecticut.raw_sentenced`;
--need to double check end_sentence_date, sentence_days, and special_parole_end_date

SELECT DISTINCT PARSE_DATE('%m/%d/%Y', download_date) AS download_date
FROM `connecticut.raw_sentenced`
ORDER BY download_date;

SELECT DISTINCT identifier 
FROM `connecticut.raw_sentenced`
ORDER BY identifier;

SELECT DISTINCT PARSE_DATE('%m/%d/%Y', latest_admission_date) AS latest_admission_date
FROM `connecticut.raw_sentenced`
ORDER BY latest_admission_date;

SELECT DISTINCT race AS race
FROM `connecticut.raw_sentenced`;

SELECT DISTINCT gender AS gender
FROM `connecticut.raw_sentenced`;

SELECT DISTINCT CAST(age AS INT64) AS age
FROM `connecticut.raw_sentenced`
ORDER BY age;

SELECT DISTINCT offense AS offense
FROM `connecticut.raw_sentenced`
ORDER BY offense;
--need to make sure everything is added to crosswalk

SELECT DISTINCT facility AS facility
FROM `connecticut.raw_sentenced`
ORDER BY facility;
--need to make sure everything is added to crosswalk, also remove random 145

SELECT DISTINCT detainer AS detainer
FROM `connecticut.raw_sentenced`
ORDER BY detainer;
--rename unknown values, same as before

SELECT COUNT(TRIM(end_sentence_date))
FROM `connecticut.raw_sentenced`
WHERE end_sentence_date = '';
--need to change to nulls

SELECT COUNT(TRIM(sentence_days))
FROM `connecticut.raw_sentenced`;

SELECT DISTINCT CAST(REPLACE(TRIM(sentence_days), ',', '') AS INT64) AS sentence_days
FROM `connecticut.raw_sentenced`
ORDER BY sentence_days;

SELECT COUNT(TRIM(special_parole_end_date))
FROM `connecticut.raw_sentenced`
WHERE special_parole_end_date = ''
--need to change to nulls


