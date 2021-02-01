/**************************************************************************
DataBase2 Project	: Create Data Warehouse Procedures
Authors					: Sajede Nicknadaf, Maryam Saeedmehr
Student Numbers	: 9637453, 9629373
Semester					: fall 1399
version						: 4
***************************************************************************/
use HospitalDW
go

create or alter procedure dimInsuranceCompanies_FirstLoader
	as
	begin
		begin try 
			truncate table HospitalDW.dbo.dimInsuranceCompanies
			insert into HospitalDW.dbo.InsuranceCompanies
				SELECT [insuranceCompany_ID]
			,[name]
			,[license_code]
			,[phone_number]
			,[address]
			FROM HospitalSA.dbo.InsuranceCompanies
			insert into HospitalDW.dbo.InsuranceCompanies
			values(-1,'Nothing','Nothing','Nothing','Nothing')
			
		---------------------------------------------------
			insert into [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[text]
				,[affected_rows])
			values
				(GETDATE()
				,'InsuranceCompanies'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		end try
		begin catch
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [text], [affected_rows])
			VALUES (GETDATE(), 'InsuranceCompanies', 0, 'Error while inserting or updating', @@ROWCOUNT);
			select ERROR_MESSAGE()
		end catch
	end
go
---------------------------------------------
---------------------------------------------

create or alter procedure dimInsuranceCompanies
	as 
	begin
	begin try
		merge HospitalDW.dbo.InsuranceCompanies as IC
		using HospitalSA.dbo.InsuranceCompanies as SA on
		IC.insuranceCompany_ID = SA.insuranceCompany_ID

		when not matched then 
		insert values (
		[insuranceCompany_ID]
		,[name]
		,[license_code]
		,[phone_number]
		,[address]
		)
		when matched and (IC.phone_number != SA.phone_number) then 
		update set IC.phone_Number = SA.phone_number
		;
		--logs
		insert into [dbo].[Logs]
			([date]
			,[table_name]
			,[status]
			,[text]
			,[affected_rows])
		values
			(GETDATE()
			,'InsuranceCompanies'
			,1
			,'inserting new values was successfull'
			,@@ROWCOUNT)
	end try
	begin catch
		INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [text], [affected_rows])
		VALUES (GETDATE(), 'dbo.InsuranceCompanies', 0, 'Error while inserting or updating', @@ROWCOUNT);
	end catch
	end
go
---------------------------------------------
---------------------------------------------
create or alter procedure Pharmacy.dimMedicineFactory
	as 
	begin
	begin try
		merge HospitalDW.Pharmacy.MedicineFactories as MF
		using HospitalSA.dbo.MedicineFactories as SA on
		MF.MedicineFactory_ID = SA.MedicineFactory_ID

		when not matched then 
		insert values (
		[medicineFactory_ID],
		[name],
		[license_code],
		[phone_number]
		)
		when matched and (MF.phone_number != SA.phone_number) then 
		update set MF.phone_Number = SA.phone_number
		;
		--logs
		insert into [dbo].[Logs]
			([date]
			,[table_name]
			,[status]
			,[text]
			,[affected_rows])
		values
			(GETDATE()
			,'MedicineFactories'
			,1
			,'inserting new values was successfull'
			,@@ROWCOUNT)
	end try
	begin catch
		INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [text], [affected_rows])
		VALUES (GETDATE(), 'dbo.MedicineFactories', 0, 'Error while inserting or updating', @@ROWCOUNT);
	end catch
	end
go

------------------------------------------------------
------------------------------------------------------

create or alter procedure Pharmacy.dimMedicineFactory_FirstLoader
	as
	begin
		begin try 
			truncate table HospitalDW.Pharmacy.MedicineFactories
			insert into HospitalDW.Pharmacy.MedicineFactories 
				select 
			[medicineFactory_ID],
			[name],
			[license_code],
			[phone_number]
			from HospitalSA.dbo.MedicineFactories;
			insert into HospitalDW.Pharmacy.MedicineFactories 
			values(-1,'Nothing','Nothing','Nothing')
		---------------------------------------------------
			insert into [dbo].[Logs]
				([date]
				,[table_name]
				,[status]
				,[text]
				,[affected_rows])
			values
				(GETDATE()
				,'MedicineFactories'
				,1
				,'inserting new values was successfull'
				,@@ROWCOUNT)
		end try
		begin catch
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [text], [affected_rows])
			VALUES (GETDATE(), 'dbo.MedicineFactories', 0, 'Error while inserting or updating', @@ROWCOUNT);
			select ERROR_MESSAGE()
		end catch
	end
