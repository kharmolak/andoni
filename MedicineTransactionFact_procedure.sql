/**************************************************************************
DataBase2 Project				: Create Data Warehouse Procedures - Pharmacy 
Authors							: Sajede Nicknadaf,Maryam Saeidmehr,Nastaran Ashoori
Student Numbers					: 9637453,9629373,9631793
Semester						: fall 1399
version							: 1
***************************************************************************/
--FirstLoader
create or alter procedure  MedicineTransactionFactFirstLoader as 
begin
	begin try
		declare @temp_cur_date date;
		declare @temp_cur_datekey int;
		declare @end_date date;
		declare @tmp_order table(
			medicineOrderHeader_ID int ,
			patient_ID int,
			insuranceCompany_code int
		);
		declare @tmp_order_sarrogate table(
			medicineOrderHeader_ID int ,
			patient_code int,
			insuranceCompany_code int
		);
		declare @tmp_grouped table(
			medicineOrderHeader_ID int, 
			medicine_ID int,
			total_count int,
			total_price int
		);
		declare @tmp_grouped_factory table(
			medicineOrderHeader_ID int, 
			medicine_ID int,
			medicineFactory_code int,
			total_count int,
			total_price int
		);
		declare @tmp_medicine_surrogate_key table(
			medicineOrderHeader_ID int, 
			medicine_code int,
			medicineFactory_code int,
			total_count int,
			total_price int
		);
		declare @tmp_patient_insurance table(
			patient_ID int,
			insuranceCompany_ID int
		);
		declare @tmp_patient_insurance_code table(
			patient_ID int,
			insuranceCompany_code int
		);
		declare @tmp_medicine_factory_code table(
			medicine_ID int,
			medicineFactory_code int
		);

		--InsuranceCompany*Patient
		insert into @tmp_patient_insurance
		select p.patient_ID,i.insuranceCompany_ID
		from HospitalSA.dbo.Insurances as i inner join HospitalSA.dbo.Patients as p on (i.insurance_ID=p.insurance_ID);
		--InsuraceCompany_sarrugateKey * Patient
		insert into @tmp_patient_insurance_code
		select t.patient_ID,d.insuranceCompany_code
		from @tmp_patient_insurance as t inner join dbo.InsuranceCompanies as d on(t.insuranceCompany_ID=d.insuranceCompany_ID);
		--delete @tmp_patient_insurance
		delete from @tmp_patient_insurance;

		--medicineFactory_sarrugateKey * medicine
		insert into @tmp_medicine_factory_code
		select m.medicine_ID,f.medicineFactory_code
		from HospitalSA.dbo.Medicines as m inner join Pharmacy.MedicineFactories as f on(m.medicineFactory_ID=f.medicineFactory_ID);

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
					from dbo.[Date]
					where FullDateAlternateKey=@temp_cur_date
				);
				--read this day OrderHeader and then finding insuranceCompany sarrugate key
				insert into @tmp_order
				select o.medicineOrderHeader_ID, o.patient_ID, i.insuranceCompany_code
				from HospitalSA.dbo.MedicineOrderHeaders as o inner join @tmp_patient_insurance_code as i on(o.patient_ID=i.patient_ID)
				where order_date=@temp_cur_date;

				--finding patient sarrugate key
				insert into @tmp_order_sarrogate
				select o.medicineOrderHeader_ID, p.patient_code, o.insuranceCompany_code
				from @tmp_order as o inner join dbo.Patients as p on(o.patient_ID=p.patient_ID);

				--delete @tmp_order
				delete from @tmp_order;
				
				--find this day OrderDetails and group by header_ID and Medicine_ID
				insert  into @tmp_grouped
				select tmp.medicineOrderHeader_ID, src.medicine_ID,sum( src.[count]), sum(src.unit_price*src.[count])
				from @tmp_order_sarrogate as tmp inner join HospitalSA.dbo.MedicineOrderDetails as src on (tmp.medicineOrderHeader_ID=src.medicineOrderHeader_ID)
				group by tmp.medicineOrderHeader_ID, src.medicine_ID;

				--finding medicine factory sarrugate key
				insert into @tmp_grouped_factory
				select g.medicineOrderHeader_ID,g.medicine_ID,f.medicineFactory_code,g.total_count,g.total_price
				from @tmp_grouped as g inner join @tmp_medicine_factory_code as f on (g.medicine_ID=f.medicine_ID)

				--delete @tmp_grouped
				delete from @tmp_grouped;

				--finding medicine sarrugate key
				insert into @tmp_medicine_surrogate_key
				select g.medicineOrderHeader_ID, m.medicine_code,g.medicineFactory_code,g.total_count, g.total_price
				from @tmp_grouped_factory as g inner join Pharmacy.Medicines as m on(g.medicine_ID=m.medicine_ID)
				where m.[start_date] <= @temp_cur_date and (m.current_flag=1 or m.end_date>@temp_cur_date);

				--delete @tmp_grouped_factory
				delete from @tmp_grouped_factory;

				--insert to MedicineTransactionFact
				insert into Pharmacy.MedicineTransactionFact
				select o.patient_code,o.insuranceCompany_code,m.medicine_code,m.medicineFactory_code,@temp_cur_datekey,m.total_count,m.total_price
				from @tmp_medicine_surrogate_key as m inner join @tmp_order_sarrogate as o on(m.medicineOrderHeader_ID=o.medicineOrderHeader_ID);

				--delete @tmp_medicine_surrogate_key
				delete from @tmp_medicine_surrogate_key;

				--delete @tmp_order_sarrogate
				delete from @tmp_order_sarrogate;

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
--Loader
create or alter procedure  MedicineTransactionFactLoader as 
begin
	begin try
		declare @temp_cur_date date;
		declare @temp_cur_datekey int;
		declare @end_date date;
		declare @tmp_order table(
			medicineOrderHeader_ID int ,
			patient_ID int,
			insuranceCompany_code int
		);
		declare @tmp_order_sarrogate table(
			medicineOrderHeader_ID int ,
			patient_code int,
			insuranceCompany_code int
		);
		declare @tmp_grouped table(
			medicineOrderHeader_ID int, 
			medicine_ID int,
			total_count int,
			total_price int
		);
		declare @tmp_grouped_factory table(
			medicineOrderHeader_ID int, 
			medicine_ID int,
			medicineFactory_code int,
			total_count int,
			total_price int
		);
		declare @tmp_medicine_surrogate_key table(
			medicineOrderHeader_ID int, 
			medicine_code int,
			medicineFactory_code int,
			total_count int,
			total_price int
		);
		declare @tmp_patient_insurance table(
			patient_ID int,
			insuranceCompany_ID int
		);
		declare @tmp_patient_insurance_code table(
			patient_ID int,
			insuranceCompany_code int
		);
		declare @tmp_medicine_factory_code table(
			medicine_ID int,
			medicineFactory_code int
		);

		--InsuranceCompany*Patient
		insert into @tmp_patient_insurance
		select p.patient_ID,i.insuranceCompany_ID
		from HospitalSA.dbo.Insurances as i inner join HospitalSA.dbo.Patients as p on (i.insurance_ID=p.insurance_ID);
		--InsuraceCompany_sarrugateKey * Patient
		insert into @tmp_patient_insurance_code
		select t.patient_ID,d.insuranceCompany_code
		from @tmp_patient_insurance as t inner join dbo.InsuranceCompanies as d on(t.insuranceCompany_ID=d.insuranceCompany_ID);
		--delete @tmp_patient_insurance
		delete from @tmp_patient_insurance;

		--medicineFactory_sarrugateKey * medicine
		insert into @tmp_medicine_factory_code
		select m.medicine_ID,f.medicineFactory_code
		from HospitalSA.dbo.Medicines as m inner join Pharmacy.MedicineFactories as f on(m.medicineFactory_ID=f.medicineFactory_ID);

		--set end_date and current_date
		set @end_date=(
			select max(order_date)
			from HospitalSA.dbo.MedicineOrderHeaders
		);
		set @temp_cur_datekey=(
			select max(TimeKey)
			from Pharmacy.MedicineTransactionFact
		);
		set @temp_cur_date=(
			select dateadd(day,1,FullDateAlternateKey)
			from dbo.[Date]
			where TimeKey=@temp_cur_datekey
		);

		--loop in days
		while @temp_cur_date<@end_date begin
			begin try
				--find TimeKey
				set @temp_cur_datekey=(
					select TimeKey
					from dbo.[Date]
					where FullDateAlternateKey=@temp_cur_date
				);
				--read this day OrderHeader and then finding insuranceCompany sarrugate key
				insert into @tmp_order
				select o.medicineOrderHeader_ID, o.patient_ID, i.insuranceCompany_code
				from HospitalSA.dbo.MedicineOrderHeaders as o inner join @tmp_patient_insurance_code as i on(o.patient_ID=i.patient_ID)
				where order_date=@temp_cur_date;

				--finding patient sarrugate key
				insert into @tmp_order_sarrogate
				select o.medicineOrderHeader_ID, p.patient_code, o.insuranceCompany_code
				from @tmp_order as o inner join dbo.Patients as p on(o.patient_ID=p.patient_ID);

				--delete @tmp_order
				delete from @tmp_order;
				
				--find this day OrderDetails and group by header_ID and Medicine_ID
				insert  into @tmp_grouped
				select tmp.medicineOrderHeader_ID, src.medicine_ID,sum( src.[count]), sum(src.unit_price*src.[count])
				from @tmp_order_sarrogate as tmp inner join HospitalSA.dbo.MedicineOrderDetails as src on (tmp.medicineOrderHeader_ID=src.medicineOrderHeader_ID)
				group by tmp.medicineOrderHeader_ID, src.medicine_ID;

				--finding medicine factory sarrugate key
				insert into @tmp_grouped_factory
				select g.medicineOrderHeader_ID,g.medicine_ID,f.medicineFactory_code,g.total_count,g.total_price
				from @tmp_grouped as g inner join @tmp_medicine_factory_code as f on (g.medicine_ID=f.medicine_ID)

				--delete @tmp_grouped
				delete from @tmp_grouped;

				--finding medicine sarrugate key
				insert into @tmp_medicine_surrogate_key
				select g.medicineOrderHeader_ID, m.medicine_code,g.medicineFactory_code,g.total_count, g.total_price
				from @tmp_grouped_factory as g inner join Pharmacy.Medicines as m on(g.medicine_ID=m.medicine_ID)
				where m.[start_date] <= @temp_cur_date and (m.current_flag=1 or m.end_date>@temp_cur_date);

				--delete @tmp_grouped_factory
				delete from @tmp_grouped_factory;

				--insert to MedicineTransactionFact
				insert into Pharmacy.MedicineTransactionFact
				select o.patient_code,o.insuranceCompany_code,m.medicine_code,m.medicineFactory_code,@temp_cur_datekey,m.total_count,m.total_price
				from @tmp_medicine_surrogate_key as m inner join @tmp_order_sarrogate as o on(m.medicineOrderHeader_ID=o.medicineOrderHeader_ID);

				--delete @tmp_medicine_surrogate_key
				delete from @tmp_medicine_surrogate_key;

				--delete @tmp_order_sarrogate
				delete from @tmp_order_sarrogate;

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