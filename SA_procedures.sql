/**************************************************************************
DataBase2 Project				: Create Stage Area Procedures
Authors							: Sajede Nicknadaf,Maryam Saeidmehr,Nastaran Ashoori
Student Numbers					: 9637453,9629373,9631793
Semester						: fall 1399
version							: 1
***************************************************************************/
--InsuranceCompanies
create procedure InsuranceCompanies_insert as
begin
	truncate table InsuranceCompanies;
	insert into InsuranceCompanies
	select insuranceCompany_ID,[name],license_code,phone_number,[address]
	from Hospital.dbo.InsuranceCompanies; 
	insert into Logs values
	('InsuranceCompanies inserted',GETDATE());
end
go
--Insurances
create procedure Insurances_insert as
begin
	truncate table Insurances;
	insert into Insurances
	select insurance_ID,insuranceCompany_ID,code,expire_date
	from Hospital.dbo.Insurances; 
	insert into Logs values
	('Insurances inserted',GETDATE());
end
go
--Patients
create procedure Patients_insert as
begin
	truncate table Patients;
	insert into Patients
	select patient_ID,national_code,insurance_ID,first_name,last_name,birthdate,height,[weight],gender,phone_number
	from Hospital.dbo.Patients; 
	insert into Logs values
	('Patients inserted',GETDATE());
end
go
--MedicineFactories
create procedure MedicineFactories_insert as
begin
	truncate table MedicineFactories;
	insert into MedicineFactories
	select medicineFactory_ID,[name],license_code,phone_number
	from Hospital.dbo.MedicineFactories; 
	insert into Logs values
	('MedicineFactories inserted',GETDATE());
end
go
--Medicines
create procedure Medicines_insert as
begin
	truncate table Medicines;
	insert into Medicines
	select medicine_ID,medicineFactory_ID,[name],latin_name,dose,side_effects,price,[description]
	from Hospital.dbo.Medicines; 
	insert into Logs values
	('Medicines inserted',GETDATE());
end
go
--MedicineOrderHeaders
create procedure  MedicineOrder_insert as 
begin
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
		('OrderHeaders of '+convert(varchar,@temp_cur_date)+' inserted',GETDATE());
		--read and insert this day OrderDetails
		insert into MedicineOrderDetails
		select src.medicineOrderDetails_ID, src.medicineOrderHeader_ID, src.medicine_ID, src.[count], src.unit_price
		from @tmp_order as tmp inner join Hospital.dbo.MedicineOrderDetails as src on (tmp.medicineOrderHeader_ID=src.medicineOrderHeader_ID);
		insert into Logs values
		('OrderDetails of '+convert(varchar,@temp_cur_date)+' inserted',GETDATE());
		--add a day 
		set @temp_cur_date=DATEADD(day, 1, @temp_cur_date);
		--clear tmp
		delete from @tmp_order;
	end
	insert into Logs values
	('Orders insertions done',GETDATE());
end
go
--MainProcedure
create procedure InsertToSA as
begin
	exec InsuranceCompanies_insert;
	exec Insurances_insert;
	exec Patients_insert;
	exec MedicineFactories_insert;
	exec Medicines_insert;
	exec MedicineOrder_insert;
	insert into Logs values
	('All insertions done!',GETDATE());
end
go

--exec InsertToSA;