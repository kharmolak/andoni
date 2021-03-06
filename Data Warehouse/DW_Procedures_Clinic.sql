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
				([DATE]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimDepartments'
				,1
				,'inserting new VALUES was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([DATE], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimDepartments', 0, 'Error WHILE inserting OR updating', @@ROWCOUNT);
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
						,[active_description]
						,[additional_info]
				FROM HospitalSA.DoctorContracts
			---------------------------------------------------
			INSERT INTO [dbo].[Logs]
				([DATE]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimDoctorContracts'
				,1
				,'inserting new VALUES was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([DATE], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimDoctorContracts', 0, 'Error WHILE inserting OR updating', @@ROWCOUNT);
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
				([DATE]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimDoctors'
				,1
				,'inserting new VALUES was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH 
			INSERT INTO HospitalDW.dbo.Logs([DATE], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimDoctors', 0, 'Error WHILE inserting OR updating', @@ROWCOUNT);
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
				([DATE]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimIllnessTypes'
				,1
				,'inserting new VALUES was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([DATE], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimIllnessTypes', 0, 'Error WHILE inserting OR updating', @@ROWCOUNT);
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
						,[special_illness_description]
						,[killing_status]
						,[killing_description]
						,[chronic]
						,[chronic_description]
				FROM HospitalSA.Illnesses i
				INNER JOIN HospitalSA.IllnessTypes it
				ON i.illnessType_ID = it.illnessType_ID
			---------------------------------------------------
			INSERT INTO [dbo].[Logs]
				([DATE]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimIllnesses'
				,1
				,'inserting new VALUES was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH 
			INSERT INTO HospitalDW.dbo.Logs([DATE], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimIllnesses', 0, 'Error WHILE inserting OR updating', @@ROWCOUNT);
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
				([DATE]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimDepartments'
				,1
				,'inserting new VALUES was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([DATE], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimDepartments', 0, 'Error WHILE inserting OR updating', @@ROWCOUNT);
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
				,sa.[active_description]
				,sa.[additional_info]
			);
			---------------------------------------------------
			INSERT INTO [dbo].[Logs]
				([DATE]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimDoctorContracts'
				,1
				,'inserting new VALUES was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([DATE], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimDoctorContracts', 0, 'Error WHILE inserting OR updating', @@ROWCOUNT);
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
				([DATE]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimDoctors'
				,1
				,'inserting new VALUES was successfull'
				,@@ROWCOUNT + @RowAffected)
		END TRY
		BEGIN CATCH 
			INSERT INTO HospitalDW.dbo.Logs([DATE], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimDoctors', 0, 'Error WHILE inserting OR updating', @@ROWCOUNT + @RowAffected);
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
				([DATE]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimIllnessTypes'
				,1
				,'inserting new VALUES was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([DATE], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimIllnessTypes', 0, 'Error WHILE inserting OR updating', @@ROWCOUNT);
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
				([DATE]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			VALUES
				(GETDATE()
				,'dimIllnesses'
				,1
				,'inserting new VALUES was successfull'
				,@@ROWCOUNT)
		END TRY
		BEGIN CATCH 
			INSERT INTO HospitalDW.dbo.Logs([DATE], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimIllnesses', 0, 'Error WHILE inserting OR updating', @@ROWCOUNT);
			SELECT ERROR_MESSAGE() AS ErrorMessage
		END CATCH
	END
GO

---------------------------------------------
-- Clinic Mart : Facts
---------------------------------------------
-- Facts First Loader Procedures
CREATE OR ALTER PROCEDURE Clinic.factTransactionAppointment_FirstLoader
	AS
	BEGIN
		BEGIN TRY
			DECLARE @curr_date DATE;
			DECLARE @curr_date_key INT;
			DECLARE @end_date DATE;

			SET @curr_date = (
				SELECT MIN(appointment_date)
				FROM HospitalSA.dbo.Appointments
			);

			SET @end_date = (
				SELECT MAX(appointment_date)
				FROM HospitalSA.dbo.Appointments
			);
			
			TRUNCATE TABLE factTransactionAppointment

			--loop in days
			WHILE @curr_date < @end_date BEGIN
				BEGIN TRY
					--find TimeKey
					SET @curr_date_key = (
						SELECT TimeKey
						FROM dbo.dimDate
						WHERE FullDateAlternateKey = @curr_date
					);

					SELECT ISNULL(patient_ID,-1) AS patient_ID,
						   ISNULL(doctor_ID,-1) AS doctor_ID,
						   ISNULL(main_detected_illness,-1) AS main_detected_illness,
						   price,
						   doctor_share,
						   insurance_share,
						   payment_method,
						   payment_method_description,
						   credit_card_number,
						   payer,
						   payer_phone_number,
						   additional_info 
					INTO #tmp_today_appointments
					FROM HospitalSA.dbo.Appointments
					WHERE appointment_date = @curr_date
					
					SELECT p.patient_code,
						   p.patient_ID,
						   p.insurance_ID,
						   i.insuranceCompany_ID
					INTO #tmp_patient_info
					FROM dbo.dimPatients p 
						INNER JOIN dbo.dimInsurances i 
						ON p.insurance_ID = i.insurance_ID
					WHERE p.[start_date] <= @curr_date 
						AND (p.current_flag = 1 
							 OR p.end_date > @curr_date);
					
					SELECT patient_ID,
						   doctor_code,
						   doctor_ID,
						   doctorContract_ID,
						   department_ID,
						   main_detected_illness,
						   price,
						   doctor_share,
						   insurance_share,
						   payment_method,
						   payment_method_description,
						   credit_card_number,
						   payer,
						   payer_phone_number,
						   additional_info 
					INTO #tmp1
					FROM Clinic.dimDoctors d
						INNER JOIN #tmp_today_appointments a
						ON d.doctor_ID = a.doctor_ID
					WHERE [start_date] <= @curr_date 
						AND (current_flag = 1 
							 OR end_date > @curr_date);

					SELECT p.patient_code,
						   p.patient_ID,
						   p.insurance_ID,
						   p.insuranceCompany_ID
						   doctor_code,
						   doctor_ID,
						   doctorContract_ID,
						   department_ID,
						   main_detected_illness,
						   price,
						   doctor_share,
						   insurance_share,
						   payment_method,
						   payment_method_description,
						   credit_card_number,
						   payer,
						   payer_phone_number,
						   additional_info 
					INTO #tmp2
					FROM #tmp_patient_info p
						INNER JOIN #tmp1 d
						ON d.patient_ID = p.patient_ID

					SELECT p.patient_code,
						   p.patient_ID,
						   p.insurance_ID,
						   p.insuranceCompany_ID
						   doctor_code,
						   doctor_ID,
						   doctorContract_ID,
						   department_ID,
						   main_detected_illness,
						   i.illnessType_ID,
						   @curr_date_key AS TimeKey,
						   ---------------
						   price - insurance_share AS paid_price,
						   price AS real_price,
						   doctor_share,
						   insurance_share,
						   price - doctor_share AS income,
						   payment_method,
						   payment_method_description,
						   credit_card_number,
						   payer,
						   payer_phone_number,
						   additional_info 
					INTO #tmp3
					FROM #tmp2 t
						INNER JOIN Clinic.dimIllnesses i
						ON i.illness_ID = t.main_detected_illness

					INSERT INTO Clinic.factTransactionAppointment
						SELECT patient_code,
						   patient_ID,
						   insurance_ID,
						   insuranceCompany_ID
						   doctor_code,
						   doctor_ID,
						   doctorContract_ID,
						   department_ID,
						   main_detected_illness,
						   illnessType_ID,
						   TimeKey,
						   ---------------
						   paid_price,
						   real_price,
						   doctor_share,
						   insurance_share,
						   income,
						   payment_method,
						   payment_method_description,
						   credit_card_number,
						   payer,
						   payer_phone_number,
						   additional_info 
						FROM #tmp3
					--------------------------------------------
					INSERT INTO Logs
					VALUES (GETDATE(),
							'Clinic.factTransactionAppointment',
							1,
							'Transactions of '+CONVERT(VARCHAR,@curr_date)+' inserted',
							@@ROWCOUNT);
					
					--add a day 
					SET @curr_date = DATEADD(DAY, 1, @curr_date);

					--drop temporary tables
					DROP TABLE #tmp_today_appointments
					DROP TABLE #tmp_patient_info
					DROP TABLE #tmp1
					DROP TABLE #tmp2
					DROP TABLE #tmp3

				END TRY
				BEGIN CATCH
					--drop temporary tables
					DROP TABLE IF EXISTS #tmp_today_appointments
					DROP TABLE IF EXISTS #tmp_patient_info
					DROP TABLE IF EXISTS #tmp1
					DROP TABLE IF EXISTS #tmp2
					DROP TABLE IF EXISTS #tmp3

					INSERT INTO Logs 
					VALUES (GETDATE(),
							'Clinic.factTransactionAppointment',
							0,
							'ERROR : Transactions of '+CONVERT(VARCHAR,@curr_date)+' may not inserted',
							@@ROWCOUNT);
				END CATCH
			END 
			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic.factTransactionAppointment',
					1,
					'New Transactions inserted',
					@@ROWCOUNT);
		END TRY
		BEGIN CATCH
			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic.factTransactionAppointment',
					0,
					'ERROR : New Transactions may not inserted',
					@@ROWCOUNT);
		END CATCH
	END
GO

CREATE OR ALTER PROCEDURE Clinic.factDailyAppointment_FirstLoader 
	AS
	BEGIN
		BEGIN TRY
			DECLARE @curr_date DATE;
			DECLARE @curr_date_key INT;
			DECLARE @end_date DATE;

			SET @curr_date = (
				SELECT MIN(appointment_date)
				FROM HospitalSA.dbo.Appointments
			);

			SET @end_date = (
				SELECT MAX(appointment_date)
				FROM HospitalSA.dbo.Appointments
			);
			
			SELECT  ic.[insuranceCompany_ID]
					,d.[doctor_code]
					,d.[doctor_ID]
					,d.[doctorContract_ID]
					,d.[department_ID]
					,ill.[illness_ID] AS main_detected_illness
					,ill.[illnessType_ID]
			INTO #tmp_dim_cartesian
			FROM dbo.dimInsuranceCompanies ic
				 ,Clinic.dimDoctors d
				 ,Clinic.dimIllnesses ill
			WHERE d.current_flag = 1

			TRUNCATE TABLE factDailyAppointment

			--loop in days
			WHILE @curr_date < @end_date BEGIN
				BEGIN TRY
					--find TimeKey
					SET @curr_date_key = (
						SELECT TimeKey
						FROM dbo.dimDate
						WHERE FullDateAlternateKey = @curr_date
					);
					
					SELECT 	 [insuranceCompany_ID]
							,[doctor_code]
							,[doctor_ID]
							,[doctorContract_ID]
							,[department_ID]
							,[main_detected_illness]
							,[illnessType_ID]
							,[TimeKey]
							,SUM([paid_price]) AS total_paied_price
							,SUM([real_price]) AS total_real_price
							,SUM([insurance_share]) AS total_insurance_credit
							,SUM([doctor_share]) AS total_doctor_share
							,SUM([income]) AS total_income
							,SUM([patient_code]) AS number_of_patient
					INTO #tmp_groupby
					FROM HospitalDW.Clinic.factTransactionAppointment
					WHERE TimeKey = @curr_date_key
					GROUP BY [insuranceCompany_ID]
							,[doctor_code]
							,[doctor_ID]
							,[doctorContract_ID]
							,[department_ID]
							,[main_detected_illness]
							,[illnessType_ID]
							,[TimeKey]
					
					INSERT INTO Clinic.factDailyAppointment
						SELECT   [insuranceCompany_ID]
								,[doctor_code]
								,[doctor_ID]
								,[doctorContract_ID]
								,[department_ID]
								,[main_detected_illness]
								,[illnessType_ID]
								,@curr_date_key
								,ISNULL(total_paied_price,0)
								,ISNULL(total_real_price,0)
								,ISNULL(total_insurance_credit,0)
								,ISNULL(total_doctor_share,0)
								,ISNULL(total_income,0)
								,ISNULL(number_of_patient,0)
						FROM #tmp_groupby tg
							RIGHT JOIN #tmp_dim_cartesian td
							ON (tg.insuranceCompany_ID = td.insuranceCompany_ID
								AND tg.doctor_code = td.doctor_code
								AND tg.doctor_ID = td.doctor_ID
								AND tg.doctorContract_ID = td.doctorContract_ID
								AND tg.department_ID = td.department_ID
								AND tg.main_detected_illness = td.main_detected_illness
								AND tg.illnessType_ID = td.illnessType_ID)

					--------------------------------------------
					INSERT INTO Logs
					VALUES (GETDATE(),
							'Clinic.factDailyAppointment',
							1,
							'Transactions of '+CONVERT(VARCHAR,@curr_date)+' inserted',
							@@ROWCOUNT);
					
					--add a day 
					SET @curr_date = DATEADD(DAY, 1, @curr_date);

					--drop temporary tables
					DROP TABLE #tmp_groupby

				END TRY
				BEGIN CATCH
					INSERT INTO Logs 
					VALUES (GETDATE(),
							'Clinic.factDailyAppointment',
							0,
							'ERROR : Transactions of '+CONVERT(VARCHAR,@curr_date)+' may not inserted',
							@@ROWCOUNT);
				END CATCH
			END

			--drop temporary tables
			DROP TABLE #tmp_dim_cartesian

			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic.factDailyAppointment',
					1,
					'New Transactions inserted',
					@@ROWCOUNT);
		END TRY
		BEGIN CATCH
			--drop temporary tables
			DROP TABLE IF EXISTS #tmp_groupby
			DROP TABLE IF EXISTS #tmp_dim_cartesian

			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic.factDailyAppointment',
					0,
					'ERROR : New Transactions may not inserted',
					@@ROWCOUNT);
		END CATCH
	END
GO

CREATE OR ALTER PROCEDURE Clinic.factAccumulativeAppointment_FirstLoader
	AS
	BEGIN
		BEGIN TRY
			DECLARE @curr_date DATE;
			DECLARE @curr_date_key INT;
			DECLARE @end_date DATE;

			SET @curr_date = (
				SELECT MIN(appointment_date)
				FROM HospitalSA.dbo.Appointments
			);

			SET @end_date = (
				SELECT MAX(appointment_date)
				FROM HospitalSA.dbo.Appointments
			);
			
			SELECT   i.[insuranceCompany_ID]
					,d.[doctor_code]
					,d.[doctor_ID]
					,d.[doctorContract_ID]
					,d.[department_ID]
					,0 AS total_paied_price
					,0 AS total_real_price
					,0 AS total_insurance_credit
					,0 AS total_doctor_share
					,0 AS total_income
					,0 AS number_of_patient
			INTO #tmp_dim_cartesian
			FROM dbo.dimInsuranceCompanies i
				 ,Clinic.dimDoctors d
			WHERE d.current_flag = 1

			TRUNCATE TABLE factAccumulativeAppointment

			--loop in days
			WHILE @curr_date < @end_date BEGIN
				BEGIN TRY
					--find TimeKey
					SET @curr_date_key = (
						SELECT TimeKey
						FROM dbo.dimDate
						WHERE FullDateAlternateKey = @curr_date
					);

					SELECT 	 [insuranceCompany_ID]
							,[doctor_code]
							,[doctor_ID]
							,[doctorContract_ID]
							,[department_ID]
							,SUM([total_paied_price]) AS total_paied_price
							,SUM([total_real_price]) AS total_real_price
							,SUM([total_insurance_share]) AS total_insurance_credit
							,SUM([total_doctor_share]) AS total_doctor_share
							,SUM([total_income]) AS total_income
							,SUM([number_of_patient]) AS number_of_patient
					INTO #tmp_current_date_daily
					FROM Clinic.factDailyAppointment
					WHERE TimeKey = @curr_date_key
					GROUP BY [insuranceCompany_ID]
							,[doctor_code]
							,[doctor_ID]
							,[doctorContract_ID]
							,[department_ID]
					
					SELECT 	 a.[insuranceCompany_ID]
							,a.[doctor_code]
							,a.[doctor_ID]
							,a.[doctorContract_ID]
							,a.[department_ID]
							,a.total_paied_price + d.total_paied_price AS total_paied_price
							,a.total_real_price + d.total_real_price AS total_real_price
							,a.total_insurance_credit + d.total_insurance_credit AS total_insurance_credit
							,a.total_doctor_share + d.total_doctor_share AS total_doctor_share
							,a.total_income + d.total_income AS total_income
							,a.number_of_patient + d.number_of_patient AS number_of_patient
					INTO #tmp_acc_current_date
					FROM #tmp_dim_cartesian a
						INNER JOIN tmp_current_date_daily d
						ON (a.[insuranceCompany_ID] = d.[insuranceCompany_ID]
						   AND a.[doctor_code] = d.[doctor_code]
						   AND a.[doctor_ID] = d.[doctor_ID]
						   AND a.[doctorContract_ID] = d.[doctorContract_ID]
						   AND a.[department_ID] = d.[department_ID])
					
					TRUNCATE TABLE #tmp_dim_cartesian

					INSERT INTO #tmp_dim_cartesian
						SELECT 	[insuranceCompany_ID]
								,[doctor_code]
								,[doctor_ID]
								,[doctorContract_ID]
								,[department_ID]
								,total_paied_price
								,total_real_price
								,total_insurance_credit
								,total_doctor_share
								,total_income
								,number_of_patient
						FROM #tmp_acc_current_date
					--------------------------------------------
					INSERT INTO Logs
					VALUES (GETDATE(),
							'Clinic.factTransactionAppointment',
							1,
							'Transactions of '+CONVERT(VARCHAR,@curr_date)+' inserted',
							@@ROWCOUNT);
					
					--add a day 
					SET @curr_date = DATEADD(DAY, 1, @curr_date);

					--drop temporary tables
					DROP TABLE #tmp_acc_current_date
					DROP TABLE #tmp_current_date_daily

				END TRY
				BEGIN CATCH
					--drop temporary tables
					DROP TABLE IF EXISTS #tmp_acc_current_date
					DROP TABLE IF EXISTS #tmp_current_date_daily
					DROP TABLE IF EXISTS #tmp_dim_cartesian

					INSERT INTO Logs 
					VALUES (GETDATE(),
							'Clinic.factTransactionAppointment',
							0,
							'ERROR : Transactions of '+CONVERT(VARCHAR,@curr_date)+' may not inserted',
							@@ROWCOUNT);
				END CATCH
			END 
			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic.factTransactionAppointment',
					1,
					'New Transactions inserted',
					@@ROWCOUNT);
		END TRY
		BEGIN CATCH
			--drop temporary tables
			DROP TABLE IF EXISTS #tmp_dim_cartesian
			
			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic.factTransactionAppointment',
					0,
					'ERROR : New Transactions may not inserted',
					@@ROWCOUNT);
		END CATCH
	END
