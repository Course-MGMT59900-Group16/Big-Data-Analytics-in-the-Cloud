# Big-Data-Analytics-in-the-Cloud
Cloud-Based Analysis of U.S. Traffic Accident Patterns

**Project Overview:** 

This project delivers a cloud-native, end-to-end big data pipeline designed to analyze U.S. traffic accident data at scale, leveraging the full breadth of the AWS ecosystem. The primary goal is to transform raw accident records into actionable intelligence covering accident severity, geographic distribution, temporal patterns, and the influence of weather and road conditions on crash outcomes. The analysis is grounded in the US Accidents dataset (Kaggle / Sobhan Moosavi et al.), comprising approximately 7.7 million records spanning 49 U.S. states from 2016 to 2023 across 46 feature columns. The pipeline progresses through four well-defined phases that include raw data ingestion into Amazon S3, distributed ETL transformation via AWS Glue (PySpark), serverless SQL querying with Amazon Athena, and interactive visualization through Amazon QuickSight, culminating in a reproducible, scalable analytical platform suitable for academic evaluation, operational deployment, and further extension.
  
**Setup & Deployment: Prerequisites**
- Active AWS account with IAM permissions for S3, Glue, Athena, QuickSight, and CloudWatch.
- Python 3.8+ with the following packages: boto3, pyspark, pandas, pyarrow.
- AWS CLI installed and configured via aws configure with appropriate access key and region.
- Kaggle API access to download the US Accidents dataset.
  
**Deployment Steps**
  
- Clone the repository: Execute git clone https://github.com/username/us-traffic-accident-analysis.git and navigate into the project directory.
- Download dataset: Obtain US_Accidents_March23.csv from Kaggle and place it in data/raw/ (this directory is excluded from version control via .gitignore).
- Create S3 buckets: Run bash infrastructure/s3_setup.sh to provision and configure the raw and processed S3 buckets with appropriate policies.
- Register Glue jobs: Run python infrastructure/glue_setup.py to register Glue crawlers, upload PySpark job scripts to S3, and create Glue job definitions.
- Run ETL job: Trigger the ETL job from the AWS Glue console or via CLI: aws glue start-job-run --job-name etl_clean_transform.
- Query with Athena: Open the Athena console, execute athena/create_tables.sql to register external tables, then run queries from athena/analysis_queries.sql.
- Connect QuickSight: In the QuickSight console, create a new Athena data source pointing to the accidents_processed table; import or recreate the dashboard using quicksight/dashboard_config.json.

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
  
**QuickSight Dashboard**

The Amazon QuickSight dashboard serves as the primary analytical interface for non-technical stakeholders and executive audiences. It is connected directly to the Athena data source and refreshes automatically upon pipeline completion. The dashboard is composed of the following components:

**Component and	Description**
- KPI Cards:	Total Accidents, Average Severity, Most Affected State, and Peak Hour of Day — displayed as large-format summary tiles at the top of the dashboard.
- Choropleth Map:	Geospatial heat map of accident density by state, color-coded from low (light) to high (dark navy) frequency.
- Bar Charts:	Top 20 cities ranked by total accidents; stacked bar chart showing severity breakdown (1–4) per state.
- Line Charts:	Monthly accident trend from 2016 to 2023; year-over-year comparison overlay for multi-year analysis.
- Heat Map:	Two-dimensional grid of hour of day (rows) vs. day of week (columns) showing accident frequency intensity.
- Interactive Filters:	State, Year, Severity (multi-select), and Weather Condition — applied globally across all dashboard visuals.
  
**Dataset**

The dataset used in this project is the U.S. Accidents (2016–2023) dataset, a large-scale nationwide traffic incident repository containing 7,728,394 accident records collected from February 2016 through March 2023. It provides a comprehensive view of roadway incidents across 49 U.S. states, capturing detailed information on accident severity, timestamps, geographic coordinates, roadway characteristics, and weather conditions. The dataset was originally published on Kaggle and aggregates real-time traffic incident feeds from multiple APIs, including:

  -	State Departments of Transportation
  -	U.S. Department of Transportation
  -	Law enforcement agencies
  -	Traffic cameras
  -	Roadway sensors embedded throughout the national road network
  
This multi-source integration ensures broad coverage and high temporal resolution, making the dataset suitable for large-scale analytics and cloud-based processing.

