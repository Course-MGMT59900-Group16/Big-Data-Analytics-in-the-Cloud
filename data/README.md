# U.S. Traffic Accident Analytics on AWS

**MGMT 59900 — Big Data Analytics in the Cloud | Purdue University | Summer 2026**  
**Group 16:** Hector Mora Cordero - Elhadi Adam Elomda

> A cloud analytics project that processes and analyzes 7.7 million U.S. traffic accident records using Amazon S3, AWS Glue, and Amazon Athena.

---

## Project at a Glance

| | |
|---|---|
| **Dataset** | U.S. Accidents (2016–2023) |
| **Records** | 7,728,394 |
| **Raw file size** | ~3.06 GB CSV |
| **Cloud platform** | AWS |
| **Core services** | Amazon S3 · AWS Glue · Amazon Athena |
| **Architecture** | Bronze → Silver → Gold |
| **Silver format** | Snappy-compressed Parquet |
| **Partitions** | `accident_year` + `state` |
| **Implemented Gold outputs** | `gold_accidents_by_state`, `gold_accidents_by_weather` |
| **ML-ready asset** | `ml_accident_features` Athena view |
| **Model training** | Not implemented; future extension |

The project focuses on **traffic-flow disruption**, not injury severity. In the source dataset, `Severity` is a 1–4 traffic-impact scale.

---

## Business Problem

Transportation agencies, planners, emergency-response teams, and insurers need scalable ways to understand:

- when reported accidents are most frequent;
- where high-impact disruptions are concentrated;
- which weather and roadway conditions are associated with higher traffic impact;
- how a cloud-native storage and query design can reduce processing cost.

Our goal was therefore twofold:

1. build a repeatable AWS analytics pipeline for a multi-million-row dataset; and  
2. use that pipeline to produce business-ready transportation insights.

---

## Architecture

![AWS architecture](architecture/aws_medallion_architecture.png)

### Implemented workflow

```text
U.S. Accidents CSV
        │
        ▼
Amazon S3 — Bronze
Raw CSV preserved
        │
        ├──────────────► AWS Glue Crawler / Data Catalog
        │
        ▼
AWS Glue ETL — PySpark
Cleaning + feature engineering
        │
        ▼
Amazon S3 — Silver
Snappy Parquet
partitioned by accident_year + state
        │
        ▼
Amazon Athena
SQL validation + analytics
        │
        ├──► gold_accidents_by_state
        ├──► gold_accidents_by_weather
        └──► ml_accident_features
```

### Planned extensions

The following were evaluated as next steps but are **not presented as completed implementation**:

- Amazon QuickSight dashboarding
- Amazon SageMaker classification experiment

---

## What We Built

### 1. Bronze Layer — Raw Data

The original U.S. Accidents CSV was uploaded to Amazon S3 and preserved unchanged.

```text
s3://mgmt599-group16-us-accidents/bronze/us_accidents/
```

Keeping the raw source intact gives us a reproducible starting point for reprocessing and validation.

### 2. Catalog — AWS Glue

An AWS Glue crawler discovered the Bronze schema and registered the source table:

```text
group16_accidents.bronze_us_accidents
```

The cataloged table was then available to both Glue and Athena.

### 3. Transformation — AWS Glue ETL

Our PySpark Glue job transformed Bronze into a curated Silver layer by:

- standardizing field names;
- parsing timestamps;
- deriving year, month, hour, and weekday features;
- creating validation indicators;
- creating the `high_impact` analytical target;
- converting CSV to Snappy-compressed Parquet;
- partitioning the output by `accident_year` and `state`.

### 4. Silver Layer — Curated Storage

```text
s3://mgmt599-group16-us-accidents/silver/us_accidents/
```

Example partition structure:

```text
silver/us_accidents/
└── accident_year=2019/
    └── state=FL/
        └── part-....snappy.parquet
```

### 5. Athena Analytics

Amazon Athena was used for:

- source validation;
- duplicate checks;
- missing-value profiling;
- coordinate validation;
- trend and seasonality analysis;
- day-of-week and hourly analysis;
- state and weather summaries;
- roadway-feature analysis;
- ML-readiness profiling.

### 6. Gold and ML-Ready Outputs

Implemented analytical outputs:

```text
gold_accidents_by_state
gold_accidents_by_weather
ml_accident_features
```

The two Gold tables contain reusable business summaries.  
`ml_accident_features` is an Athena view containing selected predictors and the binary `high_impact` target.

