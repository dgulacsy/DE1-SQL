CREATE SCHEMA firstdb;
DROP SCHEMA IF EXISTS firstdb;
CREATE SCHEMA birdstrikes;
USE birdstrikes;

CREATE TABLE birdstrikes 
(id INTEGER NOT NULL,
aircraft VARCHAR(32),
flight_date DATE NOT NULL,
damage VARCHAR(16) NOT NULL,
airline VARCHAR(255) NOT NULL,
state VARCHAR(255),
phase_of_flight VARCHAR(32),
reported_date DATE,
bird_size VARCHAR(16),
cost INTEGER NOT NULL,
speed INTEGER,PRIMARY KEY(id));

SHOW VARIABLES LIKE "secure_file_priv";

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/birdstrikes_small.csv' 
INTO TABLE birdstrikes 
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(id, aircraft, flight_date, damage, airline, @v_state, phase_of_flight, @v_reported_date, bird_size, cost, @v_speed)
SET
state = nullif(@v_state, ''),
reported_date = nullif(@v_reported_date, ''),
speed = nullif(@v_speed, '');