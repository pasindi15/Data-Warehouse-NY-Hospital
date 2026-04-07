USE NYHospitalDW;
GO

-- Create staging table in the DW database
IF OBJECT_ID('dbo.StagingAdmissions','U') IS NOT NULL
    DROP TABLE dbo.StagingAdmissions;
GO

CREATE TABLE dbo.StagingAdmissions (
    txn_id                   NVARCHAR(50),
    facility_id              NVARCHAR(50),
    discharge_year           NVARCHAR(50),
    age_group                NVARCHAR(255),
    zip_code_3digit          NVARCHAR(255),
    gender                   NVARCHAR(255),
    race                     NVARCHAR(255),
    ethnicity                NVARCHAR(255),
    length_of_stay           NVARCHAR(50),
    type_of_admission        NVARCHAR(255),
    patient_disposition      NVARCHAR(255),
    ccs_diagnosis_code       NVARCHAR(255),
    ccs_procedure_code       NVARCHAR(255),
    source_of_payment_1      NVARCHAR(255),
    source_of_payment_2      NVARCHAR(255),
    source_of_payment_3      NVARCHAR(255),
    birth_weight             NVARCHAR(50),
    abortion_edit_indicator  NVARCHAR(10),
    emergency_dept_indicator NVARCHAR(10),
    total_charges            NVARCHAR(50),
    total_costs              NVARCHAR(50)
);
GO

-- Load CSV into staging
BULK INSERT dbo.StagingAdmissions
FROM 'E:\Year 3\Y3 S1\DWBI - IT3021\dataset\source1_admissions.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

SELECT COUNT(*) AS StagingRows FROM dbo.StagingAdmissions;
GO