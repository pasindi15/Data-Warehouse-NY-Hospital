BULK INSERT NYHospitalOLTP.dbo.StagingAdmissions
FROM 'E:\Year 3\Y3 S1\DWBI - IT3021\dataset\source1_admissions.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

SELECT COUNT(*) AS LoadedRows FROM NYHospitalOLTP.dbo.StagingAdmissions;
GO