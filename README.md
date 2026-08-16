# Big-Data-Analytics-in-the-Cloud
Cloud-Based Analysis of U.S. Traffic Accident Patterns
**Project Overview:** 
This project delivers a cloud-native, end-to-end big data pipeline designed to analyze U.S. traffic accident data at scale, leveraging the full breadth of the AWS ecosystem. The primary goal is to transform raw accident records into actionable intelligence covering accident severity, geographic distribution, temporal patterns, and the influence of weather and road conditions on crash outcomes. The analysis is grounded in the US Accidents dataset (Kaggle / Sobhan Moosavi et al.), comprising approximately 7.7 million records spanning 49 U.S. states from 2016 to 2023 across 46 feature columns. The pipeline progresses through four well-defined phases — raw data ingestion into Amazon S3, distributed ETL transformation via AWS Glue (PySpark), serverless SQL querying with Amazon Athena, and interactive visualization through Amazon QuickSight — culminating in a reproducible, scalable analytical platform suitable for academic evaluation, operational deployment, and further extension.

**Dataset**
The dataset used in this project is the U.S. Accidents (2016–2023) dataset, a large-scale nationwide traffic incident repository containing 7,728,394 accident records collected from February 2016 through March 2023. It provides a comprehensive view of roadway incidents across 49 U.S. states, capturing detailed information on accident severity, timestamps, geographic coordinates, roadway characteristics, and weather conditions. The dataset was originally published on Kaggle and aggregates real-time traffic incident feeds from multiple APIs, including:
  o	State Departments of Transportation
  o	U.S. Department of Transportation
  o	Law enforcement agencies
  o	Traffic cameras
  o	Roadway sensors embedded throughout the national road network
This multi-source integration ensures broad coverage and high temporal resolution, making the dataset suitable for large-scale analytics and cloud-based processing.

**Data Attributes**
The dataset contains 46 attributes, each contributing to a multidimensional understanding of accident conditions:
Table 1: Data Attributes
Identifiers:	Accident ID (unique identifier)
Spatial Fields:	Start_Lat, Start_Lng (geographic coordinates)
Temporal Fields:	Start_Time, End_Time, accident_year, accident_month, accident_hour, accident_weekday
Environmental Variables:	Temperature (°F), Visibility (mi), Wind_Speed (mph), Weather_Condition, Precipitation
Roadway Features:	Junction, Traffic_Signal, Crossing, Roundabout, Railway
Severity:	Severity (1–4 scale measuring traffic disruption)
Additional Features:	Twilight indicators, amenity markers, airport, bump, stop sign

**Cloud Ingestion Strategy**
To support the project's analytical goals, the raw CSV files were ingested into a cloud-native medallion architecture built on Amazon Web Services (AWS):
1.	Bronze Layer: Raw CSV files loaded into Amazon S3 and preserved in their original form
2.	Silver Layer: Transformed into cleaned and enriched Parquet format, partitioned by accident year and state
3.	Gold Layer: Pre-aggregated analytical tables optimized for business intelligence queries
4.	
**Data Quality Validation**
During validation, the project confirmed:
•	Zero duplicate IDs across all 7.7 million records, ensuring primary-key integrity
•	Complete geographic fields with valid starting coordinates
•	Complete temporal fields (start_time and state) across all records
•	28.5% missing precipitation values, intentionally preserved as NULL rather than imputed to avoid distorting weather-related analyses
•	Partial year 2023 (only January–March), excluded from year-over-year comparisons
This dataset serves as the foundation for identifying meaningful patterns in U.S. traffic accidents, ultimately contributing to safer and more resilient transportation systems nationwide

**Architecture diagram**
The following architecture illustrates the end-to-end AWS medallion pipeline used to process the U.S. Accidents dataset and transform 7.7 million raw records into analytics-ready insights.
Figure 1: Medallion Architecture Implementation: Ingestion to Visualization
<img width="841" height="443" alt="image" src="https://github.com/user-attachments/assets/92a8d342-f07f-4503-84d5-4872465e3b6c" />
The raw CSV dataset is uploaded to the S3 Raw Bucket, where a Glue Crawler catalogs its schema into the AWS Glue Data Catalog. The registered AWS Glue ETL job — written in PySpark — reads from the raw bucket, performs cleaning, standardization, and feature engineering, and writes columnar Parquet output partitioned by state and year to the S3 Processed Bucket. A second Glue Crawler refreshes the Data Catalog to reflect new partitions, making them immediately queryable in Amazon Athena using standard SQL—no infrastructure to provision. Analytical results and aggregated query outputs are connected to Amazon QuickSight for dashboard-level visualization. Glue Workflows and Triggers automate the entire pipeline, and all job logs and metrics stream to AWS CloudWatch for observability and alerting.

