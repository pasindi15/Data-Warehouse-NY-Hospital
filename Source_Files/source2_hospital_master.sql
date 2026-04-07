-- ============================================================
-- SOURCE 2: Hospital Master Data (SQL Server Table)
-- Run this in SSMS to create the OLTP hospital reference source
-- Database: NYHospitalOLTP
-- ============================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'NYHospitalOLTP')
    CREATE DATABASE NYHospitalOLTP;
GO

USE NYHospitalOLTP;
GO

IF OBJECT_ID('dbo.HospitalMaster', 'U') IS NOT NULL
    DROP TABLE dbo.HospitalMaster;
GO

CREATE TABLE dbo.HospitalMaster (
    facility_id              INT            NOT NULL PRIMARY KEY,
    facility_name            VARCHAR(200)   NOT NULL,
    operating_cert_number    VARCHAR(20)    NOT NULL,
    hospital_county          VARCHAR(100)   NOT NULL,
    health_service_area      VARCHAR(100)   NOT NULL,
    record_created_date      DATE           NOT NULL DEFAULT GETDATE(),
    is_active                BIT            NOT NULL DEFAULT 1
);
GO

INSERT INTO dbo.HospitalMaster
    (facility_id, facility_name, operating_cert_number, hospital_county, health_service_area)
VALUES
    (1, 'Albany Medical Center Hospital', '0101000', 'Albany', 'Capital/Adiron'),
    (2, 'Albany Medical Center - South Clinical Campus', '0101000', 'Albany', 'Capital/Adiron'),
    (4, 'Albany Memorial Hospital', '0101003', 'Albany', 'Capital/Adiron'),
    (5, 'St Peters Hospital', '0101004', 'Albany', 'Capital/Adiron');
GO

SELECT * FROM dbo.HospitalMaster;
GO
