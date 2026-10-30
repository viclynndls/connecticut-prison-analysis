--02_creating_offense_facility_crosswalks
CREATE OR REPLACE TABLE `connecticut.facility_crosswalk` AS
SELECT string_field_0 AS facility,
       string_field_1 AS fac_category
FROM `connecticut.facility_categories`
WHERE string_field_0 != "facility"
ORDER BY facility;

SELECT *
FROM `connecticut.facility_crosswalk`;

CREATE OR REPLACE TABLE `connecticut.offense_crosswalk` AS
SELECT DISTINCT string_field_0 AS offense,
       string_field_1 AS off_category,
       string_field_2 AS dv_flag
FROM `connecticut.offense_categories`
WHERE string_field_0 != "offense"
ORDER BY offense;

SELECT *
FROM `connecticut.offense_crosswalk`
