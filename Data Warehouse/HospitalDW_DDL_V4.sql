/*************************************************************************
DataBase2 Project		: Create Data Warehouse
Authors						: Sajede Nicknadaf, Maryam Saeedmehr
Student Numbers		: 9637453, 9629373
Semester						: fall 1399
version							: 4
**************************************************************************/
drop database if exists HospitalDW
go

create database HospitalDW
go 

use HospitalDW
go

exec sp_changedbowner 'sa'
go
/***********************************Schema******************************/
create schema Pharmacy
go

create schema Clinic
go
/********************************Dimensions*****************************/
create table dimInsuranceCompanies(
	insuranceCompany_ID			int primary key,
	[name]									varchar(75),
	license_code						varchar(25),
	phone_number					varchar(25),--SCD1
	[address]								varchar(300),--SCD1
	previous_manager				varchar(100),
	manager_change_date		date,
	current_manager					varchar(100),--SCD3
	previous_agent					varchar(100),
	agent_change_date				date,
	current_agent						varchar(100),--SCD3
	fax_number							varchar(25),--SCD1
	website_address					varchar(200),
	manager_phone_number	varchar(25),--SCD1
	agent_phone_number			varchar(25),--SCD1
	additional_info						varchar(200),
	active									tinyint,--SCD1
	active_description				varchar(200)
)
go

create table dimInsurances(
	insurance_ID						int primary key, 
	code										varchar(15), 
	insuranceCompany_ID			int,
	insuranceCompany_name	varchar(75),
	insurer									varchar(100),
	insurer_phone_number		varchar(25),
	additional_info						varchar(200),
	expire_date							date,
	medicine_reduction				int,
	appointment1_reduction		int,
	appointment2_reduction		int,
	appointment3_reduction		int,
	hospitalization_reduction	int,
	surgery_reduction				int,
	test_reduction						int,
	dentistry_reduction				int,
	radiology_reduction			int
)
go

create table dimPatients(
	patient_code						int identity(1,1) primary key,-- surrogate key
    patient_ID							int ,
    national_code						varchar(15),
	insurance_ID						int,--SCD2
    first_name							varchar(30),
    last_name							varchar(60),
    birthdate								date,
    height									int,--SCD1
    [weight]								int,--SCD1
    gender									varchar(15),
    phone_number					varchar(25),--SCD1
	death_date							date,--SCD1
	death_reason						int,--SCD1
	postal_code							varchar(20),--SCD1
	[address]								varchar(200),--SCD1
	additional_info						varchar(200),
	[start_date]							date,
    end_date								date,
    current_flag							int,
)
go

create table Pharmacy.dimMedicineFactories(
    medicineFactory_ID				int primary key,
    [name]									varchar(75),
    license_code						varchar(25),
    phone_number					varchar(25),--SCD1
	previous_manager				varchar(100),
	manager_change_date		date,
	current_manager					varchar(100),--SCD3
	previous_agent					varchar(100),
	agent_change_date				date,
	current_agent						varchar(100),--SCD3
	fax_number							varchar(25),--SCD1
	website_address					varchar(200),
	manager_phone_number	varchar(25),--SCD1
	agent_phone_number			varchar(25),--SCD1
	[address]								varchar(200),--SCD1
	additional_info						varchar(200),
	active									bit,
	active_description				varchar(200)
)
go

create table Pharmacy.dimMedicines(
    medicine_code						int identity(1,1) primary key, --surrogate key
    medicine_ID								int,
    [name]										varchar(30),
    latin_name								varchar(75),
    dose											float,
    side_effects								varchar(200),
    purchase_price							int,--SCD2
	sales_price								int,--SCD2
	stock										int, --SCD1
	medicine_type							int, 
	medicine_type_description		varchar(20),
	medicineFactory_ID					int,
	production_date						date,--SCD1
	expire_date								date,--SCD1
	additional_info							varchar(200),
    [start_date]								date,
    end_date									date,
    current_flag								int,
	sales_purchase							tinyint, -- -1 -> null records / 0 -> firstload/ 1 -> sales / 2 -> purchase / 3 -> both 
	sales_purchase_description		varchar(50)
)
go

