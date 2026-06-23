-- Q1 Find the busiest airport by the number of flights take off

Select a.Name, Count(f.FlightID) as Num_of_takeoff
From flights As f
Left Join airports As a
     On f.Origin = a.AirportID
Group By a.AirportID
Order By Num_of_takeoff Desc
Limit 1
;


-- Q2 Total number of tickets sold per airline 

Select  a.Name, count(t.TicketID) as Num_of_ticketsold
From tickets As t
Inner Join flights As f
     On t.FlightID = f.FlightID
Inner Join airlines As a
     On f.AirlineID = a.AirlineID
Group By a.Name
Order By Num_of_ticketsold Desc
     ;

-- Q3 List all flights operated by 'IndiGo' with airport names (origin and destination)

Select 
	a.Name, 	 
	ap1.Name as Origin_Airport,   
	ap2.Name as Destination_Airport
From airlines As a
Inner Join flights As f
	on a.AirlineID = f.AirlineID
Inner Join airports As ap1
    on f.Origin = ap1.AirportID
Inner Join airports As ap2
    on f.destination = ap2.AirportID
Where a.Name = 'IndiGo';

-- Q4 For each airport, show the top airline by number of flights departing from there

With CTE_Origin_num_of_flight As (
Select 
	Origin, 
    AirlineID, 
    count(FlightID) As Num_of_flight,
    Rank()Over(Partition by Origin Order By Count(FlightID) desc) As Ranking
From flights
Group by Origin,AirlineID)

Select ap.Name As Airport_Name, a.Name As Airline_Name, onf.Num_of_flight
from CTE_Origin_num_of_flight as onf
Inner Join airports As ap
   On onf.Origin = ap.AirportID
Inner Join airlines  As a
   On onf.AirlineID = a.AirlineID
where onf.Ranking = 1;


-- Q5 For each flight, show time taken in hours and categorize it as Short (<2hours),Medium (2-5hours), Long (>5h)

 Select 
	FlightID,
	DepartureTime, 
	ArrivalTime,
	round(timestampdiff(minute, DepartureTime, ArrivalTime)/60,1) As Flightduration,
    Case When timestampdiff(minute, DepartureTime, ArrivalTime) < 120 Then 'Short'
         When timestampdiff(minute, DepartureTime, ArrivalTime)Between 120 And 300 Then 'Medium'
         When timestampdiff(minute, DepartureTime, ArrivalTime) >300 Then 'Long' 
    End as FlightDuration_Category      
 From Flights;
 
 -- Q6 Show each passenger's first and last flight dates and number of flights
 
Select 
	p.Name,    
    Min(date(DepartureTime)) As FirstFlight,
    Max(date(DepartureTime)) As LastFlight,
    Count(t.FlightID) As Num_of_flight
From passengers As p
Inner Join tickets As t
	On p.PassengerID=t.PassengerID
Inner Join flights As f
	On t.FlightID=f.FlightID
Group By p.name;

-- Q7 Find flights with the highest price ticket sold for each route (origin -> destination)

With CTE_Priceranking As (
Select
	 ap1.Name As Origin,     
     ap2.Name As Destination,     
     t.Price  As Price,
	 Rank()Over(Partition By f.Origin,f.Destination Order by Price Desc) as Ranking
From flights As f
Inner Join tickets As t
	On f.FlightID = t.FlightID
Inner Join airports As ap1
	On f.Origin = ap1.AirportID
Inner Join airports As ap2
	On f.Destination= ap2.AirportID
    )

Select 
	 Origin,     
     Destination,     
     Price As HighestPrice
From CTE_Priceranking
Where Ranking =1;

-- Q8 Find the highest spending passenger in each Frequent Flyer Status group

With CTE_Spending As (
Select
p.FrequentFlyerStatus,
p.PassengerID,
p.Name,
sum(t.Price) as Totalspending,
Rank()Over(Partition By FrequentFlyerStatus Order By sum(t.Price) desc) as Ranking
From passengers as p
Inner Join tickets as t
	On p.PassengerID=t.PassengerID
Group By p.PassengerID,p.Name,p.FrequentFlyerStatus)

Select 
	FrequentFlyerStatus,
	Name,
	Totalspending
From CTE_Spending
Where Ranking = 1;

-- Q9 Find the total revenue and number of tickets sold for each airline, and rank the airlines based on total revenue

With CTE_airlinerevenue As (
Select 
	a.Name,	
	Count(t.TicketID) As Num_of_ticket,
    Sum(t.Price) As Revenue
From tickets As t
Inner Join flights As f
	on t.FlightID=f.FlightID
Inner Join airlines as a
    on f.AirlineID=a.AirlineID
Group By a.Name)

Select 
*,
Rank()Over(Order By Revenue Desc) as Ranking 
From CTE_airlinerevenue;


-- Q10, For each Passenger, identify their most frequently used airline. If a passenger has multiple airlines  with the same highest usage , show all such airlines 

With CTE_Num_of_ticket As (Select
p.Name As PassengerName,
a.Name As AirlineName,
count(a.Name) as Num_of_ticket,
Rank()over(Partition By p.Name Order By count(a.Name) Desc) as Ranking 
From passengers As p
Inner Join tickets As t
	On p.PassengerID=t.PassengerID
Inner Join flights As f
	On t.FlightID=f.FlightID
Inner Join airlines As a
    On f.AirlineID=a.AirlineID
Group by p.Name,a.Name)

Select 
	PassengerName,
    AirlineName,
    Num_of_ticket
From CTE_Num_of_ticket
Where Ranking =1
Order by PassengerName;

    

