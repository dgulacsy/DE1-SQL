###############################################################
-- DE1 TERM PROJECT
-- AUTHOR: DOMINIK GULACSY - BUSINESS ANALYTICS 2020/21

# DATA
-- Brazilian E-Commerce Public Dataset by Olist
-- Source: Olist and André Sionek, “Brazilian E-Commerce Public Dataset by Olist.” Kaggle, 2018, doi: 10.34740/KAGGLE/DSV/195341.
-- URL: https://www.kaggle.com/olistbr/brazilian-ecommerce
-- License: CC BY-NC-SA 4.0
###############################################################

# Evaluation Criteria:
-- X1 Fitness of the input dataset to the purpose 5 points
-- X2 Complexity of the input data set 5 points
-- X3 Execution of the operational data layer 10 points
-- X4 Analytics plan 10 points
-- X5 Execution of the analytical data layer 10 points
-- X6 ETL 15 points
-- X7 Data Marts 10 points
-- X8 Delivery: Naming, structure 10 points
-- X9 Delivery: Documentation 10 points
-- X10 Reproducibility 15 points

        
### Analytics plan 
## Questions:
# 1. Which were the top 5 product categories based on sales in September 2017?
# 2. What percentage of sales were made in Sao Paulo and Rio de Janeiro compared to total sales?
# 3. On which day of the week sales were the highest in the Furniture product category?
# 4. What percentage of orders were delivered to the customer before the estimated time of delivery?
# 5. What was the average delivery time for orders with below-average and above-average review score?
# 6. Which 5 sellers had the highest average consumer satisfaction based on review scores in the Health and Beauty product category?

# To answer my questions, my analytical data layer and ETL should look the following:
# Analytical data layer needs to contain "order-items-of-orders"-level data and should include the following columns:
	# DISCLAIMER: I have also included such columns that were not necessary for answering the mentioned analytics questions, but may be useful for further, more complex analysis. 
    #(e.g.: Freight value and product size & weight comparison, analysis of logistics processes, Sales and provided info on product, Review Text Analysis) 
    -- (Auxiliary) order_id 
    -- (Auxiliary) order_uuid 
    -- (Fact) price 
    -- (Seller) seller_id 
    -- (Seller) seller_city 
    -- (Seller) seller_state 
    -- (Product) product_category_name_english 
    -- (Product) product_volume = product_length*product_height*product_width
    -- (Product) product_weight_g
    -- (Product) product_photos_qty 
    -- (Location) customer_city 
    -- (Location)customer_state 
    -- (Date) order_purchase_timestamp
    -- (Logistics) freight_value
    -- (Logistics) shipping_limit_date 
    -- (Logistics) order_approved_at 
    -- (Logistics) order_delivered_carrier_date
    -- (Logistics) order_delivered_customer_date 
    -- (Logistics) order_estimated_delivery_date
    -- (Logistics) order_delivery_time_min = order_delivered_customer_date - order_purchase_timestamp) 
    -- (Customer Satisfaction) review_score
    -- (Customer Satisfaction) is_satisfied <- "0" : [review_score < avg(review_score)] , "1" : [review_score < avg(review_score)]
    -- (Customer Satisfaction) review_comment_title
    -- (Customer Satisfaction) review_comment_message
    -- (Customer Satisfaction) review_creation_date
    -- (Customer Satisfaction) review_answer_timestamp
    
    # I based the structure of the Analytical Data Layer on the Star Schema having: 
    -- Sales data as Fact
    -- Seller data as my 1st dimension
    -- Product data as my 2nd dimension
    -- Location data as my 3rd dimension
    -- Date data as my 4th dimension
    -- Logistics data as my 5th dimension
    -- Customer Satisfaction data as my 6th dimension
    
###############################################################

###
# PART 1 - LOAD DATASET TO CREATE A RELATIONAL DATABASE
###

## Initailization of the relational database
DELIMITER ;
DROP SCHEMA IF EXISTS ecom_db;
CREATE SCHEMA ecom_db;
USE ecom_db;
DROP TABLE IF EXISTS customers, order_items, order_payments, order_reviews, orders, products, sellers, prod_cat_trans, order_items_messy, order_payments_messy;

## Create tables and import data from csv files

###############################################################
#customers

CREATE TABLE customers -- Data about the customer and its location
(customer_id VARCHAR(55) NOT NULL,
customer_unique_id VARCHAR(55),
customer_zip_code_prefix VARCHAR(55),
customer_city VARCHAR(55),
customer_state VARCHAR(55),PRIMARY KEY(customer_id));

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/brazilian_ecommerce_dataset/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
#(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
;

