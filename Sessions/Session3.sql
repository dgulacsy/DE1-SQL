USE birdstrikes;

SELECT aircraft, airline, cost, 
    CASE 
        WHEN cost  = 0
            THEN 'NO COST'
        WHEN  cost >0 AND cost < 100000
            THEN 'MEDIUM COST'
        ELSE 
            'HIGH COST'
    END
    AS cost_category   
FROM  birdstrikes
ORDER BY cost_category;

-- Excercise 1 / SOLUTION: 
SELECT aircraft, airline, speed, IF(speed = 0 OR speed < 100,'LOW SPEED','HIGH SPEED') as speed_category
FROM  birdstrikes
ORDER BY speed_category;

SELECT COUNT(*) FROM birdstrikes;

SELECT COUNT(reported_date) FROM birdstrikes;

SELECT DISTINCT(state) FROM birdstrikes;

SELECT COUNT(DISTINCT(state)) FROM birdstrikes;

-- Excercise 2 / SOLUTION: 3
SELECT COUNT(distinct(aircraft)) FROM birdstrikes;

SELECT SUM(cost) FROM birdstrikes;

SELECT (AVG(speed)*1.852) as avg_kmh FROM birdstrikes;

SELECT DATEDIFF(MAX(reported_date),MIN(reported_date)) from birdstrikes;

-- Excercise 3 / SOLUTION: 9
SELECT speed FROM birdstrikes WHERE aircraft LIKE 'H%' ORDER BY speed ASC LIMIT 1;

---- Grouping

SELECT MIN(speed), aircraft FROM birdstrikes GROUP BY aircraft;

SELECT state, aircraft, SUM(cost) AS sum FROM birdstrikes WHERE state !='' GROUP BY state, aircraft ORDER BY sum DESC;

-- Excercise 4 / SOLUTION: "Taxi"
SELECT phase_of_flight, COUNT(*) as no_incidents FROM birdstrikes GROUP BY phase_of_flight ORDER BY no_incidents LIMIT 1;

-- Excercise 5 / SOLUTION: 54673
SELECT phase_of_flight, ROUND(AVG(cost)) as avg_cost FROM birdstrikes GROUP BY phase_of_flight ORDER BY avg_cost DESC LIMIT 1;

---- HAVING Use having after aggregation and where before aggregation
SELECT AVG(speed) AS avg_speed,state FROM birdstrikes GROUP BY state WHERE ROUND(avg_speed) = 50; -- WRONG!!
SELECT AVG(speed) AS avg_speed,state FROM birdstrikes GROUP BY state HAVING ROUND(avg_speed) = 50;
SELECT AVG(speed) AS avg_speed,state FROM birdstrikes WHERE state='Vermont' GROUP BY state HAVING ROUND(avg_speed) = 50;

-- Excercise 6 / SOLUTION: 2862.5000
SELECT AVG(speed) AS avg_speed, state FROM birdstrikes GROUP BY state HAVING char_length(state)<5 ORDER BY avg_speed DESC;
SELECT AVG(speed) AS avg_speed, state FROM birdstrikes WHERE char_length(state)<5 AND state!='' GROUP BY state ORDER BY avg_speed DESC LIMIT 1;