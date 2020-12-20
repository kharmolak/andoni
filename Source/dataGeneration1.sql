---testing a day
insert into MedicineOrderHeaders values
(100001,5285,'2014-10-01',2000);

insert into MedicineOrderDetails values
(1000001,100001,18,3,94);

update  Medicines
set price=2000
where medicine_ID=1;

update Patients
set weight=80
where patient_ID=1;

/*
select max(order_date) from MedicineOrderHeaders
select max(medicineOrderDetails_ID) from MedicineOrderDetails
select * from Medicines
select * from Patients
*/