###############################################################
#order_items

## NOTE: order_id in itself cannot be used as a unique identifier since in the data 2 or more records may belong to the same order_id.
## To solve this I create a composite key by combining the order_id and the order_item_id column.

# Create table without a primary key and load the data into it
CREATE TABLE order_items_messy -- Includes data about the items purchased within each order
(order_id VARCHAR(55),
order_item_id VARCHAR(55),
product_id VARCHAR(55),
seller_id VARCHAR(55),
shipping_limit_date TIMESTAMP,
price FLOAT,
freight_value FLOAT);

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/brazilian_ecommerce_dataset/order_items.csv'
INTO TABLE order_items_messy
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

# Create table with primary key
CREATE TABLE order_items
(order_id VARCHAR(55),
order_item_id VARCHAR(55),
product_id VARCHAR(55),
seller_id VARCHAR(55),
shipping_limit_date TIMESTAMP,
price FLOAT,
freight_value FLOAT,
order_uuid VARCHAR(55), PRIMARY KEY(order_uuid));

# Insert data that includes a composite key (order_uuid) as well to order_id table 
INSERT INTO order_items(order_id,order_item_id,product_id,seller_id,shipping_limit_date,price,freight_value,order_uuid)
SELECT *, CONCAT(order_id,'_',order_item_id) AS order_uuid FROM order_items_messy;

# Drop messy table to keep environment clean
DROP TABLE IF EXISTS order_items_messy;

###############################################################
#order_payments
## NOTE: order_id in itself cannot be used as a unique identifier since in the data 2 or more records may belong to the same order_id.
## To solve this I create a composite key by combining the order_id and the order_item_id column.

DROP TABLE IF EXISTS order_payments_messy;
DROP TABLE IF EXISTS order_payments;

# Create table without a primary key and load the data into it
CREATE TABLE order_payments_messy -- Includes data about the orders payment options
(order_id VARCHAR(55),
payment_sequential INT,
payment_type VARCHAR(55),
payment_installments INT,
payment_value FLOAT);

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/brazilian_ecommerce_dataset/order_payments.csv'
INTO TABLE order_payments_messy
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

# Create table with primary key
CREATE TABLE order_payments
(order_id VARCHAR(55),
payment_sequential INT,
payment_type VARCHAR(55),
payment_installments INT,
payment_value FLOAT,
payment_uuid VARCHAR(55), PRIMARY KEY(payment_uuid));

# Insert data that includes a composite key (payment_uuid) as well to order_id table 
INSERT INTO order_payments(order_id,payment_sequential,payment_type,payment_installments,payment_value,payment_uuid)
SELECT *, CONCAT(order_id,'_',payment_sequential) AS order_uuid FROM order_payments_messy;

# Drop messy table to keep environment clean
DROP TABLE IF EXISTS order_payments_messy;

###############################################################
#order_reviews

CREATE TABLE order_reviews -- Includes data about the reviews made by the customers
(review_id VARCHAR(55),
order_id VARCHAR(55),
review_score INT,
review_comment_title VARCHAR(55),
review_comment_message VARCHAR(500),
review_creation_date VARCHAR(100),
review_answer_timestamp VARCHAR(200));

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/brazilian_ecommerce_dataset/order_reviews.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(review_id,order_id,review_score,review_comment_title,review_comment_message,@review_creation_date,@review_answer_timestamp)
set
review_creation_date=str_to_date(@review_creation_date, "%d/%m/%Y %H:%i:%s"),
review_answer_timestamp=str_to_date(@review_answer_timestamp, "%d/%m/%Y %H:%i:%s")
;

###############################################################
#orders

CREATE TABLE orders -- Contains core data on orders
(order_id VARCHAR(55),
customer_id VARCHAR(55),
order_status VARCHAR(55),
order_purchase_timestamp DATETIME,
order_approved_at DATETIME,
order_delivered_carrier_date DATETIME,
order_delivered_customer_date DATETIME,
order_estimated_delivery_date DATETIME,PRIMARY KEY(order_id));

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/brazilian_ecommerce_dataset/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','  ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, customer_id, order_status, order_purchase_timestamp, @order_approved_at, @order_delivered_carrier_date, @order_delivered_customer_date, order_estimated_delivery_date)
set order_approved_at=if(@order_approved_at='',null, @order_approved_at),
	order_delivered_carrier_date=if(@order_delivered_carrier_date='',null, @order_delivered_carrier_date),
    order_delivered_customer_date=if(@order_delivered_customer_date='',null, @order_delivered_customer_date)