GO

-- Facts Usual Loader Procedures
CREATE OR ALTER PROCEDURE Clinic.factTransactionAppointment_Loader
	AS
	BEGIN
		BEGIN TRY
			DECLARE @curr_date_key INT;
			DECLARE @curr_date DATE;
			DECLARE @end_date DATE;

			SET @curr_date = (
				SELECT CONVERT(DATE,CONVERT(VARCHAR,MAX(TimeKey)))
				FROM HospitalDW.Clinic.factTransactionAppointment 
			);
			SET @curr_date = DATEADD(DAY,1,@curr_date);

			SET @end_date = (
				SELECT MAX(appointment_date)
				FROM HospitalSA.dbo.Appointments
			);
			
			--loop in days
			WHILE @curr_date < @end_date BEGIN
				BEGIN TRY
					--find TimeKey
					SET @curr_date_key = (
						SELECT TimeKey
						FROM dbo.dimDate
						WHERE FullDateAlternateKey = @curr_date
					);

					SELECT ISNULL(patient_ID,-1) AS patient_ID,
						   ISNULL(doctor_ID,-1) AS doctor_ID,
						   ISNULL(main_detected_illness,-1) AS main_detected_illness,
						   price,
						   doctor_share,
						   insurance_share,
						   payment_method,
						   payment_method_description,
						   credit_card_number,
						   payer,
						   payer_phone_number,
						   additional_info 
					INTO #tmp_today_appointments
					FROM HospitalSA.dbo.Appointments
					WHERE appointment_date = @curr_date
					
					SELECT p.patient_code,
						   p.patient_ID,
						   p.insurance_ID,
						   i.insuranceCompany_ID
					INTO #tmp_patient_info
					FROM dbo.dimPatients p 
						INNER JOIN dbo.dimInsurances i 
						ON p.insurance_ID = i.insurance_ID
					WHERE p.[start_date] <= @curr_date 
						AND (p.current_flag = 1 
							 OR p.end_date > @curr_date);
					
					SELECT patient_ID,
						   doctor_code,
						   doctor_ID,
						   doctorContract_ID,
						   department_ID,
						   main_detected_illness,
						   price,
						   doctor_share,
						   insurance_share,
						   payment_method,
						   payment_method_description,
						   credit_card_number,
						   payer,
						   payer_phone_number,
						   additional_info 
					INTO #tmp1
					FROM Clinic.dimDoctors d
						INNER JOIN #tmp_today_appointments a
						ON d.doctor_ID = a.doctor_ID
					WHERE [start_date] <= @curr_date 
						AND (current_flag = 1 
							 OR end_date > @curr_date);

					SELECT p.patient_code,
						   p.patient_ID,
						   p.insurance_ID,
						   p.insuranceCompany_ID
						   doctor_code,
						   doctor_ID,
						   doctorContract_ID,
						   department_ID,
						   main_detected_illness,
						   price,
						   doctor_share,
						   insurance_share,
						   payment_method,
						   payment_method_description,
						   credit_card_number,
						   payer,
						   payer_phone_number,
						   additional_info 
					INTO #tmp2
					FROM #tmp_patient_info p
						INNER JOIN #tmp1 d
						ON d.patient_ID = p.patient_ID

					SELECT p.patient_code,
						   p.patient_ID,
						   p.insurance_ID,
						   p.insuranceCompany_ID
						   doctor_code,
						   doctor_ID,
						   doctorContract_ID,
						   department_ID,
						   main_detected_illness,
						   i.illnessType_ID,
						   @curr_date_key AS TimeKey,
						   ---------------
						   price - insurance_share AS paid_price,
						   price AS real_price,
						   doctor_share,
						   insurance_share,
						   price - doctor_share AS income,
						   payment_method,
						   payment_method_description,
						   credit_card_number,
						   payer,
						   payer_phone_number,
						   additional_info 
					INTO #tmp3
					FROM #tmp2 t
						INNER JOIN Clinic.dimIllnesses i
						ON i.illness_ID = t.main_detected_illness

					INSERT INTO Clinic.factTransactionAppointment
						SELECT patient_code,
						   patient_ID,
						   insurance_ID,
						   insuranceCompany_ID
						   doctor_code,
						   doctor_ID,
						   doctorContract_ID,
						   department_ID,
						   main_detected_illness,
						   illnessType_ID,
						   TimeKey,
						   ---------------
						   paid_price,
						   real_price,
						   doctor_share,
						   insurance_share,
						   income,
						   payment_method,
						   payment_method_description,
						   credit_card_number,
						   payer,
						   payer_phone_number,
						   additional_info 
						FROM #tmp3
					--------------------------------------------
					INSERT INTO Logs
					VALUES (GETDATE(),
							'Clinic.factTransactionAppointment',
							1,
							'Transactions of '+CONVERT(VARCHAR,@curr_date)+' inserted',
							@@ROWCOUNT);
					
					--add a day 
					SET @curr_date = DATEADD(DAY, 1, @curr_date);

					--drop temporary tables
					DROP TABLE #tmp_today_appointments
					DROP TABLE #tmp_patient_info
					DROP TABLE #tmp1
					DROP TABLE #tmp2
					DROP TABLE #tmp3

				END TRY
				BEGIN CATCH
					--drop temporary tables
					DROP TABLE IF EXISTS #tmp_today_appointments
					DROP TABLE IF EXISTS #tmp_patient_info
					DROP TABLE IF EXISTS #tmp1
					DROP TABLE IF EXISTS #tmp2
					DROP TABLE IF EXISTS #tmp3

					INSERT INTO Logs 
					VALUES (GETDATE(),
							'Clinic.factTransactionAppointment',
							0,
							'ERROR : Transactions of '+CONVERT(VARCHAR,@curr_date)+' may not inserted',
							@@ROWCOUNT);
				END CATCH
			END 
			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic.factTransactionAppointment',
					1,
					'New Transactions inserted',
					@@ROWCOUNT);
		END TRY
		BEGIN CATCH
			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic.factTransactionAppointment',
					0,
					'ERROR : New Transactions may not inserted',
					@@ROWCOUNT);
		END CATCH
	END