**Data Attributes**

The dataset contains 46 attributes, each contributing to a multidimensional understanding of accident conditions:
 
1. Identifiers:	Accident ID (unique identifier)
2. Spatial Fields:	Start_Lat, Start_Lng (geographic coordinates)
3. Temporal Fields:	Start_Time, End_Time, accident_year, accident_month, accident_hour, accident_weekday
4. Environmental Variables:	Temperature (°F), Visibility (mi), Wind_Speed (mph), Weather_Condition, Precipitation
5. Roadway Features:	Junction, Traffic_Signal, Crossing, Roundabout, Railway
6. Severity:	Severity (1–4 scale measuring traffic disruption)
7. Additional Features:	Twilight indicators, amenity markers, airport, bump, stop sign

**Cloud Ingestion Strategy**

To support the project's analytical goals, the raw CSV files were ingested into a cloud-native medallion architecture built on Amazon Web Services (AWS):

1.	Bronze Layer: Raw CSV files loaded into Amazon S3 and preserved in their original form
2.	Silver Layer: Transformed into cleaned and enriched Parquet format, partitioned by accident year and state
3.	Gold Layer: Pre-aggregated analytical tables optimized for business intelligence queries
   
**Data Quality Validation, During validation, the project confirmed**:
- Zero duplicate IDs across all 7.7 million records, ensuring primary-key integrity
-	Complete geographic fields with valid starting coordinates
-	Complete temporal fields (start_time and state) across all records
-	28.5% missing precipitation values, intentionally preserved as NULL rather than imputed to avoid distorting weather-related analyses
-	Partial year 2023 (only January–March), excluded from year-over-year comparisons

This dataset serves as the foundation for identifying meaningful patterns in U.S. traffic accidents, ultimately contributing to safer and more resilient transportation systems nationwide

**Architecture diagram**

The following architecture illustrates the end-to-end AWS medallion pipeline used to process the U.S. Accidents dataset and transform 7.7 million raw records into analytics-ready insights.

- Medallion Architecture Implementation: Ingestion to Visualization
  
<img width="841" height="443" alt="image" src="https://github.com/user-attachments/assets/92a8d342-f07f-4503-84d5-4872465e3b6c" />

The raw CSV dataset is uploaded to the S3 Raw Bucket, where a Glue Crawler catalogs its schema into the AWS Glue Data Catalog. The registered AWS Glue ETL job — written in PySpark — reads from the raw bucket, performs cleaning, standardization, and feature engineering, and writes columnar Parquet output partitioned by state and year to the S3 Processed Bucket. A second Glue Crawler refreshes the Data Catalog to reflect new partitions, making them immediately queryable in Amazon Athena using standard SQL—no infrastructure to provision. Analytical results and aggregated query outputs are connected to Amazon QuickSight for dashboard-level visualization. Glue Workflows and Triggers automate the entire pipeline, and all job logs and metrics stream to AWS CloudWatch for observability and alerting.

End-to-End AWS Serverless Data Pipeline for US Accidents Analytics

<img width="769" height="693" alt="image" src="https://github.com/user-attachments/assets/ee7ee479-dd32-44d0-adc1-dba03bd7f78f" />

**Project Structure**
- us-traffic-accident-analysis/
- ├── data/
- │   └── raw/                        # Original dataset (not tracked in git)
- ├── glue_jobs/
- │   ├── etl_clean_transform.py      # Main Glue PySpark ETL job
- │   ├── feature_engineering.py      # Derived feature creation
- │   └── partition_writer.py         # Writes partitioned Parquet to S3
- ├── athena/
- │   ├── create_tables.sql           # DDL for Athena external tables
- │   ├── analysis_queries.sql        # Key analytical SQL queries
- │   └── views.sql                   # Reusable Athena views
- ├── notebooks/
- │   ├── eda.ipynb                   # Exploratory data analysis
- │   └── visualizations.ipynb        # Local chart prototyping
- ├── quicksight/
- │   └── dashboard_config.json       # QuickSight dataset/analysis config
- ├── infrastructure/
- │   ├── s3_setup.sh                 # S3 bucket creation script
- │   ├── glue_setup.py               # Glue crawler and job registration
- │   └── iam_policies.json           # Least-privilege IAM role policies
- ├── tests/
- │   └── test_etl.py                 # Unit tests for ETL logic
- ├── requirements.txt
- ├── README.md
- └── .gitignore

