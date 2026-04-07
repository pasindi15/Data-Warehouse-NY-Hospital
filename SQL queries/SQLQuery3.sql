USE NYHospitalDW;
GO

-- Drop index, fix the code columns to 255, recreate
DROP INDEX IX_DimDiagnosis_CCS ON dbo.DimDiagnosis;
GO

ALTER TABLE dbo.DimDiagnosis ALTER COLUMN ccs_diagnosis_code NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.DimDiagnosis ALTER COLUMN apr_drg_code       NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.DimDiagnosis ALTER COLUMN apr_mdc_code       NVARCHAR(255) NOT NULL;
GO

CREATE NONCLUSTERED INDEX IX_DimDiagnosis_CCS
    ON dbo.DimDiagnosis (ccs_diagnosis_code, apr_drg_code);
GO

-- Fix DimProcedure code column too
DROP INDEX UX_DimProcedure_Code ON dbo.DimProcedure;
GO
ALTER TABLE dbo.DimProcedure ALTER COLUMN ccs_procedure_code NVARCHAR(255) NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX UX_DimProcedure_Code
    ON dbo.DimProcedure (ccs_procedure_code);
GO

PRINT 'Done!';
GO