GO

CREATE OR ALTER PROCEDURE Clinic.factDailyAppointment_Loader 
	AS
	BEGIN
		BEGIN TRY
			DECLARE @curr_date DATE;
			DECLARE @curr_date_key INT;
			DECLARE @end_date DATE;

			SET @curr_date = (
				SELECT CONVERT(DATE,CONVERT(VARCHAR,MAX(TimeKey)))
				FROM HospitalDW.Clinic.factTransactionAppointment 
			);
			SET @curr_date = DATEADD(DAY,1,@curr_date);

			SET @end_date = (
				SELECT MAX(appointment_date)
				FROM HospitalSA.dbo.Appointments
			);
			
			SELECT  ic.[insuranceCompany_ID]
					,d.[doctor_code]
					,d.[doctor_ID]
					,d.[doctorContract_ID]
					,d.[department_ID]
					,ill.[illness_ID] AS main_detected_illness
					,ill.[illnessType_ID]
			INTO #tmp_dim_cartesian
			FROM dbo.dimInsuranceCompanies ic
				 ,Clinic.dimDoctors d
				 ,Clinic.dimIllnesses ill
			WHERE d.current_flag = 1

			--loop in days
			WHILE @curr_date < @end_date BEGIN
				BEGIN TRY
					--find TimeKey
					SET @curr_date_key = (
						SELECT TimeKey
						FROM dbo.dimDate
						WHERE FullDateAlternateKey = @curr_date
					);
					
					SELECT 	 [insuranceCompany_ID]
							,[doctor_code]
							,[doctor_ID]
							,[doctorContract_ID]
							,[department_ID]
							,[main_detected_illness]
							,[illnessType_ID]
							,[TimeKey]
							,SUM([paid_price]) AS total_paied_price
							,SUM([real_price]) AS total_real_price
							,SUM([insurance_share]) AS total_insurance_credit
							,SUM([doctor_share]) AS total_doctor_share
							,SUM([income]) AS total_income
							,SUM([patient_code]) AS number_of_patient
					INTO #tmp_groupby
					FROM HospitalDW.Clinic.factTransactionAppointment
					WHERE TimeKey = @curr_date_key
					GROUP BY [insuranceCompany_ID]
							,[doctor_code]
							,[doctor_ID]
							,[doctorContract_ID]
							,[department_ID]
							,[main_detected_illness]
							,[illnessType_ID]
							,[TimeKey]
					
					INSERT INTO Clinic.factDailyAppointment
						SELECT   [insuranceCompany_ID]
								,[doctor_code]
								,[doctor_ID]
								,[doctorContract_ID]
								,[department_ID]
								,[main_detected_illness]
								,[illnessType_ID]
								,@curr_date_key
								,ISNULL(total_paied_price,0)
								,ISNULL(total_real_price,0)
								,ISNULL(total_insurance_credit,0)
								,ISNULL(total_doctor_share,0)
								,ISNULL(total_income,0)
								,ISNULL(number_of_patient,0)
						FROM #tmp_groupby tg
							RIGHT JOIN #tmp_dim_cartesian td
							ON (tg.insuranceCompany_ID = td.insuranceCompany_ID
								AND tg.doctor_code = td.doctor_code
								AND tg.doctor_ID = td.doctor_ID
								AND tg.doctorContract_ID = td.doctorContract_ID
								AND tg.department_ID = td.department_ID
								AND tg.main_detected_illness = td.main_detected_illness
								AND tg.illnessType_ID = td.illnessType_ID)

					--------------------------------------------
					INSERT INTO Logs
					VALUES (GETDATE(),
							'Clinic.factDailyAppointment',
							1,
							'Transactions of '+CONVERT(VARCHAR,@curr_date)+' inserted',
							@@ROWCOUNT);
					
					--add a day 
					SET @curr_date = DATEADD(DAY, 1, @curr_date);

					--drop temporary tables
					DROP TABLE #tmp_groupby

				END TRY
				BEGIN CATCH
					INSERT INTO Logs 
					VALUES (GETDATE(),
							'Clinic.factDailyAppointment',
							0,
							'ERROR : Transactions of '+CONVERT(VARCHAR,@curr_date)+' may not inserted',
							@@ROWCOUNT);
				END CATCH
			END

			--drop temporary tables
			DROP TABLE #tmp_dim_cartesian

			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic.factDailyAppointment',
					1,
					'New Transactions inserted',
					@@ROWCOUNT);
		END TRY
		BEGIN CATCH
			--drop temporary tables
			DROP TABLE IF EXISTS #tmp_groupby
			DROP TABLE IF EXISTS #tmp_dim_cartesian

			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic.factDailyAppointment',
					0,
					'ERROR : New Transactions may not inserted',
					@@ROWCOUNT);
		END CATCH
	END
