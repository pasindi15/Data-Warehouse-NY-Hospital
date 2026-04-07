-- ============================================================
--  IT3021: Data Warehousing and Business Intelligence
--  Assignment 1 — Task 4: Data Warehouse Schema
--  Dataset: NY State Hospital Inpatient Discharge (2009)
--  Database: NYHospitalDW
-- ============================================================
--  EXECUTION ORDER:
--    1. Create Database
--    2. Create Dimension Tables (DimDate first — no dependencies)
--    3. Create Fact Table last (references all dimensions)
--    4. Insert sample DimDate rows
--    5. Verify with SELECT statements
-- ============================================================

USE master;
GO

-- ── Step 1: Create the Data Warehouse database ──────────────
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'NYHospitalDW')
BEGIN
    CREATE DATABASE NYHospitalDW;
    PRINT 'Database NYHospitalDW created successfully.';
END
ELSE
    PRINT 'Database NYHospitalDW already exists.';
GO

USE NYHospitalDW;
GO

-- ============================================================
--  DIMENSION TABLES
-- ============================================================

-- ── DimDate ─────────────────────────────────────────────────
-- Loaded first — no foreign key dependencies
IF OBJECT_ID('dbo.DimDate', 'U') IS NOT NULL
    DROP TABLE dbo.DimDate;
GO

CREATE TABLE dbo.DimDate (
    date_key         INT            NOT NULL,   -- Surrogate key e.g. 20090101
    discharge_year   INT            NOT NULL,   -- e.g. 2009
    quarter          INT            NOT NULL,   -- 1, 2, 3, or 4
    month            INT            NOT NULL,   -- 1 to 12
    month_name       VARCHAR(20)    NOT NULL,   -- e.g. 'January'
    year_quarter     VARCHAR(10)    NOT NULL,   -- e.g. '2009-Q1'
    year_month       VARCHAR(10)    NOT NULL,   -- e.g. '2009-01'
    CONSTRAINT PK_DimDate PRIMARY KEY (date_key)
);
GO

PRINT 'DimDate created.';
GO

-- ── DimHospital (SCD Type 2) ─────────────────────────────────
-- SCD Type 2: when hospital name or region changes,
-- a new row is inserted with updated effective dates.
-- is_current = 1 flags the active version.
IF OBJECT_ID('dbo.DimHospital', 'U') IS NOT NULL
    DROP TABLE dbo.DimHospital;
GO

CREATE TABLE dbo.DimHospital (
    hospital_key             INT            NOT NULL IDENTITY(1,1),  -- Surrogate key
    facility_id              INT            NOT NULL,                 -- Natural key from source
    facility_name            VARCHAR(100)   NOT NULL,
    operating_cert_number    VARCHAR(20)    NOT NULL,
    hospital_county          VARCHAR(50)    NOT NULL,
    health_service_area      VARCHAR(50)    NOT NULL,
    -- SCD Type 2 columns
    effective_start_date     DATE           NOT NULL,
    effective_end_date       DATE           NULL,      -- NULL = still active
    is_current               BIT            NOT NULL DEFAULT 1,
    CONSTRAINT PK_DimHospital PRIMARY KEY (hospital_key)
);
GO

-- Index on natural key + is_current for fast SCD lookups
CREATE NONCLUSTERED INDEX IX_DimHospital_NaturalKey
    ON dbo.DimHospital (facility_id, is_current);
GO

PRINT 'DimHospital (SCD Type 2) created.';
GO

-- ── DimPatient ───────────────────────────────────────────────
-- No individual patient ID in source — demographics as groups
IF OBJECT_ID('dbo.DimPatient', 'U') IS NOT NULL
    DROP TABLE dbo.DimPatient;
GO

CREATE TABLE dbo.DimPatient (
    patient_key      INT            NOT NULL IDENTITY(1,1),  -- Surrogate key
    age_group        VARCHAR(20)    NOT NULL,   -- '0 to 17','18 to 29','30 to 49','50 to 69','70 or Older'
    gender           CHAR(1)        NOT NULL,   -- 'M','F','U' (U=Unknown found in real data)
    race             VARCHAR(50)    NOT NULL,   -- 'White','Black/African American','Other Race','Unknown'
    ethnicity        VARCHAR(30)    NOT NULL,   -- 'Not Span/Hispanic','Spanish/Hispanic','Unknown'
    zip_code_3digit  VARCHAR(10)    NOT NULL,   -- 3-digit zip; 'Unknown' if source NULL
    CONSTRAINT PK_DimPatient PRIMARY KEY (patient_key)
);
GO

-- Unique index on demographic combo to avoid duplicate dimension rows
CREATE UNIQUE NONCLUSTERED INDEX UX_DimPatient_Demographics
    ON dbo.DimPatient (age_group, gender, race, ethnicity, zip_code_3digit);