go

------------------------------------------------------
------------------------------------------------------

CREATE OR ALTER PROCEDURE dimPatients_FirstLoader
	AS 
	BEGIN
		BEGIN TRY
			TRUNCATE TABLE HospitalDW.dbo.Patients;
			-- CREATE A RECORD WITH -1 KEY-ID 
			INSERT INTO HospitalDW.dbo.Patients(
				[patient_ID]
				,[national_code]
				,[name]
				,[family]
				,[birthdate]
				,[height]
				,[weight]
				,[gender]
				,[phone_number]
			) 
			VALUES(
				-1,
				'Nothing',
				'Nothing',
				'Nothing',
				'0001-01-01',
				-1,
				-1,
				'Nothing',
				'Nothing'
			)
			-------------------------------------------------
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
			VALUES (GETDATE(), 'dbo.Patients', 1, 'First Load was Successful', @@ROWCOUNT);
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [text], [affected_rows])
			VALUES (GETDATE(), 'dbo.Patients', 0, 'First Load was Failed', @@ROWCOUNT);
			RETURN;
		END CATCH
	END
GO

------------------------------------------------------
------------------------------------------------------

CREATE OR ALTER PROCEDURE dimPatients
	AS 
	BEGIN 
		BEGIN TRY
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
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [text], [affected_rows])
			VALUES (GETDATE(), 'dbo.Patients', 1, 'Update or Insert was Successful', @@ROWCOUNT);
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [text], [affected_rows])
			VALUES (GETDATE(), 'dbo.Patients', 0, 'Update or Insert was Failed', @@ROWCOUNT);
			RETURN;
		END CATCH
	END
GO

------------------------------------------------------
------------------------------------------------------

CREATE OR ALTER PROCEDURE Pharmacy.dimMedicines_FirstLoader @curr_date DATE
	AS 
	BEGIN
		BEGIN TRY
			TRUNCATE TABLE HospitalDW.Pharmacy.Medicines;
			-- CREATE A RECORD WITH -1 KEY-ID 
			INSERT INTO HospitalDW.Pharmacy.Medicines(
				[medicine_ID]
				,[name]
				,[latin_name]
				,[dose]
				,[side_effects]
				,[price]
				,[description]
				,[start_date]
				,[end_date]
				,[current_flag]
			)VALUES(
				-1
				,'Nothing'
				,'Nothing'
				,-1
				,'Nothing'
				,-1
				,'Nothing'
				,'0001-01-01'
				,'0001-01-01'
				,-1
			)
			INSERT INTO HospitalDW.Pharmacy.Medicines
				SELECT [medicine_ID]
							,[name]
							,[latin_name]
							,[dose]
							,[side_effects]
							,[price]
							,[description]
							,@curr_date
							,NULL
							,1
				FROM HospitalSA.dbo.Medicines;
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [text], [affected_rows])
			VALUES (GETDATE(), 'Pharmacy.Medicines', 1, 'First Load was Successful', @@ROWCOUNT);
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [text], [affected_rows])
			VALUES (GETDATE(), 'Pharmacy.Medicines', 0, 'First Load was Failed', @@ROWCOUNT);
			RETURN;
		END CATCH
	END
GO

------------------------------------------------------
------------------------------------------------------

