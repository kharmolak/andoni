/**************************************************************************
DataBase2 Project	: Create Data Warehouse - Clinic Procedures
Authors					: Sajede Nicknadaf, Maryam Saeedmehr
Student Numbers	: 9637453, 9629373
Semester					: fall 1399
version						: 1
***************************************************************************/
USE HospitalDW
GO

---------------------------------------------
-- Clinic Mart : Dimensions
---------------------------------------------
-- Dimensions First Loader Procedures
CREATE OR ALTER PROCEDURE Clinic.dimDepartments_FirstLoader
	AS
	BEGIN
		BEGIN TRY
			TRUNCATE TABLE Clinic.dimDepartments

			INSERT INTO Clinic.dimDepartments
				VALUES(-1,'Unknown','Unknown','Unknown',
					   NULL,'Unknown','Unknown',NULL,
					   'Unknown','Unknown','Unknown',NULL,
					   NULL,'Unknown',NULL,'Unknown')

			INSERT INTO Clinic.dimDepartments
				SELECT 	[department_ID]
						,[name]
						,[description]
						,NULL
						,NULL
						,[chairman]
						,NULL
						,NULL
						,[assistant]
						,[chairman_phone_number]
						,[assistant_phone_number]
						,[chairman_room]
						,[assistant_room]
						,[reception_phone_number]
						,[budget]
						,[additional_info]
				FROM HospitalSA.dbo.Departments
		---------------------------------------------------
			INSERT INTO [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimDepartments'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimDepartments', 0, 'Error while inserting or updating', @@ROWCOUNT);
			SELECT ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
GO

CREATE OR ALTER PROCEDURE Clinic.dimDoctorContracts_FirstLoader
	AS
	BEGIN
		BEGIN TRY
			TRUNCATE TABLE Clinic.dimDoctorContracts

			INSERT INTO Clinic.dimDoctorContracts
				VALUES(-1,NULL,NULL,NULL,NULL,NULL,'Unknown','Unknown')

			INSERT INTO Clinic.dimDoctorContracts
				SELECT 	[doctorContract_ID]
						,[contract_start_date]
						,[contract_end_date]
						,[appointment_portion]
						,[salary]
						,[active]
						,CASE
							WHEN [active] = 0 THEN 'Not Active'
							ELSE 'Active'
						 END AS [active_description]
						,[additional_info]
				FROM HospitalSA.DoctorContracts
			---------------------------------------------------
			INSERT INTO [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimDoctorContracts'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimDoctorContracts', 0, 'Error while inserting or updating', @@ROWCOUNT);
			SELECT ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
GO

