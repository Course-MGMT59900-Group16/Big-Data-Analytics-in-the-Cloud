-- Roadway feature associations
-- This comparison shows associations in the dataset. We are not treating these values as causal effects.

SELECT
    'Junction' AS roadway_feature,
    SUM(CASE WHEN junction THEN 1 ELSE 0 END) AS accidents_near_feature,
    ROUND(
        100.0 * SUM(CASE WHEN junction AND high_impact = 1 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN junction THEN 1 ELSE 0 END), 0),
        2
    ) AS high_impact_pct
FROM group16_accidents.silver_us_accidents

UNION ALL

SELECT
    'Traffic Signal',
    SUM(CASE WHEN traffic_signal THEN 1 ELSE 0 END),
    ROUND(
        100.0 * SUM(CASE WHEN traffic_signal AND high_impact = 1 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN traffic_signal THEN 1 ELSE 0 END), 0),
        2
    )
FROM group16_accidents.silver_us_accidents

UNION ALL

SELECT
    'Crossing',
    SUM(CASE WHEN crossing THEN 1 ELSE 0 END),
    ROUND(
        100.0 * SUM(CASE WHEN crossing AND high_impact = 1 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN crossing THEN 1 ELSE 0 END), 0),
        2
    )
FROM group16_accidents.silver_us_accidents;
