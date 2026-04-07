USE NYHospitalDW;
GO

-- Fig 6.3: TotalFact / Updated / Pending summary
SELECT 
    COUNT(*)                                                           AS TotalFact,
    SUM(CASE WHEN accm_txn_complete_time IS NOT NULL THEN 1 ELSE 0 END) AS UpdatedRows,
    SUM(CASE WHEN accm_txn_complete_time IS NULL     THEN 1 ELSE 0 END) AS PendingRows
FROM dbo.FactAdmission;
GO