CREATE OR ALTER PROCEDURE Clinic.dimDoctors_FirstLoader @curr_date DATE
	AS
	BEGIN
		BEGIN TRY
			TRUNCATE TABLE Clinic.dimDoctors

			INSERT INTO [Clinic].[dimDoctors]
           ([doctor_ID]
           ,[doctorContract_ID]
           ,[national_code]
           ,[license_code]
           ,[first_name]
           ,[last_name]
           ,[birthdate]
           ,[phone_number]
           ,[department_ID]
           ,[department_name]
           ,[education_degree]
           ,[specialty_description]
           ,[graduation_date]
           ,[university]
           ,[gender]
           ,[religion]
           ,[nationality]
           ,[marital_status]
           ,[marital_status_description]
           ,[postal_code]
           ,[address]
           ,[additional_info]
           ,[start_date]
           ,[end_date]
           ,[current_flag]
           ,[Contract_Degree]
           ,[Contract_Degree_description])
     VALUES
           (-1
           ,-1
           ,'Unknown'
           ,'Unknown'
           ,'Unknown'
           ,'Unknown'
           ,NULL
           ,'Unknown'
           ,-1
           ,'Unknown'
           ,NULL
           ,'Unknown'
           ,NULL
           ,'Unknown'
           ,'Unknown'
           ,'Unknown'
           ,'Unknown'
           ,NULL
           ,'Unknown'
           ,'Unknown'
           ,'Unknown'
           ,'Unknown'
           ,NULL
           ,NULL
           ,1
           ,-1
           ,'Unknown')

			INSERT INTO Clinic.dimDoctors(
						 [doctor_ID],[doctorContract_ID],[national_code]
						,[license_code],[first_name],[last_name]
						,[birthdate],[phone_number],[department_ID]
						,[department_name],[education_degree]
						,[specialty_description],[graduation_date]
						,[university],[gender],[religion],[nationality]
						,[marital_status],[marital_status_description]
						,[postal_code],[address],[additional_info]
						,[start_date],[end_date],[current_flag]
						,[Contract_Degree],[Contract_Degree_description])

				SELECT 	 [doctor_ID]
						,[doctorContract_ID]
						,[national_code]
						,[license_code]
						,[first_name]
						,[last_name]
						,[birthdate]
						,[phone_number]
						,doc.[department_ID]
						,dep.[name]
						,[education_degree]
						,[specialty_description]
						,[graduation_date]
						,[university]
						,[gender]
						,[religion]
						,[nationality]
						,[marital_status]
						,[marital_status_description]
						,[postal_code]
						,[address]
						,[additional_info]
						,@curr_date
						,NULL
						,1
						,0 AS [Contract_Degree]
						,'First Load'
				FROM HospitalSA.Doctors doc 
				INNER JOIN HospitalSA.Departments dep 
				ON doc.department_ID = dep.department_ID
			---------------------------------------------------
			INSERT INTO [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimDoctors'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH 
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimDoctors', 0, 'Error while inserting or updating', @@ROWCOUNT);
			SELECT ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
GO

CREATE OR ALTER PROCEDURE Clinic.dimIllnessTypes_FirstLoader
	AS 
	BEGIN
		BEGIN TRY
			TRUNCATE TABLE Clinic.dimIllnessTypes

			INSERT INTO Clinic.dimIllnessTypes
				VALUES(-1,'Unknown','Unknown',-1)

			INSERT INTO Clinic.dimIllnessTypes
				SELECT  [illnessType_ID]
						,[name]
						,[description]
						,[related_department_ID]
				FROM HospitalSA.IllnessTypes
			---------------------------------------------------
			INSERT INTO [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimIllnessTypes'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimIllnessTypes', 0, 'Error while inserting or updating', @@ROWCOUNT);
			SELECT ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
GO

CREATE OR ALTER PROCEDURE Clinic.dimIllnesses_FirstLoader
	AS
	BEGIN
		BEGIN TRY 
			TRUNCATE TABLE Clinic.dimIllnesses

			INSERT INTO Clinic.dimIllnesses
				VALUES(-1,'Unknown',-1,'Unknown','Unknown'
					   ,NULL,'Unknown',NULL,'Unknown',NULL,'Unknown')

			INSERT INTO Clinic.dimIllnesses
				SELECT   [illness_ID]
						,[name]
						,i.[illnessType_ID]
						,it.[name] AS [illnessType_name]
						,[scientific_name]
						,[special_illness]
						,CASE
							WHEN [special_illness] = 0 THEN 'Not special'
							ELSE 'Special'
						 END
						,[killing_status]
						,[killing_description]
						,[chronic]
						,[chronic_description]
				FROM HospitalSA.Illnesses i
				INNER JOIN HospitalSA.IllnessTypes it
				ON i.illnessType_ID = it.illnessType_ID
			---------------------------------------------------
			INSERT INTO [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimIllnesses'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH 
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimIllnesses', 0, 'Error while inserting or updating', @@ROWCOUNT);
			SELECT ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
GO

-- Dimensions Usual Loader Procedures
CREATE OR ALTER PROCEDURE Clinic.dimDepartments_Loader @curr_date DATE
	AS
	BEGIN
		BEGIN TRY
			MERGE Clinic.dimDepartments AS dw
			USING HospitalSA.dbo.Departments AS sa 
			ON dw.department_ID = sa.department_ID

			WHEN MATCHED AND (
				dw.current_chairman	<> sa.chairman
				OR dw.current_assistant <> sa.assistant
				OR dw.chairman_phone_number <> sa.chairman_phone_number
				OR dw.assistant_phone_number <> sa.assistant_phone_number
				OR dw.reception_phone_number <> sa.reception_phone_number
			) 
			THEN UPDATE SET 
				-- SCD3
				dw.previous_chairman = 	CASE 
											WHEN dw.current_chairman <> sa.chairman 
												THEN dw.current_chairman 
											ELSE dw.previous_chairman
									 	END,
				dw.chairman_change_date = 	CASE 
												WHEN dw.current_chairman <> sa.chairman 
													THEN @curr_date 
												ELSE dw.chairman_change_date
									 		END,
				dw.current_chairman	= 	CASE 
											WHEN dw.current_chairman <> sa.chairman 
												THEN sa.chairman 
											ELSE dw.current_chairman
									 	END,
				dw.previous_assistant = CASE 
											WHEN dw.current_assistant <> sa.assistant 
												THEN dw.current_assistant
											ELSE dw.previous_assistant
									 	END,
				dw.assistant_change_date = 	CASE 
												WHEN dw.current_assistant <> sa.assistant 
													THEN @curr_date
												ELSE dw.assistant_change_date
									 		END,
				dw.current_assistant = 	CASE 
											WHEN dw.current_assistant <> sa.assistant 
												THEN sa.assistant
											ELSE dw.current_assistant
									 	END,
				-- SCD1
				dw.chairman_phone_number = sa.chairman_phone_number,
				dw.assistant_phone_number = sa.assistant_phone_number,
				dw.reception_phone_number = sa.reception_phone_number
			WHEN NOT MATCHED BY TARGET 
			THEN INSERT (
				 [department_ID]
				,[name]
				,[description]
				,[previous_chairman]
				,[chairman_change_date]
				,[current_chairman]
				,[previous_assistant]
				,[assistant_change_date]
				,[current_assistant]
				,[chairman_phone_number]
				,[assistant_phone_number]
				,[chairman_room]
				,[assistant_room]
				,[reception_phone_number]
				,[budget]
				,[additional_info]
			) VALUES (
				 sa.[department_ID]
				,sa.[name]
				,sa.[description]
				,NULL
				,NULL
				,sa.[chairman]
				,NULL
				,NULL
				,sa.[assistant]
				,sa.[chairman_phone_number]
				,sa.[assistant_phone_number]
				,sa.[chairman_room]
				,sa.[assistant_room]
				,sa.[reception_phone_number]
				,sa.[budget]
				,sa.[additional_info]
			);
		---------------------------------------------------
			INSERT INTO [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimDepartments'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimDepartments', 0, 'Error while inserting or updating', @@ROWCOUNT);
			SELECT ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
GO

CREATE OR ALTER PROCEDURE Clinic.dimDoctorContracts_Loader
	AS
	BEGIN
		BEGIN TRY
			MERGE Clinic.dimDoctorContracts AS dw
			USING HospitalSA.dbo.DoctorContracts AS sa 
			ON dw.doctorContract_ID = sa.doctorContract_ID
			WHEN NOT MATCHED BY TARGET 
			THEN INSERT (
				 [doctorContract_ID]
				,[contract_start_date]
				,[contract_end_date]
				,[appointment_portion]
				,[salary]
				,[active]
				,[active_description]
				,[additional_info]
			) VALUES (
				 sa.[doctorContract_ID]
				,sa.[contract_start_date]
				,sa.[contract_end_date]
				,sa.[appointment_portion]
				,sa.[salary]
				,sa.[active]
				,CASE
					WHEN sa.[active] = 0 THEN 'Not Active'
					ELSE 'Active'
					END 
				,sa.[additional_info]
			);
			---------------------------------------------------
			INSERT INTO [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimDoctorContracts'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimDoctorContracts', 0, 'Error while inserting or updating', @@ROWCOUNT);
			SELECT ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
GO

CREATE OR ALTER PROCEDURE Clinic.dimDoctors_Loader @curr_date DATE
	AS
	BEGIN
		BEGIN TRY
			DECLARE @RowAffected INT;
			SET @RowAffected = 0;

			SELECT 	 [doctor_ID]
					,[doctorContract_ID]
					,[national_code]
					,[license_code]
					,[first_name]
					,[last_name]
					,[birthdate]
					,[phone_number]
					,doc.[department_ID]
					,dep.[name]
					,[education_degree]
					,[specialty_description]
					,[graduation_date]
					,[university]
					,[gender]
					,[religion]
					,[nationality]
					,[marital_status]
					,[marital_status_description]
					,[postal_code]
					,[address]
					,[additional_info]
					,[start_date]
					,[end_date]
					,[current_flag]
					,[Contract_Degree]
					,[Contract_Degree_description]
			INTO #tmp
			FROM HospitalSA.Doctors doc
			INNER JOIN HospitalSA.Departments dep
			ON doc.department_ID = dep.department_ID

			MERGE INTO Clinic.dimDoctors AS dw
			USING #tmp AS sa
			ON  dw.doctor_ID = sa.doctor_ID 
			AND dw.[current_flag] = 1

			WHEN MATCHED AND(
				dw.doctorContract_ID <> sa.doctorContract_ID 
				OR dw.education_degree <> sa.education_degree
				OR dw.phone_number <> sa.phone_number
			)
			THEN UPDATE SET 
				-- SCD2
				end_date = 	CASE
								WHEN dw.doctorContract_ID <> sa.doctorContract_ID 
								OR dw.education_degree <> sa.education_degree
								THEN @curr_date
								ELSE dw.end_date
							END, 
				current_flag = 	CASE
									WHEN dw.doctorContract_ID <> sa.doctorContract_ID 
									OR dw.education_degree <> sa.education_degree
									THEN 0
									ELSE 1
								END,
				Contract_Degree = CASE
									WHEN dw.doctorContract_ID <> sa.doctorContract_ID 
									AND dw.education_degree = sa.education_degree
									THEN 1
									WHEN dw.doctorContract_ID = sa.doctorContract_ID 
									AND dw.education_degree <> sa.education_degree
									THEN 2
									WHEN dw.doctorContract_ID <> sa.doctorContract_ID 
									AND dw.education_degree <> sa.education_degree
									THEN 3
									ELSE 0
								  END,
				Contract_Degree_description = CASE
									WHEN dw.doctorContract_ID <> sa.doctorContract_ID 
									AND dw.education_degree = sa.education_degree
									THEN 'Contract'
									WHEN dw.doctorContract_ID = sa.doctorContract_ID 
									AND dw.education_degree <> sa.education_degree
									THEN 'Degree'
									WHEN dw.doctorContract_ID <> sa.doctorContract_ID 
									AND dw.education_degree <> sa.education_degree
									THEN 'Both'
									ELSE 'First Load'
								  END,
				-- SCD1
				dw.phone_number = sa.phone_number
			WHEN NOT MATCHED BY Target 
			THEN  INSERT 
			(
				 [doctor_ID]
				,[doctorContract_ID]
				,[national_code]
				,[license_code]
				,[first_name]
				,[last_name]
				,[birthdate]
				,[phone_number]
				,[department_ID]
				,[department_name]
				,[education_degree]
				,[specialty_description]
				,[graduation_date]
				,[university]
				,[gender]
				,[religion]
				,[nationality]
				,[marital_status]
				,[marital_status_description]
				,[postal_code]
				,[address]
				,[additional_info]
				,[start_date]
				,[end_date]
				,[current_flag]
				,[Contract_Degree]
				,[Contract_Degree_description]
			)
			VALUES 
			(
				 sa.[doctor_ID]
				,sa.[doctorContract_ID]
				,sa.[national_code]
				,sa.[license_code]
				,sa.[first_name]
				,sa.[last_name]
				,sa.[birthdate]
				,sa.[phone_number]
				,sa.[department_ID]
				,sa.[department_name]
				,sa.[education_degree]
				,sa.[specialty_description]
				,sa.[graduation_date]
				,sa.[university]
				,sa.[gender]
				,sa.[religion]
				,sa.[nationality]
				,sa.[marital_status]
				,sa.[marital_status_description]
				,sa.[postal_code]
				,sa.[address]
				,sa.[additional_info]
				,@curr_date
				,NULL
				,1
				,0
				,'First Load'
			);
			SET @RowAffected = @@ROWCOUNT;
			INSERT INTO HospitalDW.Clinic.dimDoctors
				SELECT   sa.[doctor_ID]
						,sa.[doctorContract_ID]
						,sa.[national_code]
						,sa.[license_code]
						,sa.[first_name]
						,sa.[last_name]
						,sa.[birthdate]
						,sa.[phone_number]
						,sa.[department_ID]
						,sa.[department_name]
						,sa.[education_degree]
						,sa.[specialty_description]
						,sa.[graduation_date]
						,sa.[university]
						,sa.[contract_start_date]
						,sa.[contract_end_date]
						,sa.[appointment_portion]
						,sa.[gender]
						,sa.[religion]
						,sa.[nationality]
						,sa.[marital_status]
						,sa.[marital_status_description]
						,sa.[postal_code]
						,sa.[address]
						,sa.[additional_info]
						,@curr_date
						,NULL
						,1
						,0
						,'First Load'
				FROM HospitalDW.Clinic.dimDoctors dw 
				INNER JOIN #tmp sa
				ON dw.doctor_ID = sa.doctor_ID 
				AND dw.[end_date] = @curr_date;

			DROP TABLE #tmp;
			---------------------------------------------------
			INSERT INTO [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimDoctors'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT + @RowAffected)
		END TRY
		BEGIN CATCH 
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimDoctors', 0, 'Error while inserting or updating', @@ROWCOUNT + @RowAffected);
			SELECT ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
GO

CREATE OR ALTER PROCEDURE Clinic.dimIllnessTypes_Loader
	AS 
	BEGIN
		BEGIN TRY
			MERGE Clinic.dimIllnessTypes AS dw
			USING HospitalSA.dbo.IllnessTypes AS sa 
			ON dw.illnessType_ID = sa.illnessType_ID
			WHEN NOT MATCHED BY TARGET 
			THEN INSERT (
				 [illnessType_ID]
				,[name]
				,[description]
				,[related_department_ID]
			) VALUES (
				 sa.[illnessType_ID]
				,sa.[name]
				,sa.[description]
				,sa.[related_department_ID]
			);
			---------------------------------------------------
			INSERT INTO [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimIllnessTypes'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimIllnessTypes', 0, 'Error while inserting or updating', @@ROWCOUNT);
			SELECT ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
GO

CREATE OR ALTER PROCEDURE Clinic.dimIllnesses_Loader
	AS
	BEGIN
		BEGIN TRY 
			SELECT [illness_ID]
					,[name]
					,i.[illnessType_ID]
					,it.[name] AS [illnessType_name]
					,[scientific_name]
					,[special_illness]
					,[killing_status]
					,[killing_description]
					,[chronic]
					,[chronic_description]
			INTO #tmp
			FROM HospitalSA.Illnesses i
			INNER JOIN HospitalSA.IllnessTypes it
			ON i.illnessType_ID = it.illnessType_ID

			MERGE Clinic.dimIllnesses AS dw
			USING #tmp AS sa 
			ON dw.illness_ID = sa.illness_ID
			WHEN NOT MATCHED BY TARGET 
			THEN INSERT (
				 [illnessType_ID]
				,[name]
				,[description]
				,[related_department_ID]
			) VALUES (
				 sa.[illnessType_ID]
				,sa.[name]
				,sa.[description]
				,sa.[related_department_ID]
			);

			DROP TABLE #tmp;
			---------------------------------------------------
			INSERT INTO [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimIllnesses'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH 
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimIllnesses', 0, 'Error while inserting or updating', @@ROWCOUNT);
			SELECT ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
GO

---------------------------------------------
-- Clinic Mart : Facts
---------------------------------------------
