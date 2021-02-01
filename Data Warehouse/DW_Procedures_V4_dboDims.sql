/**************************************************************************
DataBase2 Project		: Create Data Warehouse Procedures-dbo dimensions
Authors					: Sajede Nicknadaf, Maryam Saeedmehr
Student Numbers			: 9637453, 9629373
Semester				: fall 1399
version					: 4
***************************************************************************/
use HospitalDW
go

create or alter procedure dimInsuranceCompanies_FirstLoader @curr_date date
	as
	begin
		begin try 
			truncate table HospitalDW.dbo.dimInsuranceCompanies
			insert into HospitalDW.dbo.dimInsuranceCompanies
			SELECT [insuranceCompany_ID]
				,[name]
				,[license_code]
				,[phone_number]
				,[address]
				,NULL -- previous_manager
				,@curr_date -- manager_change_date
				,[manager]
				,NULL -- previous_agent
				,@curr_date -- agent_change_date
				,[agent]
				,[fax_number]
				,[website_address]
				,[manager_phone_number]
				,[agent_phone_number]
				,[additional_info]
				,[active]
				,[active_description]
			FROM HospitalSA.dbo.InsuranceCompanies
			insert into HospitalDW.dbo.dimInsuranceCompanies
			values(-1,'Nothing','Nothing','Nothing','Nothing','Nothing','0001-01-01','Nothing','Nothing','0001-01-01','Nothing','Nothing','Nothing','Nothing','Nothing','Nothing',null,'Nothing');
			
		---------------------------------------------------
			insert into [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			values
				(GETDATE()
				,'dimInsuranceCompanies'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		end try
		begin catch
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimInsuranceCompanies', 0, 'Error while inserting or updating', @@ROWCOUNT);
			select ERROR_MESSAGE()
		end catch
	end
go
---------------------------------------------
---------------------------------------------

create or alter procedure dimInsuranceCompanies_Loader @curr_date Date
	as 
	begin
	begin try
		merge HospitalDW.dbo.dimInsuranceCompanies as IC
		using HospitalSA.dbo.InsuranceCompanies as SA on
		IC.insuranceCompany_ID = SA.insuranceCompany_ID
		when not matched then 
		insert values (
		[insuranceCompany_ID]
		,[name]
		,[license_code]
		,[phone_number]
		,[address]
		,NULL -- previous_manager
		,@curr_date -- manager_change_date
		,[manager]
		,NULL -- previous_agent
		,@curr_date -- agent_change_date
		,[agent]
		,[fax_number]
		,[website_address]
		,[manager_phone_number]
		,[agent_phone_number]
		,[additional_info]
		,[active]
		,[active_description]
		)
		when matched and (
			IC.phone_number <> SA.phone_number or
			IC.[address] <> SA.[address] or
			IC.fax_number <> SA.fax_number or
			IC.website_address <> SA.website_address or
			IC.manager_phone_number <> SA.manager_phone_number or
			IC.agent_phone_number <> SA.agent_phone_number or
			IC.current_manager <> SA.manager or
			IC.current_agent <> SA.agent
		) then 
		update set 
			IC.phone_Number = SA.phone_number,
			IC.[address] = SA.[address],
			IC.fax_number = SA.fax_number,
			IC.website_address = SA.website_address,
			IC.manager_phone_number = SA.manager_phone_number,
			IC.agent_phone_number = SA.agent_phone_number,
			IC.previous_manager = case 
				when IC.current_manager <> SA.manager then IC.current_manager
				else IC.previous_manager
			end,
			IC.manager_change_date=case 
				when IC.current_manager <> SA.manager then @curr_date
				else IC.manager_change_date
			end,
			IC.current_manager = case 
				when IC.current_manager <> SA.manager then SA.manager
				else IC.current_manager
			end,
			IC.previous_agent = case 
				when IC.current_agent <> SA.agent then IC.current_agent
				else IC.previous_manager
			end,
			IC.agent_change_date=case 
				when IC.current_agent <> SA.agent then @curr_date
				else IC.agent_change_date
			end,
			IC.current_agent = case 
				when IC.current_agent <> SA.agent then SA.agent
				else IC.current_agent
			end

		;
		/*merge HospitalDW.dbo.dimInsuranceCompanies as IC
		using HospitalSA.dbo.InsuranceCompanies as SA on
		IC.insuranceCompany_ID = SA.insuranceCompany_ID
		when matched and (IC.current_manager != SA.manager) then 
		update set 
			IC.previous_manager=IC.current_manager,
			IC.current_manager = SA.manager,
			IC.manager_change_date=@curr_date
		;
		merge HospitalDW.dbo.dimInsuranceCompanies as IC
		using HospitalSA.dbo.InsuranceCompanies as SA on
		IC.insuranceCompany_ID = SA.insuranceCompany_ID
		when matched and (IC.current_agent != SA.agent) then 
		update set 
			IC.previous_agent=IC.current_agent,
			IC.current_agent = SA.agent,
			IC.agent_change_date=@curr_date
		;*/
		--logs
		insert into [dbo].[Logs]
			([date]
			,[table_name]
			,[status]
			,[description]
			,[affected_rows])
		values
			(GETDATE()
			,'InsuranceCompanies'
			,1
			,'inserting new values was successfull'
			,@@ROWCOUNT)
	end try
	begin catch
		INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
		VALUES (GETDATE(), 'dbo.InsuranceCompanies', 0, 'Error while inserting or updating', @@ROWCOUNT);
	end catch
	end
go
---------------------------------------------
---------------------------------------------
create or alter procedure dimInsurances_FirstLoader
	as
	begin
		begin try 
			truncate table HospitalDW.dbo.dimInsurances
			insert into HospitalDW.dbo.dimInsurances
			SELECT i.[insurance_ID]
				,i.[code]
				,i.[insuranceCompany_ID]
				,c.[name] --insuranceCompany_name
				,i.[insurer]
				,i.[insurer_phone_number]
				,i.[additional_info]
				,i.[expire_date]
				,i.[medicine_reduction]
				,i.[appointment1_reduction]
				,i.[appointment2_reduction]
				,i.[appointment3_reduction]
				,i.[hospitalization_reduction]
				,i.[surgery_reduction]
				,i.[test_reduction]
				,i.[dentistry_reduction]
				,i.[radiology_reduction]
			FROM HospitalSA.dbo.Insurances as i inner join HospitalSA.dbo.InsuranceCompanies as c on(i.insuranceCompany_ID=c.insuranceCompany_ID)
			insert into HospitalDW.dbo.dimInsurances
			values(-1,'Nothing',-1,'Nothing','Nothing','Nothing','Nothing','0001-01-01',0,0,0,0,0,0,0,0,0);
			
		---------------------------------------------------
			insert into [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			values
				(GETDATE()
				,'dimInsurances'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		end try
		begin catch
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimInsurances', 0, 'Error while inserting or updating', @@ROWCOUNT);
			select ERROR_MESSAGE()
		end catch
	end
go
---------------------------------------------
---------------------------------------------
create or alter procedure dimInsurances_Loader
	as
	begin
		begin try 
			declare @source table(
				insurance_ID int , 
				code varchar(15), 
				insuranceCompany_ID	int,
				insuranceCompany_name varchar(75),
				insurer	varchar(100),
				insurer_phone_number varchar(25),
				additional_info	varchar(200),
				expire_date	date,
				medicine_reduction int,
				appointment1_reduction int,
				appointment2_reduction int,
				appointment3_reduction int,
				hospitalization_reduction int,
				surgery_reduction int,
				test_reduction int,
				dentistry_reduction	int,
				radiology_reduction int
			);
			insert into @source
			SELECT i.[insurance_ID]
				,i.[code]
				,i.[insuranceCompany_ID]
				,c.[name] --insuranceCompany_name
				,i.[insurer]
				,i.[insurer_phone_number]
				,i.[additional_info]
				,i.[expire_date]
				,i.[medicine_reduction]
				,i.[appointment1_reduction]
				,i.[appointment2_reduction]
				,i.[appointment3_reduction]
				,i.[hospitalization_reduction]
				,i.[surgery_reduction]
				,i.[test_reduction]
				,i.[dentistry_reduction]
				,i.[radiology_reduction]
			FROM HospitalSA.dbo.Insurances as i inner join HospitalSA.dbo.InsuranceCompanies as c on(i.insuranceCompany_ID=c.insuranceCompany_ID);

			merge HospitalDW.dbo.dimInsurances as I
			using @source as SA on
			I.insurance_ID = SA.insurance_ID

			when not matched then 
			insert values(
				 [insurance_ID]
				,[code]
				,[insuranceCompany_ID]
				,[insuranceCompany_name] --insuranceCompany_name
				,[insurer]
				,[insurer_phone_number]
				,[additional_info]
				,[expire_date]
				,[medicine_reduction]
				,[appointment1_reduction]
				,[appointment2_reduction]
				,[appointment3_reduction]
				,[hospitalization_reduction]
				,[surgery_reduction]
				,[test_reduction]
				,[dentistry_reduction]
				,[radiology_reduction]
			);
			
		---------------------------------------------------
			insert into [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			values
				(GETDATE()
				,'dimInsurances'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		end try
		begin catch
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dimInsurances', 0, 'Error while inserting or updating', @@ROWCOUNT);
			select ERROR_MESSAGE()
		end catch
	end
go
---------------------------------------------
---------------------------------------------
CREATE OR ALTER PROCEDURE dimPatients_FirstLoader @curr_date date
	AS 
	BEGIN
		BEGIN TRY
			TRUNCATE TABLE HospitalDW.dbo.dimPatients;
			-- CREATE A RECORD WITH -1 KEY-ID 
			INSERT INTO HospitalDW.dbo.dimPatients(
				[patient_code]
				,[patient_ID]
				,[national_code]
				,[insurance_ID]
				,[first_name]
				,[last_name]
				,[birthdate]
				,[height]
				,[weight]
				,[gender]
				,[phone_number]
				,[death_date]
				,[death_reason]
				,[postal_code]
				,[address]
				,[additional_info]
				,[start_date]
				,[end_date]
				,[current_flag]
			) 
			VALUES(
				-1,
				-1,
				'Nothing',
				-1,
				'Nothing',
				'Nothing',
				'0001-01-01',
				0,
				0,
				'Nothing',
				'Nothing',
				'0001-01-01',
				-1,
				'Nothing',
				'Nothing',
				'Nothing',
				'0001-01-01',
				'0001-01-01',
				1
			)
			-------------------------------------------------
			INSERT INTO HospitalDW.dbo.dimPatients(
				[patient_ID]
				,[national_code]
				,[insurance_ID]
				,[first_name]
				,[last_name]
				,[birthdate]
				,[height]
				,[weight]
				,[gender]
				,[phone_number]
				,[death_date]
				,[death_reason]
				,[postal_code]
				,[address]
				,[additional_info]
				,[start_date]
				,[end_date]
				,[current_flag]
			) 
				SELECT [patient_ID]
				,[national_code]
				,[insurance_ID]
				,[first_name]
				,[last_name]
				,[birthdate]
				,[height]
				,[weight]
				,[gender]
				,[phone_number]
				,[death_date]
				,[death_reason]
				,[postal_code]
				,[address]
				,[additional_info]
				,@curr_date
				,null
				,1
				FROM HospitalSA.dbo.Patients;

			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dbo.Patients', 1, 'First Load was Successful', @@ROWCOUNT);
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dbo.Patients', 0, 'First Load was Failed', @@ROWCOUNT);
			RETURN;
		END CATCH
	END
GO
------------------------------------------------------
------------------------------------------------------
CREATE OR ALTER PROCEDURE dimPatients_Loader @curr_date date
	AS 
	BEGIN 
		BEGIN TRY
			MERGE INTO HospitalDW.dbo.dimPatients AS [Target]
			USING HospitalSA.dbo.Patients AS [Source]
			ON Source.patient_ID = [Target].patient_ID
			WHEN MATCHED AND
				(
					[Target].height	<> Source.height
					OR [Target].[weight]<> Source.[weight]
					OR [Target].phone_number <> Source.phone_number
					OR [Target].death_date <> Source.death_date
					OR [Target].death_reason <> Source.death_reason
					OR [Target].insurance_ID<>Source.insurance_ID
				) 
			THEN UPDATE SET 
						height = Source.[height],
						[weight] = Source.[weight],
						phone_number = Source.[phone_number],
						death_date = Source.death_date,
						death_reason = Source.death_reason,
						end_date= case
							when [Target].insurance_ID<>Source.insurance_ID then @curr_date
							else end_date
						end,
						current_flag =  case
							when [Target].insurance_ID<>Source.insurance_ID then 0
							else current_flag
						end
			WHEN NOT MATCHED BY TARGET 
			THEN INSERT (
				[patient_ID]
				,[national_code]
				,[insurance_ID]
				,[first_name]
				,[last_name]
				,[birthdate]
				,[height]
				,[weight]
				,[gender]
				,[phone_number]
				,[death_date]
				,[death_reason]
				,[postal_code]
				,[address]
				,[additional_info]
				,[start_date]
				,[end_date]
				,[current_flag]
			) VALUES (
				[patient_ID]
				,[national_code]
				,[insurance_ID]
				,[first_name]
				,[last_name]
				,[birthdate]
				,[height]
				,[weight]
				,[gender]
				,[phone_number]
				,[death_date]
				,[death_reason]
				,[postal_code]
				,[address]
				,[additional_info]
				,@curr_date
				,NULL
				,1
			);
			/*MERGE INTO HospitalDW.dbo.dimPatients AS [Target]
			USING HospitalSA.dbo.Patients AS [Source]
			ON Source.patient_ID = [Target].patient_ID
			WHEN MATCHED AND([Target].insurance_ID<>Source.insurance_ID)
			THEN UPDATE SET
					end_date=@curr_date,
					current_flag=0
			;*/
			INSERT INTO HospitalDW.dbo.dimPatients(
				[patient_ID]
				,[national_code]
				,[insurance_ID]
				,[first_name]
				,[last_name]
				,[birthdate]
				,[height]
				,[weight]
				,[gender]
				,[phone_number]
				,[death_date]
				,[death_reason]
				,[postal_code]
				,[address]
				,[additional_info]
				,[start_date]
				,[end_date]
				,[current_flag]
			)
			select d.[patient_ID]
				,d.[national_code]
				,s.[insurance_ID]
				,d.[first_name]
				,d.[last_name]
				,d.[birthdate]
				,d.[height]
				,d.[weight]
				,d.[gender]
				,d.[phone_number]
				,d.[death_date]
				,d.[death_reason]
				,d.[postal_code]
				,d.[address]
				,d.[additional_info]
				,@curr_date
				,NULL
				,1
			from HospitalDW.dbo.dimPatients as d inner join HospitalSA.dbo.Patients as s
				on(d.patient_ID=s.patient_ID)
			where d.end_date=@curr_date
			;

			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dbo.Patients', 1, 'Update or Insert was Successful', @@ROWCOUNT);
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dbo.Patients', 0, 'Update or Insert was Failed', @@ROWCOUNT);
			RETURN;
		END CATCH
	END
GO
------------------------------------------------------
------------------------------------------------------
