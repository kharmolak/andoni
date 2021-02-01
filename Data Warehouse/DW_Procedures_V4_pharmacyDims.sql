/**************************************************************************
DataBase2 Project	: Create Data Warehouse Procedures-Pharmacy dimensions
Authors					: Sajede Nicknadaf, Maryam Saeedmehr
Student Numbers	: 9637453, 9629373
Semester					: fall 1399
version						: 4
***************************************************************************/
use HospitalDW
go

create or alter procedure Pharmacy.dimMedicineFactory_FirstLoader @curr_date date
	as
	begin
		begin try 
			truncate table HospitalDW.Pharmacy.MedicineFactories
			insert into HospitalDW.Pharmacy.dimMedicineFactories 
			select 
				[medicineFactory_ID],
				[name],
				[license_code],
				[phone_number],
				NULL,--[previous_manager]
				@curr_date,
				[manager],--[current_manager]
				NULL,--[previous_agent]
				@curr_date,
				[agent],--current_agent
				[fax_number],
				[website_address],
				[manager_phone_number],
				[agent_phone_number],
				[address],
				[additional_info],
				[active],
				[active_description]
			from HospitalSA.dbo.MedicineFactories;
			insert into HospitalDW.Pharmacy.dimMedicineFactories 
			values(-1,'Nothing','Nothing','Nothing','Nothing','0001-01-01','Nothing','Nothing','0001-01-01','Nothing','Nothing','Nothing','Nothing','Nothing','Nothing','Nothing',null,'Nothing')
		---------------------------------------------------
			insert into [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows])
			values
				(GETDATE()
				,'dimMedicineFactories'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		end try
		begin catch
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'dbo.dimMedicineFactories', 0, 'Error while inserting or updating', @@ROWCOUNT);
			select ERROR_MESSAGE()
		end catch
	end
go
------------------------------------------------------
------------------------------------------------------
create or alter procedure Pharmacy.dimMedicineFactory_Loader @curr_date date
	as 
	begin
	begin try
		merge HospitalDW.Pharmacy.dimMedicineFactories as MF
		using HospitalSA.dbo.MedicineFactories as SA on
		MF.MedicineFactory_ID = SA.MedicineFactory_ID

		when not matched then 
		insert values (
			[medicineFactory_ID],
			[name],
			[license_code],
			[phone_number],
			NULL,--[previous_manager]
			@curr_date,
			[manager],--[current_manager]
			NULL,--[previous_agent]
			@curr_date,
			[agent],--current_agent
			[fax_number],
			[website_address],
			[manager_phone_number],
			[agent_phone_number],
			[address],
			[additional_info],
			[active],
			[active_description]
		)
		when matched and (
			MF.phone_number <> SA.phone_number or
			MF.fax_number <> SA.fax_number or
			MF.manager_phone_number <> SA.manager_phone_number or
			MF.agent_phone_number <> SA.agent_phone_number or
			MF.active <> SA.active or
			MF.current_manager <> SA.manager or
			MF.current_agent <> SA.agent 
		) then update set
			 MF.phone_Number = SA.phone_number,
			 MF.fax_number = SA.fax_number,
			 MF.manager_phone_number = SA.manager_phone_number,
			 MF.agent_phone_number = SA.agent_phone_number,
			 MF.active = SA.active,
			 MF.previous_manager = case 
				when MF.current_manager <> SA.manager then MF.current_manager
				else MF.previous_manager
			end,
			MF.manager_change_date=case 
				when MF.current_manager <> SA.manager then @curr_date
				else MF.manager_change_date
			end,
			MF.current_manager = case 
				when MF.current_manager <> SA.manager then SA.manager
				else MF.current_manager
			end,
			MF.previous_agent = case 
				when MF.current_agent <> SA.agent then MF.current_agent
				else MF.previous_manager
			end,
			MF.agent_change_date=case 
				when MF.current_agent <> SA.agent then @curr_date
				else MF.agent_change_date
			end,
			MF.current_agent = case 
				when MF.current_agent <> SA.agent then SA.agent
				else MF.current_agent
			end
		;
		--logs
		insert into [dbo].[Logs]
			([date]
			,[table_name]
			,[status]
			,[description]
			,[affected_rows])
		values
			(GETDATE()
			,'dimMedicineFactories'
			,1
			,'inserting new values was successfull'
			,@@ROWCOUNT)
	end try
	begin catch
		INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
		VALUES (GETDATE(), 'dbo.dimMedicineFactories', 0, 'Error while inserting or updating', @@ROWCOUNT);
	end catch
	end
go
------------------------------------------------------
------------------------------------------------------