GO

PRINT 'DimPatient created.';
GO

-- ── DimDiagnosis ─────────────────────────────────────────────
-- Contains 3-level hierarchy: MDC (25) → DRG (306) → CCS (253)
-- 1,918 unique MDC+DRG+CCS combinations in the dataset
IF OBJECT_ID('dbo.DimDiagnosis', 'U') IS NOT NULL
    DROP TABLE dbo.DimDiagnosis;
GO

CREATE TABLE dbo.DimDiagnosis (
    diagnosis_key               INT            NOT NULL IDENTITY(1,1),  -- Surrogate key
    -- Level 3 (lowest): CCS Diagnosis
    ccs_diagnosis_code          VARCHAR(10)    NOT NULL,
    ccs_diagnosis_description   VARCHAR(50)    NOT NULL,
    -- Level 2: APR DRG
    apr_drg_code                VARCHAR(10)    NOT NULL,
    apr_drg_description         VARCHAR(150)   NOT NULL,
    -- Level 1 (highest): APR MDC
    apr_mdc_code                VARCHAR(10)    NOT NULL,
    apr_mdc_description         VARCHAR(150)   NOT NULL,
    -- Severity & Clinical classification
    severity_of_illness_code    INT            NOT NULL,   -- 1=Minor, 2=Moderate, 3=Major, 4=Extreme
    severity_of_illness_desc    VARCHAR(20)    NOT NULL,   -- 'Minor','Moderate','Major','Extreme'
    risk_of_mortality           VARCHAR(20)    NOT NULL,   -- 'Minor','Moderate','Major','Extreme'
    medical_surgical_desc       VARCHAR(20)    NOT NULL,   -- 'Medical' or 'Surgical'
    CONSTRAINT PK_DimDiagnosis PRIMARY KEY (diagnosis_key)
);
GO

CREATE NONCLUSTERED INDEX IX_DimDiagnosis_CCS
    ON dbo.DimDiagnosis (ccs_diagnosis_code, apr_drg_code);
GO

PRINT 'DimDiagnosis created.';
GO

-- ── DimProcedure ─────────────────────────────────────────────
-- 210 unique CCS procedure codes including 'NO PROC' (000)
IF OBJECT_ID('dbo.DimProcedure', 'U') IS NOT NULL
    DROP TABLE dbo.DimProcedure;
GO

