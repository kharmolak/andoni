create or alter procedure Pharmacy.MedicineFactoryLoader
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

exec MedicineFactoryLoader

------------------------------------------------------
------------------------------------------------------

create or alter procedure Pharmacy.MedicineFactoryFirstLoader
as
begin
	begin try 
		delete from HospitalDW.Pharmacy.MedicineFactories
		dbcc CHECKIDENT([HospitalDW.Pharmacy.MedicineFactories],RESEED,0)
		insert into HospitalDW.Pharmacy.MedicineFactories 
        select 
		[medicineFactory_ID],
		[name],
		[license_code],
		[phone_number]
		from HospitalSA.dbo.MedicineFactories;
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

exec MedicineFactoryFirstLoader