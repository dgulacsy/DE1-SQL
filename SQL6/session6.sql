<<<<<<< HEAD
USE classicmodels;
=======

USE classicmodels;

>>>>>>> 79cb74fc4a1ed792d12bfa4537332af59e2a4185
--  ANALYTICAL DATA STORE

DROP PROCEDURE IF EXISTS CreateProductSalesStore;

DELIMITER //

CREATE PROCEDURE CreateProductSalesStore()
BEGIN

	DROP TABLE IF EXISTS product_sales;

	CREATE TABLE product_sales AS
	SELECT 
	   orders.orderNumber AS SalesId, 
	   orderdetails.priceEach AS Price, 
	   orderdetails.quantityOrdered AS Unit,
	   products.productName AS Product,
	   products.productLine As Brand,   
	   customers.city As City,
	   customers.country As Country,   
	   orders.orderDate AS Date,
	   WEEK(orders.orderDate) as WeekOfYear
	FROM
		orders
	INNER JOIN
		orderdetails USING (orderNumber)
	INNER JOIN
		products USING (productCode)
	INNER JOIN
		customers USING (customerNumber)
	ORDER BY 
		orderNumber, 
		orderLineNumber;

END //
DELIMITER ;


CALL CreateProductSalesStore();

    
-- EVENTS
SHOW VARIABLES LIKE "event_scheduler";

-- on
SET GLOBAL event_scheduler = ON;
-- off
SET GLOBAL event_scheduler = OFF;

TRUNCATE messages;

DELIMITER $$

CREATE EVENT CreateProductSalesStoreEvent
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 1 HOUR
DO
	BEGIN
	INSERT INTO messages SELECT CONCAT('event:',NOW());
    CALL CreateProductSalesStore();
	END$$
DELIMITER ;

SELECT * FROM messages;

SHOW EVENTS;

DROP EVENT IF EXISTS CreateProductSalesStoreEvent;








-- TRIGGER AS ETL

DELIMITER $$

<<<<<<< HEAD
-- empty log table
TRUNCATE messages;

=======
CREATE TRIGGER trigger_namex
    AFTER INSERT ON table_namex FOR EACH ROW
BEGIN
    -- statements
    -- NEW.orderNumber, NEW.productCode etc
END$$    

DELIMITER ;



-- Exercise1: Copy the birdstrikes structure into a new tabe called birdstrikes2. Insert into birdstrikes2 the line where id is 10.
-- Hints:
-- Use the samples from Chapter2 for copy
-- For insert user the format like: INSERT INTO bla SELECT blabla

USE classicmodels;
   
>>>>>>> 79cb74fc4a1ed792d12bfa4537332af59e2a4185
DROP TRIGGER IF EXISTS after_order_insert; 

DELIMITER $$
CREATE TRIGGER after_order_insert
AFTER INSERT ON orderdetails FOR EACH ROW
BEGIN
   	-- log the order number of the newley inserted order
    INSERT INTO messages SELECT CONCAT('new orderNumber: ', NEW.orderNumber);
   
	-- archive the order and assosiated table entries to order_store
  	INSERT INTO product_sales
	SELECT 
	   orders.orderNumber AS SalesId, 
	   orderdetails.priceEach AS Price, 
	   orderdetails.quantityOrdered AS Unit,
	   products.productName AS Product,
	   products.productLine As Brand,
	   customers.city As City,
	   customers.country As Country,   
	   orders.orderDate AS Date,
	   WEEK(orders.orderDate) as WeekOfYear
	FROM orders
	INNER JOIN orderdetails USING (orderNumber)
	INNER JOIN products USING (productCode)
	INNER JOIN customers USING (customerNumber)
	WHERE orderNumber = NEW.orderNumber
	ORDER BY orderNumber, orderLineNumber;
END $$
DELIMITER ;



SELECT * FROM product_sales ORDER BY SalesId;


SELECT COUNT(*) FROM product_sales;

TRUNCATE messages;

INSERT INTO orders  VALUES(16,'2020-10-01','2020-10-01','2020-10-01','Done','',131);
INSERT INTO orderdetails  VALUES(16,'S18_1749','1','10',1);

SELECT * FROM messages;

SELECT * FROM product_sales WHERE product_sales.SalesId = 16;

-- DELETE FROM classicmodels.product_sales WHERE SalesId=16;
-- DELETE FROM classicmodels.orderdetails WHERE orderNumber=16;
-- DELETE FROM classicmodels.orders WHERE orderNumber=16;

<<<<<<< HEAD
-- VIEWS AS DATAMARTS
SELECT DISTINCT productlines.productline from productlines;
=======

-- VIEWS AS DATAMARTS
>>>>>>> 79cb74fc4a1ed792d12bfa4537332af59e2a4185

DROP VIEW IF EXISTS Vintage_Cars;

CREATE VIEW `Vintage_Cars` AS
	SELECT * FROM product_sales WHERE product_sales.Brand = 'Vintage Cars';

SELECT * FROM Vintage_Cars;

DROP VIEW IF EXISTS USA;

CREATE VIEW `USA` AS
	SELECT * FROM product_sales WHERE country = 'USA';
    
SELECT * FROM USA;

<<<<<<< HEAD
SELECT * FROM Vintage_Cars;

DROP VIEW IF EXISTS Sales_03_05;
=======
-- Exercise2: Create a view, which contains product_sales rows of 2003 and 2005. How many row has the resulting view?
>>>>>>> 79cb74fc4a1ed792d12bfa4537332af59e2a4185

CREATE VIEW `Sales_03_05` AS
SELECT * FROM product_sales WHERE EXTRACT(YEAR FROM product_sales.date) IN (2003,2005);
SELECT * FROM Sales_03_05;

SELECT count(*) FROM Sales_03_05;
