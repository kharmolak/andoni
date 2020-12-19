/**************************************************************************
DataBase2 Project		: Create Data Warehouse General Procedures - Pharmacy 
Authors						: Sajede Nicknadaf,Maryam Saeidmehr,Nastaran Ashoori
Student Numbers		: 9637453,9629373,9631793
Semester						: fall 1399
version							: 1
***************************************************************************/
CREATE OR ALTER PROCEDURE [Pharmacy].uspFirstLoad
AS
BEGIN 
	BEGIN TRY
		DECLARE @curr_date DATE;
		SET @curr_date=(
			SELECT MIN(order_date)
			FROM [HospitalSA].[dbo].[MedicineOrderHeaders]
		);
		EXEC dbo.InsuranceCompaniesFirstLoader;
		EXEC dbo.uspDimPatientsFirstLoad;
		EXEC Pharmacy.MedicineFactoryFirstLoader;
		EXEC Pharmacy.uspDimMedicinesFirstLoad @curr_date ;
		EXEC MedicineTransactionFactFirstLoader;
		INSERT INTO [dbo].[Logs]
           ([date]
           ,[table_name]
           ,[status]
           ,[text]
           ,[affected_rows])
		 VALUES
           (GETDATE()
           ,'All Tables'
           ,1
           ,'All First Load insertions was successful'
           ,@@ROWCOUNT);
	END TRY
	BEGIN CATCH
		INSERT INTO [dbo].[Logs]
           ([date]
           ,[table_name]
           ,[status]
           ,[text]
           ,[affected_rows])
		 VALUES
           (GETDATE()
           ,'All Tables'
           ,0
           ,'ERROR : First Load insertions FAILED'
           ,@@ROWCOUNT);
			RETURN;
	END CATCH
END
GO
 
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
		INSERT INTO [dbo].[Logs]
			([date]
			,[table_name]
			,[status]
			,[text]
			,[affected_rows])
			VALUES
			(GETDATE()
			,'All Tables'
			,1
			,'All Usual Load insertions was successful'
			,@@ROWCOUNT);
	END TRY
	BEGIN CATCH
		INSERT INTO [dbo].[Logs]
           ([date]
           ,[table_name]
           ,[status]
           ,[text]
           ,[affected_rows])
		 VALUES
           (GETDATE()
           ,'All Tables'
           ,0
           ,'ERROR : Usual Load insertions FAILED'
           ,@@ROWCOUNT);
			RETURN;
	END CATCH
 END
 GO

 -- Test the procedures ------------------------------------------
--EXEC [Pharmacy].uspFirstLoad;
--SELECT * FROM Logs;
--EXEC [Pharmacy].uspUsaual;
--SELECT * FROM Logs;