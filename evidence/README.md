# Implementation Evidence

The final report contains the detailed AWS screenshots. For the GitHub repository, these are the main implementation artifacts we would keep if we export the original screenshots separately:

1. **S3 Bronze ingestion**
   - Raw `US_Accidents_March23.csv` visible in the Bronze prefix.

2. **Glue Data Catalog**
   - `bronze_us_accidents` table and discovered schema.

3. **Athena Bronze validation**
   - Preview / row count / data-quality query output.

4. **Glue Bronze-to-Silver ETL**
   - Successful Glue job run.

5. **S3 Silver partitions**
   - `accident_year=.../` and `state=.../` structure.

6. **Parquet output**
   - Snappy Parquet file visible inside a state partition.

7. **Gold state summary**
   - Athena result for `gold_accidents_by_state`.

8. **Gold weather summary**
   - Athena result for `gold_accidents_by_weather`.

9. **ML-ready target distribution**
   - 80.54% lower impact vs. 19.46% high impact.

The aligned final report is included under `docs/` and contains the implementation screenshots used for the final submission.
