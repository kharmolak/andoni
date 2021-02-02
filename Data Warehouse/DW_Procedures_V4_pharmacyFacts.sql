/**************************************************************************
DataBase2 Project	: Create Data Warehouse Procedures-Pharmacy facts
Authors					: Sajede Nicknadaf, Maryam Saeedmehr
Student Numbers	: 9637453, 9629373
Semester					: fall 1399
version						: 4
***************************************************************************/
use HospitalDW
go

create or alter procedure  Pharmacy.factTransactionalMedicine_FirstLoader
	as 
	begin
		begin try
			DECLARE @temp_cur_date DATE;
			declare @temp_cur_datekey int;
			declare @end_date date;
			

			--set end_date and current_date
			set @end_date=(
				select max(order_date)
				from HospitalSA.dbo.MedicineOrderHeaders
			);
			
			SET @temp_cur_date=(
				SELECT min(order_date)
				FROM [HospitalSA].[dbo].[MedicineOrderHeaders]
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
					select p.patient_code,p.patient_ID,p.insurance_ID,i.insuranceCompany_ID
					into #active_patient
					from dimPatients as p inner join dimInsurances as i on(p.insurance_ID=i.insurance_ID)
					where p.[start_date] <= @temp_cur_date and (p.current_flag=1 or p.end_date>@temp_cur_date);

					--active medicine and factory
					select medicine_code,medicine_ID,medicineFactory_ID
					into #active_medicine
					from Pharmacy.dimMedicines
					where [start_date] <= @temp_cur_date and (current_flag=1 or end_date>@temp_cur_date);

					--read this day OrderHeader 
					select o.medicineOrderHeader_ID, isnull(o.patient_ID,-1)as patient_ID
					into #tmp_order
					from HospitalSA.dbo.MedicineOrderHeaders as o
					where order_date=@temp_cur_date
					
					--find this day OrderDetails and group by header_ID and Medicine_ID
					select tmp.medicineOrderHeader_ID,tmp.patient_ID ,isnull(src.medicine_ID,-1)as medicine_ID,sum( src.[count])as total_count, sum((src.unit_price-src.insurance_portion)*src.[count])as paid_price,sum(src.unit_price*src.[count])as total_price,sum(src.insurance_portion*src.[count])as insurance_credit,sum(src.purchase_unit_price*src.[count])as factory_share,sum((src.unit_price-src.purchase_unit_price)*src.[count])as income
					into #tmp_grouped
					from #tmp_order as tmp inner join HospitalSA.dbo.MedicineOrderDetails as src on (tmp.medicineOrderHeader_ID=src.medicineOrderHeader_ID)
					group by tmp.medicineOrderHeader_ID,tmp.patient_ID, src.medicine_ID;

					--finding medicine keys
					select g.medicineOrderHeader_ID,g.patient_ID,m.medicine_code,g.medicine_ID,m.medicineFactory_ID,g.total_count,g.paid_price,g.total_price,g.insurance_credit,g.factory_share,g.income
					into #tmp_grouped_medicine
					from #tmp_grouped as g inner join #active_medicine as m on (g.medicine_ID=m.medicine_ID)


					--finding patient keys and insert to fact
					insert into Pharmacy.factTransactionalMedicine
					select a.patient_code,a.patient_ID,a.insurance_ID,a.insuranceCompany_ID,m.medicine_code,m.medicine_ID,m.medicineFactory_ID,@temp_cur_datekey,m.total_count,m.paid_price,m.total_price,m.insurance_credit,m.factory_share,m.income
					from #tmp_grouped_medicine as m inner join #active_patient as a on(m.patient_ID=a.patient_ID)

					--truncate
					truncate table #tmp_order;
					truncate table #tmp_grouped;
					truncate table #active_medicine;
					truncate table #tmp_grouped_medicine;
					truncate table #active_patient;

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
			
			--drop table 
			drop table #tmp_order;
			drop table #tmp_grouped;
			drop table #active_medicine;
			drop table #tmp_grouped_medicine;
			drop table #active_patient;

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

create or alter procedure  Pharmacy.factTransactionalMedicine_Loader 
	as 
	begin
		begin try
			DECLARE @temp_cur_date DATE;
			declare @temp_cur_datekey int;
			declare @end_date date;
			

			--set end_date and current_date
			set @end_date=(
				select max(order_date)
				from HospitalSA.dbo.MedicineOrderHeaders
			);

			SET @temp_cur_datekey=(
				SELECT max(TimeKey)
				FROM [HospitalDW].[Pharmacy].[factTransactionalMedicine]
			);
			
			set @temp_cur_date=(
			select FullDateAlternateKey
			from dbo.dimDate
			where TimeKey=@temp_cur_datekey
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
					select p.patient_code,p.patient_ID,p.insurance_ID,i.insuranceCompany_ID
					into #active_patient
					from dimPatients as p inner join dimInsurances as i on(p.insurance_ID=i.insurance_ID)
					where p.[start_date] <= @temp_cur_date and (p.current_flag=1 or p.end_date>@temp_cur_date);

					--active medicine and factory
					select medicine_code,medicine_ID,medicineFactory_ID
					into #active_medicine
					from Pharmacy.dimMedicines
					where [start_date] <= @temp_cur_date and (current_flag=1 or end_date>@temp_cur_date);

					--read this day OrderHeader 
					select o.medicineOrderHeader_ID, isnull(o.patient_ID,-1)as patient_ID
					into #tmp_order
					from HospitalSA.dbo.MedicineOrderHeaders as o
					where order_date=@temp_cur_date
					
					--find this day OrderDetails and group by header_ID and Medicine_ID
					select tmp.medicineOrderHeader_ID,tmp.patient_ID ,isnull(src.medicine_ID,-1)as medicine_ID,sum( src.[count])as total_count, sum((src.unit_price-src.insurance_portion)*src.[count])as paid_price,sum(src.unit_price*src.[count])as total_price,sum(src.insurance_portion*src.[count])as insurance_credit,sum(src.purchase_unit_price*src.[count])as factory_share,sum((src.unit_price-src.purchase_unit_price)*src.[count])as income
					into #tmp_grouped
					from #tmp_order as tmp inner join HospitalSA.dbo.MedicineOrderDetails as src on (tmp.medicineOrderHeader_ID=src.medicineOrderHeader_ID)
					group by tmp.medicineOrderHeader_ID,tmp.patient_ID, src.medicine_ID;

					--finding medicine keys
					select g.medicineOrderHeader_ID,g.patient_ID,m.medicine_code,g.medicine_ID,m.medicineFactory_ID,g.total_count,g.paid_price,g.total_price,g.insurance_credit,g.factory_share,g.income
					into #tmp_grouped_medicine
					from #tmp_grouped as g inner join #active_medicine as m on (g.medicine_ID=m.medicine_ID)


					--finding patient keys and insert to fact
					insert into Pharmacy.factTransactionalMedicine
					select a.patient_code,a.patient_ID,a.insurance_ID,a.insuranceCompany_ID,m.medicine_code,m.medicine_ID,m.medicineFactory_ID,@temp_cur_datekey,m.total_count,m.paid_price,m.total_price,m.insurance_credit,m.factory_share,m.income
					from #tmp_grouped_medicine as m inner join #active_patient as a on(m.patient_ID=a.patient_ID)

					--truncate
					truncate table #tmp_order;
					truncate table #tmp_grouped;
					truncate table #active_medicine;
					truncate table #tmp_grouped_medicine;
					truncate table #active_patient;

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
			
			--drop table 
			drop table #tmp_order;
			drop table #tmp_grouped;
			drop table #active_medicine;
			drop table #tmp_grouped_medicine;
			drop table #active_patient;

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

create or alter procedure  Pharmacy.factMonthlyMedicine_FirstLoader
	as 
	begin
		begin try
			declare @small_curr_date date;--loop in days
			declare @small_curr_datekey int;
			declare @temp_cur_date date;--loop in month
			declare @temp_cur_datekey int;
			declare @end_month_datekey int;
			declare @end_date date;

			--set end_date and current_date
			set @end_date=(
				select max(order_date)
				from HospitalSA.dbo.MedicineOrderHeaders
			);

			SET @temp_cur_date=(
				SELECT min(order_date)
				FROM [HospitalSA].[dbo].[MedicineOrderHeaders]
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

					set @small_curr_date=@temp_cur_date;
					set @small_curr_datekey=@temp_cur_datekey;
					--loop in days
					while @small_curr_date<DATEADD(month, 1, @temp_cur_date) begin
						
						--transactions of this day
						select insuranceCompany_ID,medicine_ID,medicineFactory_ID,sum(number_of_units_bought)as total_number_bought,sum(paid_price)as total_paid_price,sum(real_price)as total_real_price,sum(insurance_credit)as total_insurance_credit,sum(factory_share)as total_factory_share,sum(income)as total_income,count(patient_ID)as number_of_patients_bought
						into #tmp_grouped_day
						from Pharmacy.factTransactionalMedicine
						where TimeKey=@small_curr_datekey
						group by insuranceCompany_ID,medicine_ID,medicineFactory_ID;

						--add day
						set @small_curr_date=DATEADD(day, 1, @small_curr_date);
						set @small_curr_datekey=(
							select TimeKey
							from dbo.dimDate
							where FullDateAlternateKey=@small_curr_date
						);
					end

					
					--group by
					select insuranceCompany_ID,medicine_ID,medicineFactory_ID,sum(total_number_bought)as total_number_bought,sum(total_paid_price)as total_paid_price,sum(total_real_price)as total_real_price,sum(total_insurance_credit)as total_insurance_credit,sum(total_factory_share)as total_factory_share,sum(total_income)as total_income,count(number_of_patients_bought)as number_of_patients_bought
					into #tmp_grouped
					from #tmp_grouped_day
					group by insuranceCompany_ID,medicine_ID,medicineFactory_ID;

					--this month medicine
					select medicine_ID ,max( [start_date]) as [start_date]
					into #tmp_active_medicine
					from Pharmacy.dimMedicines
					where [start_date]<DATEADD(month, 1, @temp_cur_date) and (current_flag=1 or [end_date]>=@temp_cur_date )
					group by medicine_ID;

					--
					select m.medicine_code,m.medicine_ID,m.medicineFactory_ID
					into #tmp_medicine
					from Pharmacy.dimMedicines as m inner join #tmp_active_medicine as a on(m.medicine_ID=a.medicine_ID and a.[start_date]=m.[start_date] and m.medicine_code<>-1);

					--Medicine X InsuranceCompanies
					select t.insuranceCompany_ID ,m.medicine_code,m.medicine_ID,m.medicineFactory_ID
					into #tmp_kartezian
					from #tmp_medicine as m , dbo.dimInsuranceCompanies as t
					where m.medicine_code<>-1 and t.insuranceCompany_ID<>-1;
					
					--insert
					insert into Pharmacy.factMonthlyMedicine
					select i.insuranceCompany_ID,i.medicine_code,i.medicine_ID,i.medicineFactory_ID,@temp_cur_datekey,isnull(t.total_number_bought,0)as total_number_bought,isnull(t.total_paid_price,0)as total_paid_price,isnull(t.total_real_price,0)as total_real_price,isnull(t.total_insurance_credit,0)as total_insurance_credit,isnull(t.total_factory_share,0)as total_factory_share,isnull(t.total_income,0)as total_income,isnull(t.number_of_patients_bought,0)as number_of_patients_bought
					from #tmp_kartezian as i left join #tmp_grouped as t on(i.insuranceCompany_ID=t.insuranceCompany_ID and t.medicine_ID=i.medicine_ID and t.medicineFactory_ID=i.medicineFactory_ID)

					--truncate tmps
					truncate table #tmp_grouped_day;
					truncate table #tmp_grouped;
					truncate table #tmp_active_medicine;
					truncate table #tmp_medicine;
					truncate table #tmp_kartezian;

					insert into Logs values
					(GETDATE(),'Pharmacy.factMonthlyMedicine',1,'Records of '+convert(varchar,@temp_cur_date)+' inserted',@@ROWCOUNT);
					
					--add a day 
					set @temp_cur_date=DATEADD(month, 1, @temp_cur_date);
					
				end try
				begin catch
					insert into Logs values
					(GETDATE(),'Pharmacy.factMonthlyMedicine',0,'ERROR : Records of '+convert(varchar,@temp_cur_date)+' may not inserted',@@ROWCOUNT);
				end catch
			end
			--drop tables
				drop table #tmp_grouped_day;
				drop table #tmp_grouped;
				drop table #tmp_active_medicine;
				drop table #tmp_medicine;
				drop table #tmp_kartezian;

			insert into Logs values
			(GETDATE(),'Pharmacy.factMonthlyMedicine',1,'New Records inserted',@@ROWCOUNT);
		end try
		begin catch
			insert into Logs values
			(GETDATE(),'Pharmacy.factMonthlyMedicine',0,'ERROR : New Records may not inserted',@@ROWCOUNT);
		end catch
	end
go

------------------------------------------------------
------------------------------------------------------

create or alter procedure  Pharmacy.factMonthlyMedicine_Loader 
	as 
	begin
		begin try
			declare @small_curr_date date;--loop in days
			declare @small_curr_datekey int;
			declare @temp_cur_date date;--loop in month
			declare @temp_cur_datekey int;
			declare @end_month_datekey int;
			declare @end_date date;

			--set end_date and current_date
			set @end_date=(
				select max(order_date)
				from HospitalSA.dbo.MedicineOrderHeaders
			);

			declare @month_count int;
			set @month_count=(select count(*) from Pharmacy.factMonthlyMedicine);
			if @month_count=0 begin
				SET @temp_cur_date=(
				SELECT min(order_date)
				FROM [HospitalSA].[dbo].[MedicineOrderHeaders]
			);
			end
			else begin
				SET @temp_cur_datekey=(
					SELECT max(TimeKey)
					FROM [HospitalDW].[Pharmacy].[factMonthlyMedicine]
				);
				set @temp_cur_date=(select DATEADD(month, 1, FullDateAlternateKey)  from dbo.dimDate where TimeKey=@temp_cur_datekey);
				set @temp_cur_datekey=(select TimeKey  from dbo.dimDate where FullDateAlternateKey=@temp_cur_date);
			end

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

					set @small_curr_date=@temp_cur_date;
					set @small_curr_datekey=@temp_cur_datekey;
					--loop in days
					while @small_curr_date<DATEADD(month, 1, @temp_cur_date) begin
						
						--transactions of this day
						select insuranceCompany_ID,medicine_ID,medicineFactory_ID,sum(number_of_units_bought)as total_number_bought,sum(paid_price)as total_paid_price,sum(real_price)as total_real_price,sum(insurance_credit)as total_insurance_credit,sum(factory_share)as total_factory_share,sum(income)as total_income,count(patient_ID)as number_of_patients_bought
						into #tmp_grouped_day
						from Pharmacy.factTransactionalMedicine
						where TimeKey=@small_curr_datekey
						group by insuranceCompany_ID,medicine_ID,medicineFactory_ID;

						--add day
						set @small_curr_date=DATEADD(day, 1, @small_curr_date);
						set @small_curr_datekey=(
							select TimeKey
							from dbo.dimDate
							where FullDateAlternateKey=@small_curr_date
						);
					end

					
					--group by
					select insuranceCompany_ID,medicine_ID,medicineFactory_ID,sum(total_number_bought)as total_number_bought,sum(total_paid_price)as total_paid_price,sum(total_real_price)as total_real_price,sum(total_insurance_credit)as total_insurance_credit,sum(total_factory_share)as total_factory_share,sum(total_income)as total_income,count(number_of_patients_bought)as number_of_patients_bought
					into #tmp_grouped
					from #tmp_grouped_day
					group by insuranceCompany_ID,medicine_ID,medicineFactory_ID;

					--this month medicine
					select medicine_ID ,max( [start_date]) as [start_date]
					into #tmp_active_medicine
					from Pharmacy.dimMedicines
					where [start_date]<DATEADD(month, 1, @temp_cur_date) and (current_flag=1 or [end_date]>=@temp_cur_date )
					group by medicine_ID;

					--
					select m.medicine_code,m.medicine_ID,m.medicineFactory_ID
					into #tmp_medicine
					from Pharmacy.dimMedicines as m inner join #tmp_active_medicine as a on(m.medicine_ID=a.medicine_ID and a.[start_date]=m.[start_date] and m.medicine_code<>-1);

					--Medicine X InsuranceCompanies
					select t.insuranceCompany_ID ,m.medicine_code,m.medicine_ID,m.medicineFactory_ID
					into #tmp_kartezian
					from #tmp_medicine as m , dbo.dimInsuranceCompanies as t
					where m.medicine_code<>-1 and t.insuranceCompany_ID<>-1;
					
					--insert
					insert into Pharmacy.factMonthlyMedicine
					select i.insuranceCompany_ID,i.medicine_code,i.medicine_ID,i.medicineFactory_ID,@temp_cur_datekey,isnull(t.total_number_bought,0)as total_number_bought,isnull(t.total_paid_price,0)as total_paid_price,isnull(t.total_real_price,0)as total_real_price,isnull(t.total_insurance_credit,0)as total_insurance_credit,isnull(t.total_factory_share,0)as total_factory_share,isnull(t.total_income,0)as total_income,isnull(t.number_of_patients_bought,0)as number_of_patients_bought
					from #tmp_kartezian as i left join #tmp_grouped as t on(i.insuranceCompany_ID=t.insuranceCompany_ID and t.medicine_ID=i.medicine_ID and t.medicineFactory_ID=i.medicineFactory_ID)

					--truncate tmps
					truncate table #tmp_grouped_day;
					truncate table #tmp_grouped;
					truncate table #tmp_active_medicine;
					truncate table #tmp_medicine;
					truncate table #tmp_kartezian;

					insert into Logs values
					(GETDATE(),'Pharmacy.factMonthlyMedicine',1,'Records of '+convert(varchar,@temp_cur_date)+' inserted',@@ROWCOUNT);
					
					--add a day 
					set @temp_cur_date=DATEADD(month, 1, @temp_cur_date);
					
				end try
				begin catch
					insert into Logs values
					(GETDATE(),'Pharmacy.factMonthlyMedicine',0,'ERROR : Records of '+convert(varchar,@temp_cur_date)+' may not inserted',@@ROWCOUNT);
				end catch
			end
			--drop tables
				drop table #tmp_grouped_day;
				drop table #tmp_grouped;
				drop table #tmp_active_medicine;
				drop table #tmp_medicine;
				drop table #tmp_kartezian;

			insert into Logs values
			(GETDATE(),'Pharmacy.factMonthlyMedicine',1,'New Records inserted',@@ROWCOUNT);
		end try
		begin catch
			insert into Logs values
			(GETDATE(),'Pharmacy.factMonthlyMedicine',0,'ERROR : New Records may not inserted',@@ROWCOUNT);
		end catch
	end
go

------------------------------------------------------
------------------------------------------------------

create or alter procedure  Pharmacy.factAccumulativeMedicine_FirstLoader 
	as 
	begin
		begin try
			declare @temp_cur_date date;
			declare @temp_cur_datekey int;
			declare @end_date date;
			declare @end_datekey int;

			--set end_date and current_date
			set @end_date=(
				select max(order_date)
				from HospitalSA.dbo.MedicineOrderHeaders
			);
			SET @temp_cur_date=(
				SELECT min(order_date)
				FROM [HospitalSA].[dbo].[MedicineOrderHeaders]
			);

			--kartezian
			select i.insuranceCompany_ID,m.medicine_code,m.medicine_ID,m.medicineFactory_ID,0 as total_number_bought,0 as total_paid_price,
					0 as total_real_price,0 as total_insurance_credit, 0 as total_factory_share,0 as total_income,0 as number_of_patients_bought
			into #temp1
			from dbo.dimInsuranceCompanies as i,Pharmacy.dimMedicines as m
			where i.insuranceCompany_ID<>-1 and m.medicine_code<>-1 and m.current_flag=1

			while @temp_cur_date<@end_date begin
				--curr datekey
				set @temp_cur_datekey=(select TimeKey from dbo.dimDate where FullDateAlternateKey=@temp_cur_date);

				--this day transactions
				select insuranceCompany_ID,medicine_ID,medicineFactory_ID,sum(number_of_units_bought)as total_number_bought,sum(paid_price) as total_paid_price,
						sum(real_price)as total_real_price,sum(insurance_credit)as total_insurance_credit,sum(factory_share)as total_factory_share,
						sum(income)as total_income, count(patient_ID) as number_of_patients_bought
				into #temp2
				from Pharmacy.factTransactionalMedicine
				where TimeKey=@temp_cur_datekey
				group by insuranceCompany_ID,medicine_ID,medicineFactory_ID;

				--
				select *
				into #temp3
				from #temp1
				--
				truncate table #temp1

				insert into #temp1
				select s.insuranceCompany_ID,s.medicine_code,s.medicine_ID,s.medicineFactory_ID,isnull(n.total_number_bought,0)+s.total_number_bought,isnull(n.total_paid_price,0)+s.total_paid_price ,
						isnull(n.total_real_price,0)+s.total_real_price,isnull(n.total_insurance_credit,0)+s.total_insurance_credit,isnull(n.total_factory_share,0)+s.total_factory_share ,
						isnull(n.total_income,0)+s.total_income, isnull(n.number_of_patients_bought,0)+s.number_of_patients_bought
				from #temp3 as s left join #temp2 as n on(s.insuranceCompany_ID=n.insuranceCompany_ID and s.medicine_ID=n.medicine_ID and s.medicineFactory_ID=n.medicineFactory_ID)
			
				--add day
				set @temp_cur_date=DATEADD(day, 1, @temp_cur_date);
			
			end

			--insert to fact
			insert into Pharmacy.factAccumulativeMedicine
			select insuranceCompany_ID,medicine_code,medicine_ID,medicineFactory_ID,total_number_bought,total_paid_price,
					total_real_price,total_insurance_credit,total_factory_share,total_income,number_of_patients_bought
			from #temp1;

			--drop tables
			drop table #temp1;
			drop table #temp2;
			drop table #temp3;

			insert into Logs values
			(GETDATE(),'Pharmacy.factAccumulativeMedicine',1,'New Records inserted',@@ROWCOUNT);
		end try
		begin catch
			insert into Logs values
			(GETDATE(),'Pharmacy.factAccumulativeMedicine',0,'ERROR : New Records may not inserted',@@ROWCOUNT);
		end catch
	end
go

------------------------------------------------------
------------------------------------------------------

create or alter procedure  Pharmacy.factAccumulativeMedicine_Loader @cur_date date
	as 
	begin
		begin try
			declare @temp_cur_date date;
			declare @temp_cur_datekey int;
			declare @end_date date;
			declare @end_datekey int;

			--set end_date and current_date
			set @end_date=(
				select max(order_date)
				from HospitalSA.dbo.MedicineOrderHeaders
			);
			set @temp_cur_date=@cur_date;

			--kartezian
			select i.insuranceCompany_ID,m.medicine_code,m.medicine_ID,m.medicineFactory_ID
			into #kartezian
			from dbo.dimInsuranceCompanies as i,Pharmacy.dimMedicines as m
			where i.insuranceCompany_ID<>-1 and m.medicine_code<>-1 and m.current_flag=1

			--#temp1
			select k.insuranceCompany_ID,k.medicine_code,k.medicine_ID,k.medicineFactory_ID,isnull( total_number_bought,0)as total_number_bought, isnull( total_paid_price,0)as total_paid_price,
					isnull(total_real_price,0) as total_real_price,isnull(total_insurance_credit,0) as total_insurance_credit, isnull(total_factory_share,0) as total_factory_share,isnull(total_income,0) as total_income,isnull(number_of_patients_bought,0) as number_of_patients_bought
			into #temp1
			from #kartezian as k left join Pharmacy.factAccumulativeMedicine as a on(k.insuranceCompany_ID=a.insuranceCompany_ID and k.medicine_ID=a.medicine_ID and k.medicineFactory_ID=a.medicineFactory_ID)

			while @temp_cur_date<@end_date begin
				--curr datekey
				set @temp_cur_datekey=(select TimeKey from dbo.dimDate where FullDateAlternateKey=@temp_cur_date);

				--this day transactions
				select insuranceCompany_ID,medicine_ID,medicineFactory_ID,sum(number_of_units_bought)as total_number_bought,sum(paid_price) as total_paid_price,
						sum(real_price)as total_real_price,sum(insurance_credit)as total_insurance_credit,sum(factory_share)as total_factory_share,
						sum(income)as total_income, count(patient_ID) as number_of_patients_bought
				into #temp2
				from Pharmacy.factTransactionalMedicine
				where TimeKey=@temp_cur_datekey
				group by insuranceCompany_ID,medicine_ID,medicineFactory_ID;

				--
				select *
				into #temp3
				from #temp1
				--
				truncate table #temp1

				insert into #temp1
				select s.insuranceCompany_ID,s.medicine_code,s.medicine_ID,s.medicineFactory_ID,isnull(n.total_number_bought,0)+s.total_number_bought,isnull(n.total_paid_price,0)+s.total_paid_price ,
						isnull(n.total_real_price,0)+s.total_real_price,isnull(n.total_insurance_credit,0)+s.total_insurance_credit,isnull(n.total_factory_share,0)+s.total_factory_share ,
						isnull(n.total_income,0)+s.total_income, isnull(n.number_of_patients_bought,0)+s.number_of_patients_bought
				from #temp3 as s left join #temp2 as n on(s.insuranceCompany_ID=n.insuranceCompany_ID and s.medicine_ID=n.medicine_ID and s.medicineFactory_ID=n.medicineFactory_ID)
			
				--add day
				set @temp_cur_date=DATEADD(day, 1, @temp_cur_date);

			end

			--insert to fact
			insert into Pharmacy.factAccumulativeMedicine
			select insuranceCompany_ID,medicine_code,medicine_ID,medicineFactory_ID,total_number_bought,total_paid_price,
					total_real_price,total_insurance_credit,total_factory_share,total_income,number_of_patients_bought
			from #temp1;

			--drop tables
			drop table #temp1;
			drop table #temp2;
			drop table #temp3;

			insert into Logs values
			(GETDATE(),'Pharmacy.factMonthlyMedicine',1,'New Records inserted',@@ROWCOUNT);
		end try
		begin catch
			insert into Logs values
			(GETDATE(),'Pharmacy.factMonthlyMedicine',0,'ERROR : New Records may not inserted',@@ROWCOUNT);
		end catch
	end
go

------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

create or alter procedure Pharmacy.FirstLoad as
begin
	begin try
		declare @curr_date date;
		SET @curr_date=(
					SELECT min(order_date)
					FROM [HospitalSA].[dbo].[MedicineOrderHeaders]
				);
		exec Pharmacy.dimMedicineFactory_FirstLoader @curr_date;
		exec Pharmacy.dimMedicines_FirstLoader @curr_date;
		exec Pharmacy.factTransactionalMedicine_FirstLoader;
		exec Pharmacy.factMonthlyMedicine_FirstLoader;
		exec Pharmacy.factAccumulativeMedicine_FirstLoader;

		INSERT INTO [dbo].[Logs](
				[date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows]
			)VALUES(
				GETDATE()
				,'Pharmacy Tables'
				,1
				,'First Load insertions was successful'
				,@@ROWCOUNT
			);
	end try
	begin catch
		INSERT INTO [dbo].[Logs](
				[date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows]
			)VALUES(
				GETDATE()
				,'Pharmacy Tables'
				,0
				,'ERROR : First Load insertions FAILED'
				,@@ROWCOUNT
			);
	end catch

end
go

------------------------------------------------------
------------------------------------------------------

create or alter procedure Pharmacy.[Load] as
begin
	begin try
		declare @curr_date date;
		declare @curr_datekey int;
		SET @curr_datekey=(
					SELECT max(TimeKey)
					FROM Pharmacy.[factTransactionalMedicine]
				);
		set @curr_date=(select DATEADD(day, 1, FullDateAlternateKey) from dbo.dimDate where TimeKey=@curr_datekey);

		exec Pharmacy.dimMedicineFactory_Loader @curr_date;
		exec Pharmacy.dimMedicines_Loader @curr_date;
		exec Pharmacy.factTransactionalMedicine_Loader;
		exec Pharmacy.factMonthlyMedicine_Loader;
		exec Pharmacy.factAccumulativeMedicine_Loader @curr_date;

		INSERT INTO [dbo].[Logs](
				[date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows]
			)VALUES(
				GETDATE()
				,'Pharmacy Tables'
				,1
				,'Load insertions was successful'
				,@@ROWCOUNT
			);
	end try
	begin catch
		INSERT INTO [dbo].[Logs](
				[date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows]
			)VALUES(
				GETDATE()
				,'Pharmacy Tables'
				,0
				,'ERROR : Load insertions FAILED'
				,@@ROWCOUNT
			);
	end catch

end
