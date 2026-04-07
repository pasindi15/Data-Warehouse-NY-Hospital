-- ============================================================
--  Task 4: Verification Queries (Fixed)
--  Run these in SSMS after connecting to NYHospitalDW
-- ============================================================

USE NYHospitalDW;
GO

-- ── Query 1: Check all tables and row counts ─────────────────
-- (Fixed: renamed reserved word RowCount to Row_Count)
SELECT
    t.name                  AS TableName,
    p.rows                  AS Row_Count
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)
ORDER BY
    CASE t.name
        WHEN 'DimDate'       THEN 1
        WHEN 'DimHospital'   THEN 2
        WHEN 'DimPatient'    THEN 3
        WHEN 'DimDiagnosis'  THEN 4
        WHEN 'DimProcedure'  THEN 5
        WHEN 'DimPayment'    THEN 6
        WHEN 'FactAdmission' THEN 7
        ELSE 8
    END;
GO

-- ── Query 2: View DimDate (should show 12 rows) ──────────────
SELECT * FROM dbo.DimDate ORDER BY date_key;
GO

-- ── Query 3: Confirm all tables exist ────────────────────────
SELECT name AS TableName, create_date AS CreatedOn
FROM sys.tables
ORDER BY create_date;
GO
