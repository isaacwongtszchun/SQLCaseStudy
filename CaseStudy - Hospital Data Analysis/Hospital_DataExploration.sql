-- Q1. For each doctor, count how many distinct patients they have treated.

Select 
dd.DoctorID as DoctorID,
Concat(dd.FirstName," ",dd.LastName) as DoctorName,
count(distinct pv.PatientID) as Num_of_patient
From dim_doctor As dd
Inner Join patientvisits As pv
	On dd.DoctorID = pv.DoctorID
Group By DoctorID,DoctorName
Order by  Num_of_patient Desc;

-- Q2. Show the revenue split by each payment method, along with total visits
 
Select
pm.Paymentmethod,
sum(pv.BillAmount) as Revenue ,
count(pv.VisitID) as TotalVisit
From dim_paymentmethod As pm
Inner Join patientvisits As pv
	On pm.PaymentMethodID=pv.PaymentMethodID
Group By pm.Paymentmethod;

-- Q3. Categories patients into age groups ('0-17','18-35','36-55','56+'), calculate the total number of visits and the average bill amount for each age groups. (Assume age at time of visit based on VisitDate)

With CTE_PatientAgeGroup As(
Select
    p.patientID,
	pv.visitID,
    p.DOB,
    pv.VisitDate,
    Timestampdiff(Year,p.DOB, pv.VisitDate),
	Case When Timestampdiff(Year,p.DOB, pv.VisitDate) <18 Then '0-17'
	     When Timestampdiff(Year,p.DOB, pv.VisitDate) Between 18 and 35 Then '18-35'
         When Timestampdiff(Year,p.DOB, pv.VisitDate) Between 36 and 55 Then '36-55'
     Else '56+'
	End As AgeGroup,
    pv.BillAmount
From dim_patient_clean As p
Inner Join patientvisits As pv
	On p.PatientID=pv.PatientID)

Select
	AgeGroup,
    Count(visitID) as Num_of_visit,
    Round(Avg(BillAmount),2)
From CTE_PatientAgeGroup 
Group By AgeGroup;
    

-- Q4. Find total revenue and number of visits for each department.

Select
	dd.DepartmentName,
	Sum(pv.BillAmount) As total_revenue,
	Count(pv.VisitID)  As Num_of_visits
From patientvisits as pv
Inner Join dim_department_clean As dd
	On pv.DepartmentID = dd.DepartmentID
Group by dd.DepartmentName;

-- Q5 Rank departments based on their total revenue within each department category

Select
    dd.DepartmentCategory,
	dd.DepartmentName,
	Sum(pv.BillAmount) As total_revenue,
	Rank()Over(Partition By dd.DepartmentCategory Order By Sum(pv.BillAmount) Desc) As Rankning 
From patientvisits as pv
Inner Join dim_department_clean As dd
	On pv.DepartmentID = dd.DepartmentID
Group by dd.DepartmentCategory,dd.DepartmentName
Order By dd.DepartmentCategory;

-- Q6 For each department, find the average satisfaction score and average wait time

Select
	dd.DepartmentName,
	Round(Avg(pv.SatisfactionScore),2) As Avg_satisfaction_score,
    Round(Avg(pv.WaitTimeMinutes),0) As Avg_WaitTimeMinutes
From patientvisits as pv
 Join dim_department_clean As dd
	On pv.DepartmentID = dd.DepartmentID
Group by dd.DepartmentName
Order by dd.DepartmentName;

-- Q7 Compare the total number of hospitals visits on weekdays vs weekends

With CTE_DayCategory As (
Select
	*,
	Case When Weekday(VisitDate) <= 4 Then 'Weekday'
		 When Weekday(VisitDate) >4 Then 'Weekend'
	End As DayCategory
From patientvisits)


Select 
	DayCategory,
	Count(VisitID) As Total_Num_of_Visit
From CTE_DayCategory
Group by DayCategory;

-- Q8 For each month, calculate total visits and a running cumulative total of visits.

Select
	Year(VisitDate) As Year,
    Month(VisitDate) As Month,
    Count(VisitID) As Total_Num_of_Visit,
    Sum(Count(VisitID))Over(Order By Year(VisitDate),Month(VisitDate)) As Cum_Num_of_Visit
From patientvisits
Group by Year(VisitDate),Month(VisitDate);

-- Q9 Find the doctors with the highest average satisfaction score (minimum 100 visits)

Select
    d.DoctorID,
	Concat(d.FirstName," ",d.LastName) As DoctorName,
	Round(Avg(pv.SatisfactionScore),2) As Avg_satisfaction_score,
    Count(pv.visitID) As Num_of_Visit
From patientvisits As pv
Inner Join dim_doctor As d
	On pv.DoctorID=d.DoctorID
Group by d.DoctorID,Concat(d.FirstName," ",d.LastName)
Having Count(pv.visitID)>=100;

-- Q10 Identify the most commonly prescribed treatment for each diagnosis

With CTE_treatment As (Select
	d.DiagnosisName,
    t.TreatmentName,
    Count(t.TreatmentID) as Treatment_Count,
    Rank()Over(Partition By d.DiagnosisName Order By Count(t.TreatmentID) Desc) As Ranking
From patientvisits As pv
Inner Join dim_diagnosis As d
	On pv.DiagnosisID=d.DiagnosisID
Inner Join dim_treatment As t
	On t.TreatmentID=pv.TreatmentID
Group By d.DiagnosisName,t.TreatmentName)

Select DiagnosisName,TreatmentName,Treatment_Count
From CTE_treatment
Where Ranking=1
    