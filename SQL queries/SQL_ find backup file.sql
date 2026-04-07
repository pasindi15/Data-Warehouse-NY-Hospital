-- Find the backup file location
SELECT physical_device_name AS BackupFilePath
FROM msdb.dbo.backupmediafamily
ORDER BY media_set_id DESC;
GO

C:\Program Files\Microsoft SQL Server\MSSQL17.DWBI\MSSQL\Backup\NYHospitalDW.bak