CREATE OR ALTER PROCEDURE Pharmacy.dimMedicines @curr_date DATE
	AS 
	BEGIN
		BEGIN TRY
			DECLARE @RowAffected INT;
			MERGE INTO HospitalDW.Pharmacy.Medicines AS [Target]
			USING HospitalSA.dbo.Medicines AS Source
			ON  [Target].medicine_ID = Source.medicine_ID 
			AND [Target].[current_flag] = 1
			WHEN MATCHED AND
				(
					[Target].price <> Source. price 
				)
			THEN UPDATE SET 
					end_date = @curr_date, 
					current_flag = 0
			WHEN NOT MATCHED BY Target 
			THEN  INSERT 
			(
				[medicine_ID]
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
			VALUES 
			(
				Source.[medicine_ID], 
				Source.[name],
				Source.[latin_name],
				Source.[dose],
				Source.[side_effects],
				Source.[price],
				Source.[description],
				@curr_date,
				NULL,
				1
			);
			SET @RowAffected = @@ROWCOUNT;
			INSERT INTO HospitalDW.Pharmacy.Medicines
				SELECT Source.[medicine_ID], 
							Source.[name],
							Source.[latin_name],
							Source.[dose],
							Source.[side_effects],
							Source.[price],
							Source.[description],
							@curr_date,
							NULL,
							1
				FROM HospitalDW.Pharmacy.Medicines AS Target INNER JOIN HospitalSA.dbo.Medicines AS Source
				ON  [Target].medicine_ID = Source.medicine_ID 
				AND [Target].[end_date] = @curr_date;

			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [text], [affected_rows])
			VALUES (GETDATE(), 'Pharmacy.Medicines', 1, 'Update or Insert was Successful', @@ROWCOUNT + @RowAffected);
		END TRY
		BEGIN CATCH
			INSERT INTO HospitalDW.dbo.Logs([date], [table_name], [status], [text], [affected_rows])
			VALUES (GETDATE(), 'Pharmacy.Medicines', 0, 'Update or Insert was Failed', @@ROWCOUNT);
			RETURN;
		END CATCH
	END
GO

------------------------------------------------------
------------------------------------------------------

