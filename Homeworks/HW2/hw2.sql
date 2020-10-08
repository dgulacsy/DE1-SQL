-- Excercise 1 / SOLUTION: Tennessee
SELECT state FROM birdstrikes LIMIT 144,1;

-- Excercise 2 / SOLUTION: 2000-04-18
SELECT flight_date FROM birdstrikes ORDER BY flight_date DESC LIMIT 1;

-- Excercise 3 / SOLUTION: 5345
SELECT DISTINCT cost FROM birdstrikes ORDER BY cost DESC LIMIT 49,1;

-- Excercise 4 / SOLUTION: ''
SELECT state FROM birdstrikes WHERE state IS NOT NULL AND bird_size IS NOT NULL LIMIT 1,1;

-- Excercise 5 / SOLUTION: 7582
SELECT DATEDIFF(NOW(),flight_date) FROM birdstrikes WHERE state="Colorado" AND weekofyear(flight_date)=52;