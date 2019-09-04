SELECT D.FiscalYear,
    D.FiscalMonth,
    P.[Project Code],
    P.[Project ServiceLine Code],
    S.[Phase ServiceLine Code],
    P.[Project Phase Worktype Code],
    T.[Project Transaction Company Currency Code],
    SUM(T.[Project Transaction Labor Revenue] + T.[Project Transaction Revenue Adjustment]) [Labor Revenue]
FROM dbo.DimProjectPhase P
JOIN dbo.vFactProjectTransaction T
 ON T.ProjectPhaseKey = P.ProjectPhaseKey
JOIN dbo.DimDate D
 ON D.DateKey = T.DateKey
JOIN dbo.DimPhaseServiceLines S
 ON S.PhaseServiceLineKey = T.PhaseServiceLineKey
WHERE D.FiscalYear=2019
 --AND [Project ServiceLine Code] <> [Phase ServiceLine Code]
GROUP BY D.FiscalYear,
    D.FiscalMonth,
    P.[Project Code],
    P.[Project ServiceLine Code],
    S.[Phase ServiceLine Code],
    P.[Project Phase Worktype Code],
    T.[Project Transaction Company Currency Code]