create or alter procedure  factMedicineTransaction_FirstLoader 
	as 
	begin
		begin try
			declare @temp_cur_date date;
			declare @temp_cur_datekey int;
			declare @end_date date;
			declare @tmp_order table(
				medicineOrderHeader_ID int ,
				patient_ID int
			);
			declare @active_patient table(
				patient_code int,
				patient_ID int ,
				insurance_ID int,
				insuranceCompany_ID int
			);
			declare @active_medicine table(
				medicine_code int,
				medicine_ID int,
				medicineFactory_ID int
			);
			declare @tmp_grouped table(
				medicineOrderHeader_ID int, 
				patient_ID int,
				medicine_ID int,
				total_count int,
				paid_price int,
				total_price int,
				insurance_credit int,
				factory_share int,
				income int
			);
			declare @tmp_grouped_medicine table(
				medicineOrderHeader_ID int,
				patient_ID int,
				medicine_code int, 
				medicine_ID int,
				medicineFactory_ID int,
				total_count int,
				paid_price int,
				total_price int,
				insurance_credit int,
				factory_share int,
				income int
			);

			--set end_date and current_date
			set @end_date=(
				select max(order_date)
				from HospitalSA.dbo.MedicineOrderHeaders
			);
			set @temp_cur_date=(
				select min(order_date)
				from HospitalSA.dbo.MedicineOrderHeaders
			);

			--loop in days
			while @temp_cur_date<@end_date begin
				begin try
					--find TimeKey
					set @temp_cur_datekey=(
						select TimeKey
						from dbo.dimDate
						where FullDateAlternateKey=@temp_cur_date
					);
					--active patient and insurance and company
					insert into @active_patient
					select p.patient_code,p.patient_ID,p.insurance_ID,i.insuranceCompany_ID
					from dimPatients as p inner join dimInsurances as i on(p.insurance_ID=i.insurance_ID)
					where p.[start_date] <= @temp_cur_date and (p.current_flag=1 or p.end_date>@temp_cur_date);

					--active medicine and factory
					insert into @active_medicine
					select medicine_code,medicine_ID,medicineFactory_ID
					from Pharmacy.dimMedicines
					where [start_date] <= @temp_cur_date and (current_flag=1 or end_date>@temp_cur_date);

					--read this day OrderHeader 
					insert into @tmp_order
					select o.medicineOrderHeader_ID, isnull(o.patient_ID,-1)as patient_ID
					from HospitalSA.dbo.MedicineOrderHeaders as o
					where order_date=@temp_cur_date
					
					--find this day OrderDetails and group by header_ID and Medicine_ID
					insert  into @tmp_grouped
					select tmp.medicineOrderHeader_ID,tmp.patient_ID ,isnull(src.medicine_ID,-1),sum( src.[count]), sum((src.unit_price-src.insurance_portion)*src.[count]),sum(src.unit_price*src.[count]),sum(src.insurance_portion*src.[count]),sum(src.purchase_unit_price*src.[count]),sum((src.unit_price-src.purchase_unit_price)*src.[count])
					from @tmp_order as tmp inner join HospitalSA.dbo.MedicineOrderDetails as src on (tmp.medicineOrderHeader_ID=src.medicineOrderHeader_ID)
					group by tmp.medicineOrderHeader_ID,tmp.patient_ID, src.medicine_ID;

					--delete @tmp_order
					delete from @tmp_order;

					--finding medicine keys
					insert into @tmp_grouped_medicine
					select g.medicineOrderHeader_ID,g.patient_ID,m.medicine_code,g.medicine_ID,m.medicineFactory_ID,g.total_count,g.paid_price,g.total_price,g.insurance_credit,g.factory_share,g.income
					from @tmp_grouped as g inner join @active_medicine as m on (g.medicine_ID=m.medicine_ID)

					--delete @tmp_grouped
					delete from @tmp_grouped;

					--delete @active_medicine
					delete from @active_medicine;

					--finding patient keys and insert to fact
					insert into Pharmacy.factTransactionalMedicine
					select a.patient_code,a.patient_ID,a.insurance_ID,a.insuranceCompany_ID,m.medicine_code,m.medicine_ID,m.medicineFactory_ID,@temp_cur_datekey,m.total_count,m.paid_price,m.total_price,m.insurance_credit,m.factory_share,m.income
					from @tmp_grouped_medicine as m inner join @active_patient as a on(m.patient_ID=a.patient_ID)

					--delete @tmp_grouped_medicine
					delete from @tmp_grouped_medicine;

					--delete @active_patient
					delete from @active_patient;

					insert into Logs values
					(GETDATE(),'Pharmacy.MedicineTransactionFact',1,'Transactions of '+convert(varchar,@temp_cur_date)+' inserted',@@ROWCOUNT);
					
					--add a day 
					set @temp_cur_date=DATEADD(day, 1, @temp_cur_date);
					
				end try
				begin catch
					insert into Logs values
					(GETDATE(),'Pharmacy.MedicineTransactionFact',0,'ERROR : Transactions of '+convert(varchar,@temp_cur_date)+' may not inserted',@@ROWCOUNT);
				end catch
			end
			insert into Logs values
			(GETDATE(),'Pharmacy.MedicineTransactionFact',1,'New Transactions inserted',@@ROWCOUNT);
		end try
		begin catch
			insert into Logs values
			(GETDATE(),'Pharmacy.MedicineTransactionFact',0,'ERROR : New Transactions may not inserted',@@ROWCOUNT);
		end catch
	end
go

------------------------------------------------------
------------------------------------------------------

