/**************************************************************************
DataBase2 Project				: Create Stage Area Tables
Authors							: Sajede Nicknadaf,Maryam Saeidmehr
Student Numbers					: 9637453,9629373
Semester						: fall 1399
version							: 2
***************************************************************************/
--InsuranceCompanies
create table InsuranceCompanies(
insuranceCompany_ID int ,
[name] varchar(50) ,
license_code varchar(15) ,
phone_number varchar(15),
[address] varchar(200)
);
--Insurances
create table Insurances(
insurance_ID int ,
insuranceCompany_ID int ,
code varchar(15) ,
expire_date date ,
medicine_reduction int ,
appointment1_reduction int ,
appointment2_reduction int ,
appointment3_reduction int ,
hospitalization_reduction int ,
surgery_reduction int ,
test_reduction int ,
dentistry_reduction int ,
radiology_reduction int 
);
--Departments
create table Departments(
department_ID int,
[name] varchar(20),
[description] varchar(200) 
);
--IlnessTypes
create table IlnessTypes(
ilnessType_ID int ,
[name] varchar(50) ,
[description] varchar(200) ,
related_department_ID int 
);
--Ilnesses
create table Ilnesses(
illness_ID int ,
[name] varchar(100) ,
scientific_name varchar(100) ,
danger smallint  --[1,5]
);
--Patients
create table Patients(
patient_ID int ,
national_code varchar(10) ,
insurance_ID int ,
first_name varchar(20) ,
last_name varchar(50) ,
birthdate date ,
height int ,
[weight] int ,
gender varchar(10) ,
phone_number varchar(15) ,
death_date date ,
death_reason int ,
);
--Doctors
create table Doctors(
doctor_ID int ,
department_ID int ,
national_code varchar(10) ,
license_code varchar(15) ,
first_name varchar(20) ,
last_name varchar(50) ,
birthdate date ,
phone_number varchar(15) ,
education_degree int , --[1-3]
specialty_description varchar(100) ,
graduation_date date ,
university varchar(100) ,
contract_start_date date ,
contract_end_date date ,
appointment_portion int ,
surgery_portion int
);
--PatientIlnesses
create table PatientIlnesses(
patientIlnesse_ID int ,
patient_ID int ,
ilness_ID int ,
[detection_date] date ,
degree int --[1-5]
);
--Hospitalizations
/*create table Hospitalizations(
hospitalization_ID int ,
patient_ID int ,
doctor_ID int ,
admit_date date ,
discharg_date date ,
section_ID int ,
room_number int ,
daily_price int ,
total_price int ,
[status] int ,
foreign key(patient_ID) references Patients(patient_ID),
foreign key(doctor_ID) references Doctors(doctor_ID),
foreign key(section_ID) references Sections(section_ID)
);
--Surgeries
create table Surgeries(
surgery_ID int ,
patient_ID int ,
doctor_ID int ,
[start_date] date ,
[end_date] date ,
price int ,
[status] int ,
foreign key(patient_ID) references Patients(patient_ID),
foreign key(doctor_ID) references Doctors(doctor_ID)
);*/
--MedicineFactories
create table MedicineFactories(
medicineFactory_ID int ,
[name] varchar(50) ,
license_code varchar(15) ,
phone_number varchar(15) 
);
--Medicines
create table Medicines(
medicine_ID int ,
medicineFactory_ID int ,
[name] varchar(20) ,
latin_name varchar(50) ,
dose float ,
side_effects varchar(100) ,
purchase_price int ,
sales_price int ,
stock int ,
[description] varchar(100) ,
medicine_type int --0:normal(with reduction with insurance) 1:beauty(without reduction) 2:special(free)
);
--MedicineOrderHeaders
create table MedicineOrderHeaders(
medicineOrderHeader_ID int ,
patient_ID int ,
order_date date ,
total_price int 
);
--MedicineOrderDetails
create table MedicineOrderDetails(
medicineOrderDetails_ID int ,
medicineOrderHeader_ID int ,
medicine_ID int ,
[count] int ,
unit_price int 
);
--Appointments
create table Appointments(
appointment_ID int ,
patient_ID int ,
doctor_ID int ,
main_detected_illness int,
appointment_number int ,
appointment_date date ,
price int ,
[status] int 
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