-- Bronze validation queries
-- We used these first to confirm that the Glue table was connected to the raw S3 CSV.

-- Preview a few records.
SELECT *
FROM group16_accidents.bronze_us_accidents
LIMIT 10;

-- Confirm the total row count in the raw dataset.
SELECT COUNT(*) AS total_accidents
FROM group16_accidents.bronze_us_accidents;

-- Check whether the accident ID can be treated as a unique business key.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT id) AS unique_ids,
    COUNT(*) - COUNT(DISTINCT id) AS duplicate_rows
FROM group16_accidents.bronze_us_accidents;

-- Review the source Severity distribution.
-- In this project Severity is traffic-flow impact, not injury severity.
SELECT
    severity,
    COUNT(*) AS accident_count
FROM group16_accidents.bronze_us_accidents
GROUP BY severity
ORDER BY severity;