;

###############################################################
# products
DROP TABLE IF EXISTS products;

CREATE TABLE products -- Includes data about the products sold by Olist
(product_id VARCHAR(55),
product_category_name VARCHAR(255),
product_name_lenght INT,
product_description_lenght INT,
product_photos_qty INT,
product_weight_g INT,
product_length_cm INT,
product_height_cm INT,
product_width_cm INT,PRIMARY KEY(product_id));

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/brazilian_ecommerce_dataset/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','  ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id,product_category_name,@product_name_lenght,@product_description_lenght,@product_photos_qty,@product_weight_g,@product_length_cm,@product_height_cm,@product_width_cm)
set product_name_lenght=if(@product_name_lenght='',null, @product_name_lenght),
	product_description_lenght=if(@product_description_lenght='',null, @product_description_lenght),
    product_photos_qty=if(@product_photos_qty='',null, @product_photos_qty),
	product_weight_g=if(@product_weight_g='',null, @product_weight_g),
    product_length_cm=if(@product_length_cm='',null, @product_length_cm),
    product_height_cm=if(@product_height_cm='',null, @product_height_cm),
    product_width_cm=if(@product_width_cm='',null, @product_width_cm)
;

###############################################################
# sellers

CREATE TABLE sellers -- Includes data about the sellers that fulfilled orders made at Olist
(seller_id VARCHAR(255),
seller_zip_code_prefix VARCHAR(55),
seller_city VARCHAR(255),
seller_state VARCHAR(55),PRIMARY KEY(seller_id));

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/brazilian_ecommerce_dataset/sellers.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','  ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(seller_id, seller_zip_code_prefix, seller_city, seller_state)
;

###############################################################
# prod_cat_trans
DROP TABLE IF EXISTS prod_cat_trans;
CREATE TABLE prod_cat_trans -- Translates the productcategoryname to english
(product_category_name VARCHAR(255),
product_category_name_english VARCHAR(255),PRIMARY KEY(product_category_name));

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/brazilian_ecommerce_dataset/product_category_name_translation.csv'
INTO TABLE prod_cat_trans
FIELDS TERMINATED BY ','  ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

###############################################################
## Write ETL process to create the Analytical Data Layer
###############################################################
# Create joined table for analysis

DROP PROCEDURE IF EXISTS create_order_analytics_table;

DELIMITER //

CREATE PROCEDURE create_order_analytics_table()
BEGIN
	# Calculate Average Review Score and save it to variable
	DECLARE avg_review_score DECIMAL DEFAULT 3;
    SET avg_review_score = (SELECT avg(review_score) FROM order_reviews);
    
	DROP TABLE IF EXISTS order_analytics;

	CREATE TABLE order_analytics AS
	SELECT
	   orders.order_id AS OrderID,
	   order_items.order_uuid AS OrderUUID, 
	   order_items.price AS Price, 
	   sellers.seller_id  AS SellerID,
	   sellers.seller_city  AS SellerCity,
	   sellers.seller_state As SellerState,
       prod_cat_trans.product_category_name_english AS ProductCategoryName,
       products.product_weight_g AS ProductWeight,
       products.product_photos_qty AS ProductPhotosQty,
       ((product_length_cm*product_height_cm*product_width_cm)/1000) AS ProductVolumeLiter,
	   customers.customer_city As CustomerCity,
	   customers.customer_state As CustomerState,
	   orders.order_purchase_timestamp AS PurchaseDate,
       order_items.freight_value AS FreightValue,
       order_items.shipping_limit_date AS ShippingLimitDate,
       orders.order_approved_at AS DateApproved,
       orders.order_delivered_carrier_date AS CarrierDate,
       orders.order_delivered_customer_date AS CustomerDeliveryDate,
       orders.order_estimated_delivery_date  AS EstDeliveryDate,
       TIMESTAMPDIFF(MINUTE,orders.order_purchase_timestamp,orders.order_delivered_customer_date) AS OrderDeliveryTimeMin,
       order_reviews.review_score AS ReviewScore,
       IF(order_reviews.review_score > avg_review_score, 1, 0) AS is_satisfied,
       order_reviews.review_comment_title AS ReviewTitle,
       order_reviews.review_comment_message AS ReviewMessage,
       order_reviews.review_creation_date AS ReviewCreationDate,
       order_reviews.review_answer_timestamp AS ReviewAnswerDate,
       DAYOFWEEK(orders.order_purchase_timestamp) as PurchaseDayOfWeek
	FROM
		orders
	INNER JOIN
		customers USING (customer_id)
    INNER JOIN    
		order_reviews USING (order_id)
	INNER JOIN
		order_items USING (order_id)
	INNER JOIN
		sellers USING (seller_id)
	INNER JOIN
		products USING (product_id)
	INNER JOIN
		prod_cat_trans USING (product_category_name)
	ORDER BY 
		order_purchase_timestamp,
		price
    ;
    
