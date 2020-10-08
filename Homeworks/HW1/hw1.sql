-- DE1 Homework 1
-- DOMINIK GULACSY

-- LOADING A RELATIONAL DATABASE CONTAINING DATA ON LEGO PARTS

CREATE SCHEMA lego_db;
USE lego_db;

DROP TABLE IF EXISTS colors, inventory_sets, inventory_parts, inventories, part_categories, parts, sets, themes;

-- QUESTION: How can I quickly check if all value types of a variable is the same? (e.g. if there is no float between many integer observations)
-- QUESTION: How can I quickly check if an ID is truly a unique identifier? (My way is using Excel and check if every ID appears only once.)

CREATE TABLE colors
(id INTEGER NOT NULL,
name VARCHAR(255),
rgb VARCHAR(32),
is_trans VARCHAR(16),PRIMARY KEY(id)); -- QUESTION: How to load properly a ("t"/"f") binary variable?
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LEGO_Database/colors.csv' 
INTO TABLE colors
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES 
(id, name, rgb, is_trans);

CREATE TABLE inventory_sets
(id INTEGER NOT NULL,
inventory_id INTEGER NOT NULL,
set_num VARCHAR(32),
quantity INTEGER,
PRIMARY KEY(id));
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LEGO_Database/inventory_sets.csv' 
INTO TABLE inventory_sets
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES 
(id, inventory_id, set_num, quantity);

CREATE TABLE inventory_parts
(id INTEGER NOT NULL,
inventory_id INTEGER NOT NULL,
part_num VARCHAR(32),
color_id INTEGER NOT NULL,
quantity INTEGER NOT NULL,
is_spare VARCHAR(16),
PRIMARY KEY(id));
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LEGO_Database/inventory_parts.csv' 
INTO TABLE inventory_parts
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(id, inventory_id, part_num, color_id, quantity, is_spare);

CREATE TABLE inventories
(id INTEGER NOT NULL,
version INTEGER NOT NULL,
set_num VARCHAR(32),
PRIMARY KEY(id));
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LEGO_Database/inventories.csv' 
INTO TABLE inventories
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(id, version, set_num);


CREATE TABLE part_categories
(id INTEGER NOT NULL,
name VARCHAR(255),
PRIMARY KEY(id));
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LEGO_Database/part_categories.csv' 
INTO TABLE part_categories
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(id, name);

CREATE TABLE parts
(part_num VARCHAR(32),
name VARCHAR(255),
part_cat_id INTEGER,
PRIMARY KEY(part_num));
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LEGO_Database/parts.csv' 
INTO TABLE parts
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(part_num, name, part_cat_id);

CREATE TABLE sets
(set_num VARCHAR(255),
name VARCHAR(255),
year INTEGER,
theme_id INTEGER,
num_parts INTEGER,
PRIMARY KEY(set_num));
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LEGO_Database/sets.csv' 
INTO TABLE sets
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(set_num, name, year, theme_id, num_parts);

CREATE TABLE themes
(id INTEGER NOT NULL,
name VARCHAR(255),
parent_id INTEGER,
PRIMARY KEY(id));
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LEGO_Database/themes.csv' 
INTO TABLE themes
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(id, name, @v_parent_id)
SET
parent_id = nullif(@v_parent_id, '' or ' '); -- QUESTION: How to know if MySQL translates missing value in our data file to '' or ' '?

-- QUESTION: Is there a way to iterate through this loading process conveniently by writing a loop?
