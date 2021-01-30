/**************************************************************************
DataBase2 Project				: Create Data Warehouse Tables
Authors							: Sajede Nicknadaf,Maryam Saeidmehr
Student Numbers					: 9637453,9629373
Semester						: fall 1399
version							: 3
***************************************************************************/
/***********************************Schema********************************/
/*create schema Hospital;
go*/
create schema Pharmacy;
go
create schema Clinic;
go
/***********************************Table********************************/
--InsuranceCompanies
create table InsuranceCompanies(
    insuranceCompany_ID int primary key,
    [name]              varchar(75) not null,
    license_code        varchar(25) not null,
    phone_number        varchar(25) null,--SCD1
    [address]           varchar(300) null
);

--Insurances
create table Insurances(
	insurance_ID				int primary key,
	insuranceCompany_ID			int not null,
	insuranceCompany_name		varchar(75) not null,
	code						varchar(15) not null,
	expire_date					date null,
	medicine_reduction			int not null,
	appointment1_reduction		int not null,
	appointment2_reduction		int not null,
	appointment3_reduction		int not null,
	hospitalization_reduction	int not null,
	surgery_reduction			int not null,
	test_reduction				int not null,
	dentistry_reduction			int not null,
	radiology_reduction			int not null,
);

--Patients
create table Patients(
    patient_ID      int primary key,
    national_code   varchar(15) not null,
	insurance_ID	int not null,
    [name]          varchar(30) not null,
    family          varchar(30) not null,
    birthdate       date not null,
    height          int null,--SCD1
    [weight]        int null,--SCD1
    gender          varchar(15),
    phone_number    varchar(25) not null,
	death_date		date null,--SCD1
	death_reason	int null,--SCD1
);

--MedicineFactories
create table Pharmacy.MedicineFactories(
    medicineFactory_ID  int primary key,
    [name]              varchar(75) not null,
    license_code        varchar(25) not null,
    phone_number        varchar(25) null
);

--Medicines
create table Pharmacy.Medicines(
    medicine_code   int IDENTITY(1,1) primary key,
    medicine_ID     int,
    [name]          varchar(30) not null,
    latin_name      varchar(75) not null,
    dose            float not null,
    side_effects    varchar(200) null,
    purchase_price	int not null,--SCD2
	sales_price		int not null,--SCD2
	stock			int not null,--SCD3
	medicine_type	int not null, 
    [description]   varchar(200) null,
    start_date      date,
    end_date        date,
    current_flag    int
);

--date
CREATE TABLE Date (
    TimeKey                     int primary key,
    FullDateAlternateKey        varchar(max),
    PersianFullDateAlternateKey varchar(max),
    DayNumberOfWeek             int,
    PersianDayNumberOfWeek      int,
    EnglishDayNameOfWeek        varchar(max),
    PersianDayNameOfWeek        nvarchar(max),
    DayNumberOfMonth            int,
    PersianDayNumberOfMonth     int,
    DayNumberOfYear             int,
    PersianDayNumberOfYear      int,
    WeekNumberOfYear            int,
    PersianWeekNumberOfYear     int,
    EnglishMonthName            varchar(max),
    PersianMonthName            nvarchar(max),
    MonthNumberOfYear           int,
    PersianMonthNumberOfYear    int,
    CalendarQuarter             int,
    PersianCalendarQuarter      int,
    CalendarYear                int,
    PersianCalendarYear         int,
    CalendarSemester            int,
    PersianCalendarSemester     int
);

--Departments
create table Clinic.Departments(
    department_ID   int primary key,
    [name]          varchar(30) not null,
    [description]   varchar(300) null
);

--Doctors
create table Clinic.Doctors(
    doctor_ID				int primary key,
    national_code			varchar(15) not null,
    license_code			varchar(25) not null,
    [name]					varchar(30) not null,
    family					varchar(75) not null,
    birthdate				date null,
    phone_number			varchar(25) not null,
	department_ID			int not null,
	department_name			varchar(30) not null,
	education_degree		int not null, --[1-3]  --SCD2
	specialty_description	varchar(100) null,
	graduation_date			date not null,
	university				varchar(100) null,
	contract_start_date		date not null,
	contract_end_date		date not null,
	appointment_portion		int not null,
	surgery_portion			int not null
);

--IlnessTypes
create table Clinic.IlnessTypes(
	ilnessType_ID			int primary key,
	[name]					varchar(50) not null,
	[description]			varchar(200) null,
	related_department_ID	int not null
);

--Ilnesses
create table Clinic.Ilnesses(
	illness_ID			int primary key,
	[name]				varchar(100) not null,
	ilnessType_ID		int,
	ilnessType_name		varchar(50),
	scientific_name		varchar(100) not null,
	danger				smallint not null --[1,5]
);

-------------------------------------------------
-------------------------------------------------
--MedicineTransactionFact
create table Pharmacy.FactTransactionalMedicine(
    patient_ID				int NOT NULL,
    insuranceCompany_ID		int NOT NULL,
    medicine_code           int NOT NULL,
    medicine_ID             int ,
    medicineFactory_ID		int NOT NULL,
    TimeKey                 int NOT NULL,
    number_of_units_bought  int,
    paied_price             int,
	real_price				int,
	insurance_credit		int,
	factory_debit			int,
	income					int,
);

