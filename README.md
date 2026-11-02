# Connecticut DOC: Pretrial Detention, Sentenced Custody, and Returns to Custody

**[View the interactive dashboard](https://datastudio.google.com/reporting/62277530-74b4-4f72-af9e-5a6a858b3161)** · Built with BigQuery SQL, Python (pandas), and Looker Studio

## Summary

This project analyzes nearly ten years of daily Connecticut Department of Correction (DOC) data, covering 137,823 pretrial stays and 75,250 sentenced stays, to answer:

**Who is held in Connecticut DOC custody before trial and after sentencing, how long do they stay, and how often do they return?**

**Key findings**
- **Court and supervision violations** (failures to appear, probation violations) are the largest category in both populations: 37% of pretrial stays and 27% of sentenced stays.
- **About 3 in 10** people released from pretrial detention return to pretrial detention within a year.
- **About 1 in 5** people released from a sentence return to sentenced custody within a year, and **more than a third** within three years.
- People **released early** from a sentence return at about **2.5 times** the one-year rate of those released at sentence end (29% vs. 12%), but the gap narrows by three years (39% vs. 31%), suggesting early returns are concentrated during post-release supervision.
- Pretrial stays with high bonds last much longer: over 90% of stays with bonds under \$50,000 end within six months, compared to about 43% at \$500,000 or more. Black detainees make up about a third of stays with bonds under \$50,000 but nearly half at \$500,000 or more.

## Contents
1. [Data](#data)
2. [Tools and pipeline](#tools-and-pipeline)
3. [Key data decisions](#key-data-decisions)
4. [Findings](#findings)
5. [What this suggests](#what-this-suggests)
6. [Limitations](#limitations)
7. [Next steps](#next-steps)
8. [Repository structure](#repository-structure)
9. [Reproducing the analysis](#reproducing-the-analysis)

## Data

Two public datasets from the Connecticut Open Data Portal, each a daily snapshot of everyone held by the DOC:

| Dataset | Coverage | Grain |
|---|---|---|
| [Accused Pre-Trial Inmates in Correctional Facilities](https://catalog.data.gov/dataset/accused-pre-trial-inmates-in-correctional-facilities) | July 2016 – present | One row per person per day |
| [Sentenced Inmates in Correctional Facilities](https://data.ct.gov/Public-Safety/Sentenced-Inmates-in-Correctional-Facilities/um73-fxm4/about_data) | August 2017 – present | One row per person per day |

Together the datasets contain more than 12 million rows. The raw data is not stored in this repository; it can be downloaded from the portal links above.

## Tools and pipeline

- **BigQuery (SQL):** cleaning, categorization, and stay modeling
- **Python (pandas, matplotlib) in Google Colab:** readmission analysis
- **Looker Studio:** interactive dashboard
- **Git / GitHub:** version control

```
raw daily snapshots (BigQuery)
  -> cleaned tables          types, nulls, text standardization, deduplication
  -> crosswalk joins         offense category, class, DV flag; facility type
  -> final daily tables      stay IDs, stay-level fields, monthly snapshot flags
  -> stays tables            one row per stay
  -> pandas                  readmission flags and rates
  -> readmission tables      written back to BigQuery
  -> Looker Studio dashboard
```

Each tool does the part it's best at: SQL models the data, pandas handles the readmission logic, and Looker Studio presents the results interactively.

## Key data decisions

### Defining a "stay"
The data has no stay ID, so stays had to be constructed. The first version defined a stay as **identifier + admission date**. Validation exposed a problem: readmission gaps came back negative, and tracing one person showed a "stay" observed on only 49 of 681 days. This suggests the DOC sometimes **reuses an earlier admission date** when a person leaves custody and returns. About 5,200 pretrial stays (~4%) were affected, concentrated among the longest stays, which inflated lengths of stay and hid real readmissions.

Stays are now defined as **continuous runs of daily snapshots** (a "gaps and islands" approach):
- Each date in the dataset gets a sequence number with `DENSE_RANK`, so days missing from the source data don't break stays.
- A new stay begins when a person is absent from **two or more consecutive snapshots**. Single-snapshot absences were common in the pretrial data and are treated as data noise.
- Length of stay is measured from the first to the last snapshot of each stay.

After the change, no readmission gaps were negative or shorter than 3 days. The original definition is preserved in the commit history (tag `stay-definition-v1`).

### Offense categories
About 400 distinct offense strings were mapped in a crosswalk to:
- **Class** (Class A–E felony, Class A–C misdemeanor, unclassified), parsed from codes embedded in the offense text
- **Category:** Violent, Sexual, Property, Drug, Weapons, Court/Supervision Violation, DUI/Traffic, Public Order/Obstruction, Warrant/Hold/Procedural, and Unknown. Based on Bureau of Justice Statistics groupings, with court and supervision violations separated because they are central to pretrial detention.
- **DV flag** for offenses that are domestic-violence-related by definition, such as protective order violations

### Readmission
- A **return** is the start of a person's next stay of the same type (pretrial after pretrial, sentenced after sentenced).
- Each N-day rate includes **only stays released at least N days before the end of the data**, so recent releases don't pull rates down.
- Rates were calculated in pandas and written back to BigQuery so the dashboard could filter them interactively.

### Other decisions
- Facilities were consolidated into types: DOC jail, DOC prison, medical, mental health, community residential, parole, and out-of-state/federal.
- Bond buckets follow cutoffs used in Connecticut's own pretrial reporting (\$5,000, \$20,000, \$500,000).
- Population trends use one snapshot per month (the last available date) to avoid counting the same person once per day.
- Stays already in progress when the data began are excluded from length-of-stay and admissions analysis.

## Findings

### Population trends
- The **pretrial population** fell by about a third in spring 2020, recovered to pre-pandemic levels by 2024, and has declined since mid-2025.
- The **sentenced population** was already declining before 2020, fell to under 6,000 during the pandemic, and has only partly recovered, remaining well below 2017 levels.
- Pretrial admissions for **court/supervision violations** dropped from about 450–500 a month to about 100 in April 2020 and took until about 2023 to recover. Violent-offense admissions recovered faster.

### Pretrial detention
- Court/supervision violations make up the largest share of most bond ranges. Violent offenses make up over 40% of stays with bonds of \$500,000 or more.
- More than 90% of stays with bonds under \$50,000 end within six months, compared to about 43% of stays with bonds of \$500,000 or more.
- Black detainees account for about a third of stays with bonds under \$50,000 but nearly half of stays at \$500,000 or more. Offense mix explains part of this; the dashboard allows comparison within offense categories.

### Sentenced custody
- Most sentences are under three years. DUI/traffic accounts for about 40% of sentences under six months; violent offenses make up about three-quarters of sentences of 20 years or more.
- Because Connecticut has no county jails, about 40% of sentences under six months are served in DOC jails, compared to under 10% of longer sentences.
- Slightly more than half of released sentenced stays end before the scheduled end date, most likely through parole or transitional supervision.

### Returns to custody

| | 30 days | 90 days | 1 year | 3 years |
|---|---|---|---|---|
| **Pretrial** (return to pretrial detention) | 4.9% | 12.4% | 31.1% | — |
| **Sentenced** (return to sentenced custody) | 5.5% | 9.8% | 21.2% | 35.4% |

- **By offense (pretrial):** public order/obstruction (42%) and court/supervision violations (34%) have the highest one-year return rates; sexual offenses have the lowest (16%).
- **By bond (pretrial):** one-year returns fall from about 37% for bonds under \$20,000 to about 19% at \$500,000 or more.
- **By offense (sentenced):** property offenses have the highest return rates at one and three years; DUI/traffic has the lowest (9% at one year).
- **By release timing (sentenced):** early releases return at 29% within one year vs. 12% for releases at sentence end; at three years, 39% vs. 31%.
- **Timing of returns:** about 40% of three-year sentenced returns happen in years two and three, so one-year measures miss a large share of returns.

## What this suggests

These are descriptive findings and don't establish causes, but they point to questions worth acting on:

- **Court and supervision violations are a major driver of custody.** Tools that help people make court dates or meet supervision requirements could reduce detention without involving new charges.
- **The first year after early release is the highest-risk period.** The early-release gap narrows over time, consistent with returns driven by supervision violations. Support during the first year of supervision may have outsized impact.
- **High-bond detention is long detention.** Stays with bonds of \$100,000 or more are far more likely to last six months or longer, and the racial composition of high-bond stays warrants analysis within offense type and controlling for criminal history, which this data doesn't include.

## Limitations
- Returns are measured **within each population** only. A return to pretrial detention after a sentenced release isn't counted, and re-arrests that didn't lead to detention don't appear.
- A pretrial stay can end because the person was **sentenced** rather than released, which lowers measured pretrial readmission for groups more likely to be sentenced, such as those with high bonds.
- **Time served** counts only time in sentenced custody, starting at a person's first appearance in the sentenced data; pretrial time credited to the sentence isn't included.
- The **controlling offense** is the charge at the top of the mittimus at admission and may not be the most serious charge. About 40% of pretrial offense records have no class code in the source data.
- The data has **no criminal history, case outcome, or supervision status**, so differences between groups can't be attributed to any one cause.
- Small groups (under 18, Asian, American Indian) have less reliable rates.

## Next steps
- **Link pretrial and sentenced records** by identifier to build continuous custody episodes. This would separate pretrial stays that ended in release from those that ended in a sentence (a cleaner test of the bond finding) and measure return to **any** DOC custody.
- **Survival analysis** of time to return, which handles stays still under observation more fully than fixed windows.
- **Model bond amounts** within offense type and class to test whether racial differences persist after accounting for charge severity.
- **Automate data refreshes** from the Connecticut Open Data Portal API.

## Repository structure

```
connecticut-prison-analysis/
├── README.md
├── sql/            BigQuery queries, numbered in run order
├── notebooks/      Pretrial and sentenced readmission analysis (pandas)
└── crosswalks/     Offense and facility category mappings (CSV)
```

## Reproducing the analysis
1. Download both datasets from the Connecticut Open Data Portal and load them into BigQuery as raw tables.
2. Load the crosswalk CSVs from `crosswalks/` into BigQuery.
3. Run the SQL files in `sql/` in numbered order to build the cleaned, final daily, and stays tables.
4. Run the notebooks in `notebooks/` in Google Colab to calculate readmission and write the results back to BigQuery.
5. Connect Looker Studio to the final, stays, and readmission tables.

## Contact
Victoria · [github.com/viclynndls](https://github.com/viclynndls) · viclynndls@gmail.com
