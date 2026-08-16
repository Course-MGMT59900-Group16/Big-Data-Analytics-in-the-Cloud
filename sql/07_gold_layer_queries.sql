-- Gold-layer queries
-- We implemented state and weather summaries and queried them from Athena.

-- Top states by total reported accident volume.
SELECT
    state,
    total_accidents,
    high_impact_accidents,
    high_impact_pct,
    avg_duration_minutes
FROM group16_accidents.gold_accidents_by_state
ORDER BY total_accidents DESC
LIMIT 10;

-- Weather conditions with enough records to make the comparison more useful.
SELECT
    weather_condition,
    total_accidents,
    high_impact_accidents,
    high_impact_pct,
    avg_visibility_mi
FROM group16_accidents.gold_accidents_by_weather
WHERE total_accidents >= 10000
ORDER BY high_impact_pct DESC
LIMIT 10;