CREATE OR ALTER PROCEDURE Pharmacy.dimMedicines_FirstLoader @curr_date DATE
	AS 
	BEGIN
		BEGIN TRY
			TRUNCATE TABLE HospitalDW.Pharmacy.Medicines;
			-- CREATE A RECORD WITH -1 KEY-ID 
			INSERT INTO HospitalDW.Pharmacy.dimMedicines(
				[medicine_code]
				,[medicine_ID]
				,[name]
				,[latin_name]
				,[dose]
				,[side_effects]
				,[purchase_price]
				,[sales_price]
				,[stock]
				,[medicine_type]
				,[medicine_type_description]
				,[medicineFactory_ID]
				,[production_date]
				,[expire_date]
				,[additional_info]
				,[start_date]
				,[end_date]
				,[current_flag]
				,[sales_purchase]
				,[sales_purchase_description]
			)VALUES(
				-1
				,-1
				,'Nothing'
				,'Nothing'
				,0
				,'Nothing'
				,0
				,0
				,0
				,-1
				,'Nothing'
				,-1
				,'0001-01-01'
				,'0001-01-01'
				,'Nothing'
				,'0001-01-01'
				,'0001-01-01'
				,-1
				,-1
				,'Nothing'
			)
			INSERT INTO HospitalDW.Pharmacy.dimMedicines(
				[medicine_ID]
				,[name]
				,[latin_name]
				,[dose]
				,[side_effects]
				,[purchase_price]
				,[sales_price]
				,[stock]
				,[medicine_type]
				,[medicine_type_description]
				,[medicineFactory_ID]
				,[production_date]
				,[expire_date]
				,[additional_info]
				,[start_date]
				,[end_date]
				,[current_flag]
				,[sales_purchase]
				,[sales_purchase_description]
			)
			SELECT 
				[medicine_ID]
				,[name]
				,[latin_name]
				,[dose]
				,[side_effects]
				,[purchase_price]
				,[sales_price]
				,[stock]
				,[medicine_type]
				,[medicine_type_description]
				,[medicineFactory_ID]
				,[production_date]
				,[expire_date]
				,[additional_info]
				,@curr_date
				,NULL
				,1
				,0
				,'FirstLoad'
				FROM HospitalSA.dbo.Medicines;
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'Pharmacy.dimMedicines', 1, 'First Load was Successful', @@ROWCOUNT);
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'Pharmacy.dimMedicines', 0, 'First Load was Failed', @@ROWCOUNT);
			RETURN;
		END CATCH
	END
GO
------------------------------------------------------
------------------------------------------------------
CREATE OR ALTER PROCEDURE Pharmacy.dimMedicines_Loader @curr_date DATE
	AS 
	BEGIN
		BEGIN TRY
			DECLARE @RowAffected INT;
			MERGE INTO HospitalDW.Pharmacy.dimMedicines AS [Target]
			USING HospitalSA.dbo.Medicines AS Source
			ON  [Target].medicine_ID = Source.medicine_ID 
			WHEN MATCHED AND
				(
					[Target].purchase_price <> Source. purchase_price or
					[Target].sales_price <> Source. sales_price or
					[Target].stock <> Source. stock or
					[Target].production_date <> Source. production_date or
					[Target].expire_date <> Source. expire_date 
				)
			THEN UPDATE SET 
					[Target].stock = Source. stock ,
					[Target].production_date = Source. production_date ,
					[Target].expire_date = Source. expire_date ,
					end_date =case
						when ([Target].purchase_price <> Source. purchase_price or [Target].sales_price <> Source. sales_price ) and current_flag=1 then @curr_date
						else end_date
					end,
					current_flag =  case
						when ([Target].purchase_price <> Source. purchase_price or [Target].sales_price <> Source. sales_price )  then 0
						else current_flag
					end
			WHEN NOT MATCHED BY Target 
			THEN  INSERT 
			(
				[medicine_ID]
				,[name]
				,[latin_name]
				,[dose]
				,[side_effects]
				,[purchase_price]
				,[sales_price]
				,[stock]
				,[medicine_type]
				,[medicine_type_description]
				,[medicineFactory_ID]
				,[production_date]
				,[expire_date]
				,[additional_info]
				,[start_date]
				,[end_date]
				,[current_flag]
				,[sales_purchase]
				,[sales_purchase_description]
			)
			VALUES 
			(
				[medicine_ID]
				,[name]
				,[latin_name]
				,[dose]
				,[side_effects]
				,[purchase_price]
				,[sales_price]
				,[stock]
				,[medicine_type]
				,[medicine_type_description]
				,[medicineFactory_ID]
				,[production_date]
				,[expire_date]
				,[additional_info]
				,@curr_date
				,NULL
				,1
				,0
				,'FirstLoad'
			);
			SET @RowAffected = @@ROWCOUNT;
			INSERT INTO HospitalDW.Pharmacy.dimMedicines
				SELECT [Target].[medicine_ID]
				,[Target].[name]
				,[Target].[latin_name]
				,[Target].[dose]
				,[Target].[side_effects]
				,Source.[purchase_price]
				,Source.[sales_price]
				,[Target].[stock]
				,[Target].[medicine_type]
				,[Target].[medicine_type_description]
				,[Target].[medicineFactory_ID]
				,[Target].[production_date]
				,[Target].[expire_date]
				,[Target].[additional_info]
				,@curr_date
				,NULL
				,1
				,case
						when [Target].purchase_price <> Source. purchase_price and [Target].sales_price <> Source. sales_price then 3
						when [Target].purchase_price <> Source. purchase_price then 2
						when [Target].sales_price <> Source. sales_price then 1
						else sales_purchase
					end
				,case
						when [Target].purchase_price <> Source. purchase_price and [Target].sales_price <> Source. sales_price then 'both'
						when [Target].purchase_price <> Source. purchase_price then 'purchase price'
						when [Target].sales_price <> Source. sales_price then 'sales price'
						else sales_purchase_description
					end
				FROM HospitalDW.Pharmacy.dimMedicines AS Target INNER JOIN HospitalSA.dbo.Medicines AS Source
				ON  [Target].medicine_ID = Source.medicine_ID 
				AND [Target].[end_date] = @curr_date;

			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'Pharmacy.dimMedicines', 1, 'Update or Insert was Successful', @@ROWCOUNT + @RowAffected);
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [description], [affected_rows])
			VALUES (GETDATE(), 'Pharmacy.dimMedicines', 0, 'Update or Insert was Failed', @@ROWCOUNT);
			RETURN;
		END CATCH
	END
GO
------------------------------------------------------
------------------------------------------------------