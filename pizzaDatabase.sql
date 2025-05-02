CREATE DATABASE IF NOT EXISTS pizza_db;
USE pizza_db;

CREATE TABLE Person(
	name VARCHAR(20) PRIMARY KEY,
    age INT NOT NULL,
    gender CHAR(1) NOT NULL
);
CREATE TABLE Serves(
	pizzeria VARCHAR(20),
    pizza VARCHAR(20),
    price INT,
    PRIMARY KEY (pizzeria, pizza)
);
CREATE TABLE Eats(
	name VARCHAR(20) NOT NULL,
    pizza VARCHAR(20) NOT NULL,
    FOREIGN KEY (name) REFERENCES Person(name) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (pizza) REFERENCES Serves(pizza) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (name, pizza)
);

CREATE TABLE Frequents(
	name VARCHAR(20) NOT NULL,
    pizzeria VARCHAR(20) NOT NULL,
	FOREIGN KEY (name) REFERENCES Person(name) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (pizzeria) REFERENCES Serves(pizzeria) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (name, pizzeria)
);

INSERT INTO Person 
(name, age, gender) 
VALUES
('Alice', 25, 'F'),
('Bob', 30, 'M'),
('Charlie', 22, 'M'),
('Diana', 28, 'F');

INSERT INTO Serves 
(pizzeria, pizza, price) 
VALUES
('MarioPizza', 'Margherita', 10),
('MarioPizza', 'Pepperoni', 12),
('LuigiSlices', 'Margherita', 9),
('LuigiSlices', 'Veggie', 11),
('TonyPizza', 'Pepperoni', 13),
('TonyPizza', 'BBQ Chicken', 14);

INSERT INTO Frequents 
(name, pizzeria) 
VALUES
('Alice', 'MarioPizza'),
('Bob', 'TonyPizza'),
('Charlie', 'LuigiSlices'),
('Diana', 'MarioPizza'),
('Diana', 'TonyPizza');

INSERT INTO Eats 
(name, pizza) 
VALUES
('Alice', 'Margherita'),
('Alice', 'Pepperoni'),
('Bob', 'BBQ Chicken'),
('Charlie', 'Veggie'),
('Diana', 'Pepperoni');

-- 1) Find all pizzerias frequented by at least one person under the age of 18.
SELECT DISTINCT pizzeria 
FROM Frequents AS f
INNER JOIN Person AS p
ON f.name = p.name
WHERE p.age<18;
    
-- 2) Find the names of all females who eat either mushroom or pepperoni pizza (or both).
SELECT p.name
FROM Eats AS e
INNER JOIN Person AS p
ON e.name=p.name
WHERE p.gender='F' AND pizza IN ('Mushroom', 'Pepperoni');

-- 3) Find the names of all people who frequent a pizzeria serving at least one pizza they eat.
SELECT DISTINCT f.name
FROM Frequents AS f
INNER JOIN Serves AS s ON f.pizzeria = s.pizzeria
INNER JOIN Eats AS e ON f.name = e.name AND s.pizza = e.pizza;

-- 4)  Find the names of all people who frequent every pizzeria serving at least one pizza they eat.
SELECT f.name 
FROM Frequents AS f
WHERE f.name NOT IN (
	SELECT e.name
	FROM Eats AS e
	INNER JOIN Serves AS s ON e.pizza = s.pizza
	WHERE pizzeria NOT IN (SELECT f.pizzeria FROM Frequents AS f WHERE e.name = f.name)
);

-- 5) Find the pizzeria serving the cheapest pepperoni pizza. In the case of ties, return all of the cheapest pepperoni pizzerias.
WITH 
	cte1 AS (SELECT pizzeria, price
			 FROM Serves 
             WHERE pizza = 'Pepperoni'),
    cte2 AS (SELECT MIN(price) AS min_price
			 FROM (SELECT price FROM cte1) AS t1
             )
	SELECT pizzeria
    FROM cte1
    WHERE price = (SELECT min_price FROM cte2);
    
-- 6) For each person, find all pizzas the person eats that are not served by any pizzeria the person frequents. 
-- Return all such person (name) / pizza pairs.
SELECT e.name, e.pizza
FROM Eats AS e
WHERE e.pizza NOT IN (
	SELECT s.pizza 
	FROM Frequents AS f
	INNER JOIN Serves AS s ON s.pizzeria = f.pizzeria
    WHERE f.name = e.name);






