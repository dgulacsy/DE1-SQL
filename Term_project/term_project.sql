##################################################
-- DE1 TERM PROJECT
-- AUTHOR: DOMINIK GULACSY - BUSINESS ANALYTICS 2020/21

# DATA
-- Brazilian E-Commerce Public Dataset by Olist
-- Source: Olist and André Sionek, “Brazilian E-Commerce Public Dataset by Olist.” Kaggle, 2018, doi: 10.34740/KAGGLE/DSV/195341.
-- URL: https://www.kaggle.com/olistbr/brazilian-ecommerce
-- License: CC BY-NC-SA 4.0
##################################################

-- LOADING DATASET TO CREATE A RELATIONAL DATABASE
CREATE SCHEMA ecom_db;
USE ecom_db;

DROP TABLE IF EXISTS customers, geolocation, order_items, order_payments, order_reviews, orders, products, sellers, prod_cat_trans;

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
(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
;

CREATE TABLE geolocation -- Dataset has information Brazilian zip codes and its lat/lng coordinates
(geozip_code_prefix VARCHAR(55) NOT NULL,
geolocation_zip_code_prefix VARCHAR(55),
geolocation_lat FLOAT,
geolocation_lng FLOAT,
geolocation_city VARCHAR(55),
geolocation_state VARCHAR(55),PRIMARY KEY(geolocation_zip_code_prefix));

CREATE TABLE order_items -- Includes data about the items purchased within each order
(order_id VARCHAR(55),
order_item_id VARCHAR(55),
product_id VARCHAR(55),
seller_id VARCHAR(55),
shipping_limit_date TIMESTAMP,
price FLOAT,
freight_value FLOAT,PRIMARY KEY(order_id));

CREATE TABLE order_payments -- Includes data about the orders payment options
(order_id VARCHAR(55),
payment_sequential INT,
payment_type VARCHAR(55),
payment_installments INT,
payment_value FLOAT,PRIMARY KEY(order_id));

CREATE TABLE order_reviews -- Includes data about the reviews made by the customers
(review_id VARCHAR(55),
order_id VARCHAR(55),
review_score INT,
review_comment_title VARCHAR(55),
review_comment_message VARCHAR(300),
review_creation_date TIMESTAMP,
review_answer_timestamp TIMESTAMP,PRIMARY KEY(review_id));

CREATE TABLE orders -- Contains core data on orders
(order_id VARCHAR(55),
customer_id VARCHAR(55),
order_status VARCHAR(55),
order_purchase_timestamp TIMESTAMP,
order_approved_at TIMESTAMP,
order_delivered_carrier_date TIMESTAMP,
order_delivered_customer_date TIMESTAMP,
order_estimated_delivery_date TIMESTAMP,PRIMARY KEY(order_id));

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

CREATE TABLE sellers -- Includes data about the sellers that fulfilled orders made at Olist
(seller_id VARCHAR(55),
seller_zip_code_prefix VARCHAR(55),
seller_city VARCHAR(255),
seller_state VARCHAR(55),PRIMARY KEY(seller_id));

CREATE TABLE prod_cat_trans -- Translates the productcategoryname to english
(product_category_name VARCHAR(255),
product_category_name_english VARCHAR(255),PRIMARY KEY(product_category_name));

## Creat stored procedure to load files to tables
DELIMITER //

CREATE PROCEDURE LoadData()
SET fnames ENUM('c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/brazilian_ecommerce_dataset/');
SET tables ENUM();
BEGIN
	myloop: LOOP
		LOAD DATA INFILE CONCAT(fnames,tables)
		INTO TABLE tables
		FIELDS TERMINATED BY ','
		LINES TERMINATED BY '\n'
		IGNORE 1 LINES
		LEAVE myloop;
	END LOOP myloop;

END //

DELIMITER ;

CALL LoadData();

