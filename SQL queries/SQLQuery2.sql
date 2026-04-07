USE NYHospitalDW;
GO

-- Step 1: Drop the unique index first
DROP INDEX UX_DimPatient_Demographics ON dbo.DimPatient;
GO

-- Step 2: Fix all column sizes
ALTER TABLE dbo.DimPatient ALTER COLUMN age_group   VARCHAR(50) NOT NULL;
ALTER TABLE dbo.DimPatient ALTER COLUMN gender      VARCHAR(50) NOT NULL;
ALTER TABLE dbo.DimPatient ALTER COLUMN race        VARCHAR(50) NOT NULL;
ALTER TABLE dbo.DimPatient ALTER COLUMN ethnicity   VARCHAR(50) NOT NULL;
ALTER TABLE dbo.DimPatient ALTER COLUMN zip_code_3digit VARCHAR(50) NOT NULL;
GO

-- Step 3: Recreate the index with new column sizes
CREATE UNIQUE NONCLUSTERED INDEX UX_DimPatient_Demographics
    ON dbo.DimPatient (age_group, gender, race, ethnicity, zip_code_3digit);
GO

PRINT 'DimPatient columns fixed successfully!';
GO