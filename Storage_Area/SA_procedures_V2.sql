/**************************************************************************
DataBase2 Project				: Create Stage Area Procedures
Authors							: Sajede Nicknadaf,Maryam Saeidmehr
Student Numbers					: 9637453,9629373
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
		select insurance_ID,insuranceCompany_ID,code,expire_date,medicine_reduction,appointment1_reduction,appointment2_reduction,appointment3_reduction,hospitalization_reduction,surgery_reduction,test_reduction,dentistry_reduction,radiology_reduction
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
--Departments
create or alter procedure Departments_insert as
begin
	begin try
		truncate table Departments;
		insert into Departments
		select department_ID,[name],[description]
		from Hospital.dbo.Departments; 
		insert into Logs values
		(GETDATE(),'Departments',1,'Departments inserted',@@ROWCOUNT);
	end try
	begin catch
		insert into Logs values
		(GETDATE(),'Departments',0,'ERROR : Departments may not inserted',@@ROWCOUNT);
	end catch
end
go
--IlnessTypes
create or alter procedure IlnessTypes_insert as
begin
	begin try
		truncate table IlnessTypes;
		insert into IlnessTypes
		select ilnessType_ID,[name],[description],related_department_ID
		from Hospital.dbo.IlnessTypes; 
		insert into Logs values
		(GETDATE(),'IlnessTypes',1,'IlnessTypes inserted',@@ROWCOUNT);
	end try
	begin catch
		insert into Logs values
		(GETDATE(),'IlnessTypes',0,'ERROR : IlnessTypes may not inserted',@@ROWCOUNT);
	end catch
end
go
--Ilnesses
create or alter procedure Ilnesses_insert as
begin
	begin try
		truncate table Ilnesses;
		insert into Ilnesses
		select illness_ID,[name],scientific_name,danger
		from Hospital.dbo.Ilnesses; 
		insert into Logs values
		(GETDATE(),'Ilnesses',1,'Ilnesses inserted',@@ROWCOUNT);
	end try
	begin catch
		insert into Logs values
		(GETDATE(),'Ilnesses',0,'ERROR : Ilnesses may not inserted',@@ROWCOUNT);
	end catch
end
go
--Patients
create or alter procedure Patients_insert as
begin
	begin try
		truncate table Patients;
		insert into Patients
		select patient_ID,national_code,insurance_ID,first_name,last_name,birthdate,height,[weight],gender,phone_number,death_date,death_reason
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
--Doctors
create or alter procedure Doctors_insert as
begin
	begin try
		truncate table Doctors;
		insert into Doctors
		select doctor_ID,department_ID,national_code,license_code,first_name,last_name,birthdate,phone_number,education_degree,specialty_description,graduation_date,university,contract_start_date,contract_end_date,appointment_portion,surgery_portion
		from Hospital.dbo.Doctors; 
		insert into Logs values
		(GETDATE(),'Doctors',1,'Doctors inserted',@@ROWCOUNT);
	end try
	begin catch
		insert into Logs values
		(GETDATE(),'Doctors',0,'ERROR : Doctors may not inserted',@@ROWCOUNT);
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
		select medicine_ID,medicineFactory_ID,[name],latin_name,dose,side_effects,purchase_price,sales_price,stock,[description],medicine_type
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
		set @end_date=(
			select max(order_date)
			from Hospital.dbo.MedicineOrderHeaders
		);
		set @temp_cur_date=isnull((
			select dateadd(day,1,max(order_date))
			from MedicineOrderHeaders
		),(
			select min(order_date)
			from Hospital.dbo.MedicineOrderHeaders
		));
		while @temp_cur_date<=@end_date begin
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
--Appointments
create or alter procedure  Appointments_insert as 
begin
	begin try
		declare @temp_cur_date date;
		declare @end_date date;

		set @end_date=(
			select max(appointment_date)
			from Hospital.dbo.Appointments
		);
		set @temp_cur_date=isnull((
			select dateadd(day,1,max(appointment_date))
			from Appointments
		),(
			select min(appointment_date)
			from Hospital.dbo.Appointments
		));
		while @temp_cur_date<=@end_date begin
			begin try
				--read and insert this day appointments
				insert into Appointments
				select appointment_ID,patient_ID,doctor_ID,main_detected_illness,appointment_number,appointment_date,price,[status]
				from Hospital.dbo.Appointments
				where appointment_date=@temp_cur_date;
				--log
				insert into Logs values
				(GETDATE(),'Appointments',1,'Appointments of '+convert(varchar,@temp_cur_date)+' inserted',@@ROWCOUNT);
				--add a day 
				set @temp_cur_date=DATEADD(day, 1, @temp_cur_date);
			end try
			begin catch
				insert into Logs values
				(GETDATE(),'Appointments',0,'ERROR : Appointments of '+convert(varchar,@temp_cur_date)+' may not inserted',@@ROWCOUNT);
			end catch
		end

		insert into Logs values
		(GETDATE(),'Appointments',1,'Appointments inserted',@@ROWCOUNT);
	end try
	begin catch
		insert into Logs values
		(GETDATE(),'Appointments',0,'ERROR : Appointments may not inserted',@@ROWCOUNT);
	end catch
end
go
--PatientIlnesses
create or alter procedure  PatientIlnesses_insert as 
begin
	begin try
		declare @temp_cur_date date;
		declare @end_date date;

		set @end_date=(
			select max(detection_date)
			from Hospital.dbo.PatientIlnesses
		);
		set @temp_cur_date=isnull((
			select dateadd(day,1,max(detection_date))
			from PatientIlnesses
		),(
			select min(detection_date)
			from Hospital.dbo.PatientIlnesses
		));
		while @temp_cur_date<=@end_date begin
			begin try
				--read and insert this day appointments
				insert into PatientIlnesses
				select patientIlnesse_ID,patient_ID,ilness_ID,[detection_date],degree
				from Hospital.dbo.PatientIlnesses
				where detection_date=@temp_cur_date;
				--log
				insert into Logs values
				(GETDATE(),'PatientIlnesses',1,'PatientIlnesses of '+convert(varchar,@temp_cur_date)+' inserted',@@ROWCOUNT);
				--add a day 
				set @temp_cur_date=DATEADD(day, 1, @temp_cur_date);
			end try
			begin catch
				insert into Logs values
				(GETDATE(),'PatientIlnesses',0,'ERROR : PatientIlnesses of '+convert(varchar,@temp_cur_date)+' may not inserted',@@ROWCOUNT);
			end catch
		end

		insert into Logs values
		(GETDATE(),'PatientIlnesses',1,'PatientIlnesses inserted',@@ROWCOUNT);
	end try
	begin catch
		insert into Logs values
		(GETDATE(),'PatientIlnesses',0,'ERROR : PatientIlnesses may not inserted',@@ROWCOUNT);
	end catch
end
go
--MainProcedure
create or alter procedure InsertToSA as
begin
	begin try
		exec InsuranceCompanies_insert;
		exec Insurances_insert;
		exec Departments_insert;
		exec IlnessTypes_insert;
		exec Ilnesses_insert;
		exec Patients_insert;
		exec Doctors_insert;
		exec MedicineFactories_insert;
		exec Medicines_insert;
		exec MedicineOrder_insert;
		exec Appointments_insert;
		exec PatientIlnesses_insert;
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

