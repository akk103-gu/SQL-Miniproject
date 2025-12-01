#1 
select Reporting_Airline as "Airline name", max(DepDelay) as "Max delay"
from al_perf
group by Reporting_Airline
order by "Max delay" desc;

#2
select Reporting_Airline as "Airline name", min(DepDelay) as "Max early departure"
from al_perf
group by Reporting_Airline
order by "Max early departure" desc;

#3 
with flights_day (Day, Flights) as (
select DayOfWeek, count(*)
from al_perf
group by DayOfWeek) 
select flights_day.Day, flights_day.Flights, L_WEEKDAYS.Day, rank() over (order by flights_day.Flights desc) as FlightRank
from flights_day left join L_WEEKDAYS on flights_day.Day = L_WEEKDAYS.Code 
group by flights_day.Day
order by flights_day.Flights asc;

select *
from al_perf;

#4 
with MaxAvgDeptDelay (Name, Code, Delay) as (
select L_AIRPORT_ID.Name, OriginAirportID, avg(DepDelay)
from al_perf left join L_AIRPORT_ID on L_AIRPORT_ID.ID = OriginAirportID
group by L_AIRPORT_ID.Name, OriginAirportID)
select *
from MaxAvgDeptDelay
where Delay = (select max(Delay) from MaxAvgDeptDelay);

#5
With MaxDelays as (
select L_AIRLINE_ID.Name as AirlineName,
L_AIRPORT_ID.Name as AirportName, 
DOT_ID_Reporting_Airline, OriginAirportID, 
avg(DepDelay) as AirportAvgDelay
from al_perf 
left join L_AIRLINE_ID on al_perf.DOT_ID_Reporting_Airline = L_AIRLINE_ID.ID 
left join L_AIRPORT_ID on al_perf.OriginAirportID = L_AIRPORT_ID.ID
group by DOT_ID_Reporting_Airline, OriginAirportID)
select MaxDelays.AirlineName as "Airline Name", 
MaxDelays.AirportName as "Airport Name", 
MaxDelays.AirportAvgDelay as "Delay"
from MaxDelays
where AirportAvgDelay = (
select max(AirportAvgDelay)
    from MaxDelays as MD
    where MD.DOT_ID_Reporting_Airline = MaxDelays.DOT_ID_Reporting_Airline
);

#6a
select count(*)
from al_perf
where Cancelled = 1;

#6b
with CancelCounts as (
select OriginAirportID, CancellationCode, count(CancellationCode) as ReasonCounts
from al_perf
where Cancelled = 1
group by OriginAirportID, CancellationCode)
select L_AIRPORT_ID.Name, L_CANCELATION.Reason, CancelCounts.ReasonCounts as "Number of Occurrences"
from CancelCounts 
left join L_AIRPORT_ID on CancelCounts.OriginAirportID = L_AIRPORT_ID.ID
left join L_CANCELATION on CancelCounts.CancellationCode = L_CANCELATION.Code
where ReasonCounts = (
select max(ReasonCounts)
from CancelCounts as CC
where CancelCounts.OriginAirportID = CC.OriginAirportID);

#7
select FlightDate as "Flight date", avg(count(*)) over (order by FlightDate rows between 3 preceding and 1 preceding) as "Average number of flights over past 3 days" 
from al_perf
group by FlightDate;