END //
DELIMITER ;

CALL create_order_analytics_table();

###############################################################
# Views and answers to Analytics Questions
###############################################################
# 1. Which were the top 5 product categories based on sales in September 2017?
# DATAMART 1: Fixed Time
DROP VIEW IF EXISTS sep_2017;
CREATE VIEW `sep_2017` AS
SELECT * FROM order_analytics WHERE order_analytics.PurchaseDate BETWEEN '2017-09-01 00:00:00' AND '2017-10-01 00:00:00';

# Write Query to get top 5 Product categories based on sales in Sep 2017
SELECT ProductCategoryName, SUM(Price) AS Sales FROM sep_2017
GROUP BY ProductCategoryName
ORDER BY Sales DESC
LIMIT 5;

###############################################################
# 2. What percentage of sales were made in Sao Paulo and Rio de Janeiro compared to total sales?
# DATAMART 2:  Fixed Area
DROP VIEW IF EXISTS state_sp_rj;
CREATE VIEW `state_sp_rj` AS
SELECT * FROM order_analytics WHERE order_analytics.CustomerState IN ("SP","RJ");

# Create Stored Procedure to get Rio de Janeiro's and Sao Paulo's share of total sales
DROP PROCEDURE IF EXISTS get_percentage_of_total_sales_RJ_SP;

DELIMITER //

CREATE PROCEDURE get_percentage_of_total_sales_RJ_SP(
	OUT percentage_of_total FLOAT)
BEGIN
	SELECT (SELECT SUM(price) FROM state_sp_rj)/(SELECT SUM(price) FROM order_analytics)
	INTO percentage_of_total;
END //
DELIMITER ;
CALL get_percentage_of_total_sales_RJ_SP(@percentage_of_total);
SELECT @percentage_of_total;

###############################################################
# 3. On which day of the week sales were the highest in the Furniture product category?
# DATAMART 3:  Fixed Product Category
DROP VIEW IF EXISTS furniture;
CREATE VIEW `furniture` AS
SELECT * FROM order_analytics WHERE order_analytics.ProductCategoryName = "furniture_decor";
SELECT * FROM furniture;
# Write Query that returns total sales for each day of the week
SELECT PurchaseDayOfWeek, SUM(price) AS 'Total Sales' FROM order_analytics
GROUP BY order_analytics.PurchaseDayOfWeek
ORDER BY SUM(price) DESC
;

###############################################################
# 4. What percentage of orders were delivered to the customer before the estimated time of delivery?

# Create Stored Procedure to get the percentage share of orders that were delivered before the estimated delivery time
DROP PROCEDURE IF EXISTS get_percentage_of_orders_delivered_in_time;

DELIMITER //

CREATE PROCEDURE get_percentage_of_orders_delivered_in_time(
	OUT percentage_of_orders FLOAT)
BEGIN
	SELECT 
		(SELECT COUNT(*) FROM 
			(SELECT * FROM order_analytics 
				GROUP BY order_analytics.OrderID -- get order level data because order-item level data would take into account the orders with more than one item multiple times
                HAVING order_analytics.CustomerDeliveryDate < order_analytics.EstDeliveryDate) -- filter for those orders that were delivered in time
                AS order_level_table_conditioned) 
		/ (SELECT COUNT(*) FROM 
			(SELECT * FROM order_analytics 
				GROUP BY order_analytics.OrderID)  -- get order level data
                AS order_level_table)
	INTO percentage_of_orders;
END //
DELIMITER ;
CALL get_percentage_of_orders_delivered_in_time(@percentage_of_orders);
SELECT @percentage_of_orders;

###############################################################
# 5. What was the average delivery time for orders with below-average and above-average review score?
# Writing Query to get the average delivery time for orders with below-average and above-average review scores
SELECT order_analytics.is_satisfied, AVG(OrderDeliveryTimeMin) AS "Average Delivery Time" -- Calculate time difference in minutes
FROM order_analytics
WHERE order_analytics.CustomerDeliveryDate > order_analytics.PurchaseDate -- Disregarding possible errors
GROUP BY order_analytics.is_satisfied;  