**No ML model was trained or deployed for this submission.**

---

## Data Quality Checks

Our Athena profiling produced the following results:

| Check | Result |
|---|---:|
| Total records | 7,728,394 |
| Duplicate IDs | 0 |
| Missing `start_time` | 0 |
| Missing `state` | 0 |
| Invalid starting coordinates | 0 |
| Missing precipitation | 2,203,586 (28.51%) |
| Missing weather condition | 173,459 (2.24%) |
| Missing visibility | 177,098 (2.29%) |
| Missing temperature | 163,853 (2.12%) |

We preserved missing precipitation values as `NULL` rather than assuming a missing measurement meant zero precipitation.

We also excluded 2023 from full-year trend comparisons because the source only contains January through March 2023.

---

## Main Analytical Results

### Reported Volume Over Time

Reported records increased from:

- **410,821 in 2016**
- to **1,762,452 in 2022**

This is a trend in **dataset record volume**, not an exposure-adjusted U.S. accident rate. The dataset does not provide a denominator such as vehicle miles traveled.

### Seasonal Pattern

| Season | Total Records | High-Impact % |
|---|---:|---:|
| Fall | 2,086,676 | 18.37% |
| Winter | 2,041,827 | 17.91% |
| Summer | 1,683,374 | **23.06%** |
| Spring | 1,669,884 | 21.54% |

**Interpretation:** Fall and winter have the largest volumes, but summer has the highest high-impact percentage.

### Day and Hour

- **Friday** has the highest day-level volume: **1,366,499**
- **Sunday** has the highest day-level high-impact percentage: **22.33%**
- **7 AM** has the highest hourly volume: **587,472**
- **4 PM** is another major commute-period peak: **581,969**
- **8 PM** has the highest hourly high-impact percentage: **21.51%**

### Geographic Findings

Among the high-volume states included in our Gold analysis:

| State | Total Records | High-Impact % |
|---|---:|---:|
| California | 1,741,433 | 16.38% |
| Florida | 880,192 | 13.32% |
| Texas | 582,837 | 21.90% |
| New York | 347,960 | 23.22% |
| Virginia | 303,301 | 22.92% |

### Roadway Associations

| Roadway Indicator | High-Impact % |
|---|---:|
| Junction | **26.79%** |
| Traffic Signal | 9.51% |
| Crossing | 7.04% |

These are **associations in the dataset** and should not be interpreted as causal effects.

---

## Cloud Engineering Result

One of the strongest technical outcomes was the reduction in Athena data scanned after moving from raw CSV to partitioned Parquet.

| Layer | Storage Design | Data Scanned in Representative Filter |
|---|---|---:|
| Bronze | CSV | 2.85 GB |
| Silver | Snappy Parquet + year/state partitions | 8.58 KB |

The documented Bronze-to-Silver Glue run completed in approximately **2 minutes 19 seconds using 10 DPUs**.

This demonstrates why the Silver design matters: columnar storage and partition pruning reduce unnecessary scan volume and improve cost efficiency.

---

## Repository Guide

```text
.
├── README.md
├── architecture/
│   ├── aws_medallion_architecture.png
│   └── aws_medallion_architecture.md
│
├── data/
│   └── README.md
│
├── docs/
│   ├── final_project_report.docx
│   ├── cost_and_cleanup.md
│   ├── generative_ai_use.md
│   └── presentation_README.md
│
├── evidence/
│   └── README.md
│
├── glue/
│   └── README.md
│
├── results/
│   ├── annual_trend.csv
│   ├── data_quality_summary.csv
│   ├── day_of_week_summary.csv
│   ├── hourly_summary.csv
│   ├── ml_target_distribution.csv
│   ├── roadway_summary.csv
│   ├── seasonal_summary.csv
│   ├── state_summary.csv
│   └── weather_summary.csv
│
└── sql/
    ├── 01_bronze_validation.sql
    ├── 02_data_quality_checks.sql
    ├── 03_silver_validation.sql
    ├── 04_trend_and_seasonality.sql
    ├── 05_day_hour_analysis.sql
    ├── 06_roadway_analysis.sql
    ├── 07_gold_layer_queries.sql
    └── 08_ml_readiness.sql
```

### Where to start

