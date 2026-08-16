# AWS Medallion Architecture

This diagram shows the architecture we actually implemented and separates it from the planned extensions.

```mermaid
flowchart LR
    A[U.S. Accidents CSV<br/>7.7M records] --> B[Amazon S3 Bronze<br/>Raw CSV preserved]
    B --> C[AWS Glue Crawler<br/>Data Catalog]
    C --> D[AWS Glue ETL<br/>PySpark]
    D --> E[Amazon S3 Silver<br/>Snappy Parquet<br/>year/state partitions]
    E --> F[Amazon Athena<br/>Validation + Analytics]
    F --> G[Gold: by State]
    F --> H[Gold: by Weather]
    F --> I[ML-ready View<br/>ml_accident_features]
    G --> J[Report / Presentation]
    H --> J
    I -. planned .-> K[SageMaker Experiment]
    G -. planned .-> L[QuickSight Dashboard]
    H -. planned .-> L
```

## Implemented

- Amazon S3 Bronze
- AWS Glue Crawler / Data Catalog
- AWS Glue PySpark ETL
- Amazon S3 Silver
- Snappy-compressed Parquet
- `accident_year` / `state` partitioning
- Amazon Athena
- `gold_accidents_by_state`
- `gold_accidents_by_weather`
- `ml_accident_features`

## Planned

- QuickSight dashboard
- SageMaker classification experiment
