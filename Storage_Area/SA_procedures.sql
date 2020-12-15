/**************************************************************************
DataBase2 Project				: Create Stage Area Procedures
Authors							: Sajede Nicknadaf,Maryam Saeidmehr,Nastaran Ashoori
Student Numbers					: 9637453,9629373,9631793
Semester						: fall 1399
version							: 2
***************************************************************************/
--InsuranceCompanies
create or alter procedure InsuranceCompanies_insert as
begin
	begin try
		truncate table InsuranceCompanies;
		insert into InsuranceCompanies
		select insuranceCompany_ID,[name],license_code,phone_number,[address]
		from Hospital.dbo.InsuranceCompanies; 
		insert into Logs values
		(GETDATE(),'InsuranceCompanies',1,'InsuranceCompanies inserted',@@ROWCOUNT);
	end try
	begin catch
		insert into Logs values
		(GETDATE(),'InsuranceCompanies',0,'ERROR : InsuranceCompanies may not inserted',@@ROWCOUNT);
	end catch
end
go
--Insurances
create or alter procedure Insurances_insert as
begin
	begin try
		truncate table Insurances;
		insert into Insurances
		select insurance_ID,insuranceCompany_ID,code,expire_date
		from Hospital.dbo.Insurances; 
		insert into Logs values
		(GETDATE(),'Insurances',1,'Insurances inserted',@@ROWCOUNT);
	end try
	begin catch
		insert into Logs values
		(GETDATE(),'Insurances',0,'ERROR : Insurances may not inserted',@@ROWCOUNT);
	end catch
end
go
--Patients
create or alter procedure Patients_insert as
begin
	begin try
		truncate table Patients;
		insert into Patients
		select patient_ID,national_code,insurance_ID,first_name,last_name,birthdate,height,[weight],gender,phone_number
		from Hospital.dbo.Patients; 
		insert into Logs values
		(GETDATE(),'Patients',1,'Patients inserted',@@ROWCOUNT);
	end try
	begin catch
		insert into Logs values
		(GETDATE(),'Patients',0,'ERROR : Patients may not inserted',@@ROWCOUNT);
	end catch
end
go
--MedicineFactories
create or alter procedure MedicineFactories_insert as
begin
	begin try
		truncate table MedicineFactories;
		insert into MedicineFactories
		select medicineFactory_ID,[name],license_code,phone_number
		from Hospital.dbo.MedicineFactories; 
		insert into Logs values
		(GETDATE(),'MedicineFactories',1,'MedicineFactories inserted',@@ROWCOUNT);
	end try
	begin catch
		insert into Logs values
		(GETDATE(),'MedicineFactories',0,'ERROR : MedicineFactories may not inserted',@@ROWCOUNT);
	end catch
end
go
--Medicines
create or alter procedure Medicines_insert as
begin
	begin try
		truncate table Medicines;
		insert into Medicines
		select medicine_ID,medicineFactory_ID,[name],latin_name,dose,side_effects,price,[description]
		from Hospital.dbo.Medicines; 
		insert into Logs values
		(GETDATE(),'Medicines',1,'Medicines inserted',@@ROWCOUNT);
	end try
	begin catch
		insert into Logs values
		(GETDATE(),'Medicines',0,'ERROR : Medicines may not inserted',@@ROWCOUNT);
	end catch
end
go
--MedicineOrderHeaders
create or alter procedure  MedicineOrder_insert as 
begin
	begin try
		declare @temp_cur_date date;
		declare @end_date date;
		declare @tmp_order table(
			medicineOrderHeader_ID int ,
			patient_ID int,
			order_date date,
			total_price int);
		set @end_date=getdate();
		set @temp_cur_date=isnull((
			select dateadd(day,1,max(order_date))
			from MedicineOrderHeaders
		),(
			select min(order_date)
			from Hospital.dbo.MedicineOrderHeaders
		));
		while @temp_cur_date<@end_date begin
			begin try
				--read this day OrderHeader
				insert into @tmp_order
				select medicineOrderHeader_ID, patient_ID, order_date, total_price
				from Hospital.dbo.MedicineOrderHeaders
				where order_date=@temp_cur_date;
				--insert to MedicineOrderHeaders
				insert into MedicineOrderHeaders
				select medicineOrderHeader_ID, patient_ID, order_date, total_price
				from @tmp_order;
				insert into Logs values
				(GETDATE(),'MedicineOrderHeaders',1,'OrderHeaders of '+convert(varchar,@temp_cur_date)+' inserted',@@ROWCOUNT);
				--read and insert this day OrderDetails
				insert into MedicineOrderDetails
				select src.medicineOrderDetails_ID, src.medicineOrderHeader_ID, src.medicine_ID, src.[count], src.unit_price
				from @tmp_order as tmp inner join Hospital.dbo.MedicineOrderDetails as src on (tmp.medicineOrderHeader_ID=src.medicineOrderHeader_ID);
				insert into Logs values
				(GETDATE(),'MedicineOrderDetails',1,'OrderDetails of '+convert(varchar,@temp_cur_date)+' inserted',@@ROWCOUNT);
				--add a day 
				set @temp_cur_date=DATEADD(day, 1, @temp_cur_date);
				--clear tmp
				delete from @tmp_order;
			end try
			begin catch
				insert into Logs values
				(GETDATE(),'MedicineOrder',0,'ERROR : Orders of '+convert(varchar,@temp_cur_date)+' may not inserted',@@ROWCOUNT);
			end catch
		end
		insert into Logs values
		(GETDATE(),'MedicineOrder',1,'MedicineOrder inserted',@@ROWCOUNT);
	end try
	begin catch
		insert into Logs values
		(GETDATE(),'MedicineOrder',0,'ERROR : MedicineOrder may not inserted',@@ROWCOUNT);
	end catch
end
go
--MainProcedure
create or alter procedure InsertToSA as
begin
	begin try
		exec InsuranceCompanies_insert;
		exec Insurances_insert;
		exec Patients_insert;
		exec MedicineFactories_insert;
		exec Medicines_insert;
		exec MedicineOrder_insert;
		insert into Logs values
		(GETDATE(),'All Tables',1,'All insertions done!',@@ROWCOUNT);
	end try
	begin catch
		insert into Logs values
		(GETDATE(),'All Tables',0,'ERROR : All insertions may not done!',@@ROWCOUNT);
	end catch
end
go

--exec InsertToSA;