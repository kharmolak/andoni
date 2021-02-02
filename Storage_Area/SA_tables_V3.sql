/**************************************************************************
DataBase2 Project		: Create Stage Area Tables
Authors						: Sajede Nicknadaf, Maryam Saeedmehr
Student Numbers		: 9637453, 9629373
Semester						: fall 1399
version							: 3
***************************************************************************/
drop database if exists HospitalSA
go

create database HospitalSA
go

use HospitalSA
go

exec sp_changedbowner 'sa'
go

create table InsuranceCompanies(
insuranceCompany_ID int primary key,
[name] varchar(50) ,
license_code varchar(15) ,
manager varchar(50) ,
agent varchar(50) ,
phone_number varchar(15) ,
fax_number varchar(15) ,
website_address varchar(200) ,
manager_phone_number varchar(15) ,
agent_phone_number varchar(15) ,
[address] varchar(200) ,
additional_info varchar(200) ,
active bit ,
active_description varchar(200) 
);

create table Insurances(
insurance_ID int primary key,
insuranceCompany_ID int ,
code varchar(15) ,
insurer varchar(50) ,
insurer_phone_number varchar(15) ,
expire_date date ,
medicine_reduction int ,
appointment1_reduction int , --General doctor
appointment2_reduction int , --Specialist doctor
appointment3_reduction int , --Subspecialty doctor
hospitalization_reduction int ,
surgery_reduction int ,
test_reduction int ,
dentistry_reduction int ,
radiology_reduction int ,
additional_info varchar(200) 
);

create table Departments(
department_ID int primary key,
[name] varchar(20) ,
[description] varchar(200) ,
chairman varchar(50) ,
assistant varchar(50) ,
chairman_phone_number varchar(15) ,
assistant_phone_number varchar(15) ,
chairman_room int ,
assistant_room int ,
reception_phone_number varchar(15) ,
budget int ,
additional_info varchar(200) 
);

create table IllnessTypes(
illnessType_ID int primary key,
[name] varchar(50) ,
[description] varchar(200) ,
related_department_ID int 
);

create table Illnesses(
illness_ID int primary key,
illnessType_ID int ,
[name] varchar(100) ,
scientific_name varchar(100) ,
special_illness bit , --0 for not special / 1 for special illnesses
killing_status smallint ,
killing_description varchar(100) ,
chronic bit ,
chronic_description varchar(100) 
);

create table Patients(
patient_ID int primary key,
national_code varchar(10) ,
insurance_ID int ,
first_name varchar(20) ,
last_name varchar(50) ,
birthdate date ,
height int ,
[weight] int ,
gender varchar(10) ,
phone_number varchar(15) ,
postal_code varchar(12) ,
[address] varchar(200) ,
death_date date ,
death_reason int ,
additional_info varchar(200) 
);

create table Doctors(
doctor_ID int primary key,
doctorContract_ID int ,
department_ID int ,
national_code varchar(10) ,
license_code varchar(15) ,
first_name varchar(20) ,
last_name varchar(50) ,
birthdate date ,
gender varchar(10),
religion varchar(100) ,
nationality varchar(50) ,
marital_status bit ,
marital_status_description varchar(20) , -- 0 for single / 1 for married
phone_number varchar(15) ,
postal_code varchar(12) ,
[address] varchar(200) ,
education_degree int , --[1-3]
specialty_description varchar(100) ,
graduation_date date ,
university varchar(100) ,
additional_info varchar(200) 
);

create table DoctorContracts(
doctorContract_ID int ,
contract_start_date date  ,
contract_end_date date  ,
appointment_portion int  ,
salary int  ,
active bit  ,
additional_info varchar(200) 
);

create table PatientIllnesses(
patient_ID int ,
illness_ID int ,
detection_date date ,
severity int ,--[1-5]
additional_info varchar(200)
);

