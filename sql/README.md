# Athena SQL

These files organize the Athena queries we used during the project.

I kept the comments short and tied to what we were actually checking in AWS.

| File | Purpose |
|---|---|
| `01_bronze_validation.sql` | Preview, total row count, duplicate IDs, Severity distribution |
| `02_data_quality_checks.sql` | Missing values, coordinate validation, source-year coverage |
| `03_silver_validation.sql` | Silver sample, row-count check, partition-filtered query |
| `04_trend_and_seasonality.sql` | Annual, monthly, and seasonal analysis |
| `05_day_hour_analysis.sql` | Day-of-week and hour-of-day analysis |
| `06_roadway_analysis.sql` | Junction / traffic-signal / crossing associations |
| `07_gold_layer_queries.sql` | State and weather Gold summaries |
| `08_ml_readiness.sql` | Model-ready feature view and target distribution |

The database and table names match the AWS environment we used:

```text
Database: group16_accidents

bronze_us_accidents
silver_us_accidents
gold_accidents_by_state
gold_accidents_by_weather
ml_accident_features
```
