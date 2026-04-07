USE NYHospitalDW;
GO

ALTER TABLE dbo.DimHospital
    ALTER COLUMN facility_name VARCHAR(200) NOT NULL;

ALTER TABLE dbo.DimHospital
    ALTER COLUMN health_service_area VARCHAR(100) NOT NULL;

ALTER TABLE dbo.DimHospital
    ALTER COLUMN hospital_county VARCHAR(100) NOT NULL;
GO