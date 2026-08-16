# Cloud-Based Analysis of U.S. Traffic Accident Patterns

MGMT 59900: Big Data Analytics in the Cloud  
Purdue University — Summer 2026  
Group 16: Hector Mora Cordero and Elhadi Adam Elomda

## Project Overview

For this project, we built a cloud analytics pipeline for the U.S. Accidents dataset using a Bronze-Silver-Gold approach on AWS. The dataset contains 7,728,394 reported traffic-accident records from February 2016 through March 2023.

Our main goal was to show how a cloud-native pipeline can preserve the raw source, validate and transform the data, reduce query scan volume, and produce repeatable analytical outputs for transportation-related questions.

We focused on reported accident volume and traffic-flow impact. In this dataset, `Severity` represents traffic disruption (levels 1-4), not injury severity.

## Business Questions

We used the pipeline to support the following questions:

1. How did reported accident volume change over time?
2. Are there seasonal patterns in accident volume and high-impact disruption?
3. Which days of the week and hours of the day have the highest volume or high-impact percentage?
4. Which geographic, weather, and roadway conditions are associated with higher traffic impact?
5. How much query-efficiency improvement can we get from Parquet and partitioning?

## Dataset

- **Source:** U.S. Accidents (2016-2023), Kaggle
- **Records:** 7,728,394
- **Coverage:** February 2016 through March 2023
- **Geographic coverage:** 49 U.S. states
- **Source attributes:** 46
- **Raw source file:** approximately 3.06 GB CSV

The raw dataset is not stored in this repository because of its size. See [`data/README.md`](data/README.md) for the source and expected S3 layout.

## AWS Architecture

![Implemented AWS Medallion Architecture](architecture/aws_medallion_architecture.png)

### What we implemented

```text
U.S. Accidents CSV
        |
        v
Amazon S3 - Bronze
        |
        v
AWS Glue Crawler / Data Catalog
        |
        v
AWS Glue ETL (PySpark)
        |
        v
Amazon S3 - Silver
Snappy Parquet
partitioned by accident_year and state
        |
        v
Amazon Athena
        |
        +--> Gold: gold_accidents_by_state
        |
        +--> Gold: gold_accidents_by_weather
        |
        +--> ML readiness: ml_accident_features
```

### Planned extensions

QuickSight dashboarding and SageMaker model training were considered future extensions. They are not presented as completed implementation in this repository.

## AWS Services Used

| Service | How we used it |
|---|---|
| Amazon S3 | Bronze raw storage, Silver Parquet storage, Gold analytical outputs, Athena query results |
| AWS Glue Crawler / Data Catalog | Schema discovery and table registration |
| AWS Glue ETL | Bronze-to-Silver PySpark transformation |
| Amazon Athena | Validation, data-quality checks, analytics queries, Gold-table analysis, and ML-ready feature view |

## Data Pipeline

### Bronze

We preserved the original CSV unchanged in S3 so we could keep traceability and reprocess from the original source if needed.

Example location:

```text
s3://mgmt599-group16-us-accidents/bronze/us_accidents/
```

### Silver

The Glue ETL job created the cleaned analytical dataset in Snappy-compressed Parquet. We partitioned it by:

```text
accident_year/
    state/
```

The transformation included:

- standardized column names;
- timestamp parsing;
- temporal features such as year, month, hour, and weekday;
- validation indicators;
- a binary `high_impact` field where Severity 3-4 = 1 and Severity 1-2 = 0;
- Parquet conversion and Snappy compression.

### Gold

We implemented two business-ready analytical summaries:

- `gold_accidents_by_state`
- `gold_accidents_by_weather`

These support geographic and weather-related analysis without repeatedly scanning the full Silver dataset.

### ML Readiness

We also created:

```text
ml_accident_features
```

This Athena view organizes selected temporal, geographic, weather, and roadway features with the `high_impact` target.

No classifier was trained for the final submission. The view was created to show that the pipeline can produce model-ready data for a future experiment.

## Data Quality Findings

Our Athena profiling found:

- **7,728,394 total records**
- **0 duplicate IDs**
- **0 invalid starting coordinate records in the range check**
- **0 missing `start_time`**
- **0 missing `state`**
- **2,203,586 missing precipitation values (28.51%)**
- **173,459 missing weather-condition values (2.24%)**
- **177,098 missing visibility values (2.29%)**
- **163,853 missing temperature values (2.12%)**

We preserved missing precipitation as `NULL` rather than forcing missing measurements to zero.

We also excluded partial-year 2023 from full-year trend comparisons because the dataset only includes January through March 2023.

## Key Findings

### Trend

Reported records increased from **410,821 in 2016** to **1,762,452 in 2022**.

We interpret this as a trend in dataset record volume, not a population- or exposure-adjusted national accident rate.

### Seasonality

