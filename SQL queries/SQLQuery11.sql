USE NYHospitalDW;
GO

-- Allow NULL temporarily for loading
ALTER TABLE dbo.DimDiagnosis ALTER COLUMN ccs_diagnosis_code  NVARCHAR(255) NULL;
ALTER TABLE dbo.DimDiagnosis ALTER COLUMN apr_drg_code        NVARCHAR(255) NULL;
ALTER TABLE dbo.DimDiagnosis ALTER COLUMN apr_mdc_code        NVARCHAR(255) NULL;
ALTER TABLE dbo.DimDiagnosis ALTER COLUMN ccs_diagnosis_description NVARCHAR(255) NULL;
ALTER TABLE dbo.DimDiagnosis ALTER COLUMN apr_drg_description       NVARCHAR(255) NULL;
ALTER TABLE dbo.DimDiagnosis ALTER COLUMN apr_mdc_description       NVARCHAR(255) NULL;
ALTER TABLE dbo.DimDiagnosis ALTER COLUMN severity_of_illness_desc  NVARCHAR(255) NULL;
ALTER TABLE dbo.DimDiagnosis ALTER COLUMN risk_of_mortality         NVARCHAR(255) NULL;
ALTER TABLE dbo.DimDiagnosis ALTER COLUMN medical_surgical_desc     NVARCHAR(255) NULL;
ALTER TABLE dbo.DimDiagnosis ALTER COLUMN severity_of_illness_code  INT NULL;
GO

-- Also allow NULL in DimProcedure and DimPayment
ALTER TABLE dbo.DimProcedure ALTER COLUMN ccs_procedure_code        NVARCHAR(255) NULL;
ALTER TABLE dbo.DimProcedure ALTER COLUMN ccs_procedure_description NVARCHAR(255) NULL;
GO

PRINT 'Done!';
GO