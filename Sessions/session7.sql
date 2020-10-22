#Immutability

DROP TABLE IF EXISTS birdstrikes2; 
USE birdstrikes;
CREATE TABLE birdstrikes2 LIKE birdstrikes;
INSERT INTO birdstrikes2
SELECT * FROM birdstrikes
WHERE id=10;

SELECT * FROM birdstrikes2;
DELETE FROM birdstrikes2 WHERE id IS NULL;