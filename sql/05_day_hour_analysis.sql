-- Day-of-week and hour-of-day analysis
-- We compared volume and high-impact percentage because the peaks are not always the same.

-- Day-of-week patterns.
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

-- Hour-of-day patterns.
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
