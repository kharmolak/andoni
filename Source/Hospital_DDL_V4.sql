/**************************************************************************
DataBase2 Project				: Create Source Tables
Authors							: Sajede Nicknadaf,Maryam Saeidmehr
Student Numbers					: 9637453,9629373
Semester						: fall 1399
version							: 4
***************************************************************************/
--InsuranceCompanies
create table InsuranceCompanies(
insuranceCompany_ID int primary key,
[name] varchar(50) not null,
license_code varchar(15) not null,
phone_number varchar(15) null,
[address] varchar(200) null
);
--Insurances
create table Insurances(
insurance_ID int primary key,
insuranceCompany_ID int not null,
code varchar(15) not null,
expire_date date null,
medicine_reduction int not null,
appointment1_reduction int not null,
appointment2_reduction int not null,
appointment3_reduction int not null,
hospitalization_reduction int not null,
surgery_reduction int not null,
test_reduction int not null,
dentistry_reduction int not null,
radiology_reduction int not null,
foreign key(insuranceCompany_ID) references InsuranceCompanies(insuranceCompany_ID)
);
--Departments
create table Departments(
department_ID int primary key,
[name] varchar(20) not null,
[description] varchar(200) null
);
--IlnessTypes
create table IlnessTypes(
ilnessType_ID int primary key,
[name] varchar(50) not null,
[description] varchar(200) null,
related_department_ID int not null,
foreign key(related_department_ID) references Departments(department_ID)
);
--Ilnesses
create table Ilnesses(
illness_ID int primary key,
[name] varchar(100) not null,
scientific_name varchar(100) not null,
danger smallint not null --[1,5]
);
--Patients
create table Patients(
patient_ID int primary key,
national_code varchar(10) not null,
insurance_ID int not null,
first_name varchar(20) not null,
last_name varchar(50) not null,
birthdate date not null,
height int null,
[weight] int null,
gender varchar(10) Check (gender in('Male','Female','Bi_sexual')),
phone_number varchar(15) not null,
death_date date null,
death_reason int null,
foreign key(insurance_ID) references Insurances(insurance_ID),
foreign key(death_reason) references Ilnesses(illness_ID)
);
--Doctors
create table Doctors(
doctor_ID int primary key,
department_ID int not null,
national_code varchar(10) not null,
license_code varchar(15) not null,
first_name varchar(20) not null,
last_name varchar(50) not null,
birthdate date null,
phone_number varchar(15) not null,
education_degree int not null, --[1-3]
specialty_description varchar(100) null,
graduation_date date not null,
university varchar(100) null,
contract_start_date date not null,
contract_end_date date not null,
appointment_portion int not null,
surgery_portion int not null,
foreign key(department_ID) references Departments(department_ID)
);
--PatientIlnesses
create table PatientIlnesses(
patientIlnesse_ID int primary key,
patient_ID int not null,
ilness_ID int not null,
[detection_date] date not null,
degree int null,--[1-5]
foreign key(ilness_ID) references Ilnesses(illness_ID),
foreign key(patient_ID) references Patients(patient_ID)
);
--Nurses
create table Nurses(
nurse_ID int primary key,
national_code varchar(10) not null,
license_code varchar(15) not null,
first_name varchar(20) not null,
last_name varchar(50) not null,
birthdate date null,
gender varchar(10) Check (gender in('Male','Female','Bi_sexual')),
phone_number varchar(15) not null
);
--Sections
create table Sections(
section_ID int primary key,
supervisor_ID int not null,
[description] varchar(500),
foreign key(supervisor_ID) references Nurses(nurse_ID)
);
--Hospitalizations
create table Hospitalizations(
hospitalization_ID int primary key,
patient_ID int not null,
doctor_ID int not null,
admit_date date not null,
discharg_date date not null,
section_ID int not null,
room_number int null,
daily_price int not null,
total_price int not null,
[status] int not null,
foreign key(patient_ID) references Patients(patient_ID),
foreign key(doctor_ID) references Doctors(doctor_ID),
foreign key(section_ID) references Sections(section_ID)
);
--Surgeries
create table Surgeries(
surgery_ID int primary key,
patient_ID int not null,
doctor_ID int not null,
[start_date] date not null,
[end_date] date not null,
price int not null,
[status] int not null,
foreign key(patient_ID) references Patients(patient_ID),
foreign key(doctor_ID) references Doctors(doctor_ID)
);
--MedicineFactories
create table MedicineFactories(
medicineFactory_ID int primary key,
[name] varchar(50) not null,
license_code varchar(15) not null,
phone_number varchar(15) null
);
--Medicines
create table Medicines(
medicine_ID int primary key,
medicineFactory_ID int not null,
[name] varchar(20) not null,
latin_name varchar(50) not null,
dose float not null,
side_effects varchar(100) null,
purchase_price int not null,
sales_price int not null,
stock int not null,
[description] varchar(100) null,
medicine_type int not null,--0:normal(with reduction with insurance) 1:beauty(without reduction) 2:special(free)
foreign key (medicineFactory_ID) references MedicineFactories(medicineFactory_ID)
);
--MedicineOrderHeaders
create table MedicineOrderHeaders(
medicineOrderHeader_ID int primary key,
patient_ID int not null,
order_date date not null,
total_price int not null,
foreign key (patient_ID) references Patients(patient_ID)
);
--MedicineOrderDetails
create table MedicineOrderDetails(
medicineOrderDetails_ID int primary key,
medicineOrderHeader_ID int not null,
medicine_ID int not null,
[count] int not null,
unit_price int not null,
foreign key (medicineOrderHeader_ID) references MedicineOrderHeaders(medicineOrderHeader_ID),
foreign key (medicine_ID) references Medicines(medicine_ID)
);
--Appointments
create table Appointments(
appointment_ID int primary key,
patient_ID int not null,
doctor_ID int not null,
main_detected_illness int not null,
appointment_number int not null,
appointment_date date not null,
price int not null,
[status] int not null,
foreign key(patient_ID) references Patients(patient_ID),
foreign key(doctor_ID) references Doctors(doctor_ID),
foreign key(main_detected_illness) references Illnesses(illness_ID)
);
--Tests
create table Tests(
test_ID int primary key,
[name] varchar(50) not null,
[description] varchar(200) null,
price int not null,
response_day int null
);
--PatientTests
create table PatientTests(
PatientTest_ID int primary key,
test_ID int not null,
patient_ID int not null,
doctor_ID int null,
[date] date not null,
foreign key(test_ID) references Tests(test_ID),
foreign key(patient_ID) references Patients(patient_ID),
foreign key(doctor_ID) references Doctors(doctor_ID)
);
--NurseShifts
create table NurseShifts(
nurseShift_ID int primary key,
nurse_ID int not null,
section_ID int not null,
[date] date not null,
foreign key(nurse_ID) references Nurses(nurse_ID),
foreign key(section_ID) references Sections(section_ID)
);
--DoctorShifts
create table DoctorShifts(
doctorShift_ID int primary key,
doctor_ID int not null,
section_ID int not null,
[date] date not null,
foreign key(doctor_ID) references Doctors(doctor_ID),
foreign key(section_ID) references Sections(section_ID)
);