**Key Analytical Questions**
1. Severity Distribution: What proportion of accidents fall into each severity tier (1–4), and how does the distribution vary across states and years?
2. Geographic Hotspots: Which states and cities exhibit the highest accident rates per capita, and do hotspots persist across multiple years?
3. Temporal Patterns: How do accident frequencies vary by hour of day, day of week, and month or season, and what drives peak periods?
4. Weather Impact: Which weather conditions (e.g., fog, ice, rain) correlate most strongly with high-severity accidents, controlling for exposure?
5. Road Feature Correlation: Do the presence of junctions, crossings, and traffic signals meaningfully increase or decrease accident severity outcomes?
6. Year-over-Year Trends: How has the national accident rate and average severity evolved from 2016 to 2023, and what inflection points are observable?

**ETL Pipeline Details**

**Data ingestion, storage, transformation, and quality plan**
- Ingestion Strategy.
  
The raw US_Accidents_March23.csv file (approximately 3.06 GB) was uploaded to Amazon S3 using the AWS CLI. The Bronze layer preserves the original CSV unchanged, providing:
-	Traceability: Ability to reprocess from the original source
-	Reproducibility: Complete audit trail of transformations
-	Disaster recovery: Raw data remains intact for restoration.

Storage Architecture

<img width="672" height="197" alt="image" src="https://github.com/user-attachments/assets/112c22e1-71a4-415f-8307-bbbcafb36f56" />

-	Transformation Process: From Bronze to Silver

The AWS Glue ETL PySpark job performs the following transformations:
1.	Column Standardization: Standardizes column names (lowercase, underscores)
2.	Timestamp Parsing: Converts Start_Time and End_Time to proper timestamp format
3.	Derived Feature Creation: Extracts accident_year, accident_month, accident_hour, accident_weekday
4.	Validation Flags: Creates data quality indicators for each record
5.	High_Impact Classification: Binary flag (Severity 3–4 = 1, Severity 1–2 = 0)
6.	Data Type Optimization: Converts strings to appropriate numeric/timestamp types
7.	Format Conversion: Convert CSV files to Snappy-compressed Parquet format for efficient columnar storage

- Data Quality Validation Framework

The ETL process implements comprehensive data quality validation:

<img width="759" height="135" alt="image" src="https://github.com/user-attachments/assets/a3870c16-d9af-44fe-afc3-b2cb8288ed47" />

-	Performance Optimization
  
The transformation from Bronze to Silver achieved significant performance gains:
- File Format: CSV → Snappy-compressed Parquet
-	Partitioning: accident_year and state subdirectories
-	Compression: Snappy for balanced compression/performance
Performance Validation: An identical Athena query filtered by state and timeframe scanned:
-	Bronze: 2.85 GB
-	Silver: 8.58 KB (99.99% reduction in data scanned)

**Cleaning & Transformation (PySpark / AWS Glue)**
- Drop all records where Severity, Start_Time, or State are null, as these are non-negotiable fields for all analytical queries.
- Standardize timestamp fields: parse Start_Time and End_Time to UTC, then extract derived columns: hour, day_of_week, month, and year.
- Normalize free-text fields: apply .trim().lower() to Weather_Condition and City, then map common variant spellings to canonical values (e.g., "Light Rain" → "light rain").
- Cast all boolean road-feature columns (Junction, Traffic_Signal, Crossing, etc.) from string to native boolean type.
- Filter dataset to the contiguous 48 states plus DC; exclude Alaska, Hawaii, and any unrecognized state codes.

**Data model, query design, or analytics workflow**

**Data Model Overview**

The Silver layer serves as the central analytical dataset, containing cleaned and enriched accident records with derived features for analysis:

Key Fields:
-	id: Unique accident identifier (business key)
-	start_time, end_time: Incident timestamps
-	accident_year, accident_month, accident_hour, accident_weekday: Derived temporal features
-	state, county: Geographic dimensions
-	severity: Traffic disruption severity (1-4)
-	high_impact: Binary classification (Severity 3-4)
-	temperature, visibility, wind_speed, weather_condition: Environmental factors
-	junction, traffic_signal, crossing, roundabout: Roadway features

