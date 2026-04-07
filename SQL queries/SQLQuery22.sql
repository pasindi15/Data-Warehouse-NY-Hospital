USE NYHospitalDW;
GO

IF OBJECT_ID('dbo.StagingCompletions','U') IS NOT NULL
    DROP TABLE dbo.StagingCompletions;
GO

CREATE TABLE dbo.StagingCompletions (
    txn_id                  NVARCHAR(50),
    accm_txn_complete_time  NVARCHAR(50)
);
GO

BULK INSERT dbo.StagingCompletions
FROM 'E:\Year 3\Y3 S1\DWBI - IT3021\dataset\source4_txn_completions.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

SELECT COUNT(*) AS CompletionRows FROM dbo.StagingCompletions;
GO