USE NYHospitalDW;
GO

INSERT INTO dbo.FactAdmission (
    hospital_key, patient_key, date_key, diagnosis_key,
    procedure_key, payment_key, txn_id, type_of_admission,
    patient_disposition, emergency_dept_indicator,
    abortion_edit_indicator, birth_weight,
    length_of_stay, total_charges, total_costs,
    accm_txn_create_time
)
SELECT
    h.hospital_key,
    p.patient_key,
    d.date_key,
    diag.diagnosis_key,
    pr.procedure_key,
    pay.payment_key,
    TRY_CAST(s.txn_id AS INT),
    s.type_of_admission,
    s.patient_disposition,
    s.emergency_dept_indicator,
    s.abortion_edit_indicator,
    TRY_CAST(s.birth_weight AS INT),
    TRY_CAST(s.length_of_stay AS INT),
    TRY_CAST(s.total_charges AS DECIMAL(12,2)),
    TRY_CAST(s.total_costs AS DECIMAL(12,2)),
    GETDATE()
FROM dbo.StagingAdmissions s
JOIN dbo.DimHospital h
    ON TRY_CAST(s.facility_id AS INT) = h.facility_id
    AND h.is_current = 1
JOIN dbo.DimPatient p
    ON s.age_group = p.age_group
    AND s.gender = p.gender
    AND s.race = p.race
    AND s.ethnicity = p.ethnicity
JOIN dbo.DimDate d
    ON TRY_CAST(s.discharge_year AS INT) * 100 + 1 = d.date_key
JOIN dbo.DimDiagnosis diag
    ON s.ccs_diagnosis_code = diag.ccs_diagnosis_code
JOIN dbo.DimProcedure pr
    ON s.ccs_procedure_code = pr.ccs_procedure_code
JOIN dbo.DimPayment pay
    ON s.source_of_payment_1 = pay.source_of_payment_1;
GO

SELECT COUNT(*) AS FactRows FROM dbo.FactAdmission;
GO