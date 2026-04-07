USE NYHospitalDW;
GO

-- Fix ALL remaining VARCHAR columns to NVARCHAR across all tables
ALTER TABLE dbo.DimHospital ALTER COLUMN facility_name         NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.DimHospital ALTER COLUMN operating_cert_number NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.DimHospital ALTER COLUMN hospital_county       NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.DimHospital ALTER COLUMN health_service_area   NVARCHAR(255) NOT NULL;

ALTER TABLE dbo.FactAdmission ALTER COLUMN type_of_admission        NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.FactAdmission ALTER COLUMN patient_disposition       NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.FactAdmission ALTER COLUMN emergency_dept_indicator  NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.FactAdmission ALTER COLUMN abortion_edit_indicator   NVARCHAR(255) NOT NULL;
GO

PRINT 'Done!';
GO