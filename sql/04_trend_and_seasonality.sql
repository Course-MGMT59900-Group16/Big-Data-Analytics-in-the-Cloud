-- Trend and seasonal analysis
-- We excluded 2023 from full-year comparisons because the source only includes Jan-Mar 2023.

-- Annual reported record volume.
SELECT
    accident_year,
    COUNT(*) AS total_accidents
FROM group16_accidents.silver_us_accidents
WHERE accident_year <> '2023'
GROUP BY accident_year
ORDER BY accident_year;

-- Monthly volume and high-impact percentage.
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

-- Seasonal summary used in the final presentation.
SELECT
    CASE
        WHEN accident_month IN (12, 1, 2) THEN 'Winter'
        WHEN accident_month IN (3, 4, 5) THEN 'Spring'
        WHEN accident_month IN (6, 7, 8) THEN 'Summer'
        WHEN accident_month IN (9, 10, 11) THEN 'Fall'
    END AS season,
    COUNT(*) AS total_accidents,
    SUM(high_impact) AS high_impact_accidents,
    ROUND(
        100.0 * SUM(high_impact) / COUNT(*),
        2
    ) AS high_impact_pct
FROM group16_accidents.silver_us_accidents
WHERE accident_year <> '2023'
GROUP BY 1
ORDER BY total_accidents DESC;
