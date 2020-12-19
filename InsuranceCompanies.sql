create or alter procedure InsuranceCompaniesFirstLoader
as
begin
	begin try 
		truncate table HospitalDW.dbo.InsuranceCompanies
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

create or alter procedure InsuranceCompaniesLoader
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