**Project Structure**
us-traffic-accident-analysis/
├── data/
│   └── raw/                        # Original dataset (not tracked in git)
├── glue_jobs/
│   ├── etl_clean_transform.py      # Main Glue PySpark ETL job
│   ├── feature_engineering.py      # Derived feature creation
│   └── partition_writer.py         # Writes partitioned Parquet to S3
├── athena/
│   ├── create_tables.sql           # DDL for Athena external tables
│   ├── analysis_queries.sql        # Key analytical SQL queries
│   └── views.sql                   # Reusable Athena views
├── notebooks/
│   ├── eda.ipynb                   # Exploratory data analysis
│   └── visualizations.ipynb        # Local chart prototyping
├── quicksight/
│   └── dashboard_config.json       # QuickSight dataset/analysis config
├── infrastructure/
│   ├── s3_setup.sh                 # S3 bucket creation script
│   ├── glue_setup.py               # Glue crawler and job registration
│   └── iam_policies.json           # Least-privilege IAM role policies
├── tests/
│   └── test_etl.py                 # Unit tests for ETL logic
├── requirements.txt
├── README.md
└── .gitignore

**Key Analytical Questions**
1- Severity Distribution — What proportion of accidents fall into each severity tier (1–4), and how does the distribution vary across states and years?
2- Geographic Hotspots — Which states and cities exhibit the highest accident rates per capita, and do hotspots persist across multiple years?
3- Temporal Patterns — How do accident frequencies vary by hour of day, day of week, and month or season, and what drives peak periods?
4- Weather Impact — Which weather conditions (e.g., fog, ice, rain) correlate most strongly with high-severity accidents, controlling for exposure?
5- Road Feature Correlation — Do the presence of junctions, crossings, and traffic signals meaningfully increase or decrease accident severity outcomes?
6- Year-over-Year Trends — How has the national accident rate and average severity evolved from 2016 to 2023, and what inflection points are observable?

**ETL Pipeline Details**

**1- Data Ingestion**
Upload the raw CSV file (US_Accidents_March23.csv) to the designated S3 Raw Bucket using the AWS CLI or the S3 console.
A Glue Crawler is configured to scan the raw bucket and automatically infer and register the schema in the AWS Glue Data Catalog, making the dataset immediately accessible to downstream Glue jobs and Athena.

**Cleaning & Transformation (PySpark / AWS Glue)**

1- Drop all records where Severity, Start_Time, or State are null, as these are non-negotiable fields for all analytical queries.
2- Standardize timestamp fields: parse Start_Time and End_Time to UTC, then extract derived columns: hour, day_of_week, month, and year.
3- Normalize free-text fields: apply .trim().lower() to Weather_Condition and City, then map common variant spellings to canonical values (e.g., "Light Rain" → "light rain").
4- Cast all boolean road-feature columns (Junction, Traffic_Signal, Crossing, etc.) from string to native boolean type.
5- Filter dataset to the contiguous 48 states plus DC; exclude Alaska, Hawaii, and any unrecognized state codes.

**Feature Engineering**

1- duration_minutes — Computed as the difference between End_Time and Start_Time in minutes; records with negative durations are flagged and excluded.
2- is_rush_hour — Boolean flag set to TRUE for accidents occurring between 6–9 AM or 4–7 PM on weekdays.
3- severity_label — Human-readable string mapped from the ordinal scale: 1 → Low, 2 → Moderate, 3 → High, 4 → Critical.
4- season — Derived from month: Winter (Dec–Feb), Spring (Mar–May), Summer (Jun–Aug), Fall (Sep–Nov).

**Output**

