-- Create a database
create database if not exists hr_project;

-- use database
use hr_project;
  
-- Display all data in hr table
select * from hr;

-- Rename id Column
alter table hr
change column id employee_id varchar(20) null; 

-- check all columns type
describe hr;

-- Lets clean the birthdate column 
select birthdate from hr;

set sql_safe_updates = 0;

-- birthday column cleaning
update hr
set birthdate = case
 when birthdate like "%/%" then date_format(str_to_date(birthdate, "%m/%d/%Y"), "%Y-%m-%d")
 when birthdate like "%-%" then date_format(str_to_date(birthdate, "%m-%d-%Y"), "%Y-%m-%d")
 else null
end;

select birthdate from hr; 

-- change birthdate type to date
alter table hr
modify column birthdate date;


-- hiredate column cleaning
update hr
set hire_date = case
 when hire_date like "%/%" then date_format(str_to_date(hire_date, "%m/%d/%Y"), "%Y-%m-%d")
 when hire_date like "%-%" then date_format(str_to_date(hire_date, "%m-%d-%Y"), "%Y-%m-%d")
 else null
end;

select hire_date from hr;

-- change hire_date type
alter table hr
modify column hire_date date;


-- termdate cleaning
select termdate from hr;
 
update hr
set termdate = date(str_to_date(termdate, "%Y-%m-%d %H:%i:%s UTC"))
where termdate is not null and termdate != '';


alter table hr
modify column termdate date;



-- define the age column
alter table hr 
add column age int;

update hr 
set age = timestampdiff(YEAR, birthdate, curdate());

select age from hr;

select min(age) as youngest, max(age) as oldest from hr;

select count(*) from hr where age < 18;


-- ANALYSIS QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
select gender, count(*) as count
from hr
where age >= 18 and termdate = "0000-00-00"
group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
select race, count(*) as count
from hr
where age >= 18 and termdate = "0000-00-00"
group by race
order by count(*) desc;

-- 3. What is the age distribution of employees in the company?
select min(age) as youngest, max(age) as oldest
from hr
where age >= 18 and termdate = "0000-00-00";

select 
case 
when age >= 18 and age <= 30 then "Young (18-30)"
when age >= 31 and age <= 50 then "Adult (31-50)"
else "Old (51+)"
end as age_group, count(*) as count
from hr
where age >= 18 and termdate = "0000-00-00"
group by age_group
order by age_group;

select 
case 
when age >= 18 and age <= 30 then "Young (18-30)"
when age >= 31 and age <= 50 then "Adult (31-50)"
else "Old (51+)"
end as age_group, gender, count(*) as count
from hr
where age >= 18 and termdate = "0000-00-00"
group by age_group, gender
order by age_group, gender;


-- 4. How many employees work at headquaters versus remote locations
select location, count(*) as count
from hr 
where age >= 18 and termdate = "0000-00-00"
group by location;

-- 5. What is the avarage length of employent for employess who has been terminated
select  avg(datediff(termdate, hire_date))/365 as avg_length_employment
from hr 
where termdate <= curdate() and termdate <> "0000-00-00" and  age >=18;

-- 6. How does the gender distribution vary across departments and job titles?
select department, gender, count(*) as count
from hr 
where age >= 18 and termdate = "0000-00-00"
group by department, gender
order by department;

-- What is the distribution of job titles across the company
select jobtitle, count(*) as count
from hr
where age >= 18 and termdate = "0000-00-00"
group by jobtitle
order by jobtitle desc;

-- 8. Which department has the highest turnover rate
select department, total_count, terminated_count, terminated_count/total_count as termination_rate
from( select department, count(*) as total_count, sum(case when termdate <> "0000-00-00" and termdate <= curdate() then 1 else 0 end) as terminated_count
from hr 
where age >= 18
group by department) as subquery
order by termination_rate desc;


-- 9. What is the distribution of rmployees across locations by city and state?
select location_state, count(*) as count 
from hr
where age >= 18 and termdate = "0000-00-00"
group by location_state
order by count desc;


-- 10. How has the employee count changed over time based on hire and term dates
select year, hires, terminations, hires - terminations as net_change, round((hires - terminations)/hires * 100, 2) as net_charge_percent
from (select year(hire_date) as year, count(*) as hires, sum(case when termdate <> "0000-00-00" and termdate <= curdate() then 1 else 0 end) as terminations
from hr
where age >= 18
group by YEAR(hire_date)
) as subquery
order by year asc;


-- What is the ternure distribution for each department
select department, round(avg(datediff(termdate, hire_date)/365),0) as avg_tenure
from hr 
where termdate <= curdate() and termdate <> "0000-00-00" and age >= 18
group by department;