| If you want to review... | Open... |
|---|---|
| Overall project | `README.md` |
| Architecture | `architecture/` |
| SQL used in Athena | `sql/` |
| Verified summary outputs | `results/` |
| Glue transformation logic | `glue/README.md` |
| AWS screenshot/evidence guide | `evidence/README.md` |
| Full written report | `docs/final_project_report.docx` |
| Cost and cleanup approach | `docs/cost_and_cleanup.md` |
| Generative AI disclosure | `docs/generative_ai_use.md` |

---

## Reproducing the Workflow

### Prerequisites

To reproduce the AWS workflow, you need:

- an AWS account with access to Amazon S3, AWS Glue, and Amazon Athena;
- the U.S. Accidents source dataset;
- permissions to create S3 objects, Glue catalog resources, crawlers, and ETL jobs;
- an Athena query-results S3 location.

The raw dataset can be obtained from:

**Kaggle — U.S. Accidents (2016–2023)**  
https://www.kaggle.com/datasets/sobhanmoosavi/us-accidents/data

The ~3 GB source file and generated Parquet data are intentionally excluded from this repository.

### Step 1 — Load Bronze

Upload the raw CSV to an S3 Bronze prefix.

```text
s3://<your-bucket>/bronze/us_accidents/
```

### Step 2 — Catalog Bronze

Create and run an AWS Glue crawler against the Bronze prefix.

Expected logical table:

```text
bronze_us_accidents
```

### Step 3 — Validate Bronze

Run:

```text
sql/01_bronze_validation.sql
sql/02_data_quality_checks.sql
```

These queries validate record count, ID uniqueness, missing values, coordinate ranges, and source-year coverage.

### Step 4 — Run Bronze-to-Silver ETL

Configure the Glue PySpark job using the transformation logic documented in:

```text
glue/README.md
```

Write the output as Snappy Parquet partitioned by:

```text
accident_year
state
```

### Step 5 — Validate Silver

Run:

```text
sql/03_silver_validation.sql
```

### Step 6 — Run the Analytics

Use the remaining Athena SQL scripts:

```text
04_trend_and_seasonality.sql
05_day_hour_analysis.sql
06_roadway_analysis.sql
07_gold_layer_queries.sql
08_ml_readiness.sql
```

The small CSV files in `results/` contain the verified summary values used in our report and presentation.

---

## How to Interpret the Results

A few interpretation rules are important:

1. **Counts are not national accident rates.**  
   We analyzed records present in the dataset. We did not normalize by population, registered vehicles, or vehicle miles traveled.

2. **2023 is a partial year.**  
   Full-year trend comparisons use 2016–2022.

3. **Severity means traffic impact.**  
   The source `Severity` field does not represent injury severity.

4. **High impact is an analytical target.**  
   We define:
   - Severity 1–2 → `high_impact = 0`
   - Severity 3–4 → `high_impact = 1`

5. **Association does not imply causation.**  
   Weather, time, state, and roadway findings describe patterns in the observed data.

6. **The ML view is preparation, not a completed model.**  
   The target distribution is 80.54% lower impact and 19.46% high impact. No classifier was trained for the final project.

---

## Cost and Cleanup

The implemented stack was intentionally serverless and on demand.

Cost controls included:

- Parquet instead of repeatedly scanning CSV;
- year/state partitioning;
- Glue jobs run only when needed;
- Athena on demand;
- no production ML endpoint;
- no required QuickSight deployment.

See [`docs/cost_and_cleanup.md`](docs/cost_and_cleanup.md) for the project-scale estimate and cleanup plan.

---

## Limitations and Future Work

Current limitations include:

- incomplete weather measurements;
- partial-year 2023 coverage;
- no population or traffic-exposure denominator;
- observational associations rather than causal inference;
- an imbalanced ML-ready target;
- no trained ML model.

Potential next steps:

- QuickSight geographic and KPI dashboard;
- a small SageMaker classification experiment;
- exposure-aware normalization using population or vehicle-miles-traveled data;
- scheduled data-quality validation;
- incremental ingestion and orchestration.

---

## Generative AI Use

We used generative AI tools, including ChatGPT and Microsoft Copilot, along with Grammarly, to assist with brainstorming, AWS troubleshooting, SQL refinement, interpretation support, and editing.

All AWS configurations, Glue runs, Athena queries, outputs, and final conclusions were reviewed and verified by our group.

See [`docs/generative_ai_use.md`](docs/generative_ai_use.md).

---

## Authors

**Group 16**

**Hector Mora Cordero**  
**Elhadi Adam Elomda**

MGMT 59900 — Big Data Analytics in the Cloud  
Purdue University · Summer 2026