###############################################################
# 6. Which 5 sellers had the highest average consumer satisfaction based on review scores in the Health and Beauty product category (above 50 number of review scores received)?
# DATAMART 4:  Fixed Product Category
DROP VIEW IF EXISTS health_beauty;
CREATE VIEW `health_beauty` AS
SELECT * FROM order_analytics WHERE order_analytics.ProductCategoryName = "health_beauty";
SELECT * FROM health_beauty;

# Writing Stored Procedure to get the top n sellers with the highest average consumer satisfaction based on review scores (above 100 number of review scores received)
DROP PROCEDURE IF EXISTS get_top_n_sellers_hb;

DELIMITER //

CREATE PROCEDURE get_top_n_sellers_hb(
	IN n INT)
BEGIN
	CREATE TABLE top_n_sellers_hb AS
		SELECT order_level_table.SellerID, AVG(order_level_table.ReviewScore) AS "Average Review Score", COUNT(*) 
			FROM (SELECT * FROM health_beauty GROUP BY health_beauty.OrderID) AS order_level_table  -- get order level data
			GROUP BY order_level_table.SellerID
			HAVING COUNT(*) > 50 -- Get rid of sellers that have low number of reviews
			ORDER BY AVG(order_level_table.ReviewScore) DESC
			LIMIT n; -- get first top n sellers
END //
DELIMITER ;
CALL get_top_n_sellers_hb(5);
SELECT * FROM top_n_sellers_hb;

###############################################################
## Create Materialized view for the product category summary statics of Datamart 2 (Fixed Location Dimension: Sao Paulo and Rio de Janiero)

# Creating Table of Interest
DROP TABLE IF EXISTS prod_cat_summary_SP_RJ_mv;
CREATE TABLE prod_cat_summary_SP_RJ_mv AS
	SELECT state_sp_rj.ProductCategoryName AS "Product Category", COUNT(*) AS "# of items sold", SUM(Price) AS "Total Sales", AVG(ProductWeight) AS "Avg. Product Weight", AVG(ProductVolumeLiter) AS "Avg. Product Volume (L)", AVG(OrderDeliveryTimeMin) AS "Avg. Delivery Time (Min)", AVG(state_sp_rj.ReviewScore) AS "Avg. Review Score", AVG(state_sp_rj.is_satisfied) AS "% of reviews above mean score"
		FROM state_sp_rj
		GROUP BY state_sp_rj.ProductCategoryName
		ORDER BY SUM(Price) DESC;

# Creating Stored Procedure that refreshes the Materialized View
#DROP PROCEDURE refresh_prod_cat_summary_SP_RJ_mv;

DELIMITER $$

CREATE PROCEDURE refresh_prod_cat_summary_SP_RJ_mv (
    OUT rc INT
)
BEGIN

  TRUNCATE TABLE prod_cat_summary_SP_RJ_mv;

  INSERT INTO prod_cat_summary_SP_RJ_mv
	SELECT state_sp_rj.ProductCategoryName, 
			COUNT(*), 
			SUM(Price), 
			AVG(ProductWeight), 
			AVG(ProductVolumeLiter), 
			AVG(OrderDeliveryTimeMin), 
			AVG(state_sp_rj.ReviewScore), 
			AVG(state_sp_rj.is_satisfied)
		FROM state_sp_rj
		GROUP BY state_sp_rj.ProductCategoryName
		ORDER BY SUM(Price) DESC;

  SET rc = 0;
END;
$$
DELIMITER ;
# Refresh the summary table
CALL refresh_prod_cat_summary_SP_RJ_mv(@rc);
# View summary table
SELECT * FROM prod_cat_summary_SP_RJ_mv;

###############################################################
# EXTRAS
##### 
# Event for extra points
# Create messages to log the operation of the event
CREATE TABLE messages (message VARCHAR(255));
TRUNCATE messages;

# Turn on event scheduler and check it
SET GLOBAL event_scheduler = ON;
SHOW VARIABLES LIKE "event_scheduler";


DELIMITER //
CREATE EVENT refresh_prod_cat_summary_SP_RJ_mv_event
ON SCHEDULE EVERY 2 MINUTE
STARTS (CURRENT_TIMESTAMP+MINUTE(1)) -- From 1 minute from now
ENDS TIMESTAMP(CURRENT_DATE+2) -- Till the midnight of tomorrow
DO
	BEGIN
		INSERT INTO messages SELECT CONCAT('event:',NOW());
    		CALL refresh_prod_cat_summary_SP_RJ_mv();
	END//
DELIMITER ;
SELECT * FROM messages;

DROP EVENT IF EXISTS refresh_prod_cat_summary_SP_RJ_mv_event;