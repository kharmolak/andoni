/**************************************************************************
DataBase2 Project		: Load data from SA to DW - Dimensions 
Authors						: Sajede Nicknadaf,Maryam Saeidmehr,Nastaran Ashoori
Student Numbers		: 9637453,9629373,9631793
Semester						: fall 1399
version							: 1
***************************************************************************/
/**************************Dimension Patients***************************/
CREATE OR ALTER PROCEDURE dbo.uspDimPatientsFirstLoad
AS 
BEGIN
	BEGIN TRY
		TRUNCATE TABLE HospitalDW.dbo.Patients;
		INSERT INTO HospitalDW.dbo.Patients 
			SELECT [patient_ID],
						[national_code],
						[first_name],
						[last_name],
						[birthdate],
						[height],
						[weight],
						[gender],
						[phone_number]
			FROM HospitalSA.dbo.Patients;

		INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [text], [affected_rows])
		VALUES (GETDATE(), 'dbo.Patients', 1, 'Patients First Load', @@ROWCOUNT);
	END TRY
	BEGIN CATCH
		INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [text], [affected_rows])
		VALUES (GETDATE(), 'dbo.Patients', 0, ERROR_MESSAGE(), @@ROWCOUNT);
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.uspDimPatients
AS 
BEGIN 
	MERGE INTO HospitalDW.dbo.Patients AS [Target]
	USING HospitalSA.dbo.Patients AS [Source]
	ON Source.patient_ID = [Target].patient_ID
	WHEN MATCHED AND
		 (
			   [Target].height						<> Source.height
			   OR [Target].[weight]				<> Source.[weight]
			   OR [Target].phone_number <> Source.phone_number
		 ) 
	THEN UPDATE SET 
				height = Source.[height],
				[weight] = Source.[weight],
				phone_number = Source.[phone_number]
	WHEN NOT MATCHED BY TARGET 
	THEN INSERT (
		[patient_ID]
		,[national_code]
		,[name]
		,[family]
		,[birthdate]
		,[height]
		,[weight]
		,[gender]
		,[phone_number]
	) VALUES (
		Source.[patient_ID],
		Source.[national_code],
		Source.[first_name],
		Source.[last_name],
		Source.[birthdate],
		Source.[height],
		Source.[weight],
		Source.[gender],
		Source.[phone_number]
	);
END
GO

/**************************Dimension Medicines***************************/
CREATE OR ALTER PROCEDURE Pharmacy.uspDimMedicinesFirstLoad
AS 
BEGIN
	INSERT INTO HospitalDW.Pharmacy.Medicines
		SELECT [medicine_ID]
					,[medicineFactory_ID]
					,[name]
					,[latin_name]
					,[dose]
					,[side_effects]
					,[price]
					,[description] 
		FROM HospitalSA.dbo.Medicines;
END
GO

CREATE OR ALTER PROCEDURE Pharmacy.uspDimMedicines
AS 
BEGIN
INSERT INTO HospitalDW.Pharmacy.Medicines
SELECT [medicine_ID]
			,[medicineFactory_ID]
			,[name]
			,[latin_name]
			,[dose]
			,[side_effects]
			,[price]
			,[description]
			,[start_date]
			,[end_date]
			,[current_flag]
FROM
(
  MERGE INTO  HospitalDW.Pharmacy.Medicines AS [Target]
  USING HospitalSA.dbo.Medicines AS Source
  ON  [Target].medicine_ID = Source.medicine_ID
  WHEN MATCHED AND
	(
		[Target].price <> Source. price AND 
		[Target].current_flag = 1
	)
  THEN UPDATE SET 
		end_date = GETDATE(), 
		current_flag = 0
  WHEN NOT MATCHED THEN  
  INSERT 
  (
    [medicine_ID]
	,[medicineFactory_ID]
	,[name]
	,[latin_name]
	,[dose]
	,[side_effects]
	,[price]
	,[description]
  )
  VALUES 
  (
    Source.[medicine_ID], 
    Source.[medicineFactory_ID],
    Source.[name],
    Source.[last_name],
    Source.[dose],
	Source.[side_effects],
	Source.[price],
	Source.[description]
  )
  OUTPUT $ACTION, 
    Source.[medicine_ID], 
    Source.[medicineFactory_ID],
    Source.[name],
    Source.[last_name],
    Source.[dose],
	Source.[side_effects],
	Source.[price],
	Source.[description],
    GETDATE(),
    NULL,
	1
) 
AS CHANGES 
(
	ACTION, 
	[medicine_ID]
	,[medicineFactory_ID]
	,[name]
	,[latin_name]
	,[dose]
	,[side_effects]
	,[price]
	,[description]
	,[start_date]
	,[end_date]
	,[current_flag]
)
WHERE ACTION='UPDATE';
END
GO