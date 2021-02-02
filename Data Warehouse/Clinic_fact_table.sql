-- create table Clinic.factTransactionAppointment (
--     patient_code								int,-- surrogate key
--     patient_ID									int,--natural key
-- 	insurance_ID								int, 
--     insuranceCompany_ID					int,
--     doctor_code								int, -- surrogate key
-- 	doctor_ID										int, --natural key
-- 	doctorContract_ID						int,
-- 	department_ID								int,
-- 	main_detected_illness					int,
-- 	illnessType_ID								int,
--     TimeKey										int,
-- 	-------------------------------------------
--     paid_price									int,
-- 	real_price										int,
-- 	doctor_share								int,
--  insurance_share                             
-- 	income											int,
-- 	payment_method						bit, -- credit card / cash
-- 	payment_method_description		varchar(60),
-- 	credit_card_number						varchar(26),
-- 	payer											varchar(60),
-- 	payer_phone_number					varchar(25),
-- 	additional_info								varchar(200),
-- )
-- go

--create table Clinic.factDailyAppointment (
--	insuranceCompany_ID		int,
-- doctor_ID							int,
--	doctorContract_ID			int,
--	department_ID					int,
--	main_detected_illness		int,
--	illnessType_ID					int,
-- TimeKey							int,
--	-------------------------------
--	total_paied_price				int,
--	total_real_price				int,
--	total_insurance_credit		int,
--	total_doctor_share			int,
--	total_income					int,
--	number_of_patient			int
--)
--go

--create table Clinic.factMonthlyAppointment (
--	insuranceCompany_ID		int,
-- doctor_ID							int,
--	doctorContract_ID			int,
--	department_ID					int,
-- TimeKey							int,
--	-------------------------------
--	total_paied_price				int,
--	total_real_price				int,
--	total_insurance_credit		int,
--	total_doctor_share			int,
--	total_income					int,
--	number_of_patient			int,
--	max_visit_per_day			int,
--	min_visit_per_day			int,
--	avg_visit_per_day				int,
--)
--go

--create table Clinic.factAccumulativeAppointment (
-- insuranceCompany_ID		int,
-- doctor_ID							int,
--	doctorContract_ID			int,
--	department_ID					int,
--	-------------------------------
--	total_paied_price				int,
--	total_real_price				int,
--	total_insurance_credit		int,
--	total_doctor_share			int,
--	total_income					int,
--	number_of_patient			int,
--	max_visit_per_month		int,
--	min_visit_per_month		int,
--	avg_visit_per_month		int,
--)
--go

--create table factlessPatientIlnesses(
--	patient_ID				int,
--	illness_ID					int,
--	[detection_date]		date,
--	severity					int, --[1-5]
--	additional_info			varchar(200)
--)
--go

--create table Logs(
-- [date]				datetime,
-- table_name     varchar(50),
-- [status]				bit,
-- [description]	varchar(500),
-- affected_rows  int,
--)