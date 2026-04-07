USE NYHospitalDW;
GO

ALTER TABLE dbo.DimHospital ALTER COLUMN facility_name         NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.DimHospital ALTER COLUMN operating_cert_number NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.DimHospital ALTER COLUMN hospital_county       NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.DimHospital ALTER COLUMN health_service_area   NVARCHAR(255) NOT NULL;
GO

-- Also fix the OLTP source table to send unicode
USE NYHospitalOLTP;
GO

ALTER TABLE dbo.HospitalMaster ALTER COLUMN facility_name          NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.HospitalMaster ALTER COLUMN operating_cert_number  NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.HospitalMaster ALTER COLUMN hospital_county        NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.HospitalMaster ALTER COLUMN health_service_area    NVARCHAR(255) NOT NULL;
GO

PRINT 'Done!';
GO