--MedicineSnapshotFact
create table Pharmacy.FactMonthlyMedicine(
	insuranceCompany_ID			int NOT NULL,
    medicine_code               int NOT NULL,
    medicine_ID                 int,
	medicineFactory_ID			int NOT NULL,
    TimeKey                     int NOT NULL,
    total_number_bought         int,
    total_paied_price            int,
	total_real_price			int,
	total_insurance_credit		int,
	total_factory_debit			int,
	total_income				int,
    number_of_patients_bought   int
);

--MedicineAccumulativeFact
create table Pharmacy.FactAccumulativeMedicine(
	insuranceCompany_ID			int NOT NULL,
    medicine_code               int NOT NULL,
    medicine_ID                 int,
	medicineFactory_ID			int NOT NULL,
    total_number_bought         int,
    total_paied_price            int,
	total_real_price			int,
	total_insurance_credit		int,
	total_factory_debit			int,
	total_income				int,
    number_of_patients_bought   int
);
-------------------------------------------------------------
-------------------------------------------------------------
--AppointmentTransactionFact
create table Clinic.FactTransactionAppointment (
    patient_ID				int NOT NULL,
    insuranceCompany_ID		int NOT NULL,
    doctor_ID				int NOT NULL,
	department_ID			int NOT NULL,
	main_detected_illness	int NOT NULL,
    TimeKey                 int NOT NULL,
    [status]                int not null,
    paied_price				int,
	real_price				int,
	insurance_credit		int,
	doctor_debit			int,
	income					int
);

--AppointmentSnapshotFact
create table Clinic.FactMonthlyAppointment (
	insuranceCompany_ID		int NOT NULL,
    doctor_ID				int NOT NULL,
	department_ID			int NOT NULL,
    TimeKey					int NOT NULL,
	total_paied_price       int,
	total_real_price		int,
	total_insurance_credit	int,
	total_doctor_debit		int,
	total_income			int,
	number_of_patient		int
);

--AppointmentAccumulativeFact
create table Clinic.FactAccumulativeAppointment (
    insuranceCompany_ID		int NOT NULL,
    doctor_ID				int NOT NULL,
	department_ID			int NOT NULL,
	total_paied_price       int,
	total_real_price		int,
	total_insurance_credit	int,
	total_doctor_debit		int,
	total_income			int,
	number_of_patient		int
);

--PatientIlnessesFactless
create table FactlessPatientIlnesses(
	patient_ID				int not null,
	ilness_ID				int not null,
	[detection_date]		date not null,
	degree					int --[1-5]
);

/*-----------------------------------------------
----------------------------------------------
--SurgeryTransactionFact
create table Hospital.SurgeryTransactionFact(
    doctor_code             int,
    patient_code            int,
    insuranceCompany_code   int,
    start_date              int,
    end_date                int,
    price                   int not null,
    [status]                int not null,
    department_code         int
);

--SurgerySnapShotFact
create table Hospital.SurgerySnapshotFact(
    doctor_code                     int,
    department_code                 int,
    TimeKey                         int,
    total_price                     int not null,
    number_of_surgeries             int,
    number_of_successful_surgeries  int,
    number_of_failed_surgeries      int
);

--SurgeryAccumulativeFact
create table Hospital.SurgeryAccumulativeFact(
    doctor_code                     int,
    department_code                 int,
    total_price                     int not null,
    number_of_surgeries             int,
    number_of_successful_surgeries  int,
    number_of_failed_surgeries      int
);

--HospitalTransactionFact
create table Hospital.HospitalTransactionFact(
    doctor_code             int,
    patient_code            int,
    insuranceCompany_code   int,
    department_code         int,
    admit_date              int not null,
    discharg_date           int not null,
    room_number             int null,
    daily_price             int not null,
    total_price             int not null,
    hospitalization_days    int
);

--HospitalSnapshotFact
create table Hospital.HospitalSnapshotFact(
    doctor_code                 int,
    department_code             int,
    TimeKey                     int not null,
    total_patients_in_hospital  int,
    patients_discharged         int,
    patients_in_hospital        int,
    total_price                 int not null
);

--HospitalAccumulativeFact
create table Hospital.HospitalAccumulativeFact(
    doctor_code                 int,
    department_code             int,
    total_patients_in_hospital  int,
    patients_discharged         int,
    patients_in_hospital        int,
    total_price                 int not null
);*/
-----------------------------------------------
----------------------------------------------
/*create table Hospital.SurgeryStatus(
    status_ID       int primary key,
    [description]   varchar(100)
);*/

create table Clinic.AppointmentStatus(
    status_ID       int primary key,
    [description]   varchar(100)
);

/*insert into Hospital.SurgeryStatus values
    (0,'Not Successful'),
    (1,'Successful');
*/
insert into Clinic.AppointmentStatus values
    (0,'Canseled'),
    (1,'Done');
-----------------------------------------------
----------------------------------------------
--logtable
create table Logs(
    date            datetime,
    table_name      varchar(50),
    status          tinyint,
    text            varchar(500),
    affected_rows   int,
);