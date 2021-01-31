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

--create schema Hospitalization
--go
/********************************Dimensions*****************************/
create table dimInsuranceCompanies(
	insuranceCompany_ID		int primary key,
	[name]								varchar(75),
	license_code					varchar(25),
	phone_number				varchar(25),--SCD1
	[address]							varchar(300),--SCD1
	manager							varchar(100),--SCD3
	agent								varchar(100),--SCD3
	fax_number						varchar(25),--SCD1
	website_address				varchar(200),
	manager_phone_number varchar(25),--SCD1
	agent_phone_number		varchar(25),--SCD1
	additional_info					varchar(200),
	active								bit,
	active_description			varchar(200)
);

create table dimInsurances(
	insurance_ID						int primary key,
	code										varchar(15), 
	insuranceCompany_ID			int,
	insuranceCompany_name	varchar(75),
	insurer									varchar(100),
	insurer_phone_number		varchar(25),
	additional_info						varchar(200),
	expire_date							date,--SCD1
	medicine_reduction				int,--SCD1
	appointment1_reduction		int,--SCD1
	appointment2_reduction		int,--SCD1
	appointment3_reduction		int,--SCD1
	hospitalization_reduction	int,--SCD1
	surgery_reduction				int,--SCD1
	test_reduction						int,--SCD1
	dentistry_reduction				int,--SCD1
	radiology_reduction			int,--SCD1
);

create table dimPatients(
    patient_ID							int primary key,
    national_code						varchar(15),
	insurance_ID						int,
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
);

create table Pharmacy.dimMedicineFactories(
    medicineFactory_ID				int primary key,
    [name]									varchar(75),
    license_code						varchar(25),
    phone_number					varchar(25),--SCD1
	manager								varchar(100),--SCD3
	agent									varchar(100),--SCD3
	fax_number							varchar(25),--SCD1
	website_address					varchar(200),
	manager_phone_number	varchar(25),--SCD1
	agent_phone_number			varchar(25),--SCD1
	[address]								varchar(200),--SCD1
	additional_info						varchar(200),
	active									bit,
	active_description				varchar(200)
);

create table Pharmacy.dimMedicines(
    medicine_code						int identity(1,1) primary key, --surrogate key
    medicine_ID								int,
    [name]										varchar(30),
    latin_name								varchar(75),
    dose											float,
    side_effects								varchar(200),
    purchase_price							int,--SCD2
	sales_price								int,--SCD2
	stock										int,--SCD3 --> SCD1 ?
	medicine_type							int, 
	medicine_type_description		varchar(20),
	medicineFactory_ID					int,
	production_date						date,--SCD1
	expire_date								date,--SCD1
	additional_info							varchar(200),
    [start_date]								date,
    end_date									date,
    current_flag								int,
);

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
);

create table Clinic.dimDepartments(
    department_ID						int primary key,
    [name]									varchar(30),
    [description]						varchar(300),
	chairman								varchar(50),--SCD3
	assistant								varchar(50),--SCD3
	chairman_phone_number	varchar(15),--SCD1
	assistant_phone_number		varchar(15),--SCD1
	chairman_room					int,
	assistant_room						int,
	reception_phone_number	varchar(15),--SCD1
	budget									int,
	additional_info						varchar(200)
);

create table Clinic.dimDoctors(
    doctor_ID								int primary key,
    national_code						varchar(15),
    license_code						varchar(25),
    first_name							varchar(30),
    last_name							varchar(75),
    birthdate								date,
    phone_number					varchar(25),--SCD1
	department_ID						int,
	department_name				varchar(30),
	education_degree				int, --[1-3]  --SCD2 
	specialty_description			varchar(100),
	graduation_date					date,
	university								varchar(100),
	contract_start_date				date, ---?
	contract_end_date				date,
	appointment_portion			int,
	gender									varchar(10),
	religion								varchar(100),
	nationality							varchar(50),
	marital_status						bit,
	marital_status_description	varchar(20), -- 0 for single / 1 for married
	postal_code							varchar(12),
	[address]								varchar(200),
	additional_info						varchar(200),
);

create table Clinic.dimIllnessTypes(
	illnessType_ID					int primary key,
	[name]								varchar(50) not null,
	[description]					varchar(200) null,
	related_department_ID	int not null
);

create table Clinic.dimIllnesses(
	illness_ID					int primary key,
	[name]						varchar(100),
	illnessType_ID			int,
	illnessType_name		varchar(50),
	scientific_name		varchar(100),
	special_illness			bit, --0 for not special / 1 for special illnesses
	killing_status			smallint,
	killing_description	varchar(100),
	chronic						bit,
	chronic_description varchar(100)
);

