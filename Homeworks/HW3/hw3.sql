-- Excercise 1 / SOLUTION: 
SELECT aircraft, airline, speed, IF(speed = 0 OR speed < 100,'LOW SPEED','HIGH SPEED') as speed_category
FROM  birdstrikes
ORDER BY speed_category;

-- Excercise 2 / SOLUTION: 3
SELECT COUNT(distinct(aircraft)) FROM birdstrikes;

-- Excercise 3 / SOLUTION: 9
SELECT speed FROM birdstrikes WHERE aircraft LIKE 'H%' ORDER BY speed ASC LIMIT 1;

-- Excercise 4 / SOLUTION: "Taxi"
SELECT phase_of_flight, COUNT(*) as no_incidents FROM birdstrikes GROUP BY phase_of_flight ORDER BY no_incidents LIMIT 1;

-- Excercise 5 / SOLUTION: 54673
SELECT phase_of_flight, ROUND(AVG(cost)) as avg_cost FROM birdstrikes GROUP BY phase_of_flight ORDER BY avg_cost DESC LIMIT 1;

-- Excercise 6 / SOLUTION: 2862.5000
SELECT AVG(speed) AS avg_speed, state FROM birdstrikes WHERE char_length(state)<5 AND state!='' GROUP BY state ORDER BY avg_speed DESC LIMIT 1;