-- Data-quality checks on the Bronze table
-- I kept these checks focused on fields that matter for the final analysis.

-- Missing values in important weather and analytical fields.
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN weather_condition IS NULL OR TRIM(weather_condition) = '' THEN 1 ELSE 0 END)
        AS missing_weather_condition,

    SUM(CASE WHEN "visibility(mi)" IS NULL THEN 1 ELSE 0 END)
        AS missing_visibility,

    SUM(CASE WHEN "temperature(f)" IS NULL THEN 1 ELSE 0 END)
        AS missing_temperature,

    SUM(CASE WHEN "precipitation(in)" IS NULL THEN 1 ELSE 0 END)
        AS missing_precipitation,

    SUM(CASE WHEN start_time IS NULL OR TRIM(start_time) = '' THEN 1 ELSE 0 END)
        AS missing_start_time,

    SUM(CASE WHEN state IS NULL OR TRIM(state) = '' THEN 1 ELSE 0 END)
        AS missing_state
FROM group16_accidents.bronze_us_accidents;

-- Basic coordinate range validation.
SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN start_lat IS NULL
              OR start_lng IS NULL
              OR start_lat < -90
              OR start_lat > 90
              OR start_lng < -180
              OR start_lng > 180
            THEN 1
            ELSE 0
        END
    ) AS invalid_coordinates
FROM group16_accidents.bronze_us_accidents;

-- Source-year coverage check.
-- We used this to confirm that 2023 is only a partial year.
SELECT
    SUBSTR(start_time, 1, 4) AS accident_year,
    COUNT(*) AS accident_count
FROM group16_accidents.bronze_us_accidents
WHERE start_time IS NOT NULL
GROUP BY SUBSTR(start_time, 1, 4)
ORDER BY accident_year;