GO

CREATE OR ALTER PROCEDURE Clinic.factAccumulativeAppointment_Loader @cur_date DATE
	AS
	BEGIN
		BEGIN TRY
			DECLARE @curr_date DATE;
			DECLARE @curr_date_key INT;
			DECLARE @end_date DATE;

			SET @curr_date = DATEADD(DAY,1,@cur_date)

			SET @end_date = (
				SELECT MAX(appointment_date)
				FROM HospitalSA.dbo.Appointments
			);
			
			SELECT   i.[insuranceCompany_ID]
					,d.[doctor_code]
					,d.[doctor_ID]
					,d.[doctorContract_ID]
					,d.[department_ID]
					,0 AS total_paied_price
					,0 AS total_real_price
					,0 AS total_insurance_credit
					,0 AS total_doctor_share
					,0 AS total_income
					,0 AS number_of_patient
			INTO #tmp_dim_cartesian
			FROM dbo.dimInsuranceCompanies i
				 ,Clinic.dimDoctors d
			WHERE d.current_flag = 1

			--loop in days
			WHILE @curr_date < @end_date BEGIN
				BEGIN TRY
					--find TimeKey
					SET @curr_date_key = (
						SELECT TimeKey
						FROM dbo.dimDate
						WHERE FullDateAlternateKey = @curr_date
					);

					SELECT 	 [insuranceCompany_ID]
							,[doctor_code]
							,[doctor_ID]
							,[doctorContract_ID]
							,[department_ID]
							,SUM([total_paied_price]) AS total_paied_price
							,SUM([total_real_price]) AS total_real_price
							,SUM([total_insurance_share]) AS total_insurance_credit
							,SUM([total_doctor_share]) AS total_doctor_share
							,SUM([total_income]) AS total_income
							,SUM([number_of_patient]) AS number_of_patient
					INTO #tmp_current_date_daily
					FROM Clinic.factDailyAppointment
					WHERE TimeKey = @curr_date_key
					GROUP BY [insuranceCompany_ID]
							,[doctor_code]
							,[doctor_ID]
							,[doctorContract_ID]
							,[department_ID]
					
					SELECT 	 a.[insuranceCompany_ID]
							,a.[doctor_code]
							,a.[doctor_ID]
							,a.[doctorContract_ID]
							,a.[department_ID]
							,a.total_paied_price + d.total_paied_price AS total_paied_price
							,a.total_real_price + d.total_real_price AS total_real_price
							,a.total_insurance_credit + d.total_insurance_credit AS total_insurance_credit
							,a.total_doctor_share + d.total_doctor_share AS total_doctor_share
							,a.total_income + d.total_income AS total_income
							,a.number_of_patient + d.number_of_patient AS number_of_patient
					INTO #tmp_acc_current_date
					FROM #tmp_dim_cartesian a
						INNER JOIN tmp_current_date_daily d
						ON (a.[insuranceCompany_ID] = d.[insuranceCompany_ID]
						   AND a.[doctor_code] = d.[doctor_code]
						   AND a.[doctor_ID] = d.[doctor_ID]
						   AND a.[doctorContract_ID] = d.[doctorContract_ID]
						   AND a.[department_ID] = d.[department_ID])
					
					TRUNCATE TABLE #tmp_dim_cartesian;

					INSERT INTO #tmp_dim_cartesian
						SELECT 	[insuranceCompany_ID]
								,[doctor_code]
								,[doctor_ID]
								,[doctorContract_ID]
								,[department_ID]
								,total_paied_price
								,total_real_price
								,total_insurance_credit
								,total_doctor_share
								,total_income
								,number_of_patient
						FROM #tmp_acc_current_date
					--------------------------------------------
					INSERT INTO Logs
					VALUES (GETDATE(),
							'Clinic.factTransactionAppointment',
							1,
							'Transactions of '+CONVERT(VARCHAR,@curr_date)+' inserted',
							@@ROWCOUNT);
					
					--add a day 
					SET @curr_date = DATEADD(DAY, 1, @curr_date);

					--drop temporary tables
					DROP TABLE #tmp_acc_current_date
					DROP TABLE #tmp_current_date_daily

				END TRY
				BEGIN CATCH
					--drop temporary tables
					DROP TABLE IF EXISTS #tmp_acc_current_date
					DROP TABLE IF EXISTS #tmp_current_date_daily
					DROP TABLE IF EXISTS #tmp_dim_cartesian

					INSERT INTO Logs 
					VALUES (GETDATE(),
							'Clinic.factTransactionAppointment',
							0,
							'ERROR : Transactions of '+CONVERT(VARCHAR,@curr_date)+' may not inserted',
							@@ROWCOUNT);
				END CATCH
			END 
			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic.factTransactionAppointment',
					1,
					'New Transactions inserted',
					@@ROWCOUNT);
		END TRY
		BEGIN CATCH
			--drop temporary tables
			DROP TABLE IF EXISTS #tmp_dim_cartesian
			
			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic.factTransactionAppointment',
					0,
					'ERROR : New Transactions may not inserted',
					@@ROWCOUNT);
		END CATCH
	END
