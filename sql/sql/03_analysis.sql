USE pharma_sc;

-- Products below reorder point = immediate stockout risk
SELECT
    Drug,
    Demand_Forecast,
    Optimal_Stock_Level,
    Restocking_Strategy,
    (Demand_Forecast - Optimal_Stock_Level)        AS shortage_units,
    CASE
        WHEN Optimal_Stock_Level = 0               THEN 'CRITICAL'
        WHEN Optimal_Stock_Level < Demand_Forecast * 0.5 THEN 'HIGH'
        ELSE 'MEDIUM'
    END AS risk_level
FROM supply_chain
WHERE Optimal_Stock_Level < Demand_Forecast
ORDER BY shortage_units DESC
LIMIT 20;

SELECT
    Drug,
    Demand_Forecast,
    Optimal_Stock_Level,
    Restocking_Strategy,
    (Optimal_Stock_Level - Demand_Forecast)               AS excess_units
FROM supply_chain
WHERE Optimal_Stock_Level > Demand_Forecast * 2  -- more than 2x safety buffer
ORDER BY excess_units DESC
LIMIT 15;