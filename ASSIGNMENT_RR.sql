-- crating database: section A --
--  1. Create database company_db.
-- 2. Create tables: departments, employees, projects, employee_project with proper Primary Keys and Foreign Keys.
-- 3. Add NOT NULL, UNIQUE and CHECK constraints wherever applicable.
-- 4. Add an index on employee salary column.--
use assignment;

CREATE TABLE department_sql (
    department_id INT UNIQUE,
    department_name TEXT,
    PRIMARY KEY (department_id)
);
CREATE TABLE employement_project_sql (
  assignment_id INT NOT NULL,
  employee_id INT ,
  project_id INT ,
  hours_worked INT NOT NULL,
  primary key(assignment_id)
  );
  CREATE TABLE Employees_sql (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    department_id INT NOT NULL,
    designation TEXT,
    salary float default 0,
    hire_date Date,
    foreign key(department_id) references department_sql(department_id) on delete cascade
);
CREATE TABLE project_sql (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    department_id INT,
    budget double,
    foreign key(department_id) references department_sql(department_id) on delete cascade
);
create index emp_salary on employees_sql(salary);

-- SECTION B – DML (Data Manipulation)
-- • 5. Insert at least 5 new employees manually.
 insert into employees_sql(employee_id,employee_name ,department_id ,designation,salary,hire_date) value
  (101,"Rohan Rotke",1,"Manager",45000,"2022-05-05"),
 (102,"Sanket Rotke",2,"Executive",50000,"2022-10-05"),
  (103,"Manthan Tighare",3,"Manager",65000,"2021-05-05"),
  (104,"Mahesh Wadibhasame",1,"Analyst",45000,"2021-01-05"),
  (105,"Lakhan Parihar",4,"Engineer",39000,"2023-08-15");
  
-- • 6. Update salary of employees in IT department by 10%.
UPDATE employees_sql 
SET 
    salary = salary + (salary * 0.1)
WHERE
    department_id = (SELECT 
            department_id
        FROM
            department_sql
        WHERE
            department_name = 'IT');
  savepoint RR1;

-- • 7. Delete employees who have salary less than 30000.--
  delete from employees_sql where salary<30000;

  select*from department_sql;
  select *from employees_sql;
  
  --  SECTION C – DQL (Queries)
-- • 8. Display all employees hired after 2022.
select* from employees_sql where year(hire_date)>"2020";

-- • 9. Find average salary department-wise.
SELECT 
    d.department_name, ROUND(AVG(salary), 1)
FROM
    employees_sql AS e
        LEFT JOIN
    department_sql AS d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY AVG(salary) ASC;

-- • 10. Find total hours worked per project.
select p.project_id ,( select sum(hw.hours_worked) from employement_project_sql as hw
where hw.project_id = p.project_id)
as total_hours 
from project_sql as p order by p.project_id asc;

-- • 11. Find highest paid employee in each department.--
SELECT 
    e.department_id, d.department_name, e.employee_name, e.salary
FROM
    employees_sql e
    left join department_sql d
    on e.department_id = d.department_id
WHERE
salary = (SELECT 
            MAX(salary)
        FROM
            employees_sql
        WHERE
            department_id = e.department_id)
order by department_id asc;
		
-- SECTION D – JOINS
-- • 12. Display employee name with department name.
select e.employee_id,employee_name,d.department_name,e.department_id from employees_sql e 
left join department_sql as d 
on e.department_id= d.department_id;

-- • 13. Show project name with total hours worked using JOIN.
select p.project_id,p.project_name ,sum(ep.hours_worked) as total_hours
from project_sql as p 
left join employement_project_sql as ep on p.project_id = ep.project_id 
group by p.project_name,p.project_id
order by p.project_id asc;

-- • 14. List employees who are not assigned to any project.--
select e.* from employees_sql e 
left join employement_project_sql ep on e.employee_id= ep.employee_id
where ep.project_id is null ;

-- • SECTION E – VIEWS
-- • 15. Create a view showing department-wise total salary expense.
create view dept_wise_sal_exp as
 select d.department_name,sum(e.salary) as total_expense from department_sql as d left join employees_sql as e 
 on d.department_id = e.department_id
 group by d.department_name order by d.department_name asc;

select*from dept_wise_sal_exp;

--  • 16. Create a view for employees earning above average salary.
create view emp_earn_avgsalary as
 select* from employees_sql where salary>(select avg(salary) from employees_sql) order by employee_name;
select* from emp_earn_avgsalary;

select*from employees_sql;

-- SECTION F – STORED PROCEDURES & FUNCTIONS
-- • 17. Create a stored procedure to get employees by department_id.
delimiter $$
create procedure get_emp(in id int)
begin select * from employees_sql
where department_id =Id;
end $$
delimiter ; 

call get_emp(1);

-- • 18. Create a stored procedure to increase salary by given percentage.
delimiter $$
create procedure increment_sal(in id int,in increment float)
begin
 update employees_sql set salary =salary+(salary*increment/100)
where employee_id =id;
end $$
delimiter ; 
call increment_sal(9,20);

-- • 19. Create a function to calculate annual salary.
DELIMITER //
CREATE FUNCTION annual_salary(monthly_salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN monthly_salary * 12;
END //
DELIMITER ;

-- SECTION G – WINDOW FUNCTIONS
-- • 20. Rank employees based on salary within each department.
SELECT employee_id, employee_name, department_id, salary,
RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
FROM employees_sql;

-- • 21. Find second highest salary in each department.
SELECT employee_id, employee_name, department_id, salary
FROM (
    SELECT employee_id, employee_name, department_id, salary,
           DENSE_RANK() OVER (
               PARTITION BY department_id
               ORDER BY salary DESC
           ) AS rnk
    FROM employees_sql
) AS ranked_data
WHERE rnk = 2;

-- • 22. Calculate running total of salaries department-wise.
SELECT  employee_id, employee_name, department_id, salary,
       SUM(salary) OVER (
           PARTITION BY department_id
           ORDER BY salary
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total_salary
FROM employees_sql;