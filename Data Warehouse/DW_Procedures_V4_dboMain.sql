/**************************************************************************
DataBase2 Project	: Create Data Warehouse Procedures-dbo main procedure
Authors					: Sajede Nicknadaf, Maryam Saeedmehr
Student Numbers	: 9637453, 9629373
Semester					: fall 1399
version						: 4
***************************************************************************/
use HospitalDW
go

create or alter procedure Pharmacy.FirstLoad as
begin
	begin try
		declare @curr_date date;
		SET @curr_date=(
					SELECT min(order_date)
					FROM [HospitalSA].[dbo].[MedicineOrderHeaders]
				);
		exec dbo.dimInsuranceCompanies_FirstLoader @curr_date;
		exec dbo.dimInsurances_FirstLoader;
		exec dbo.dimPatients_FirstLoader @curr_date;
		exec Pharmacy.FirstLoad;
		exec Clinic.FirstLoad;

		INSERT INTO [dbo].[Logs](
				[date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows]
			)VALUES(
				GETDATE()
				,'All Tables'
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
				,'All Tables'
				,0
				,'ERROR : First Load insertions FAILED'
				,@@ROWCOUNT
			);
	end catch

end
go

------------------------------------------------------
------------------------------------------------------

create or alter procedure dbo.[Load] as
begin
	begin try
		declare @curr_date date;
		declare @curr_datekey int;
		SET @curr_datekey=(
					SELECT max(TimeKey)
					FROM Pharmacy.[factTransactionalMedicine]
				);
		set @curr_date=(select DATEADD(day, 1, FullDateAlternateKey) from dbo.dimDate where TimeKey=@curr_datekey);

		exec dbo.dimInsuranceCompanies_Loader @curr_date;
		exec dbo.dimInsurances_Loader;
		exec dbo.dimPatients_Loader @curr_date;
		exec Pharmacy.[Load];
		exec Clinic.[Load];

		INSERT INTO [dbo].[Logs](
				[date]
				,[table_name]
				,[status]
				,[description]
				,[affected_rows]
			)VALUES(
				GETDATE()
				,'All Tables'
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
				,'All Tables'
				,0
				,'ERROR : Load insertions FAILED'
				,@@ROWCOUNT
			);
	end catch

end
go