- Duration_minutes: Computed as the difference between End_Time and Start_Time in minutes; records with negative durations are flagged and excluded.
- Is_rush_hour: Boolean flag set to TRUE for accidents occurring between 6–9 AM or 4–7 PM on weekdays.
- Severity_label: Human-readable string mapped from the ordinal scale: 1 → Low, 2 → Moderate, 3 → High, 4 → Critical.
- Season — Derived from month: Winter (Dec–Feb), Spring (Mar–May), Summer (Jun–Aug), Fall (Sep–Nov).

**Query Design and Analytics Workflow**

- Write the transformed dataset to the S3 Processed Bucket in Parquet format, partitioned by state then year (e.g., s3://processed-bucket/accidents/state=CA/year=2022/).
- A second Glue Crawler runs post-ETL to update the Data Catalog with all new partitions, ensuring Athena queries immediately reflect the latest data without requiring manual partition registration.
  
**Sample Athena Queries and results **
- **Athena Query 1**: Accident Trend Over Time to identify year-over-year accident volume trends
- Accident Trend Over Time to identify year-over-year accident volume trends
  
SELECT
    accident_year,
    COUNT(*) AS total_accidents
FROM group16_accidents.silver_us_accidents
WHERE accident_year <> '2023'
GROUP BY accident_year
ORDER BY accident_year;

- Annual Accident Trends (2016-2022)
  
<img width="783" height="201" alt="image" src="https://github.com/user-attachments/assets/d6f2f044-99d4-43bb-a17d-ee2a90dc60ef" />

- Insight: Accident volume increased steadily from 2016 to 2022, with 2022 recording the highest count at 1.76 million incidents, a 329% increase over 2016 levels.

- **Athena Query 2**: Seasonal Patterns to identify monthly and seasonal accident patterns with severity rates
  
SELECT
    accident_month,
    COUNT(*) AS total_accidents,
    ROUND(
        100.0 * SUM(high_impact) / COUNT(*),
        2
    ) AS high_impact_pct
FROM group16_accidents.silver_us_accidents
WHERE accident_year <> '2023'
GROUP BY accident_month
ORDER BY accident_month;

- Monthly Accident Patterns and Severity Rates
  
<img width="622" height="313" alt="image" src="https://github.com/user-attachments/assets/ad08222d-57ae-40cb-8d00-2d875f95b740" />

- Seasonal Aggregation Query

SELECT
    CASE
        WHEN accident_month IN (12,1,2) THEN 'Winter'
        WHEN accident_month IN (3,4,5) THEN 'Spring'
        WHEN accident_month IN (6,7,8) THEN 'Summer'
        WHEN accident_month IN (9,10,11) THEN 'Fall'
    END AS season,
    COUNT(*) AS total_accidents,
    ROUND(
        100.0 * SUM(high_impact) / COUNT(*),
        2
    ) AS high_impact_pct
FROM group16_accidents.silver_us_accidents
WHERE accident_year <> '2023'
GROUP BY 1
ORDER BY total_accidents DESC;

- Seasonal Accident Patterns and Severity Rates
  
<img width="761" height="133" alt="image" src="https://github.com/user-attachments/assets/163cf4e0-48ea-4734-9fd1-385bd211548a" />

- Key Insight: While fall and winter account for the highest accident volumes, summer experiences the highest severe disruption rate (23.06%).
   
- **Athena Query 3**: Day-of-Week Patterns to identify accident patterns by day of week

 SELECT
    accident_weekday,
    COUNT(*) AS total_accidents,
    ROUND(
        100.0 * SUM(high_impact) / COUNT(*),
        2
    ) AS high_impact_pct
FROM group16_accidents.silver_us_accidents
GROUP BY accident_weekday
ORDER BY total_accidents DESC;

- Day-of-Week Accident Patterns
  
<img width="759" height="234" alt="image" src="https://github.com/user-attachments/assets/715b3156-e0bd-4391-ba90-c1ea4905f243" />

- Key Insight: Friday leads in accident volume, but Sunday has the highest severe disruption rate (22.33%), despite lower traffic volume.

- **Athena Query 4**: Hour-of-Day Patterns to identify commute-hour accident patterns
  
SELECT
    accident_hour,
    COUNT(*) AS total_accidents,
    ROUND(
        100.0 * SUM(high_impact) / COUNT(*),
        2
    ) AS high_impact_pct
FROM group16_accidents.silver_us_accidents
GROUP BY accident_hour
ORDER BY accident_hour;

- Hourly Accident Patterns and Severity Rates
<img width="766" height="587" alt="image" src="https://github.com/user-attachments/assets/e02b42c7-26a3-4e08-b0fe-a8a2fbae56fe" />

- Key Insight: Rush-hour periods (7-8 AM, 4-5 PM) account for largest accident volumes, but late-night/early-morning hours (4 AM) have the highest severity rates (21.40%).
  
- **Athena Query 5**: Roadway Feature Associations to identify roadway infrastructure risk factors

SELECT
    'Junction' AS roadway_feature,
    SUM(CASE WHEN junction THEN 1 ELSE 0 END) AS accidents_near_feature,
    ROUND(
        100.0 * SUM(CASE WHEN junction AND high_impact = 1 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN junction THEN 1 ELSE 0 END), 0),
        2
    ) AS high_impact_pct

