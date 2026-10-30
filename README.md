# Connecticut DOC: Pretrial Detention, Sentenced Custody, and Returns to Custody

> **Status: In progress.** The SQL pipeline and Python readmission analysis are complete. The Looker Studio dashboard and final write-up are in development. See [Roadmap](#roadmap).

## Overview

This project analyzes nearly ten years of daily Connecticut Department of Correction (DOC) data to answer:

**Who is held in Connecticut DOC custody before trial and after sentencing, how long do they stay, and how often do they return?**

Supporting questions:
1. **Population trends:** How have the pretrial and sentenced populations changed since 2016, and what drives those changes?
2. **Detention and sentencing:** What are people held on, and how do bond amounts and sentence lengths vary by offense and race?
3. **How stays end:** How long do people stay, and how often are sentenced people released early versus at the end of their sentence?
4. **Returns:** How often do people return to custody within 30 days, 90 days, 1 year, and 3 years, and which groups return most?

## Data

Two public datasets from the Connecticut Open Data Portal, each a daily snapshot of everyone held by the DOC:

| Dataset | Coverage | Grain |
|---|---|---|
| [Accused Pre-Trial Inmates in Correctional Facilities](https://catalog.data.gov/dataset/accused-pre-trial-inmates-in-correctional-facilities) | July 2016 – present | One row per person per day |
| Sentenced Inmates in Correctional Facilities *(add link)* | August 2017 – present | One row per person per day |

The raw data (12M+ rows) is not stored in this repository; it can be downloaded from the portal links above.

## Tools

- **BigQuery (SQL):** cleaning, offense and facility categorization, stay modeling
- **Python (pandas, matplotlib) in Google Colab:** readmission analysis
- **Looker Studio:** exploratory analysis and final dashboard *(in progress)*
- **Git / GitHub:** version control

## Pipeline

```
raw daily snapshots (BigQuery)
  -> cleaned tables         (types, nulls, text standardization, deduplication)
  -> crosswalk joins        (offense category, class, DV flag; facility type)
  -> final daily tables     (stay IDs, stay-level fields, monthly snapshot flags)
  -> stays tables           (one row per stay)
  -> pandas readmission analysis
  -> Looker Studio dashboard
```

| Step | Files |
|---|---|
| Cleaning | `sql/01_...`, `sql/02_...` |
| Final daily tables | `sql/03A_creating_final_pretrial.sql`, `sql/03B_creating_final_sentenced.sql` |
| Stays tables | `sql/04A_creating_pretrial_stays.sql`, `sql/04B_creating_sentenced_stays.sql` |
| Readmission analysis | `notebooks/Pretrial_Readmission_Analysis.ipynb`, `notebooks/Sentenced_Readmission_Analysis.ipynb` |
| Crosswalks | `crosswalks/offense_crosswalk.csv`, `crosswalks/facility_crosswalk.csv` |

## Key data decisions

### Defining a "stay"
The data has no stay ID, so stays had to be constructed. The first version defined a stay as **identifier + admission date**. Validation exposed a problem: readmission gaps came back negative, and tracing one person showed a "stay" observed on only 49 of 681 days. The DOC sometimes **reuses an earlier admission date** when a person leaves custody and returns. About 5,200 pretrial stays (~4%) were affected, concentrated among the longest stays.

Stays are now defined as **continuous runs of daily snapshots** (a "gaps and islands" approach):
- Each date in the dataset gets a sequence number with `DENSE_RANK`, so days missing from the source data don't break stays.
- A new stay begins when a person is absent from **two or more consecutive snapshots**. Single-snapshot absences were common in the pretrial data and are treated as data noise.
- Length of stay is measured from the first to the last snapshot of each stay.

After the change, no readmission gaps were negative or shorter than 3 days. The original definition is preserved in the commit history (tag `stay-definition-v1`).

### Offense categories
About 400 distinct offense strings were mapped in a crosswalk to:
- **Class** (e.g., Class A–E felony, Class A–C misdemeanor), parsed from codes embedded in the offense text
- **Category:** Violent, Sexual, Property, Drug, Weapons, Court/Supervision Violation, DUI/Traffic, Public Order/Obstruction, Warrant/Hold/Procedural, Unknown. Based on Bureau of Justice Statistics groupings, with court and supervision violations separated because they are central to pretrial detention.
- **DV flag** for offenses that are domestic-violence-related by definition (e.g., protective order violations)

### Other decisions
- Facilities were consolidated into types (DOC jail, DOC prison, medical, mental health, community residential, parole, out-of-state/federal).
- Bond buckets follow cutoffs used in Connecticut's own pretrial reporting (\$5,000, \$20,000, \$500,000).
- Population trends use one snapshot per month (the last available date) to avoid counting the same person once per day.

## Findings so far

### Pretrial detention
- **Court and supervision violations** (failures to appear, probation violations) are the largest category of pretrial stays.
- Pretrial admissions **dropped sharply in April 2020**. Court-violation admissions took until about 2023 to recover, while violent-offense admissions recovered faster.
- **[X%]** of released pretrial stays were followed by a return to pretrial detention within one year.
- One-year returns were highest for **public order/obstruction (41.9%)** and **court/supervision violation (34.5%)** stays, and lowest for sexual offenses (15.8%).
- Within nearly every offense category, one-year returns **declined as bond amounts rose**, from about 37–38% for bonds under \$20,000 to about 19% at \$500,000 or more. This likely reflects that higher-bond stays more often end in a sentence rather than a release (see Limitations).

### Sentenced custody
- **21.2%** of released sentenced stays were followed by a return to sentenced custody within one year, and **35.4%** within three years.
- People **released early** returned at more than twice the rate of those released at the end of their sentence within one year (29.3% vs. 11.6%), likely reflecting post-release supervision and violations rather than early release itself.
- **DUI/traffic** sentences had the lowest one-year return rate (9.3%); **property** offenses the highest (29.1%).
- Return rates were highest for **18–24-year-olds** (24.7% within one year).

## Limitations
- Readmission measures **return to DOC custody of the same type**, not re-arrest or reconviction. People rearrested and released on bond do not appear.
- A pretrial stay can end because the person was **sentenced**, which lowers measured pretrial readmission for groups more likely to be sentenced.
- The "controlling offense" in the data is the charge at the top of the mittimus at admission and may not be the most serious charge.
- About 40% of pretrial offense records have no class code in the source data.
- Stays that began before the data starts have no visible earlier history.
- Small groups (e.g., under 18, Asian, American Indian) have less reliable rates.

## Roadmap
- [x] Clean and model pretrial and sentenced data in BigQuery
- [x] Build offense and facility crosswalks
- [x] Redefine stays as continuous custody periods
- [x] Pretrial and sentenced readmission analysis in pandas
- [ ] Looker Studio dashboard *(in progress)*
- [ ] Final write-up *(in progress)*
- [ ] **Future work:** link pretrial and sentenced records by identifier to build continuous custody episodes, separating stays that ended in release from those that ended in a sentence and measuring return to any DOC custody

## Contact
Victoria — [github.com/viclynndls](https://github.com/viclynndls) · viclynndls@gmail.com
