CREATE DATABASE flight_db;
USE flight_db;

CREATE TABLE Flights(
	flno INT PRIMARY KEY,
    origin VARCHAR(30) NOT NULL,
    destination VARCHAR(30) NOT NULL,
    distance INT NOT NULL,
    departs TIMESTAMP NOT NULL,
    arrives TIMESTAMP NOT NULL,
    price INT NOT NULL
);
CREATE TABLE Aircraft(
	aid INT PRIMARY KEY,
    aname VARCHAR(30) NOT NULL,
    cruisingrange INT NOT NULL
);
CREATE TABLE Employees(
	eid INT PRIMARY KEY,
    ename VARCHAR(30) NOT NULL,
    salary INT NOT NULL
);
CREATE TABLE Certified(
	eid INT,
    aid INT,
    FOREIGN KEY (aid) REFERENCES Aircraft(aid) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (eid) REFERENCES Employees(eid) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (eid, aid)
);

INSERT INTO Flights VALUES
(101, 'Chandigarh', 'Delhi', 350, '2025-05-01 08:00:00', '2025-05-01 11:30:00', 3000),
(102, 'Delhi', 'Mumbai', 1197, '2025-05-02 09:00:00', '2025-05-02 12:00:00', 20000),
(103, 'Varanasi', 'Pune', 2670, '2025-05-03 10:00:00', '2025-05-03 13:30:00', 25000),
(104, 'Bangalore', 'Hyderabad', 500, '2025-05-04 07:00:00', '2025-05-04 08:30:00', 4000),
(105, 'Kolkata', 'Chennai', 1360, '2025-05-05 06:00:00', '2025-05-05 09:00:00', 6000),
(106, 'Jaipur', 'Ahmedabad', 620, '2025-05-06 14:00:00', '2025-05-06 15:30:00', 3500);

INSERT INTO Aircraft VALUES
(1, 'Boeing 737', 3000),
(2, 'Airbus A320', 2800),
(3, 'Embraer E190', 2400),
(4, 'Bombardier CRJ700', 2200),
(5, 'ATR 72', 1500);

INSERT INTO Employees 
VALUES
(1001, 'Alice', 75000),
(1002, 'Bob', 80000),
(1003, 'John', 72000),
(1004, 'Meena', 78000),
(1005, 'Raj', 69000),
(1006, 'Priya', 82000),
(1007, 'Riya', 78000),
(1008, 'Rakesh', 60000),
(1009, 'Priyanshu', 72000),
(1010, 'Priya', 82000),
(1011, 'Nikita', 78000),
(1012, 'Diya', 60000),
(1013, 'Jai', 92000);

INSERT INTO Certified 
VALUES
(1001, 1),
(1001, 2),
(1002, 1),
(1003, 3),
(1004, 3),
(1004, 4),
(1005, 1),
(1006, 1),
(1007, 1),
(1008, 1),
(1009, 1),
(1006, 3),
(1007, 3),
(1008, 3),
(1009, 3);

-- 1) List in reverse alphabetical order all pilots who are certified to fly some Airbus plane.
SELECT e.ename
FROM Certified AS c
INNER JOIN Aircraft AS a ON c.aid = a.aid
INNER JOIN Employees AS e ON e.eid = c.eid
WHERE a.aname LIKE 'AirBus%'
ORDER BY e.ename DESC;

-- 2) Find the name(s) and salary(salaries) of the pilot(s) who is(are) certified to fly the largest number of planes.
SELECT e.ename, e.salary
FROM Employees AS e
INNER JOIN (
SELECT c.eid
FROM Certified AS c
GROUP BY c.eid
HAVING COUNT(c.aid) = (SELECT MAX(plane_cnt)
                        FROM (SELECT COUNT(cert.aid) AS plane_cnt
							 FROM Certified AS cert
                             GROUP BY cert.eid) AS t1
)) AS t2 ON e.eid = t2.eid;

-- 3) Compute the diff. between the average salary of a pilot and the average salary of all employees (including pilots).
WITH 
	cte1 AS (SELECT AVG(salary) AS avg_sal1 FROM Employees),
    cte2 AS (SELECT DISTINCT eid FROM Certified),
    cte3 AS (SELECT AVG(e.salary) AS avg_sal2 FROM Employees AS e WHERE e.eid IN (SELECT eid FROM cte2))
	SELECT (SELECT avg_sal2 FROM cte3) - (SELECT avg_sal1 FROM cte1) AS avg_sal_diff;

-- 4) For each plane that has at least six pilots, find the name of the plane and the average salary of the pilots who are certified to fly it
WITH 
	cte1 AS (SELECT aid FROM Certified GROUP BY aid HAVING COUNT(eid) >= 6), -- planes having atleast 6 pilots
    cte2 AS (SELECT c.aid, c2.eid FROM cte1 AS c INNER JOIN Certified AS c2 ON c.aid = c2.aid), -- pilots and plane relation
    cte3 AS (SELECT a.aname,c.eid FROM cte2 AS c INNER JOIN Aircraft AS a ON a.aid = c.aid), -- pilots and corr. plane names
    cte4 AS (SELECT c.aname, e.salary FROM cte3 AS c INNER JOIN Employees AS e ON e.eid = c.eid)
    SELECT aname, AVG(salary) AS avg_sal
    FROM cte4
    GROUP BY aname;
    
-- 5) Find the set of origins and destinations that can be reached by two hops but cannot be reached by a direct flight. 
-- (e.g., list "Pittsburgh" "Honolulu" if there's no direct flight between them, but there exists a flight from "Pittsburgh" to some city "X", and 
-- then a flight from "X" to "Honolulu")
SELECT f1.origin, f2.destination
FROM Flights AS f1
INNER JOIN Flights AS f2 ON f1.origin <> f2.destination AND f1.destination = f2.origin
WHERE (f1.origin, f2.destination) NOT IN (SELECT f3.origin, f3.destination FROM Flights AS f3);





























