create table dimDate (
    TimeKey										int primary key,
    FullDateAlternateKey					varchar(50),
    PersianFullDateAlternateKey		varchar(50),
    DayNumberOfWeek					int,
    PersianDayNumberOfWeek			int,
    EnglishDayNameOfWeek			varchar(10),
    PersianDayNameOfWeek			nvarchar(10),
    DayNumberOfMonth					int,
    PersianDayNumberOfMonth		int,
    DayNumberOfYear						int,
    PersianDayNumberOfYear			int,
    WeekNumberOfYear					int,
    PersianWeekNumberOfYear		int,
    EnglishMonthName						varchar(50),
    PersianMonthName					nvarchar(50),
    MonthNumberOfYear					int,
    PersianMonthNumberOfYear		int,
    CalendarQuarter							int,
    PersianCalendarQuarter				int,
    CalendarYear								int,
    PersianCalendarYear					int,
    CalendarSemester						int,
    PersianCalendarSemester			int
)
go

create table Clinic.dimDepartments(
    department_ID						int primary key,
    [name]									varchar(30),
    [description]						varchar(300),
	previous_chairman				varchar(100),
	chairman_change_date		date,
	current_chairman					varchar(100),--SCD3
	previous_assistant				varchar(100),
	assistant_change_date			date,
	current_assistant					varchar(100),--SCD3
	chairman_phone_number	varchar(15),--SCD1
	assistant_phone_number		varchar(15),--SCD1
	chairman_room					int,
	assistant_room						int,
	reception_phone_number	varchar(15),--SCD1
	budget									int,
	additional_info						varchar(200)
)
go

create table Clinic.dimDoctorContracts(
	doctorContract_ID			int primary key,
	contract_start_date			date,
	contract_end_date			date,
	appointment_portion		int,
	salary								int,
	active								bit,
	active_description			varchar(50),
	additional_info					varchar(200) 
)
go

create table Clinic.dimDoctors(
	doctor_code							int IDENTITY(1,1) primary key, -- surrogate key
    doctor_ID									int,
	doctorContract_ID					int,--SCD2
    national_code							varchar(15),
    license_code							varchar(25),
    first_name								varchar(30),
    last_name								varchar(75),
    birthdate									date,
    phone_number						varchar(25),--SCD1
	department_ID							int,
	department_name					varchar(30),
	education_degree					int, --[1-3]  --SCD2 
	specialty_description				varchar(100),
	graduation_date						date,
	university									varchar(100),
	gender										varchar(10),
	religion									varchar(100),
	nationality								varchar(50),
	marital_status							bit,
	marital_status_description		varchar(20), -- 0 for single / 1 for married
	postal_code								varchar(12),
	[address]									varchar(200),
	additional_info							varchar(200),
	[start_date]								date,
    end_date									date,
    current_flag								int,
	Contract_Degree						tinyint,-- -1 -> null record / 0 -> firstload / 1 -> Contract / 2 -> Degree / 3 -> both
	Contract_Degree_description	varchar(50)
)
go

create table Clinic.dimIllnessTypes(
	illnessType_ID					int primary key,
	[name]								varchar(50),
	[description]					varchar(200),
	related_department_ID	int
)
go

create table Clinic.dimIllnesses(
	illness_ID								int primary key,
	[name]									varchar(100),
	illnessType_ID						int,
	illnessType_name					varchar(50),
	scientific_name					varchar(100),
	special_illness						bit, --0 for not special / 1 for special illnesses
	special_illness_description	varchar(50),
	killing_status						smallint,
	killing_description				varchar(100),
	chronic									bit,
	chronic_description				varchar(100)
)
go

