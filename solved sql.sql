USE chdb;
SELECT * FROM multi_sensor_csv LIMIT 10;
WITH stats AS (
    SELECT
        Plant,
        MachineID,
        AVG(Temperature) AS temp_mean,
        STDDEV(Temperature) AS temp_std,
        AVG(Vibration) AS vib_mean,
        STDDEV(Vibration) AS vib_std,
        AVG(Pressure) AS pres_mean,
        STDDEV(Pressure) AS pres_std
    FROM multi_sensor_csv
    GROUP BY Plant, MachineID
)

SELECT
    m.Plant,
    m.MachineID,
    COUNT(*) AS AnomalyCount
FROM multi_sensor_csv m
JOIN stats s
    ON m.Plant = s.Plant
    AND m.MachineID = s.MachineID
WHERE
    m.Temperature NOT BETWEEN (s.temp_mean - 3*s.temp_std) AND (s.temp_mean + 3*s.temp_std)
    OR
    m.Vibration NOT BETWEEN (s.vib_mean - 3*s.vib_std) AND (s.vib_mean + 3*s.vib_std)
    OR
    m.Pressure NOT BETWEEN (s.pres_mean - 3*s.pres_std) AND (s.pres_mean + 3*s.pres_std)
GROUP BY m.Plant, m.MachineID
ORDER BY AnomalyCount DESC;

CREATE OR REPLACE VIEW sensor_condition_2025 AS
SELECT 
    MachineID,
    AvgTemp,
    AvgVib,
    AvgPressure,
    AvgEnergyPerUnit,
    TotalDefects,
    MaintenanceCount,
    CASE 
        WHEN NTILE(10) OVER (ORDER BY ConditionScore DESC) = 1 
        THEN 'Critical'
        ELSE 'Normal'
    END AS ConditionBucket
FROM (
    SELECT
        MachineID,
        AVG(Temperature) AS AvgTemp,
        AVG(Vibration) AS AvgVib,
        AVG(Pressure) AS AvgPressure,
        AVG(EnergyConsumption / ProductionUnits) AS AvgEnergyPerUnit,
        SUM(DefectCount) AS TotalDefects,
        SUM(MaintenanceFlag) AS MaintenanceCount,
        AVG(Temperature + Vibration + Pressure) AS ConditionScore
    FROM multi_sensor_csv
    GROUP BY MachineID
) t;
SELECT * FROM sensor_condition_2025;
