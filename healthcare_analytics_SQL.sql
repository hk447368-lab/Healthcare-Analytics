create database if not exists healthcare_analytics_db;
use healthcare_analytics_db;

drop table if exists healthcare_analytics;

CREATE TABLE healthcare_patient_flow (
    patient_id VARCHAR(20),
    patient_admission_date date,
    patient_admission_time time,
    patient_name VARCHAR(100),
    patient_gender VARCHAR(20),
    age_group VARCHAR(20),
    patient_age INT,
    patient_race VARCHAR(50),
    department_referral VARCHAR(100),
    patient_admission_flag VARCHAR(30),
    admission_weekday VARCHAR(20),
    admission_month VARCHAR(20),
    patient_satisfaction_score VARCHAR(20),
    patient_wait_time INT
);
                   ###### Solving Questions ########
select * from healthcare_analytics;
##-- Find total number of patients --##
select count(patient_id) from healthcare_analytics;

##-- Show patient count by gender --##
select count(patient_id) as patient_count, patient_gender
from healthcare_analytics
group by patient_gender;

##-- Find average age of patients --##
select avg(patient_age) from healthcare_analytics;

##-- Find highest patient wait time --##
select max(patient_wait_time) from healthcare_analytics;

##-- Show total patients in each department --##
select * from healthcare_analytics;
select count(patient_id) as total_patient, department_referral
from healthcare_analytics
group by department_referral;

##-- Find average satisfaction score --##
select avg(patient_satisfaction_score) as avg_patient_satisfaction_score from healthcare_analytics;

##-- Count admitted vs non-admitted patients --##
select * from healthcare_analytics;
select count(*) as total_Count, patient_admission_flag from 
healthcare_analytics
group by patient_admission_flag;

##-- Show patient admissions by month --##
select * from healthcare_analytics;
select count(*) as total_admission, admission_month
from healthcare_analytics
group by admission_month
order by admission_month;

##-- Find top 5 departments with highest patients --##
select department_referral, count(*) as total_patient
from healthcare_analytics
group by department_referral
order by total_patient desc
limit 5;

##-- Find average wait time for each department --##
select avg(patient_wait_time) as avg_patient_wait_time, department_referral
from healthcare_analytics
group by department_referral;

##-- Find average satisfaction score by gender --##
select * from healthcare_analytics;
select avg(patient_satisfaction_score) as avg_patient_satisfaction_score, patient_gender
from healthcare_analytics
group by patient_gender;

##-- Create age groups:- Child (<18),- Adult (18–59),- Senior (60+). Then count patients in each group --##
with cte as ( select *, 
case 
	when patient_age <18 then "Child"
    when patient_age between 18 and 59 then "Adult"
    else "senior"
    end as age_groups 
    from healthcare_analytics )
select age_groups, count(*) as total_patient
from cte
group by age_groups;

##-- Find which weekday has highest admissions --##
select * from healthcare_analytics;
select admission_weekday, count(*) as total_admission
from healthcare_analytics
group by admission_weekday
order by total_admission desc;

##-- Find patients whose wait time is greater than overall average wait time --##
select * from healthcare_analytics;
select patient_wait_time, patient_name
from healthcare_analytics
where patient_wait_time > (select avg(patient_wait_time) as avg_patient_wait_time 
							from healthcare_analytics );

##-- Find department having highest average satisfaction score --##
select * from healthcare_analytics;
select department_referral, avg(patient_satisfaction_score) as highest
from healthcare_analytics
group by department_referral
order by highest desc ;         

##-- Find average wait time for each month --##
select admission_month, avg(patient_wait_time) as avg_patient_wait_time
from healthcare_analytics
group by admission_month
order by admission_month asc; 

##-- Use HAVING clause to find departments with more than 500 patients --##
select * from healthcare_analytics;
select count(*) as total_patient, department_referral
from healthcare_analytics
group by department_referral
having  total_patient > 500 ;

##-- Use RANK() to rank departments based on average wait time --##
select * from healthcare_analytics;
with cte as (
select department_referral, avg(patient_wait_time) as avg3
from healthcare_analytics 
group by department_referral )
select *, rank() over (order by avg3 desc) as rnk from cte;

##-- Use DENSE_RANK() to rank departments by satisfaction score --##
select * from healthcare_analytics;
select department_referral, patient_satisfaction_score,
dense_rank() over (partition by department_referral order by patient_satisfaction_score desc) as dnsrnk 
from healthcare_analytics;

##-- Calculate cumulative/running total of admissions by date --##
select * from healthcare_analytics;
select patient_admission_date, count(*) as daily_admission, 
sum(count(*)) over ( order by patient_admission_date ) as running_total 
from healthcare_analytics 
group by patient_admission_date;

##-- Use LAG() to compare today's admissions with previous day admissions --##
select * from healthcare_analytics;
with cte as (
select patient_admission_date, count(*) as daily_admission
from healthcare_analytics
group by patient_admission_date )
select *, lag(daily_admission) over (order by patient_admission_date ) as previous_day_admission from cte;

##-- Use LEAD() to compare current patient's wait time with next patient's wait time --##
select * from healthcare_analytics;
select patient_wait_time,
lead(patient_wait_time) over (order by patient_wait_time) as next_patient_wait_time
from healthcare_analytics
group by patient_wait_time;

with cte as (
select patient_wait_time, count(*) as _wait_time
from healthcare_analytics 
group by patient_wait_time )
select*, lead(_wait_time) over (order by patient_wait_time) as next_patient_wait_time from cte;

##-- Find all patients belonging to department with highest average wait time--##
select * from healthcare_analytics;
select patient_name, department_referral
from healthcare_analytics
where department_referral = ( select department_referral
							   from healthcare_analytics
                               group by department_referral
                               order by avg(patient_wait_time)  desc 
                               limit 1);
                               
##-- Create categories: - Low Wait (<20) - Medium Wait (20–40) - High Wait (>40) Count patients in each category --##                               
with cte as (
select*,
         case
         when patient_wait_time <20 then "low_wait"
         when patient_wait_time between 20 and 40 then "medium_wait"
         else "high_wait"
         end as patient_wait_time_caytegory 
         from healthcare_analytics )
select patient_wait_time_caytegory, count(*) total_patient
from cte 
group by patient_wait_time_caytegory;       

##-- Find top 3 departments with highest admissions each month --##  
select * from healthcare_analytics;
with cte as (
select department_referral, month(patient_admission_date) as months, count(*) as total_admission
from healthcare_analytics 
group by department_referral, months)
select * from
(select *, dense_rank() over (partition by months  order by total_admission desc ) as dnsrnk from cte) as temp
where dnsrnk >3; 

