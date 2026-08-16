-- ML readiness
-- We created a model-ready view, but we did not train or deploy a classifier in this project.
-- Severity is intentionally excluded from the predictors because high_impact is derived from Severity.

CREATE OR REPLACE VIEW group16_accidents.ml_accident_features AS
SELECT
    accident_month,
    accident_hour,
    accident_weekday,
    weekend_flag,
    state,
    temperature_f,
    visibility_mi,
    precipitation_in,
    precipitation_available,
    weather_condition,
    crossing,
    junction,
    stop,
    traffic_signal,
    roundabout,
    sunrise_sunset,
    high_impact
FROM group16_accidents.silver_us_accidents
WHERE valid_timestamp = 1
  AND valid_coordinates = 1;

-- Check the target distribution before any future model experiment.
SELECT
    high_impact,
    COUNT(*) AS records,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct
FROM group16_accidents.ml_accident_features
GROUP BY high_impact
ORDER BY high_impact;