/***********************************Facts*********************************/
create table Pharmacy.factTransactionalMedicine(
	patient_code						int,-- surrogate key
    patient_ID							int,--natural key
	insurance_ID						int, 
    insuranceCompany_ID			int,
    medicine_code					int, --surrogate key
    medicine_ID							int, --natural key
    medicineFactory_ID				int,
    TimeKey								int,
	----------------------------------
    number_of_units_bought	int,
    paid_price							int,
	real_price								int,
	insurance_credit					int,
	factory_share						int,
	income									int,
)
go

create table Pharmacy.factMonthlyMedicine(
	insuranceCompany_ID				int,
    medicine_code						int, --surrogate key
    medicine_ID								int, --natural key
	medicineFactory_ID					int,
    TimeKey									int,
	-------------------------------------
    total_number_bought				int,
    total_paid_price						int,
	total_real_price						int,
	total_insurance_credit				int,
	total_factory_share					int,
	total_income							int,
    number_of_patients_bought   int,
)
go

create table Pharmacy.factAccumulativeMedicine(
	insuranceCompany_ID				int,
    medicine_code						int, --surrogate key
    medicine_ID								int, --natural key
	medicineFactory_ID					int,
	-------------------------------------
    total_number_bought				int,
    total_paid_price						int,
	total_real_price						int,
	total_insurance_credit				int,
	total_factory_share					int,
	total_income							int,
    number_of_patients_bought   int,
	max_bought_per_month			int,
	min_bought_per_month			int,
	avg_bought_per_month			int
)
go
-------------------------------------------------------------
-------------------------------------------------------------
create table Clinic.factTransactionAppointment (
    patient_code					int,-- surrogate key
    patient_ID						int,--natural key
	insurance_ID					int, 
    insuranceCompany_ID		int,
    doctor_ID							int,
	doctorContract_ID			int,
	department_ID					int,
	main_detected_illness		int,
	illnessType_ID					int,
    TimeKey							int,
	-------------------------------
    paid_price						int,
	real_price							int,
	insurance_credit				int,
	doctor_share					int,
	income								int
)
go

create table Clinic.factDailyAppointment (
	insuranceCompany_ID		int,
    doctor_ID							int,
	doctorContract_ID			int,
	department_ID					int,
	main_detected_illness		int,
	illnessType_ID					int,
    TimeKey							int,
	-------------------------------
	total_paied_price				int,
	total_real_price				int,
	total_insurance_credit		int,
	total_doctor_share			int,
	total_income					int,
	number_of_patient			int
)
go

create table Clinic.factMonthlyAppointment (
	insuranceCompany_ID		int,
    doctor_ID							int,
	doctorContract_ID			int,
	department_ID					int,
    TimeKey							int,
	-------------------------------
	total_paied_price				int,
	total_real_price				int,
	total_insurance_credit		int,
	total_doctor_share			int,
	total_income					int,
	number_of_patient			int,
	max_visit_per_day			int,
	min_visit_per_day			int,
	avg_visit_per_day				int,
)
go

create table Clinic.factAccumulativeAppointment (
    insuranceCompany_ID		int,
    doctor_ID							int,
	doctorContract_ID			int,
	department_ID					int,
	-------------------------------
	total_paied_price				int,
	total_real_price				int,
	total_insurance_credit		int,
	total_doctor_share			int,
	total_income					int,
	number_of_patient			int,
	max_visit_per_month		int,
	min_visit_per_month		int,
	avg_visit_per_month		int,
)
go

create table factlessPatientIlnesses(
	patient_ID				int,
	illness_ID					int,
	[detection_date]		date,
	severity					int, --[1-5]
	additional_info			varchar(200)
)
go

create table Logs(
    [date]				datetime,
    table_name     varchar(50),
    [status]				bit,
    [description]	varchar(500),
    affected_rows  int,
)