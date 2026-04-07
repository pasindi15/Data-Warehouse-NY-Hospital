USE NYHospitalDW;
GO

DROP INDEX UX_DimPatient_Demographics ON dbo.DimPatient;
GO

PRINT 'Unique index dropped - duplicates now allowed!';
GO