GO

---------------------------------------------
-- Clinic Mart : General Procedures 
---------------------------------------------
CREATE OR ALTER PROCEDURE Clinic.FirstLoad
	AS
	BEGIN
		BEGIN TRY
			DECLARE @curr_date DATE;

			SET @curr_date = (
				SELECT MIN(appointment_date)
				FROM HospitalSA.dbo.Appointments
			);
			
			EXEC Clinic.dimDepartments_FirstLoader;
			EXEC Clinic.dimDoctorContracts_FirstLoader;
			EXEC Clinic.dimDoctors_FirstLoader @curr_date;
			EXEC Clinic.dimIllnessTypes_FirstLoader;
			EXEC Clinic.dimIllnesses_FirstLoader;

			EXEC Clinic.factTransactionAppointment_FirstLoader
			EXEC Clinic.factDailyAppointment_FirstLoader
			EXEC Clinic.factAccumulativeAppointment_FirstLoader

			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic Mart',
					1,
					'All First Load insertions was successful',
					@@ROWCOUNT);
		END TRY
		BEGIN CATCH
			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic Mart',
					0,
					'ERROR : First Load insertions FAILED',
					@@ROWCOUNT);
		END CATCH
	END
GO

CREATE OR ALTER PROCEDURE Clinic.Load
	AS
	BEGIN
		BEGIN TRY
			DECLARE @curr_date DATE;
			DECLARE @curr_date_fact DATE;

			SET @curr_date = (
				SELECT MIN(appointment_date)
				FROM HospitalSA.dbo.Appointments
			);

			SET @curr_date_fact = (
				SELECT CONVERT(DATE,CONVERT(VARCHAR,MAX(TimeKey)))
				FROM HospitalDW.Clinic.factTransactionAppointment 
			);
			
			EXEC Clinic.dimDepartments_Loader @curr_date;
			EXEC Clinic.dimDoctorContracts_Loader;
			EXEC Clinic.dimDoctors_Loader @curr_date;
			EXEC Clinic.dimIllnessTypes_Loader;
			EXEC Clinic.dimIllnesses_Loader;

			EXEC Clinic.factTransactionAppointment_Loader;
			EXEC Clinic.factDailyAppointment_Loader;
			EXEC Clinic.factAccumulativeAppointment_Loader @curr_date_fact;

			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic Mart',
					1,
					'All insertions was successful',
					@@ROWCOUNT);
		END TRY
		BEGIN CATCH
			INSERT INTO Logs 
			VALUES (GETDATE(),
					'Clinic Mart',
					0,
					'ERROR : insertions FAILED',
					@@ROWCOUNT);
		END CATCH
	END
GO

---------------------------------------------
-- Clinic Mart : Testing
---------------------------------------------
--EXEC Clinic.FirstLoad;
--SELECT * FROM Logs;
--EXEC Clinic.Load;
--SELECT * FROM Logs;