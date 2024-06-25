--Q1: Retrieve the total number of employees in the dataset.
select count(emp_name) as Total_no_of_employees from general_data

--Q2: List all unique job roles in the dataset.
select distinct jobrole from general_data

--Q3: Find the average age of employees.
select avg(age) from general_data

--Q4: Retrieve the names and ages of employees who have worked at the company for more than 5 years.
select emp_name,age,TotalWorkingYears
from general_data
where totalworkingyears::int > 5 and totalworkingyears <> 'NA'

--Q5: Get a count of employees grouped by their department.
select department,count(emp_name) as count_of_employees
from general_data
group by department

--Q6: List employees who have 'High' Job Satisfaction.
select g.emp_name,e.jobsatisfaction
from employee_survey_data as e
inner join general_data as g 
on e.employeeid::int = g.employeeid
where e.jobsatisfaction::int = 3 and e.jobsatisfaction <> 'NA'

--Q7: Find the highest Monthly Income in the dataset.
select max(monthlyincome) as Highest_monthly_income
from general_data

--Q8: List employees who have 'Travel_Rarely' as their BusinessTravel type.
select distinct emp_name, businesstravel
from general_data
where businesstravel = 'Travel_Rarely'

--Q9: Retrieve the distinct MaritalStatus categories in the dataset.
select distinct maritalstatus from general_data

--Q10: Get a list of employees with more than 2 years of work experience but less than 4 years in their current role.
select distinct emp_name,totalworkingyears
from general_data
where totalworkingyears::int < 4 and totalworkingyears::int > 2 and totalworkingyears <> 'NA'

--Q11: List employees who have changed their job roles within the company (JobLevel and JobRole differ from their previous job).
select employeeid, emp_name, currentjobrole, previousjobrole, currentjoblevel, previousjoblevel
from (
    select 
        employeeid,
        emp_name,
        jobrole as currentjobrole,
        joblevel as currentjoblevel,
        lag(jobrole) over (partition by employeeid order by yearsatcompany) as previousjobrole,
        lag(joblevel) over (partition by employeeid order by yearsatcompany) as previousjoblevel
    from general_data
) as jobchanges
where currentjobrole <> previousjobrole or currentjoblevel <> previousjoblevel;

--Q12: Find the average distance from home for employees in each department.
select distinct department,avg(distancefromhome)
from general_data
group by department

--Q13: Retrieve the top 5 employees with the highest MonthlyIncome.
select emp_name,monthlyincome
from general_data
order by monthlyincome desc
limit 5;

--Q14: Calculate the percentage of employees who have had a promotion in the last year.
with no_of_employees_got_promoted_last_year as
(
    select count(distinct emp_name) as count_emp
    from general_data
    where yearssincelastpromotion = 1
),
total_count as
(
    select count(distinct emp_name) as t_count from general_data
)
select concat(round(((count_emp * 100.0)/t_count),2),' %') as
percentage_of_employees_who_had_promotion_in_lastyear
from no_of_employees_got_promoted_last_year,total_count

--Q15: List the employees with the highest and lowest EnvironmentSatisfaction.
(
    select g.emp_name,e.EnvironmentSatisfaction
    from general_data as g 
    inner join employee_survey_data as e 
    on g.employeeid = e.employeeid::int
    where e.EnvironmentSatisfaction <> 'NA'
    ORDER BY e.EnvironmentSatisfaction desc
    limit 1
)
union all
(
    select g.emp_name,e.EnvironmentSatisfaction
    from general_data as g 
    inner join employee_survey_data as e 
    on g.employeeid = e.employeeid::int
    where e.EnvironmentSatisfaction <> 'NA'
    ORDER BY e.EnvironmentSatisfaction asc
    limit 1
);

--Q16: Find the employees who have the same JobRole and MaritalStatus.
select distinct e1.emp_name as Employee1,e2.emp_name as Employee2, e1.jobrole, e1.maritalstatus
from general_data e1
join general_data e2
on e1.jobrole = e2.jobrole
and e1.maritalstatus = e2.maritalstatus
and e1.employeeid <> e2.employeeid
order by e1.jobrole,e1.maritalstatus,e1.emp_name,e2.emp_name;

--Q17: List the employees with the highest TotalWorkingYears who also have a PerformanceRating of 4.
select g.emp_name,g.TotalWorkingYears,m.PerformanceRating
from general_data as g 
inner join manager_survey_data as m  
on m.employeeid = g.employeeid
where m.performancerating = 4 and g.totalworkingyears = (select max(totalworkingyears) from general_data where totalworkingyears <> 'NA')
order by g.totalworkingyears desc

--Q18: Calculate the average Age and JobSatisfaction for each BusinessTravel type.
select g.businesstravel,avg(g.age) as Average_Age,avg(e.jobsatisfaction::int) as Average_JobSatisfaction
from general_data as g 
inner join employee_survey_data as e
on g.employeeid = e.employeeid::int
where e.jobsatisfaction <> 'NA'
group by g.businesstravel

--Q19: Retrieve the most common EducationField among employees.
select distinct educationfield,count(*) as No_of_occurences
from general_data
GROUP BY educationfield
order by No_of_occurences desc
limit 1;

--Q20: List the employees who have worked for the company the longest but haven't had a promotion.
select emp_name,yearsatcompany,yearssincelastpromotion
from general_data
where yearssincelastpromotion = 0 and
yearsatcompany = (select max(yearsatcompany) from general_data)