- Fall: 2,086,676 records; 18.37% high impact
- Winter: 2,041,827 records; 17.91% high impact
- Summer: 1,683,374 records; **23.06% high impact**
- Spring: 1,669,884 records; 21.54% high impact

Fall and winter have the highest volume, while summer has the highest high-impact percentage.

### Day and Hour

- Friday has the highest day-level volume: **1,366,499**
- Sunday has the highest day-level high-impact percentage: **22.33%**
- 7 AM has the highest hourly volume: **587,472**
- 4 PM is also a major commute-hour peak: **581,969**
- 8 PM has the highest hourly high-impact percentage: **21.51%**

### Geographic

Among the high-volume states shown in our Gold analysis:

- California: 1,741,433 records; 16.38% high impact
- Florida: 880,192; 13.32%
- Texas: 582,837; 21.90%
- New York: 347,960; 23.22%
- Virginia: 303,301; 22.92%

### Roadway Associations

For the roadway indicators we compared:

- Junction: **26.79% high impact**
- Traffic Signal: 9.51%
- Crossing: 7.04%

These results show associations in the dataset and do not establish causation.

## Cloud Performance

One of the clearest engineering results came from comparing a filtered Athena query against Bronze and Silver:

| Layer | Format | Data scanned |
|---|---|---:|
| Bronze | CSV | 2.85 GB |
| Silver | Snappy Parquet + year/state partitions | 8.58 KB |

This representative test demonstrates the value of columnar storage and partition pruning for both query efficiency and cost control.

The Glue Bronze-to-Silver run used 10 DPUs and completed in about 2 minutes 19 seconds in the run we documented.

## Repository Structure

```text
.
├── README.md
├── architecture/
│   ├── aws_medallion_architecture.png
│   └── aws_medallion_architecture.md
├── data/
│   └── README.md
├── docs/
│   ├── final_project_report.docx
│   ├── generative_ai_use.md
│   └── cost_and_cleanup.md
├── evidence/
│   └── README.md
├── glue/
│   └── README.md
├── results/
│   ├── annual_trend.csv
│   ├── seasonal_summary.csv
│   ├── day_of_week_summary.csv
│   ├── hourly_summary.csv
│   ├── roadway_summary.csv
│   ├── state_summary.csv
│   ├── weather_summary.csv
│   └── data_quality_summary.csv
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

## Reproducing the Main Workflow

These steps summarize the workflow we used in AWS.

1. Upload the U.S. Accidents CSV to the S3 Bronze prefix.
2. Run an AWS Glue crawler over the Bronze location.
3. Confirm `bronze_us_accidents` in the Glue Data Catalog.
4. Run the Bronze-to-Silver Glue PySpark ETL job.
5. Store the Silver data as Snappy-compressed Parquet partitioned by `accident_year` and `state`.
6. Catalog/query `silver_us_accidents`.
7. Run the SQL scripts in the [`sql/`](sql/) folder from Amazon Athena.
8. Use the resulting Gold tables and analytical outputs for the final findings.

The SQL files include comments explaining why we ran each query and what we were validating.

## Cost Control and Cleanup

We kept the project small and serverless:

- S3 for storage;
- Glue jobs only when needed;
- Athena on demand;
- Parquet and partitioning to reduce data scanned;
- no production ML endpoint;
- QuickSight not required for the implemented stack.

After the project, unused Glue jobs/crawlers and exploratory SageMaker resources should be removed if they are no longer needed.

See [`docs/cost_and_cleanup.md`](docs/cost_and_cleanup.md).

## Limitations

- The annual and state values are dataset record counts, not exposure-adjusted accident rates.
- 2023 is a partial year.
- Weather fields contain missing measurements.
- The analysis identifies associations, not causal effects.
- `Severity` represents traffic-flow disruption rather than injury severity.
- The ML-ready target is imbalanced: 80.54% lower impact and 19.46% high impact.
- We did not train or deploy an ML model for the final submission.

## Future Work

Possible next steps include:

- QuickSight geographic and KPI dashboard;
- a small SageMaker classification experiment using `ml_accident_features`;
- additional exposure data such as vehicle miles traveled or population;
- automated data-quality checks;
- incremental ingestion and orchestration.

## Generative AI Use

We used generative AI tools, including ChatGPT and Microsoft Copilot, along with Grammarly for editing support. We used these tools for brainstorming, AWS troubleshooting, SQL/query refinement, interpretation support, and writing/editing assistance.

We manually reviewed the suggestions and verified the AWS configurations, Glue runs, Athena queries, and analytical results against the work we actually completed.

See [`docs/generative_ai_use.md`](docs/generative_ai_use.md).

## Authors

**Group 16**

- Hector Mora Cordero
- Elhadi Adam Elomda

MGMT 59900: Big Data Analytics in the Cloud  
Purdue University, Summer 2026
