CREATE SCHEMA IF NOT EXISTS birdstrikes;
USE birdstrikes;

SHOW TABLES;

DESCRIBE birdstrikes.birdstrikes;

CREATE TABLE new_birdstrikes LIKE birdstrikes;
SELECT * FROM new_birdstrikes;
DROP TABLE IF EXISTS new_birdstrikes; 

CREATE TABLE employee (id INTEGER NOT NULL, employee_name VARCHAR(255) NOT NULL, PRIMARY KEY(id));

DESCRIBE employee;

SELECT * FROM employee;

INSERT INTO employee (id,employee_name) VALUES(1,'Student1');
INSERT INTO employee (id,employee_name) VALUES(2,'Student2');
INSERT INTO employee (id,employee_name) VALUES(3,'Student3');

SELECT * FROM employee;

INSERT INTO employee (id,employee_name) VALUES(3,'Student4');

UPDATE employee SET employee_name='Arnold Schwarzenegger' WHERE id = '1';
UPDATE employee SET employee_name='The Other Arnold' WHERE id = '2';
SELECT * FROM employee;

DELETE FROM employee WHERE id = 3;
SELECT * FROM employee;

TRUNCATE employee;
SELECT * FROM employee;

------------------------------------
-- Privileges
-- Create user
CREATE USER 'laszlosallo'@'%' IDENTIFIED BY 'laszlosallo1';
-- full rights on one table
GRANT ALL ON birdstrikes.employee TO 'laszlosallo'@'%';
-- access only one column
GRANT SELECT (state) ON birdstrikes.birdstrikes TO 'laszlosallo'@'%';

DROP USER 'laszlosallo'@'%';

DESCRIBE birdstrikes;

-- SELECTS
SELECT *, speed/2 FROM birdstrikes;
-- Aliases
SELECT *, speed/2 AS halfspeed FROM birdstrikes;
-- Using limits
SELECT * FROM birdstrikes LIMIT 10;
SELECT * FROM birdstrikes LIMIT 10,1;

-- Excercise1
SELECT state FROM birdstrikes limit 144,1;

-- Ordering
SELECT state, cost FROM birdstrikes ORDER BY cost;
SELECT state, cost FROM birdstrikes ORDER BY state, cost ASC;
SELECT state, cost FROM birdstrikes ORDER BY cost DESC;

SELECT flight_date FROM birdstrikes ORDER BY flight_date DESC LIMIT 1;

-- unique values
SELECT DISTINCT damage FROM birdstrikes;
SELECT DISTINCT state FROM birdstrikes;

SELECT DISTINCT cost FROM birdstrikes ORDER BY cost DESC LIMIT 49,1;

-- Filtering
SELECT * FROM birdstrikes WHERE state = 'Alabama';

SELECT DISTINCT state FROM birdstrikes WHERE state LIKE 'A%';

SELECT DISTINCT state FROM birdstrikes WHERE state LIKE 'a%';

SELECT DISTINCT state FROM birdstrikes WHERE state LIKE 'ala%';

SELECT DISTINCT state FROM birdstrikes WHERE state LIKE 'North _a%';

SELECT DISTINCT state FROM birdstrikes WHERE state NOT LIKE 'a%' ORDER BY state;

SELECT * FROM birdstrikes WHERE state = 'Alabama' AND bird_size = 'Small';

SELECT * FROM birdstrikes WHERE state = 'Alabama' OR state = 'Missouri';

SELECT DISTINCT(state) FROM birdstrikes WHERE state IS NOT NULL AND state != '' ORDER BY state;

SELECT * FROM birdstrikes WHERE state IN ('Alabama', 'Missouri','New York','Alaska');

SELECT DISTINCT(state) FROM birdstrikes WHERE LENGTH(state) = 5;

SELECT * FROM birdstrikes WHERE speed = 350;

SELECT * FROM birdstrikes WHERE speed >= 10000;

SELECT ROUND(SQRT(speed/2) * 10) AS synthetic_speed FROM birdstrikes;

SELECT * FROM birdstrikes where cost BETWEEN 20 AND 40;

SELECT state  FROM birdstrikes WHERE state IS NOT NULL AND bird_size IS NOT NULL LIMIT 1,1;

SELECT * FROM birdstrikes WHERE flight_date = "2000-01-02";
-- Excercise 5
SELECT DATEDIFF(NOW(),flight_date) FROM birdstrikes WHERE state="Colorado" AND weekofyear(flight_date)=52;
