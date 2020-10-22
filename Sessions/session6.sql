## Loops

## Determines the sign that determines the block of code to run
DELIMITER //

CREATE PROCEDURE LoopDemo()
BEGIN
	myloop: LOOP
		SELECT *  FROM products;
		LEAVE myloop;
	END LOOP myloop;

END //

DELIMITER ;

CALL LoopDemo();

-- Excercise:

DROP PROCEDURE IF EXISTS LoopDemo;

DELIMITER //

CREATE PROCEDURE LoopDemo()
BEGIN
DECLARE x INT;
	SET x = 0;
	myloop: LOOP 
		SELECT x;
		IF x = 5 THEN
			LEAVE myloop;
		END IF;
		SET x = x + 1;
	END LOOP myloop;

END //

DELIMITER ;

CALL LoopDemo();

-- LOOP

USE classicmodels;

DROP PROCEDURE IF EXISTS LoopDemo;

DELIMITER $$
CREATE PROCEDURE LoopDemo()
BEGIN
      
	myloop: LOOP 
		SELECT * FROM offices;
	END LOOP myloop;
    
END$$
DELIMITER ;

CALL LoopDemo();

-- LEAVE myloop;

DROP PROCEDURE IF EXISTS LoopDemo;

DELIMITER $$
CREATE PROCEDURE LoopDemo()
BEGIN
	DECLARE x  INT;
    
	SET x = 0;
        
	myloop: LOOP 
	           
		SET  x = x + 1;
		SELECT x;
           
		IF  (x = 5) THEN
			LEAVE myloop;
		END  IF;
         
	END LOOP myloop;
END$$
DELIMITER ;

CALL LoopDemo();


-- debug


CREATE TABLE IF NOT EXISTS messages (message varchar(100) NOT NULL);

DROP PROCEDURE IF EXISTS LoopDemo;

DELIMITER $$
CREATE PROCEDURE LoopDemo()
BEGIN
	DECLARE x  INT;
    
	SET x = 0;
     
	TRUNCATE messages;
	myloop: LOOP 
	           
		SET  x = x + 1;
    	INSERT INTO messages SELECT CONCAT('x:',x);
           
		IF  (x = 5) THEN
			LEAVE myloop;
         	END  IF;
         
	END LOOP myloop;
END$$
DELIMITER ;

CALL LoopDemo();

SELECT * FROM messages;

-- CURSOR

DROP PROCEDURE IF EXISTS CursorDemo;

DELIMITER $$
CREATE PROCEDURE CursorDemo()
BEGIN
	
    DECLARE phone varchar(50) DEFAULT "blabla";
    DECLARE finished INTEGER DEFAULT 0;
    
    DECLARE curPhone CURSOR FOR SELECT customers.phone FROM classicmodels.customers;
        
	DECLARE CONTINUE HANDLER  FOR NOT FOUND SET finished = 1;

	OPEN curPhone;
    
	TRUNCATE messages;
	myloop: LOOP 
	           
		FETCH curPhone INTO phone;
        INSERT INTO messages SELECT CONCAT('phone:',phone);
        
		IF finished = 1 THEN LEAVE myloop;
		END IF;
         
	END LOOP myloop;
END$$
DELIMITER ;

SELECT * FROM messages;

CALL CursorDemo();

-- Exercise: Loop through orders table. Fetch orderNumber + shippedDate. Write in both fields into messages as one line.alter
DROP TABLE IF EXISTS messages;

CREATE TABLE IF NOT EXISTS messages (message varchar(100));

DROP PROCEDURE IF EXISTS GetOrderDate;

DELIMITER $$
CREATE PROCEDURE GetOrderDate()
BEGIN
	
    DECLARE orderN INT DEFAULT 0;
    DECLARE shippedDate VARCHAR(55) DEFAULT "BLABLA";
    DECLARE finished INTEGER DEFAULT 0;
    
    DECLARE curOrderN CURSOR FOR SELECT orders.orderNumber FROM classicmodels.orders;
    DECLARE curShippedDate CURSOR FOR SELECT orders.shippedDate FROM classicmodels.orders;
        
	DECLARE CONTINUE HANDLER  FOR NOT FOUND SET finished = 1;

	OPEN curOrderN;
    OPEN curShippedDate;
    
	TRUNCATE messages;
	myloop: LOOP
	           
		FETCH curOrderN INTO orderN;
        FETCH curShippedDate INTO shippedDate;
        INSERT INTO messages SELECT CONCAT('curOrderN:',orderN);
        INSERT INTO messages SELECT CONCAT('curShippedDate:',shippedDate);
        
		IF finished = 1 THEN LEAVE myloop;
		END IF;
         
	END LOOP myloop;
END$$
DELIMITER ;

CALL GetOrderDate();

SELECT * FROM messages;



-- Extra exercise: take a look at the next example with FixUSPhones on Git. Try to solve the Homework. 

CREATE TABLE new_order LIKE orders;

DROP TABLE new_order;

CREATE TABLE new_order AS SELECT * FROM orders;

-- Exercise: Create a stored procedure which creates a table called "product_sales" using the select from HW4.

DROP PROCEDURE IF EXISTS createTable;

DELIMITER $$

CREATE PROCEDURE createTable()
BEGIN

CREATE TABLE product_sales AS 
	SELECT t2.orderNumber, priceEach, quantityOrdered, productName, productLine, city, country, orderDate
		FROM customers t1
		INNER JOIN orders t2
			ON t1.customerNumber = t2.customerNumber
		INNER JOIN orderdetails t3
			ON t2.orderNumber = t3.orderNumber
		INNER JOIN products t4
			ON t3.productCode = t4.productCode
	;

END $$

DELIMITER ;

CALL createTable();

SELECT * FROM product_sales;





-- END EXCERCISE

DROP PROCEDURE IF EXISTS FixUSPhones; 

DELIMITER $$

CREATE PROCEDURE FixUSPhones ()
BEGIN
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE phone varchar(50) DEFAULT "x";
	DECLARE customerNumber INT DEFAULT 0;
    	DECLARE country varchar(50) DEFAULT "";

	-- declare cursor for customer
	DECLARE curPhone
		CURSOR FOR 
            SELECT customers.customerNumber, customers.phone, customers.country FROM classicmodels.customers;

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
		FETCH curPhone INTO customerNumber,phone, country;
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
