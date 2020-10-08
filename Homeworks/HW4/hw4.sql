-- DE1 Homework 4
-- DOMINIK GULACSY

USE classicmodels;

-- INNER join orders,orderdetails,products and customers. 
-- Return back: orderNumber, priceEach, quantityOrdered, productName, productLine, city, country, orderDate

SELECT t2.orderNumber, priceEach, quantityOrdered, productName, productLine, city, country, orderDate
FROM customers t1
INNER JOIN orders t2
	ON t1.customerNumber = t2.customerNumber
INNER JOIN orderdetails t3
	ON t2.orderNumber = t3.orderNumber
INNER JOIN products t4
	ON t3.productCode = t4.productCode
;


