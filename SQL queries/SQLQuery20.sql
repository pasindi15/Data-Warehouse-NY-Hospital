USE NYHospitalDW;
GO

SELECT TOP 10
    txn_id,
    accm_txn_create_time,
    accm_txn_complete_time,
    txn_process_time_hours
FROM dbo.FactAdmission
WHERE accm_txn_complete_time IS NOT NULL
ORDER BY txn_id;
GO