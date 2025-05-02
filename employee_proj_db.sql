CREATE DATABASE IF NOT EXISTS employee_proj_db;
USE employee_proj_db;

CREATE TABLE employees(
	e_no INT PRIMARY KEY,
    e_name VARCHAR(20) NOT NULL,
    address VARCHAR(30) NOT NULL,
    basic_salary DECIMAL(7,2) NOT NULL,
    job_status VARCHAR(30) NOT NULL
);
CREATE TABLE projects(
	p_no CHAR(5) PRIMARY KEY,
    p_name VARCHAR(10) NOT NULL,
    nos_of_staff INT NOT NULL
);
CREATE TABLE emp_proj(
	p_no CHAR(5) NOT NULL,
    e_no INT NOT NULL,
    p_job VARCHAR(20) NOT NULL,
    FOREIGN KEY (p_no) REFERENCES projects(p_no),
    FOREIGN KEY (e_no) REFERENCES employees(e_no),
    PRIMARY KEY (p_no, e_no)
);

-- 1)name of those employees whose employee number is odd
SELECT e_name
FROM employees
WHERE e_no & 1 <> 0;

-- 2) name of projects which have not been assigned to any employee
SELECT p_name
FROM projects
WHERE p_no NOT IN (SELECT DISTINCT p_no
					FROM emp_proj);

-- 3) list of employees working in the same city and working on the same project
SELECT e1.e_no, e2.e_no, ep1.p_no, ep2.p_no
FROM employees AS e1
INNER JOIN employees AS e2 ON e1.e_no <> e2.e_no AND e1.address = e2.address
INNER JOIN emp_proj AS ep1 ON e1.e_no = ep1.e_no
INNER JOIN emp_proj AS ep2 ON e2.e_no = ep2.e_no AND ep2.p_no = ep1.p_no;

-- 4) name of employees who are working in more than one project
SELECT e_name
FROM employees AS e
INNER JOIN emp_proj AS ep ON e.e_no = ep.e_no
GROUP BY e.e_no
HAVING COUNT(p_no) > 1;

-- 5) name of project name with atleast 2 employees working, with one 'Coordinator' and one 'Scientist' working
SELECT p_no 
FROM emp_proj AS ep
WHERE p_job IN ('Coordinator', 'Scientist')
GROUP BY p_no
HAVING COUNT(e_no) >= 2;