FROM group16_accidents.silver_us_accidents

UNION ALL

SELECT
    'Traffic Signal',
    SUM(CASE WHEN traffic_signal THEN 1 ELSE 0 END),
    ROUND(
        100.0 * SUM(CASE WHEN traffic_signal AND high_impact = 1 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN traffic_signal THEN 1 ELSE 0 END), 0),
        2
    )
FROM group16_accidents.silver_us_accidents

UNION ALL

SELECT
    'Crossing',
    SUM(CASE WHEN crossing THEN 1 ELSE 0 END),
    ROUND(
        100.0 * SUM(CASE WHEN crossing AND high_impact = 1 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN crossing THEN 1 ELSE 0 END), 0),
        2
    )

- Roadway Feature Risk Analysis
  
<img width="759" height="105" alt="image" src="https://github.com/user-attachments/assets/577ea764-459c-4940-b63a-f9765921df89" />

- Key Insight: Junctions have the highest severe disruption rate (26.79%), far exceeding traffic signals (9.51%) and crossings (7.04%).   

**Key findings, insights, or analytics results**
- **Engineering Performance and Efficiency**: The two-tier partitioning scheme, based on accident year and state subdirectories, enables extreme partition pruning and faster columnar query performance, dramatically reducing Athena query costs.
  
- Engineering Performance and Efficiency
  
<img width="682" height="94" alt="image" src="https://github.com/user-attachments/assets/99fbc9af-0cb4-42fc-aa79-26f6833fcdf9" />

- **Seasonal Volume vs. High-Impact Disruption**: Key Insight: Raw accident volume does not directly correlate with traffic impact severity. While fall and winter account for over 4.1 million combined incidents, summer experiences the highest relative rate of high-impact severe traffic disruptions at approximately 23.06%.
  
- Seasonal Volume vs. High-Impact Disruption
  
<img width="765" height="176" alt="image" src="https://github.com/user-attachments/assets/e6a82b35-2187-430f-968a-7922eda78211" />

- Engineering Performance and Efficiency
  
<img width="975" height="504" alt="image" src="https://github.com/user-attachments/assets/3ae16771-0898-4803-b47e-5fe3592f3d00" />

- Key Insight: Raw accident volume does not directly correlate with traffic impact severity. While fall and winter account for over 4.1 million combined incidents, summer experiences the highest relative rate of high-impact severe traffic disruptions at approximately 23.06%.
  
-** Day-of-Week and Hourly Commute Dynamics**

<img width="768" height="134" alt="image" src="https://github.com/user-attachments/assets/c0cc4835-76cc-4a97-8652-061a20d094db" />

- Weekday vs. Weekend Comparison and Hourly Commute Dynamics
  
<img width="975" height="392" alt="image" src="https://github.com/user-attachments/assets/8634219c-2ced-4d0c-a4fc-5f22387c49f0" />

- Weekday mornings and evenings coincide with traditional commute hours, while weekends, particularly Sunday, show lower traffic volumes but heightened accident severity. The late-night and early-morning spike in severity suggests risk factors such as driver fatigue, impaired driving, or reduced emergency response times.

**- State Geographic Hotspots and Disruption Severity**

<img width="764" height="188" alt="image" src="https://github.com/user-attachments/assets/d3c51d35-b7ee-497e-9454-cfdd55f73309" />

- Geographic Hotspot Map
  
