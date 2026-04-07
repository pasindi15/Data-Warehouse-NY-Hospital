SELECT
    facility_id,
    CAST(facility_name         AS NVARCHAR(255)) AS facility_name,
    CAST(operating_cert_number AS NVARCHAR(255)) AS operating_cert_number,
    CAST(hospital_county       AS NVARCHAR(255)) AS hospital_county,
    CAST(health_service_area   AS NVARCHAR(255)) AS health_service_area
FROM dbo.HospitalMaster
WHERE is_active = 1