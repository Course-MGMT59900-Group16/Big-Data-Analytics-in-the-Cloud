# AWS Glue Transformation

The Bronze-to-Silver transformation was executed as an AWS Glue PySpark ETL job.

We are documenting the implemented transformation logic here rather than pretending that a locally reconstructed script is the exact Glue job source.

The job performed the following steps:

1. Read the Bronze accident data.
2. Standardize column names.
3. Parse start/end timestamps.
4. Create temporal fields:
   - `accident_year`
   - `accident_month`
   - `accident_hour`
   - `accident_weekday`
5. Create validation indicators such as:
   - `valid_timestamp`
   - `valid_coordinates`
6. Create the analytical target:
   - `high_impact = 1` for Severity 3-4
   - `high_impact = 0` for Severity 1-2
7. Keep missing precipitation as missing rather than automatically converting it to zero.
8. Convert the result to Snappy-compressed Parquet.
9. Write Silver data partitioned by `accident_year` and `state`.

The documented run completed in about **2 minutes 19 seconds using 10 DPUs**.

If we export the exact AWS Glue-generated script from the console, it can be added to this folder as the source-of-truth implementation file.
