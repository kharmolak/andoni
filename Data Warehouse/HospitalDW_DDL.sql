/**************************************************************************
DataBase2 Project				: Create Data Warehouse Tables
Authors							: Sajede Nicknadaf,Maryam Saeidmehr,Nastaran Ashoori
Student Numbers					: 9637453,9629373,9631793
Semester						: fall 1399
version							: 2
***************************************************************************/
/***********************************Schema********************************/
create schema Hospital;
go
create schema Pharmacy;
go
create schema Clinic;
go
/***********************************Table********************************/
--Patients
create table Patients(
patient_code int IDENTITY(1,1) primary key,
patient_ID varchar(12),
national_code varchar(15) not null,
[name] varchar(30) not null,
family varchar(30) not null,
birthdate date not null,
height int null,
[weight] int null,
gender varchar(15) Check (gender in('Male','Female','Bi_sexual')),
phone_number varchar(25) not null
);
--MedicineFactories
create table Pharmacy.MedicineFactories(
medicineFactory_code int IDENTITY(1,1) primary key,
medicineFactory_ID varchar(12),
[name] varchar(75) not null,
license_code varchar(25) not null,
phone_number varchar(25) null
);
--Medicines
create table Pharmacy.Medicines(
medicine_code int IDENTITY(1,1) primary key,
medicine_ID varchar(12),
[name] varchar(30) not null,
latin_name varchar(75) not null,
dose float not null,
side_effects varchar(200) null,
price int not null,
[description] varchar(200) null,
start_date date,
end_date date,
current_flag int
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
create table Departments(
department_code int IDENTITY(1,1) primary key,
department_ID varchar(12),
[name] varchar(30) not null,
[description] varchar(300) null
);
--Doctors
create table Doctors(
doctor_code int IDENTITY(1,1) primary key,
doctor_ID varchar(12),
national_code varchar(15) not null,
license_code varchar(25) not null,
[name] varchar(30) not null,
family varchar(75) not null,
birthdate date null,
phone_number varchar(25) not null
);
--InsuranceCompanies
create table InsuranceCompanies(
insuranceCompany_code int IDENTITY(1,1) primary key,
insuranceCompany_ID varchar(12),
[name] varchar(75) not null,
license_code varchar(25) not null,
phone_number varchar(25) null,
[address] varchar(300) null
);
-------------------------------------------------
-------------------------------------------------
--MedicineTransactionFact
create table Pharmacy.MedicineTransactionFact(
patient_code int,
patient_ID varchar(12),
insuranceCompany_code int,
insuranceCompany_ID varchar(12),
medicine_code int,
medicine_ID varchar(12),
medicineFactory_code int,
medicineFactory_ID varchar(12),
TimeKey int NOT NULL,
number_of_units_bought int,
cost int
);
--MedicineSnapshotFact
create table Pharmacy.MedicineSnapshotFact(
medicine_code int,
medicine_ID varchar(12),
TimeKey int NOT NULL,
total_number_bought int,
total_cost int,
number_of_patients_bought int,
medicineFactory_code int,
medicineFactory_ID varchar(12)
);
--MedicineAccumulativeFact
create table Pharmacy.MedicineAccumulativeFact(
medicine_code int,
medicine_ID varchar(12),
total_number_bought int,
total_cost int,
number_of_patients_bought int,
medicineFactory_code int,
medicineFactory_ID varchar(12)
);

-------------------------------------------------------------
-------------------------------------------------------------
--AppointmentTransactionFact
create table Clinic.AppointmentTransactionFact (
patient_code int,
patient_ID varchar(12),
insuranceCompany_code int,
insuranceCompany_ID varchar(12),
doctor_code int,
doctor_ID varchar(12),
TimeKey int NOT NULL,
diagnosis varchar(300) null,
[status] int not null,
department_code int,
department_ID varchar(12),
price int not null
)
--AppointmentSnapshotFact
create table Clinic.AppointmentSnapshotFact (
doctor_code int,
doctor_ID varchar(12),
TimeKey int NOT NULL,
department_code int,
department_ID varchar(12),
total_price int not null,
number_of_patient int
)
--AppointmentAccumulativeFact
create table Clinic.AppointmentAccumulativeFact (
doctor_code int,
doctor_ID varchar(12),
department_code int,
department_ID varchar(12),
total_price int not null,
number_of_patient int
)

-----------------------------------------------
----------------------------------------------
--SurgeryTransactionFact
create table Hospital.SurgeryTransactionFact(
doctor_code int,
doctor_ID varchar(12),
patient_code int,
patient_ID varchar(12),
insuranceCompany_code int,
insuranceCompany_ID varchar(12),
start_date int,
end_date int,
price int not null,
[status] int not null,
department_code int,
department_ID varchar(12)
)
--SurgerySnapShotFact
create table Hospital.SurgerySnapshotFact(
doctor_code int,
doctor_ID varchar(12),
department_code int,
department_ID varchar(12),
TimeKey int,
total_price int not null,
number_of_surgeries int,
number_of_successful_surgeries int,
number_of_failed_surgeries int
)
--SurgeryAccumulativeFact
create table Hospital.SurgeryAccumulativeFact(
doctor_code int,
doctor_ID varchar(12),
department_code int,
department_ID varchar(12),
total_price int not null,
number_of_surgeries int,
number_of_successful_surgeries int,
number_of_failed_surgeries int
)
--HospitalTransactionFact
create table Hospital.HospitalTransactionFact(
doctor_code int,
doctor_ID varchar(12),
patient_code int,
patient_ID varchar(12),
insuranceCompany_code int,
insuranceCompany_ID varchar(12),
department_code int,
department_ID varchar(12),
admit_date int not null,
discharg_date int not null,
room_number int null,
daily_price int not null,
total_price int not null,
[status] int not null,
hospitalization_days int
)
--HospitalSnapshotFact
create table Hospital.HospitalSnapshotFact(
doctor_code int,
doctor_ID varchar(12),
department_code int,
department_ID varchar(12),
TimeKey int not null,
total_patients_in_hospital int,
patients_discharged int,
patients_in_hospital int,
total_price int not null
)
--HospitalAccumulativeFact
create table Hospital.HospitalAccumulativeFact(
doctor_code int,
doctor_ID varchar(12),
department_code int,
department_ID varchar(12),
total_patients_in_hospital int,
patients_discharged int,
patients_in_hospital int,
total_price int not null
)
--logtable
create table Logs
(
    date       datetime,
    table_name varchar(50),
    status     tinyint,
    text       varchar(500),
    affected_rows int,
)