create or alter procedure  factMedicineTransaction
	as 
	begin
		begin try
			declare @temp_cur_date date;
			declare @temp_cur_datekey int;
			declare @end_date date;
			declare @tmp_order table(
				medicineOrderHeader_ID int ,
				patient_ID int
			);
			declare @active_patient table(
				patient_code int,
				patient_ID int ,
				insurance_ID int,
				insuranceCompany_ID int
			);
			declare @active_medicine table(
				medicine_code int,
				medicine_ID int,
				medicineFactory_ID int
			);
			declare @tmp_grouped table(
				medicineOrderHeader_ID int, 
				patient_ID int,
				medicine_ID int,
				total_count int,
				paid_price int,
				total_price int,
				insurance_credit int,
				factory_share int,
				income int
			);
			declare @tmp_grouped_medicine table(
				medicineOrderHeader_ID int,
				patient_ID int,
				medicine_code int, 
				medicine_ID int,
				medicineFactory_ID int,
				total_count int,
				paid_price int,
				total_price int,
				insurance_credit int,
				factory_share int,
				income int
			);

			--set end_date and current_date
			set @end_date=(
				select max(order_date)
				from HospitalSA.dbo.MedicineOrderHeaders
			);
			set @temp_cur_datekey=(
				select max(TimeKey)
				from Pharmacy.factTransactionalMedicine
			);
			set @temp_cur_date=(
				select dateadd(day,1,FullDateAlternateKey)
				from dbo.dimDate
				where TimeKey=@temp_cur_datekey
			);

			while @temp_cur_date<@end_date begin
				begin try
					--find TimeKey
					set @temp_cur_datekey=(
						select TimeKey
						from dbo.dimDate
						where FullDateAlternateKey=@temp_cur_date
					);
					--active patient and insurance and company
					insert into @active_patient
					select p.patient_code,p.patient_ID,p.insurance_ID,i.insuranceCompany_ID
					from dimPatients as p inner join dimInsurances as i on(p.insurance_ID=i.insurance_ID)
					where p.[start_date] <= @temp_cur_date and (p.current_flag=1 or p.end_date>@temp_cur_date);

					--active medicine and factory
					insert into @active_medicine
					select medicine_code,medicine_ID,medicineFactory_ID
					from Pharmacy.dimMedicines
					where [start_date] <= @temp_cur_date and (current_flag=1 or end_date>@temp_cur_date);

					--read this day OrderHeader 
					insert into @tmp_order
					select o.medicineOrderHeader_ID, isnull(o.patient_ID,-1)as patient_ID
					from HospitalSA.dbo.MedicineOrderHeaders as o
					where order_date=@temp_cur_date
					
					--find this day OrderDetails and group by header_ID and Medicine_ID
					insert  into @tmp_grouped
					select tmp.medicineOrderHeader_ID,tmp.patient_ID ,isnull(src.medicine_ID,-1),sum( src.[count]), sum((src.unit_price-src.insurance_portion)*src.[count]),sum(src.unit_price*src.[count]),sum(src.insurance_portion*src.[count]),sum(src.purchase_unit_price*src.[count]),sum((src.unit_price-src.purchase_unit_price)*src.[count])
					from @tmp_order as tmp inner join HospitalSA.dbo.MedicineOrderDetails as src on (tmp.medicineOrderHeader_ID=src.medicineOrderHeader_ID)
					group by tmp.medicineOrderHeader_ID,tmp.patient_ID, src.medicine_ID;

					--delete @tmp_order
					delete from @tmp_order;

					--finding medicine keys
					insert into @tmp_grouped_medicine
					select g.medicineOrderHeader_ID,g.patient_ID,m.medicine_code,g.medicine_ID,m.medicineFactory_ID,g.total_count,g.paid_price,g.total_price,g.insurance_credit,g.factory_share,g.income
					from @tmp_grouped as g inner join @active_medicine as m on (g.medicine_ID=m.medicine_ID)

					--delete @tmp_grouped
					delete from @tmp_grouped;

					--delete @active_medicine
					delete from @active_medicine;

					--finding patient keys and insert to fact
					insert into Pharmacy.factTransactionalMedicine
					select a.patient_code,a.patient_ID,a.insurance_ID,a.insuranceCompany_ID,m.medicine_code,m.medicine_ID,m.medicineFactory_ID,@temp_cur_datekey,m.total_count,m.paid_price,m.total_price,m.insurance_credit,m.factory_share,m.income
					from @tmp_grouped_medicine as m inner join @active_patient as a on(m.patient_ID=a.patient_ID)

					--delete @tmp_grouped_medicine
					delete from @tmp_grouped_medicine;

					--delete @active_patient
					delete from @active_patient;

					insert into Logs values
					(GETDATE(),'Pharmacy.MedicineTransactionFact',1,'Transactions of '+convert(varchar,@temp_cur_date)+' inserted',@@ROWCOUNT);
					
					--add a day 
					set @temp_cur_date=DATEADD(day, 1, @temp_cur_date);
					
				end try
				begin catch
					insert into Logs values
					(GETDATE(),'Pharmacy.MedicineTransactionFact',0,'ERROR : Transactions of '+convert(varchar,@temp_cur_date)+' may not inserted',@@ROWCOUNT);
				end catch
			end
			insert into Logs values
			(GETDATE(),'Pharmacy.MedicineTransactionFact',1,'New Transactions inserted',@@ROWCOUNT);
		end try
		begin catch
			insert into Logs values
			(GETDATE(),'Pharmacy.MedicineTransactionFact',0,'ERROR : New Transactions may not inserted',@@ROWCOUNT);
		end catch
	end
