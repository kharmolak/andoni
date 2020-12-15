/**************************************************************************
DataBase2 Project				: Create Stage Area Tables
Authors							: Sajede Nicknadaf,Maryam Saeidmehr,Nastaran Ashoori
Student Numbers					: 9637453,9629373,9631793
Semester						: fall 1399
version							: 2
***************************************************************************/
--InsuranceCompanies
create table InsuranceCompanies(
insuranceCompany_ID int,
[name] varchar(50)  null,
license_code varchar(15) null,
phone_number varchar(15) null,
[address] varchar(200) null
);
--Insurances
create table Insurances(
insurance_ID int ,
insuranceCompany_ID int null,
code varchar(15) null,
expire_date date null
);
--Patients
create table Patients(
patient_ID int ,
national_code varchar(10) null,
insurance_ID int null,
first_name varchar(20) null,
last_name varchar(50) null,
birthdate date null,
height int null,
[weight] int null,
gender varchar(10) ,
phone_number varchar(15) null,
);
--Departments
create table Departments(
department_ID int ,
[name] varchar(20)  null,
[description] varchar(200) null
);
--Doctors
create table Doctors(
doctor_ID int ,
department_ID int null,
national_code varchar(10) null,
license_code varchar(15) null,
first_name varchar(20) null,
last_name varchar(50) null,
birthdate date null,
phone_number varchar(15) null
);
--Hospitalizations
create table Hospitalizations(
hospitalization_ID int primary key,
patient_ID int null,
doctor_ID int null,
admit_date date null,
discharg_date date null,
room_number int null,
daily_price int null,
total_price int null,
[status] int null
);
--Surgeries
create table Surgeries(
surgery_ID int,
patient_ID int null,
doctor_ID int null,
[start_date] date null,
[end_date] date null,
price int null,
[status] int null
);
--MedicineFactories
create table MedicineFactories(
medicineFactory_ID int ,
[name] varchar(50) null,
license_code varchar(15) null,
phone_number varchar(15) null
);
--Medicines
create table Medicines(
medicine_ID int ,
medicineFactory_ID int null,
[name] varchar(20) null,
latin_name varchar(50) null,
dose float null,
side_effects varchar(100) null,
price int null,
[description] varchar(100) null
);
--MedicineOrderHeaders
create table MedicineOrderHeaders(
medicineOrderHeader_ID int ,
patient_ID int null,
order_date date null,
total_price int null
);
--MedicineOrderDetails
create table MedicineOrderDetails(
medicineOrderDetails_ID int ,
medicineOrderHeader_ID int null,
medicine_ID int null,
[count] int null,
unit_price int null
);
--Appointments
create table Appointments(
appointment_ID int ,
patient_ID int null,
doctor_ID int null,
appointment_number int null,
appointment_date date null,
price int null,
diagnosis varchar(200) null,
[status] int null
);
--PrescriptionMedicines
create table PrescriptionMedicines(
prescriptionMedicines_ID int ,
appointment_ID int null,
medicine_ID int null
);
--Logs
create table Logs(
[date] datetime,
table_name varchar(50),
[status] tinyint,
[text] varchar(500),
affected_rows int
);

/*
******************for create Logs_v2
drop table Logs;
create table Logs(
[date] datetime,
table_name varchar(50),
[status] tinyint,
[text] varchar(500),
affected_rows int
);
*/

/*
********************if you want delete all tables in SA
truncate table PrescriptionMedicines;
truncate table Insurances;
truncate table Patients;
truncate table MedicineFactories;
truncate table Medicines;
truncate table MedicineOrderHeaders;
truncate table MedicineOrderDetails;
truncate table Logs;
*/