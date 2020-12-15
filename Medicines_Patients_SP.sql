/**************************************************************************
DataBase2 Project		: Load data from SA to DW - Dimensions 
Authors						: Sajede Nicknadaf,Maryam Saeidmehr,Nastaran Ashoori
Student Numbers		: 9637453,9629373,9631793
Semester						: fall 1399
version							: 1
***************************************************************************/
CREATE OR ALTER PROCEDURE dbo.uspDimPatients
AS 
BEGIN 
	--DECLARE @tmp TABLE(
	--	[patient_ID] [int] NULL,
	--	[national_code] [varchar](15) NULL,
	--	[name] [varchar](30) NULL,
	--	[family] [varchar](30) NULL,
	--	[birthdate] [date] NULL,
	--	[height] [int] NULL,
	--	[weight] [int] NULL,
	--	[gender] [varchar](15) NULL,
	--	[phone_number] [varchar](25) NULL
	--);
	--INSERT INTO @tmp 
	--	SELECT [patient_ID]
	--				,[national_code]
	--				,[name]
	--				,[family]
	--				,[birthdate]
	--				,[height]
	--				,[weight]
	--				,[gender]
	--				,[phone_number] 
	--	FROM HospitalDW.dbo.Patients;
	
	--TRUNCATE TABLE HospitalDW.dbo.Patients;

	----new & update & not change
	--INSERT INTO HospitalDW.dbo.Patients
	--	SELECT [patient_ID]
	--			  ,[national_code]
	--			  ,[first_name]
	--			  ,[last_name]
	--			  ,[birthdate]
	--			  ,[height]
	--			  ,[weight]
	--			  ,[gender]
	--			  ,[phone_number]
	--	FROM HospitalSA.dbo.Patients

	----delete
	--INSERT INTO HospitalDW.dbo.Patients
	--	SELECT [patient_ID]
	--				,[national_code]
	--				,[name]
	--				,[family]
	--				,[birthdate]
	--				,[height]
	--				,[weight]
	--				,[gender]
	--				,[phone_number] 
	--	FROM @tmp
	--	WHERE [patient_ID] NOT IN (SELECT [patient_ID] from HospitalSA.dbo.Patients);

	MERGE INTO HospitalDW.dbo.Patients AS [Target]
	USING HospitalSA.dbo.Patients AS [Source]
	ON Source.patient_ID = [Target].patient_ID
	WHEN MATCHED AND
		 (
			   [Target].height						<> Source.height
			   OR [Target].[weight]				<> Source.[weight]
			   OR [Target].phone_number <> Source.phone_number
		 ) 
	THEN UPDATE SET 
				height = Source.[height],
				[weight] = Source.[weight],
				phone_number = Source.[phone_number]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT INTO [Target] VALUES Source.[patient_ID],
												Source.[national_code],
						 						Source.[name],
												Source.[family],
												Source.[birthdate],
												Source.[height],
												Source.[weight],
												Source.[gender],
												Source.[phone_number]


END
GO


create procedure dw.insert_or_update_dim_customer as
begin
    insert into dw.logs
    values (current_timestamp, 'dim_customer ', 2, ' insert_or_update_dim_customer ')

    SELECT customer_id,
           first_name,
           last_name,
           phone,
           email,
           street,
           city,
           state,
           zip_code
    INTO temp_customer
    FROM dw.dim_customer
    where 1 = 0

    delete from temp_customer where 1 > 0

--     insert new rows which they are not in dim

    insert into temp_customer
    select customer_id,
           first_name,
           last_name,
           phone,
           email,
           street,
           city,
           state,
           zip_code
    from SA.sa.customers
    where customer_id not in (select customer_id from dw.dim_customer)

--     insert old dim rows and update  if it is necessary

    insert into temp_customer
    select dc.customer_id,
           dc.first_name,
           dc.last_name,
           IIF(c.customer_id is null, dc.phone, c.phone),
           IIF(c.customer_id is null, dc.email, c.email),
           IIF(c.customer_id is null, dc.street, c.street),
           IIF(c.customer_id is null, dc.city, c.city),
           IIF(c.customer_id is null, dc.state, c.state),
           IIF(c.customer_id is null, dc.zip_code, c.zip_code)
    from dw.dim_customer dc
             left join SA.sa.customers c on dc.customer_id = c.customer_id

    delete from dw.dim_customer where 1 > 0

    insert into dw.dim_customer
    select customer_id,
           first_name,
           last_name,
           phone,
           email,
           street,
           city,
           state,
           zip_code
    from temp_customer

    drop table temp_customer

    insert into dw.logs
    values (current_timestamp, 'dim_customer ', 3, ' insert_or_update_dim_customer ')
end
go