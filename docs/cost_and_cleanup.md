# Cost Awareness and Cleanup

We kept the implemented architecture intentionally small and serverless.

## Cost controls we used

- Amazon S3 for storage.
- AWS Glue ETL only when needed.
- Amazon Athena on demand.
- Snappy-compressed Parquet for Silver.
- `accident_year` and `state` partitioning to reduce data scanned.
- No production SageMaker endpoint.
- QuickSight was not required for the implemented stack.

## Representative efficiency result

For a filtered year/state query:

- Bronze CSV scanned about **2.85 GB**
- Silver Parquet scanned about **8.58 KB**

This was one of the main reasons we used Parquet and partitioning.

## Illustrative project-scale estimate

The values in our report are planning estimates rather than an AWS bill.

- S3: about $1.50/month for small project-scale storage
- Glue: about $3.00/month for a few short runs similar to our test
- Athena: about $0.50/month with limited, optimized querying
- Implemented-stack illustrative total: about $5/month

Actual charges depend on region, usage, pricing changes, and educational credits.

## Cleanup

After the project, we would:

1. keep the report, SQL, and documentation;
2. remove unused Glue jobs/crawlers if they are no longer needed;
3. remove the exploratory SageMaker domain if it will not be used;
4. delete temporary Athena results and other unnecessary S3 objects;
5. verify AWS Billing / Cost Explorer before considering the project closed.