/***********************************Facts*********************************/
create table Pharmacy.factTransactionalMedicine(
    patient_ID							int,
    insuranceCompany_ID			int,
    medicine_code					int,
    medicine_ID							int,
    medicineFactory_ID				int,
    TimeKey								int,
    number_of_units_bought	int,
    paied_price							int,
	real_price								int,
	insurance_credit					int,
	factory_debit						int,
	income									int,
);

create table Pharmacy.factMonthlyMedicine(
	insuranceCompany_ID				int NOT NULL,
    medicine_code						int NOT NULL,
    medicine_ID								int,
	medicineFactory_ID					int NOT NULL,
    TimeKey									int NOT NULL,
    total_number_bought				int,
    total_paied_price						int,
	total_real_price						int,
	total_insurance_credit				int,
	total_factory_debit					int,
	total_income							int,
    number_of_patients_bought   int
);

create table Pharmacy.factAccumulativeMedicine(
	insuranceCompany_ID				int NOT NULL,
    medicine_code						int NOT NULL,
    medicine_ID								int,
	medicineFactory_ID					int NOT NULL,
    total_number_bought				int,
    total_paied_price						int,
	total_real_price						int,
	total_insurance_credit				int,
	total_factory_debit					int,
	total_income							int,
    number_of_patients_bought   int
);
-------------------------------------------------------------
-------------------------------------------------------------
create table Clinic.factTransactionAppointment (
    patient_ID						int NOT NULL,
    insuranceCompany_ID		int NOT NULL,
    doctor_ID							int NOT NULL,
	department_ID					int NOT NULL,
	main_detected_illness		int NOT NULL,
    TimeKey							int NOT NULL,
    [status]								int not null,
    paied_price						int,
	real_price							int,
	insurance_credit				int,
	doctor_debit					int,
	income								int
);

create table Clinic.factMonthlyAppointment (
	insuranceCompany_ID		int NOT NULL,
    doctor_ID							int NOT NULL,
	department_ID					int NOT NULL,
    TimeKey							int NOT NULL,
	total_paied_price				int,
	total_real_price				int,
	total_insurance_credit		int,
	total_doctor_debit			int,
	total_income					int,
	number_of_patient			int
);

create table Clinic.factAccumulativeAppointment (
    insuranceCompany_ID		int NOT NULL,
    doctor_ID							int NOT NULL,
	department_ID					int NOT NULL,
	total_paied_price				int,
	total_real_price				int,
	total_insurance_credit		int,
	total_doctor_debit			int,
	total_income					int,
	number_of_patient			int
);

create table factlessPatientIlnesses(
	patient_ID				int not null,
	ilness_ID					int not null,
	[detection_date]		date not null,
	degree						int --[1-5]
);

/*-----------------------------------------------
----------------------------------------------
create table Hospital.factSurgeryTransaction(
    doctor_code						int,
    patient_code						int,
    insuranceCompany_code    int,
    start_date								int,
    end_date								int,
    price										int not null,
    [status]									int not null,
    department_code				int
);

create table Hospital.factSurgerySnapshot(
    doctor_code									int,
    department_code							int,
    TimeKey											int,
    total_price										int not null,
    number_of_surgeries						int,
    number_of_successful_surgeries		int,
    number_of_failed_surgeries				int
);

create table Hospital.factSurgeryAccumulative(
    doctor_code									int,
    department_code							int,
    total_price										int not null,
    number_of_surgeries						int,
    number_of_successful_surgeries		int,
    number_of_failed_surgeries				int
);

create table Hospital.factHospitalTransaction(
    doctor_code						int,
    patient_code						int,
    insuranceCompany_code	int,
    department_code				int,
    admit_date							int not null,
    discharg_date						int not null,
    room_number						int null,
    daily_price							int not null,
    total_price							int not null,
    hospitalization_days			int
);

create table Hospital.factHospitalSnapshot(
    doctor_code						int,
    department_code				int,
    TimeKey								int not null,
    total_patients_in_hospital	int,
    patients_discharged			int,
    patients_in_hospital				int,
    total_price							int not null
);

create table Hospital.factHospitalAccumulative(
    doctor_code						int,
    department_code				int,
    total_patients_in_hospital	int,
    patients_discharged			int,
    patients_in_hospital				int,
    total_price							int not null
);*/
-----------------------------------------------
----------------------------------------------
/*create table Hospital.SurgeryStatus(
    status_ID			int primary key,
    [description]	varchar(100)
);*/

create table Clinic.AppointmentStatus(
    status_ID			int primary key,
    [description]	varchar(100)
);

/*insert into Hospital.SurgeryStatus values
    (0,'Not Successful'),
    (1,'Successful');
*/
insert into Clinic.AppointmentStatus values
    (0,'Canceled'),
    (1,'Done');
-----------------------------------------------
----------------------------------------------
create table Logs(
    date					datetime,
    table_name     varchar(50),
    status				tinyint,
    text					varchar(500),
    affected_rows  int,
);