- Write the transformed dataset to the S3 Processed Bucket in Parquet format, partitioned by state then year (e.g., s3://processed-bucket/accidents/state=CA/year=2022/).
- A second Glue Crawler runs post-ETL to update the Data Catalog with all new partitions, ensuring Athena queries immediately reflect the latest data without requiring manual partition registration.
  
**Sample Athena Queries**
  
**- Top 10 States by Accident Count**
SELECT state, COUNT(*) AS accident_count
FROM accidents_processed
GROUP BY state
ORDER BY accident_count DESC
LIMIT 10;

**- Hourly Accident Distribution**
SELECT hour, COUNT(*) AS accidents,
       ROUND(AVG(CAST(severity AS DOUBLE)), 2) AS avg_severity
FROM accidents_processed
GROUP BY hour
ORDER BY hour;

**- Weather Condition vs. High Severity**
SELECT weather_condition,
       COUNT(*) AS total,
       SUM(CASE WHEN severity >= 3 THEN 1 ELSE 0 END) AS high_severity,
       ROUND(100.0 * SUM(CASE WHEN severity >= 3 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_high
FROM accidents_processed
WHERE weather_condition IS NOT NULL
GROUP BY weather_condition
ORDER BY pct_high DESC
LIMIT 15;

**QuickSight Dashboard**
The Amazon QuickSight dashboard serves as the primary analytical interface for non-technical stakeholders and executive audiences. It is connected directly to the Athena data source and refreshes automatically upon pipeline completion. The dashboard is composed of the following components:

- **Component and	Description**
- KPI Cards:	Total Accidents, Average Severity, Most Affected State, and Peak Hour of Day — displayed as large-format summary tiles at the top of the dashboard.
- Choropleth Map:	Geospatial heat map of accident density by state, color-coded from low (light) to high (dark navy) frequency.
- Bar Charts:	Top 20 cities ranked by total accidents; stacked bar chart showing severity breakdown (1–4) per state.
- Line Charts:	Monthly accident trend from 2016 to 2023; year-over-year comparison overlay for multi-year analysis.
- Heat Map:	Two-dimensional grid of hour of day (rows) vs. day of week (columns) showing accident frequency intensity.
- Interactive Filters:	State, Year, Severity (multi-select), and Weather Condition — applied globally across all dashboard visuals.
- 
**-Setup & Deployment**
-** Prerequisites**
- Active AWS account with IAM permissions for S3, Glue, Athena, QuickSight, and CloudWatch.
- Python 3.8+ with the following packages: boto3, pyspark, pandas, pyarrow.
- AWS CLI installed and configured via aws configure with appropriate access key and region.
- Kaggle API access to download the US Accidents dataset.
- 
**- Deployment Steps**
  
- Clone the repository — Execute git clone https://github.com/username/us-traffic-accident-analysis.git and navigate into the project directory.
- Download dataset — Obtain US_Accidents_March23.csv from Kaggle and place it in data/raw/ (this directory is excluded from version control via .gitignore).
- Create S3 buckets — Run bash infrastructure/s3_setup.sh to provision and configure the raw and processed S3 buckets with appropriate policies.
- Register Glue jobs — Run python infrastructure/glue_setup.py to register Glue crawlers, upload PySpark job scripts to S3, and create Glue job definitions.
- Run ETL job — Trigger the ETL job from the AWS Glue console or via CLI: aws glue start-job-run --job-name etl_clean_transform.
- Query with Athena — Open the Athena console, execute athena/create_tables.sql to register external tables, then run queries from athena/analysis_queries.sql.
- Connect QuickSight — In the QuickSight console, create a new Athena data source pointing to the accidents_processed table; import or recreate the dashboard using quicksight/dashboard_config.json.
Technologies Used

**Technology	Role in Project**
- Python 3.10	ETL scripting, infrastructure automation, and Jupyter notebooks
- Apache Spark (PySpark)	Distributed data transformation at scale within AWS Glue runtime
- AWS S3	Durable object storage for raw CSV input and processed Parquet output
- AWS Glue	Serverless ETL orchestration, Crawler-based schema discovery, and Data Catalog management
- Amazon Athena	Serverless, pay-per-query SQL analytics engine over S3-resident Parquet files
- Amazon QuickSight	Cloud-native BI and dashboarding platform for interactive visual analytics
- AWS CloudWatch	Centralized monitoring, structured logging, and threshold-based alerting for Glue jobs
- AWS IAM	Granular access control and least-privilege security for all AWS service interactions
- Parquet	Columnar storage format enabling predicate pushdown and efficient compression on S3
- SQL	Ad-hoc analytical querying and view creation within Amazon Athena
  
**Technologies Used**
  
**- Technology	Role in Project**
- Python 3.10	ETL scripting, infrastructure automation, and Jupyter notebooks
- Apache Spark (PySpark)	Distributed data transformation at scale within AWS Glue runtime
- AWS S3	Durable object storage for raw CSV input and processed Parquet output
- AWS Glue	Serverless ETL orchestration, Crawler-based schema discovery, and Data Catalog management
- Amazon Athena	Serverless, pay-per-query SQL analytics engine over S3-resident Parquet files
- Amazon QuickSight	Cloud-native BI and dashboarding platform for interactive visual analytics
- AWS CloudWatch	Centralized monitoring, structured logging, and threshold-based alerting for Glue jobs
- AWS IAM	Granular access control and least-privilege security for all AWS service interactions
- Parquet	Columnar storage format enabling predicate pushdown and efficient compression on S3
- SQL	Ad-hoc analytical querying and view creation within Amazon Athena
  
**Future Enhancements**
- Real-Time Streaming Integration — Integrate live traffic incident feeds via AWS Kinesis Data Streams and Kinesis Data Firehose to enable near-real-time accident alerting and streaming analytics alongside the historical batch pipeline.
- ML Severity Prediction — Train a supervised classification model to predict accident severity at the time of incident using weather, location, and road feature inputs, leveraging Amazon SageMaker for training, tuning, and endpoint hosting.
- Reverse Geocoding Enrichment — Apply reverse geocoding (e.g., via AWS Location Service or HERE API) to convert raw coordinates into enriched county, zip code, and congressional district metadata for finer-grained spatial analysis.
- Automated Data Quality Checks — Embed pre- and post-ETL data quality validation using AWS Deequ or Great Expectations to enforce schema contracts, detect anomalies, and prevent corrupt data from reaching the processed layer.
- Managed Workflow Orchestration — Migrate pipeline scheduling to Apache Airflow on Amazon MWAA (Managed Workflows for Apache Airflow) for richer DAG-based dependency management, retry logic, and cross-service orchestration beyond what Glue Triggers support natively.
- REST API Exposure — Expose curated Athena query results and aggregated metrics through a REST API built on AWS Lambda and Amazon API Gateway, enabling programmatic access for third-party applications, mobile dashboards, and external research consumers.
