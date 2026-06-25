-- Data Cleaning (Patient Table)
-- Remove patient rows where FirstName is missing
-- Standardize FirstName and LastName to proper case and create a new FullName column
-- Gender values should be either Male or Female
-- Split CityStatecountry into city, state, and country columns

Create Table DIM_Patient_Clean(
  PatientID varchar(20) PRIMARY KEY,
  FullName varchar(50),
  Gender varchar(10),
  DOB date,
  City varchar(50),
  State varchar(50),
  Country varchar(50)
);

INSERT INTO Dim_Patient_Clean (PatientID, Fullname, Gender, DOB, City, State, Country
)
Select
	p.PatientID,
    Concat(Upper(Left(Ltrim(Rtrim(p.FirstName)),1)),Substring(Ltrim(Rtrim(p.FirstName)),2,Length(Ltrim(Rtrim(p.FirstName))))
    ," ",
    Upper(Left(Ltrim(Rtrim(p.LastName)),1)), Substring(Ltrim(Rtrim(p.LastName)),2,Length(Ltrim(Rtrim(p.LastName)))))
    As FullName,
    Case 
       When p.Gender='M' Then 'Male'
       When p.Gender ='F' Then 'Female'
       Else p.Gender
	End As Gender,
    p.DOB,
    Substring_index(CityStateCountry,',',1) as City,
    Substring_index(Substring_index(CityStateCountry,',',2),',',-1) as State,
	Substring_index(CityStateCountry,',',-1) as Country  	  
    From Dim_Patient As p
    Where p.FirstName Is Not Null;

-- Data Cleaning (Department Table)
-- Remove Departments Where DepartmentCategory is missing
-- Drop HOD adn DepartmentName Columns
-- Use Specialization as Departmentname column


CREATE TABLE Dim_Department_Clean (
  DepartmentID varchar(20) PRIMARY KEY,
  DepartmentName varchar(100),
  DepartmentCategory varchar(100)
    );

INSERT INTO Dim_Department_Clean (DepartmentID, DepartmentName, DepartmentCategory
)
Select 
	d.DepartmentID,
    d.Specialization As DepartmentName,
    d.DepartmentCategory 
From  Dim_Department As d
Where d.DepartmentCategory Is Not Null;


-- Data Cleaning (Patient Visit Table)
-- Merge all yearly visit table (2020-2025) into one consolidated PatientVisits table

CREATE TABLE PatientVisits (
  VisitID varchar(20) PRIMARY KEY,
  PatientID varchar(20),
  DoctorID varchar(20),
  DepartmentID varchar(20),
  DiagnosisID varchar(20),
  TreatmentID varchar(20),
  PaymentMethodID varchar(20),
  VisitDate date,
  VisitTime time,
  DischargeDate date,
  BillAmount decimal(18,2),
  InsuranceAmount decimal(18,2),
  SatisfactionScore integer,
  WaitTimeMinutes integer,
FOREIGN KEY (PatientID) REFERENCES Dim_Patient_Clean(PatientID),
FOREIGN KEY (DoctorID) REFERENCES Dim_Doctor(DoctorID),
FOREIGN KEY (DepartmentID) REFERENCES Dim_Department_Clean(DepartmentID),
FOREIGN KEY (DiagnosisID) REFERENCES Dim_Diagnosis(DiagnosisID),
FOREIGN KEY (TreatmentID) REFERENCES Dim_Treatment(TreatmentID),
FOREIGN KEY (PaymentMethodID) REFERENCES Dim_PaymentMethod(PaymentMethodID));


INSERT INTO PatientVisits (VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, 
TreatmentID, PaymentMethodID,VisitDate,VisitTime,DischargeDate,BillAmount,InsuranceAmount,
SatisfactionScore,WaitTimeMinutes
)
Select
VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, 
TreatmentID, PaymentMethodID,VisitDate,VisitTime,DischargeDate,BillAmount,InsuranceAmount,
SatisfactionScore,WaitTimeMinutes
From patientvisits_2020_2021
Union All
Select
VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, 
TreatmentID, PaymentMethodID,VisitDate,VisitTime,DischargeDate,BillAmount,InsuranceAmount,
SatisfactionScore,WaitTimeMinutes
From patientvisits_2022_2023
Union All
Select
VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, 
TreatmentID, PaymentMethodID,VisitDate,VisitTime,DischargeDate,BillAmount,InsuranceAmount,
SatisfactionScore,WaitTimeMinutes
From patientvisits_2024
Union All
Select
VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, 
TreatmentID, PaymentMethodID,VisitDate,VisitTime,DischargeDate,BillAmount,InsuranceAmount,
SatisfactionScore,WaitTimeMinutes
From patientvisits_2025;


