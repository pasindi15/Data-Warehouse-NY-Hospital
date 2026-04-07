USE NYHospitalDW;
GO

-- Clear all dimension tables (keep DimDate)
DELETE FROM dbo.DimHospital;
DELETE FROM dbo.DimPatient;
DELETE FROM dbo.DimDiagnosis;
DELETE FROM dbo.DimProcedure;
DELETE FROM dbo.DimPayment;

-- Reset identity counters
DBCC CHECKIDENT ('dbo.DimHospital',  RESEED, 0);
DBCC CHECKIDENT ('dbo.DimPatient',   RESEED, 0);
DBCC CHECKIDENT ('dbo.DimDiagnosis', RESEED, 0);
DBCC CHECKIDENT ('dbo.DimProcedure', RESEED, 0);
DBCC CHECKIDENT ('dbo.DimPayment',   RESEED, 0);
GO

PRINT 'All dimension tables cleared!';
GO