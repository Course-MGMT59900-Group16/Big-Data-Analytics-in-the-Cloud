-- Silver validation
-- These queries confirm that the transformed Parquet layer is queryable and preserves the full row count.

-- Check a partition-filtered sample.
SELECT
    id,
    severity,
    start_timestamp,
    accident_month,
    accident_hour,
    accident_weekday,
    weekend_flag,
    high_impact,
    precipitation_available,
    valid_coordinates,
    valid_timestamp,
    accident_year,
    state
FROM group16_accidents.silver_us_accidents
WHERE accident_year = '2019'
  AND state = 'FL'
LIMIT 10;

-- Verify total Silver row count.
SELECT COUNT(*) AS total_silver_records
FROM group16_accidents.silver_us_accidents;

-- This filtered query is also useful for showing the benefit of year/state partition pruning.
SELECT COUNT(*) AS florida_2019_records
FROM group16_accidents.silver_us_accidents
WHERE accident_year = '2019'
  AND state = 'FL';