go

------------------------------------------------------
------------------------------------------------------

CREATE OR ALTER PROCEDURE [Pharmacy].uspFirstLoader
	AS
	BEGIN 
		BEGIN TRY
			DECLARE @curr_date DATE;
			SET @curr_date=(
				SELECT MAX(order_date)
				FROM [HospitalSA].[dbo].[MedicineOrderHeaders]
			);
			EXEC dbo.InsuranceCompaniesFirstLoader;
			EXEC dbo.uspDimPatientsFirstLoad;
			EXEC Pharmacy.MedicineFactoryFirstLoader;
			EXEC Pharmacy.uspDimMedicinesFirstLoad @curr_date ;
			EXEC MedicineTransactionFactFirstLoader;
			INSERT INTO [dbo].[Logs](
				[date]
				,[table_name]
				,[status]
				,[text]
				,[affected_rows]
			)VALUES(
				GETDATE()
				,'All Tables'
				,1
				,'All First Load insertions was successful'
				,@@ROWCOUNT
			);
		END TRY
		BEGIN CATCH
			INSERT INTO [dbo].[Logs](
				[date]
				,[table_name]
				,[status]
				,[text]
				,[affected_rows]
			)VALUES(
				GETDATE()
				,'All Tables'
				,0
				,'ERROR : First Load insertions FAILED'
				,@@ROWCOUNT
			);
			RETURN;
		END CATCH
	END
GO
 
------------------------------------------------------
------------------------------------------------------

 CREATE OR ALTER PROCEDURE [Pharmacy].uspUsaual
	AS 
	BEGIN
		BEGIN TRY
			DECLARE @curr_date DATE;
			SET @curr_date=(
				SELECT MIN(order_date)
				FROM [HospitalSA].[dbo].[MedicineOrderHeaders]
			);
			EXEC dbo.InsuranceCompaniesLoader;
			EXEC dbo.uspDimPatients;
			EXEC Pharmacy.MedicineFactoryLoader;
			EXEC Pharmacy.uspDimMedicines @curr_date ;
			EXEC MedicineTransactionFactLoader;
			INSERT INTO [dbo].[Logs](
				[date]
				,[table_name]
				,[status]
				,[text]
				,[affected_rows]
			)VALUES(
				GETDATE()
				,'All Tables'
				,1
				,'All Usual Load insertions was successful'
				,@@ROWCOUNT
			);
		END TRY
		BEGIN CATCH
			INSERT INTO [dbo].[Logs](
				[date]
				,[table_name]
				,[status]
				,[text]
				,[affected_rows]
			)VALUES(
				GETDATE()
				,'All Tables'
				,0
				,'ERROR : Usual Load insertions FAILED'
				,@@ROWCOUNT
			);
			RETURN;
		END CATCH
	END
 GO

-- Test the procedures ------------------------------------------
--EXEC [Pharmacy].uspFirstLoad;
--SELECT * FROM Logs;
--EXEC [Pharmacy].uspUsaual;
--SELECT * FROM Logs;

--for test SCD
--select * from Pharmacy.Medicines where medicine_ID=1
--select * from Patients where patient_ID=1

--select * from Pharmacy.MedicineTransactionFact where TimeKey=20140930