create table Nurses(
nurse_ID int primary key,
national_code varchar(10) ,
license_code varchar(15) ,
department_ID int ,
first_name varchar(20) ,
last_name varchar(50) ,
birthdate date ,
gender varchar(10),
phone_number varchar(15) ,
postal_code varchar(12) ,
[address] varchar(200) ,
religion varchar(100) ,
nationality varchar(50) ,
marital_status bit ,
marital_status_description varchar(20) , -- 0 for single / 1 for married
education_degree int ,
specialty_description varchar(100) ,
graduation_date date ,
university varchar(100) ,
contract_start_date date ,
contract_end_date date ,
payment_base int ,
additional_info varchar(200) 
);

create table Sections(
section_ID int primary key,
supervisor_ID int ,
head_nurse_ID int ,
department_ID int ,
supervisor_phone_number varchar(15) ,
head_nurse_phone_number varchar(15) ,
supervisor_room int ,
head_nurse_room int ,
total_room int ,
budget int ,
[description] varchar(500),
additional_info varchar(200) 
);

create table Hospitalization(
hospitalization_ID int primary key,
patient_ID int ,
doctor_ID int ,
hospitalization_reason int ,
admit_date date ,
section_ID int ,
room_number int ,
accompanied_by varchar(50) ,
accompany_phone_number varchar(15) ,
dietary_recommendations varchar(MAX) ,
medication_recommendations varchar(MAX) ,
additional_info varchar(200) 
);

create table Hospitalization_checkout(
hospitalization_checkout_ID int primary key,
hospitalization_ID int ,
discharg_date date ,
payment_method bit , -- credit card / cash
payment_method_description varchar(50) ,
credit_card_number varchar(16) , 
payer varchar(50) ,
payer_phone_number varchar(15) ,
checkout_status bit , -- for Installment payment
additional_info varchar(MAX) 
);

create table Surgeries(
surgery_ID int primary key,
patient_ID int ,
main_doctor_ID int ,
anesthesiologist int ,
surgery_nurse int ,
[start_date] datetime ,
duration smallint ,
main_doctor_portion int ,
anesthesiologist_portion int ,
surgery_nurse_portion int ,
base_price int ,
paid int ,
additional_info varchar(200)
);

create table MedicineFactories(
medicineFactory_ID int primary key,
[name] varchar(50) ,
license_code varchar(15) ,
manager varchar(50) ,
agent varchar(50) ,
phone_number varchar(15) ,
fax_number varchar(15) ,
website_address varchar(200) ,
manager_phone_number varchar(15) ,
agent_phone_number varchar(15) ,
[address] varchar(200) ,
additional_info varchar(200) ,
active bit ,
active_description varchar(200) 
);

create table Medicines(
medicine_ID int primary key,
medicineFactory_ID int ,
[name] varchar(20) ,
latin_name varchar(50) ,
dose float ,
side_effects varchar(100) ,
production_date date ,
expire_date date ,
purchase_price int ,
sales_price int ,
stock int ,
[description] varchar(100) ,
medicine_type smallint ,--0:normal(with reduction with insurance) / 1:beauty(without reduction) / 2:special(free)
medicine_type_description varchar(10) ,
additional_info varchar(200) 
);

create table MedicineOrderHeaders(
medicineOrderHeader_ID int primary key,
patient_ID int ,
order_date date ,
total_price int ,
payment_method bit , -- credit card / cash
payment_method_description varchar(50) ,
credit_card_number varchar(16) , 
payer varchar(50) ,
payer_phone_number varchar(15) ,
additional_info varchar(200) 
);

create table MedicineOrderDetails(
medicineOrderDetails_ID int primary key,
medicineOrderHeader_ID int ,
medicine_ID int ,
[count] int ,
unit_price int ,
purchase_unit_price int ,
insurance_portion int 
);

create table Appointments(
appointment_ID int primary key,
patient_ID int ,
doctor_ID int , 
main_detected_illness int ,
appointment_number int ,
appointment_date date ,
price int ,
doctor_share int,
payment_method bit , -- credit card / cash
payment_method_description varchar(50) ,
credit_card_number varchar(16) , 
payer varchar(50) ,
payer_phone_number varchar(15) ,
additional_info varchar(200) 
);

--Logs
create table Logs(
[date] datetime,
table_name varchar(50),
[status] tinyint,
[text] varchar(500),
affected_rows int
);

