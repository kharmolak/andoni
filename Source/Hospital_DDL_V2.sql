/**************************************************************************
DataBase2 Project		: Create Source Tables
Authors						: Sajede Nicknadaf,Maryam Saeidmehr,Nastaran Ashoori
Student Numbers		: 9637453,9629373,9631793
Semester						: fall 1399
version							: 2
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
foreign key(insuranceCompany_ID) references InsuranceCompanies(insuranceCompany_ID)
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
foreign key(insurance_ID) references Insurances(insurance_ID)
);
--Departments
create table Departments(
department_ID int primary key,
[name] varchar(20) not null,
[description] varchar(200) null
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
foreign key(department_ID) references Departments(department_ID)
);
--Hospitalizations
create table Hospitalizations(
hospitalization_ID int primary key,
patient_ID int not null,
doctor_ID int not null,
admit_date date not null,
discharg_date date not null,
room_number int null,
daily_price int not null,
total_price int not null,
[status] int not null,
foreign key(patient_ID) references Patients(patient_ID),
foreign key(doctor_ID) references Doctors(doctor_ID)
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
price int not null,
[description] varchar(100) null,
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
appointment_number int not null,
appointment_date date not null,
price int not null,
diagnosis varchar(200) null,
[status] int not null,
foreign key(patient_ID) references Patients(patient_ID),
foreign key(doctor_ID) references Doctors(doctor_ID)
);
--PrescriptionMedicines
create table PrescriptionMedicines(
prescriptionMedicines_ID int primary key,
appointment_ID int not null,
medicine_ID int not null,
foreign key (appointment_ID) references Appointments(appointment_ID),
foreign key (medicine_ID) references Medicines(medicine_ID)
);
