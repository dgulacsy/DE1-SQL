USE classicmodels;

-- INNER
SELECT * 
FROM products 
INNER JOIN productlines  
ON products.productline = productlines.productline;

-- aliasing
SELECT t1.productLine, t2.textDescription
FROM products t1
INNER JOIN productlines t2 
ON t1.productline = t2.productline;

-- using
SELECT t1.productLine, t2.textDescription
FROM products t1
INNER JOIN productlines t2 
USING(productline);

-- Exercise 1 / SOLUTION: 
SELECT *
FROM orders
INNER JOIN orderdetails
ON orders.orderNumber = orderdetails.orderNumber;

-- Exercise 2 / SOLUTION: 
SELECT 
	t1.orderNumber,
	status,
	sum(quantityOrdered*priceEach) as totalsales
FROM orders t1
INNER JOIN orderdetails t2
	ON t1.orderNumber = t2.orderNumber
ORDER BY orderNumber;

-- Exercise3: We want to how the employees are performing. Join orders, customers and employees and return orderDate,lastName, firstName
-- Exercise 3 / SOLUTION:
SELECT orderDate, lastName, firstName 
FROM customers t1
INNER JOIN orders t2
	ON t1.customerNumber = t2.customerNumber
INNER JOIN orderdetails t3
	ON t2.orderNumber = t3.orderNumber
INNER JOIN employees t4
	on t4.employeeNumber = t1.salesRepEmployeeNumber;
    
SELECT orderDate, lastName, firstName
FROM orders t1
INNER JOIN customers t2
	ON t1.customerNumber = t2.customerNumber
INNER JOIN employees t3
	ON t2.salesRepEmployeeNumber = t3.employeeNumber;

-- SELF

-- Employee table represents a hierarchy, which can be flattened with a self join. The next query displays the Manager, Direct report pairs:
    
SELECT 
    CONCAT(m.lastName, ', ', m.firstName) AS Manager,
    CONCAT(e.lastName, ', ', e.firstName) AS 'Direct report'
FROM
    employees e
INNER JOIN employees m ON 
    m.employeeNumber = e.reportsTo
ORDER BY 
    Manager;
    
-- Exercise4: Why President is not in the list?

SELECT 
    CONCAT(m.lastName, ', ', m.firstName) AS Manager,
    CONCAT(e.lastName, ', ', e.firstName) AS 'Direct report'
FROM
    employees e
LEFT JOIN employees m ON 
    m.employeeNumber = e.reportsTo
ORDER BY 
    Manager;

-- LEFT

-- returns customer info and related orders:
SELECT
    c.customerNumber,
    customerName,
    orderNumber,
    status
FROM
    customers c
LEFT JOIN orders o 
    ON c.customerNumber = o.customerNumber;
    
-- compare with INNER join. See count on INNER and LEFT JOIN:    
SELECT
  COUNT(*)
FROM
    customers c
INNER JOIN orders o 
    ON c.customerNumber = o.customerNumber;    
    
-- WHERE 
    
SELECT 
    o.orderNumber, 
    customerNumber, 
    productCode
FROM
    orders o
LEFT JOIN orderDetails 
    USING (orderNumber)
WHERE
    orderNumber = 10123;
    
-- ON

-- different meaning, join will be applied only for orderNumber 10123
SELECT 
    o.orderNumber, 
    customerNumber, 
    productCode
FROM
    orders o
LEFT JOIN orderDetails d 
    ON o.orderNumber = d.orderNumber AND 
       o.orderNumber = 10123;


