-- Loading area codes file

DROP TABLE IF EXISTS area_codes;

CREATE TABLE area_codes
(city VARCHAR(255),
code VARCHAR(55)); -- QUESTION: How to load properly a ("t"/"f") binary variable?
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/area_codes.csv' 
INTO TABLE area_codes
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES 
(city, code);


DROP PROCEDURE IF EXISTS FixUSPhones; 

DELIMITER $$

CREATE PROCEDURE FixUSPhones ()
BEGIN
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE phone varchar(50) DEFAULT "x";
	DECLARE customerNumber INT DEFAULT 0;
	DECLARE country varchar(50) DEFAULT "";
    DECLARE code varchar(50) DEFAULT "y";

	-- declare cursor for customer
	DECLARE curPhone
		CURSOR FOR 
            SELECT customers.customerNumber, customers.phone, customers.country, area_codes.code 
            FROM classicmodels.customers 
            LEFT JOIN area_codes ON area_codes.city=customers.city;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

	OPEN curPhone;
    
	-- create a copy of the customer table 
	DROP TABLE IF EXISTS classicmodels.fixed_customers;
	CREATE TABLE classicmodels.fixed_customers LIKE classicmodels.customers;
	INSERT fixed_customers SELECT * FROM classicmodels.customers;

	TRUNCATE messages;
    
	fixPhone: LOOP
		FETCH curPhone INTO customerNumber,phone, country, code;
		IF finished = 1 THEN 
			LEAVE fixPhone;
		END IF;
		 
		INSERT INTO messages SELECT CONCAT('country is: ', country, ' and phone is: ', phone);
         
		IF country = 'USA'  THEN
			IF phone NOT LIKE '+%' THEN
				IF LENGTH(phone) = 10 THEN
					SET  phone = CONCAT('+1',phone);
					UPDATE classicmodels.fixed_customers 
						SET fixed_customers.phone=phone
							WHERE fixed_customers.customerNumber = customerNumber;
				ELSE 
					SET  phone = CONCAT('+1',code,phone);
					UPDATE classicmodels.fixed_customers 
						SET fixed_customers.phone=phone
							WHERE fixed_customers.customerNumber = customerNumber;
				END IF;    
			END IF;
		END IF;

	END LOOP fixPhone;
	CLOSE curPhone;

END$$
DELIMITER ;

CALL FixUSPhones();

SELECT * FROM fixed_customers WHERE country = 'USA';

SELECT * FROM messages;