/**************************************************************************
DataBase2 Project	: Create Data Warehouse Procedures-Pharmacy facts
Authors					: Sajede Nicknadaf, Maryam Saeedmehr
Student Numbers	: 9637453, 9629373
Semester					: fall 1399
version						: 4
***************************************************************************/
use HospitalDW
go

create or alter procedure  factTransactionalMedicine_FirstLoader @temp_cur_date date
	as 
	begin
		begin try
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

create or alter procedure  factTransactionalMedicine_Loader @temp_cur_date date
	as 
	begin
		begin try
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

create or alter procedure  factMonthlyMedicine_FirstLoader @temp_cur_date date
	as 
	begin
		begin try
			declare @temp_cur_datekey int;
			declare @end_month_datekey int;
			declare @end_date date;

			--set end_date and current_date
			set @end_date=(
				select max(order_date)
				from HospitalSA.dbo.MedicineOrderHeaders
			);

			if(DATEADD(month, 1, @temp_cur_date)>@end_date) return;
			
			--loop in months
			while @temp_cur_date<@end_date begin
				begin try
					--find TimeKeys
					set @temp_cur_datekey=(
						select TimeKey
						from dbo.dimDate
						where FullDateAlternateKey=@temp_cur_date
					);
					set @end_month_datekey=(
						select TimeKey
						from dbo.dimDate
						where FullDateAlternateKey=DATEADD(month, 1, @temp_cur_date)
					);
					--transactions of this month
					select patient_ID, insuranceCompany_ID,medicine_code,medicine_ID,medicineFactory_ID,number_of_units_bought,paid_price,real_price,insurance_credit,factory_share,income 
					into #tmp_transactions
					from Pharmacy.factTransactionalMedicine
					where TimeKey>=@temp_cur_datekey and TimeKey<@end_month_datekey;

					--group by
					select insuranceCompany_ID,medicine_code,medicine_ID,medicineFactory_ID,sum(number_of_units_bought)as total_number_bought,sum(paid_price)as total_paid_price,sum(real_price)as total_real_price,sum(insurance_credit)as total_insurance_credit,sum(factory_share)as total_factory_share,sum(income)as total_income,count(patient_ID)as number_of_patients_bought
					into #tmp_grouped
					from #tmp_transactions
					group by insuranceCompany_ID,medicine_code,medicine_ID,medicineFactory_ID

					--all insuranceCompanies
					select i.insuranceCompany_ID,isnull(t.medicine_code,-1)as medicine_code,isnull(t.medicine_ID,-1)as medicine_ID,isnull(t.medicineFactory_ID,-1)as medicineFactory_ID,isnull(t.total_number_bought,0)as total_number_bought,isnull(t.total_paid_price,0)as total_paid_price,isnull(t.total_real_price,0)as total_real_price,isnull(t.total_insurance_credit,0)as total_insurance_credit,isnull(t.total_factory_share,0)as total_factory_share,isnull(t.total_income,0)as total_income,isnull(t.number_of_patients_bought,0)as number_of_patients_bought
					into #tmp_grouped_ic
					from dbo.dimInsuranceCompanies as i left join #tmp_transactions as t on(i.insuranceCompany_ID=t.insuranceCompany_ID)
					
					--all medicines

					--all medicineFactories

					--delete data
					truncate table #tmp_transactions;

					insert into Logs values
					(GETDATE(),'Pharmacy.MedicineTransactionFact',1,'Transactions of '+convert(varchar,@temp_cur_date)+' inserted',@@ROWCOUNT);
					
					--add a day 
					set @temp_cur_date=DATEADD(month, 1, @temp_cur_date);
					
				end try
				begin catch
					insert into Logs values
					(GETDATE(),'Pharmacy.MedicineTransactionFact',0,'ERROR : Transactions of '+convert(varchar,@temp_cur_date)+' may not inserted',@@ROWCOUNT);
				end catch
			end
			--drop table
			drop table #tmp_transactions;

			insert into Logs values
			(GETDATE(),'Pharmacy.MedicineTransactionFact',1,'New Transactions inserted',@@ROWCOUNT);
		end try
		begin catch
			insert into Logs values
			(GETDATE(),'Pharmacy.MedicineTransactionFact',0,'ERROR : New Transactions may not inserted',@@ROWCOUNT);
		end catch
	end
go