<img width="975" height="379" alt="image" src="https://github.com/user-attachments/assets/8461bfe2-2dd1-453a-9203-25e51da783b0" />

- Key Insight: High-population states (CA, FL) lead in total accident count, but states like New York (23.22%), Virginia (22.92%), and Texas (21.90%) experience significantly larger proportions of high-impact traffic disruptions. These regional variations are vital for allocating transportation infrastructure and emergency response resources effectively.

**- Environmental and Roadway Feature Associations**

- Evaluating environmental factors and roadway infrastructure, the team observed notable associations between specific driving conditions and severity rates. Overcast and scattered cloudy skies showed the highest high-impact disruption percentages (34.95%–35.16%), while highway junctions showed far higher severe disruption rates (26.79%) than standard traffic signals (9.51%) or pedestrian crossings (7.04%). The speakers emphasize that these correlations highlight compounding disruption risks rather than direct causation.
  
<img width="760" height="149" alt="image" src="https://github.com/user-attachments/assets/f46d5eef-57df-41af-b1ca-cd28eea672fc" />

- Feature Association Chart
  
<img width="975" height="434" alt="image" src="https://github.com/user-attachments/assets/4f168477-0aaf-4257-a550-8423d2eae828" />

- Key Insight: Overcast and scattered cloudy skies show the highest high-impact disruption percentages (34.95-35.16%), while highway junctions show far higher severe disruption rates (26.79%) than standard traffic signals (9.51%) or pedestrian crossings (7.04%). These correlations highlight compounding disruption risks rather than direct causation.

**- Key Takeaways and Future Work**
1.	Cloud-Native Processing is Essential: Traditional desktop tools cannot handle 7.7 million records efficiently. Our serverless AWS pipeline achieved a 99.99% reduction in query scan volume through proper partition optimization.
2.	Volume ≠ Severity: High-volume regions and periods do not necessarily correlate with severe disruptions. Transportation agencies must analyze both dimensions separately.
3.	Peak accidents occur during rush hours, while off-peak hours and Sundays show higher severity rates, indicating different risk factors.
4.	Infrastructure Matters: Junctions pose a dramatically higher severe disruption risk (26.79%) than traffic signals (9.51%), guiding infrastructure investment decisions.
5.	Weather as a Multiplier: Overcast and scattered clouds significantly increase severity rates, likely due to reduced visibility and poor driving conditions.

**- Limitations, risks, and future improvements**
- Current Limitations and Risks
  
<img width="769" height="278" alt="image" src="https://github.com/user-attachments/assets/f4e6b131-4791-4e4f-8ca2-b815dde13e09" />

- Future Improvements Roadmap
  
<img width="975" height="439" alt="image" src="https://github.com/user-attachments/assets/f48e8802-8537-497b-9a00-04a599190608" />

- Future Improvements
  
<img width="760" height="355" alt="image" src="https://github.com/user-attachments/assets/39cebc73-fb3f-4211-866f-faa777f08f2a" />

**Future Enhancements**
- Real-Time Streaming Integration: Integrate live traffic incident feeds via AWS Kinesis Data Streams and Kinesis Data Firehose to enable near-real-time accident alerting and streaming analytics alongside the historical batch pipeline.
- ML Severity Prediction: Train a supervised classification model to predict accident severity at the time of incident using weather, location, and road feature inputs, leveraging Amazon SageMaker for training, tuning, and endpoint hosting.
- Reverse Geocoding Enrichment: Apply reverse geocoding (e.g., via AWS Location Service or HERE API) to convert raw coordinates into enriched county, zip code, and congressional district metadata for finer-grained spatial analysis.
- Automated Data Quality Checks: Embed pre- and post-ETL data quality validation using AWS Deequ or Great Expectations to enforce schema contracts, detect anomalies, and prevent corrupt data from reaching the processed layer.
- Managed Workflow Orchestration: Migrate pipeline scheduling to Apache Airflow on Amazon MWAA (Managed Workflows for Apache Airflow) for richer DAG-based dependency management, retry logic, and cross-service orchestration beyond what Glue Triggers support natively.
- REST API Exposure: Expose curated Athena query results and aggregated metrics through a REST API built on AWS Lambda and Amazon API Gateway, enabling programmatic access for third-party applications, mobile dashboards, and external research consumers.