CREATE TABLE dbo.DimProcedure (
    procedure_key               INT            NOT NULL IDENTITY(1,1),  -- Surrogate key
    ccs_procedure_code          VARCHAR(10)    NOT NULL,
    ccs_procedure_description   VARCHAR(50)    NOT NULL,
    CONSTRAINT PK_DimProcedure PRIMARY KEY (procedure_key)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_DimProcedure_Code
    ON dbo.DimProcedure (ccs_procedure_code);
GO

PRINT 'DimProcedure created.';
GO

-- ── DimPayment ───────────────────────────────────────────────
-- 10 payer types + derived payment_category enrichment
-- payment_category populated by joining PaymentCategoryMapping (Source 3)
IF OBJECT_ID('dbo.DimPayment', 'U') IS NOT NULL
    DROP TABLE dbo.DimPayment;
GO

CREATE TABLE dbo.DimPayment (
    payment_key          INT            NOT NULL IDENTITY(1,1),  -- Surrogate key
    source_of_payment_1  VARCHAR(50)    NOT NULL,                -- Always populated
    source_of_payment_2  VARCHAR(50)    NULL,                    -- 18.8% NULL in source
    source_of_payment_3  VARCHAR(50)    NULL,                    -- 68.4% NULL in source
    payment_category     VARCHAR(30)    NOT NULL,                -- 'Government','Private Insurance','Self-Pay','Unknown'
    CONSTRAINT PK_DimPayment PRIMARY KEY (payment_key)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_DimPayment_Combo
    ON dbo.DimPayment (source_of_payment_1, source_of_payment_2, source_of_payment_3)
    WHERE source_of_payment_2 IS NOT NULL AND source_of_payment_3 IS NOT NULL;
GO

PRINT 'DimPayment created.';
GO


-- ============================================================
--  FACT TABLE (created LAST — references all dimensions)
-- ============================================================

-- ── FactAdmission ────────────────────────────────────────────
-- Grain: 1 row = 1 patient hospital admission/discharge event
-- 49,999 rows from source dataset
-- Includes Task 6 accumulating columns
IF OBJECT_ID('dbo.FactAdmission', 'U') IS NOT NULL
    DROP TABLE dbo.FactAdmission;
GO

CREATE TABLE dbo.FactAdmission (
    -- Surrogate primary key
    admission_key               INT             NOT NULL IDENTITY(1,1),

    -- Foreign keys to dimension tables
    hospital_key                INT             NOT NULL,
    patient_key                 INT             NOT NULL,
    date_key                    INT             NOT NULL,
    diagnosis_key               INT             NOT NULL,
    procedure_key               INT             NOT NULL,
    payment_key                 INT             NOT NULL,

    -- Natural key from source (txn_id from source1_admissions.csv)
    -- Used for Task 6 accumulating fact updates
    txn_id                      INT             NOT NULL,

    -- Degenerate dimensions (descriptive — stored in fact, not worth separate dim)
    type_of_admission           VARCHAR(20)     NOT NULL,   -- 'Emergency','Elective','Urgent','Newborn','Not Available'
    patient_disposition         VARCHAR(50)     NOT NULL,   -- 18 possible values, max 37 chars
    emergency_dept_indicator    CHAR(1)         NOT NULL,   -- 'Y' or 'N'
    abortion_edit_indicator     CHAR(1)         NOT NULL,   -- 'Y' or 'N'
    birth_weight                INT             NOT NULL,   -- grams; 0 if not newborn (max 9900)

    -- ── MEASURES ────────────────────────────────────────────
    length_of_stay              INT             NOT NULL,   -- days; range 1–120
    total_charges               DECIMAL(12,2)   NOT NULL,   -- USD; range $1,013–$1,451,544
    total_costs                 DECIMAL(12,2)   NOT NULL,   -- USD; range $181–$450,188

    -- ── TASK 6: Accumulating Fact Columns ───────────────────
    accm_txn_create_time        DATETIME        NOT NULL,   -- Set to GETDATE() at load time
    accm_txn_complete_time      DATETIME        NULL,       -- Updated later via Package 3
    txn_process_time_hours      DECIMAL(10,2)   NULL,       -- Calculated: complete - create (hours)

    -- ── CONSTRAINTS ─────────────────────────────────────────
    CONSTRAINT PK_FactAdmission PRIMARY KEY (admission_key),

    CONSTRAINT FK_Fact_Hospital
        FOREIGN KEY (hospital_key) REFERENCES dbo.DimHospital(hospital_key),

    CONSTRAINT FK_Fact_Patient
        FOREIGN KEY (patient_key) REFERENCES dbo.DimPatient(patient_key),

    CONSTRAINT FK_Fact_Date
        FOREIGN KEY (date_key) REFERENCES dbo.DimDate(date_key),

    CONSTRAINT FK_Fact_Diagnosis
        FOREIGN KEY (diagnosis_key) REFERENCES dbo.DimDiagnosis(diagnosis_key),

    CONSTRAINT FK_Fact_Procedure
        FOREIGN KEY (procedure_key) REFERENCES dbo.DimProcedure(procedure_key),

    CONSTRAINT FK_Fact_Payment
        FOREIGN KEY (payment_key) REFERENCES dbo.DimPayment(payment_key)
);
GO

-- Indexes for common query patterns
CREATE NONCLUSTERED INDEX IX_Fact_Hospital  ON dbo.FactAdmission (hospital_key);
CREATE NONCLUSTERED INDEX IX_Fact_Patient   ON dbo.FactAdmission (patient_key);
CREATE NONCLUSTERED INDEX IX_Fact_Date      ON dbo.FactAdmission (date_key);
CREATE NONCLUSTERED INDEX IX_Fact_Diagnosis ON dbo.FactAdmission (diagnosis_key);
CREATE NONCLUSTERED INDEX IX_Fact_TxnId     ON dbo.FactAdmission (txn_id);   -- For Task 6 updates
GO

PRINT 'FactAdmission created.';
GO


-- ============================================================
--  POPULATE DimDate
--  (Only 2009 in dataset — populate all 12 months)
-- ============================================================
INSERT INTO dbo.DimDate (date_key, discharge_year, quarter, month, month_name, year_quarter, year_month)
VALUES
    (20090101, 2009, 1,  1,  'January',   '2009-Q1', '2009-01'),
    (20090201, 2009, 1,  2,  'February',  '2009-Q1', '2009-02'),
    (20090301, 2009, 1,  3,  'March',     '2009-Q1', '2009-03'),
    (20090401, 2009, 2,  4,  'April',     '2009-Q2', '2009-04'),
    (20090501, 2009, 2,  5,  'May',       '2009-Q2', '2009-05'),
    (20090601, 2009, 2,  6,  'June',      '2009-Q2', '2009-06'),
    (20090701, 2009, 3,  7,  'July',      '2009-Q3', '2009-07'),
    (20090801, 2009, 3,  8,  'August',    '2009-Q3', '2009-08'),
    (20090901, 2009, 3,  9,  'September', '2009-Q3', '2009-09'),
    (20091001, 2009, 4,  10, 'October',   '2009-Q4', '2009-10'),
    (20091101, 2009, 4,  11, 'November',  '2009-Q4', '2009-11'),
    (20091201, 2009, 4,  12, 'December',  '2009-Q4', '2009-12');
GO

PRINT 'DimDate populated with 12 rows for year 2009.';
GO


-- ============================================================
--  VERIFICATION QUERIES
--  Run these after SSIS ETL loads all data to confirm success
-- ============================================================

-- 1. Check all tables exist and row counts
SELECT
    t.name          AS TableName,
    p.rows          AS RowCount
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)
ORDER BY
    CASE t.name
        WHEN 'DimDate'      THEN 1
        WHEN 'DimHospital'  THEN 2
        WHEN 'DimPatient'   THEN 3
        WHEN 'DimDiagnosis' THEN 4
        WHEN 'DimProcedure' THEN 5
        WHEN 'DimPayment'   THEN 6
        WHEN 'FactAdmission'THEN 7
        ELSE 8
    END;
GO

-- 2. Verify DimDate
SELECT * FROM dbo.DimDate ORDER BY date_key;
GO

-- 3. Verify DimHospital SCD Type 2 structure
SELECT
    hospital_key, facility_id, facility_name,
    hospital_county, health_service_area,
    effective_start_date, effective_end_date, is_current
FROM dbo.DimHospital
ORDER BY facility_id, effective_start_date;
GO

-- 4. After ETL: Verify FactAdmission row count and measures
SELECT
    COUNT(*)                    AS TotalAdmissions,
    AVG(CAST(length_of_stay AS FLOAT))   AS AvgLengthOfStay,
    AVG(total_charges)          AS AvgTotalCharges,
    AVG(total_costs)            AS AvgTotalCosts,
    MIN(total_charges)          AS MinCharges,
    MAX(total_charges)          AS MaxCharges
FROM dbo.FactAdmission;
GO

-- 5. After ETL: Admissions by hospital (join fact to dimension)
SELECT
    h.facility_name,
    COUNT(*)            AS Admissions,
    AVG(f.total_charges)AS AvgCharges,
    AVG(CAST(f.length_of_stay AS FLOAT)) AS AvgLOS
FROM dbo.FactAdmission f
JOIN dbo.DimHospital h ON f.hospital_key = h.hospital_key AND h.is_current = 1
GROUP BY h.facility_name
ORDER BY Admissions DESC;
GO

-- 6. After ETL: Admissions by diagnosis MDC (top 10)
SELECT TOP 10
    d.apr_mdc_description           AS MajorDiagnosticCategory,
    COUNT(*)                        AS Admissions,
    AVG(f.total_charges)            AS AvgCharges,
    AVG(CAST(f.length_of_stay AS FLOAT)) AS AvgLOS
FROM dbo.FactAdmission f
JOIN dbo.DimDiagnosis d ON f.diagnosis_key = d.diagnosis_key
GROUP BY d.apr_mdc_description
ORDER BY Admissions DESC;
GO

-- 7. After ETL: Payment category breakdown
SELECT
    p.payment_category,
    COUNT(*)            AS Admissions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS PctOfTotal
FROM dbo.FactAdmission f
JOIN dbo.DimPayment p ON f.payment_key = p.payment_key
GROUP BY p.payment_category
ORDER BY Admissions DESC;
GO

-- 8. After Task 6: Verify accumulating fact updates
SELECT
    txn_id,
    accm_txn_create_time,
    accm_txn_complete_time,
    txn_process_time_hours
FROM dbo.FactAdmission
WHERE accm_txn_complete_time IS NOT NULL
ORDER BY txn_id;
GO

-- 9. Star Schema — Sample join across all dimensions
SELECT TOP 20
    h.facility_name,
    p.age_group,
    p.gender,
    d.apr_mdc_description,
    pr.ccs_procedure_description,
    py.payment_category,
    f.type_of_admission,
    f.length_of_stay,
    f.total_charges,
    f.total_costs
FROM dbo.FactAdmission f
JOIN dbo.DimHospital  h  ON f.hospital_key  = h.hospital_key  AND h.is_current = 1
JOIN dbo.DimPatient   p  ON f.patient_key   = p.patient_key
JOIN dbo.DimDate      dt ON f.date_key      = dt.date_key
JOIN dbo.DimDiagnosis d  ON f.diagnosis_key = d.diagnosis_key
JOIN dbo.DimProcedure pr ON f.procedure_key = pr.procedure_key
JOIN dbo.DimPayment   py ON f.payment_key   = py.payment_key
ORDER BY f.total_charges DESC;
GO

PRINT '============================================';
PRINT ' NYHospitalDW schema created successfully!';
PRINT ' Tables: DimDate, DimHospital, DimPatient,';
PRINT '         DimDiagnosis, DimProcedure,';
PRINT '         DimPayment, FactAdmission';
PRINT '============================================';
GO
