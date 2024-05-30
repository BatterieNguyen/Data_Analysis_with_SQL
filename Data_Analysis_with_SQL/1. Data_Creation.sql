 /* IMPORT DATA FROM LOCAL_HOST */

DROP TABLE IF EXISTS us_retail_sales;

-- Create table
CREATE TABLE us_retail_sales	
      (
      	sales_month DATE,
      	naics_code VARCHAR(255),
      	kind_of_business VARCHAR(255),
      	reason_for_null VARCHAR(255),
      	sales DECIMAL (10, 2)
      );


EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

-- Import data from CSV file
BULK INSERT	us_retail_sales
FROM 'D:/0. Let''s Stress/DATA ANALYSIS/SQL/SQLServer/us_retail_sales.csv'
WITH (
  	  FORMAT = 'CSV',
      FIELDTERMINATOR = ',',
      ROWTERMINATOR = '0x0a',
      FIRSTROW = 2
      );
```
---------------------------------------------------------------------------------------
/* SET UP CONSTRAINTS FOR COLUMNS */

/* DATASET CREATION */

-- 1. Create Schema
CREATE SCHEMA production;
CREATE SCHEMA sales;

-- 2. Create Table
USE production;
CREATE TABLE categories 
	(category_id	INT AUTO_INCREMENT PRIMARY KEY,
     category_name	VARCHAR(255)	NOT NULL
     );

CREATE TABLE brands
	(brand_id	INT	AUTO_INCREMENT	PRIMARY KEY,
     brand_name VARCHAR(255)	NOT NULL
     );

CREATE TABLE	products
	(product_id		INT	AUTO_INCREMENT	PRIMARY KEY,
     product_name	VARCHAR(255)	NOT NULL,
     brand_id		INT 	NOT NULL,
     category_id	INT		NOT NULL,
     model_year		SMALLINT	NOT NULL,
     list_price		DECIMAL (10,2) NOT NULL,
     FOREIGN KEY	(category_id)	REFERENCES	categories(category_id)
		ON DELETE CASCADE	ON UPDATE CASCADE,
	 FOREIGN KEY	(brand_id)	REFERENCES	brands(brand_id)
		ON DELETE CASCADE	ON UPDATE CASCADE
	);

CREATE TABLE stocks
	(store_id	INT,
     product_id	INT,
     quantity	INT,
     
     PRIMARY KEY (store_id, product_id),
     FOREIGN KEY (store_id)		REFERENCES	sales.stores(store_id)		ON DELETE CASCADE ON UPDATE CASCADE,
     FOREIGN KEY (product_id)	REFERENCES	products(product_id)	ON DELETE CASCADE ON UPDATE CASCADE
	);

USE sales;
CREATE TABLE	customers
	(customer_id	INT	AUTO_INCREMENT	PRIMARY KEY,
     first_name		VARCHAR(255) NOT NULL,
     last_name		VARCHAR(255) NOT NULL,
     phone			VARCHAR(25),
     email			VARCHAR(255) NOT NULL,
     street			VARCHAR(255),
     city			VARCHAR(50),
     state			VARCHAR(25),
     zip_code		VARCHAR(5)
    );

CREATE TABLE	stores
	(store_id		INT AUTO_INCREMENT	PRIMARY KEY,
     store_name		VARCHAR(255)	NOT NULL,
     phone			VARCHAR(25),
     email			VARCHAR(255),
     street			VARCHAR(255),
     city			VARCHAR(255),
     state			VARCHAR(10),
     zip_code		VARCHAR(5)
	);
    
CREATE TABLE	staffs
	(staff_id	INT AUTO_INCREMENT	PRIMARY KEY,
     first_name VARCHAR(50)	NOT NULL,
     last_name	VARCHAR(50) NOT NULL,
     email		VARCHAR(255),
     phone		VARCHAR(25),
     active		tinyint	NOT NULL,
     store_id	INT,
     manager_id	INT,
     
     FOREIGN KEY (store_id)	REFERENCES	stores(store_id)
		ON DELETE CASCADE	ON UPDATE CASCADE,
	 FOREIGN KEY (manager_id)	REFERENCES	staffs(staff_id)
		ON DELETE NO ACTION ON UPDATE NO ACTION
	);


    
CREATE TABLE orders
	(order_id	INT AUTO_INCREMENT PRIMARY KEY,
     customer_id	INT,
     order_status	TINYINT NOT NULL,
     -- Order status: 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed
     order_date		DATE NOT NULL,
     required_date	DATE NOT NULL,
     shipped_date	DATE NOT NULL,
     store_id		INT NOT NULL,
     staff_id		INT NOT NULL,
     
     FOREIGN KEY	(customer_id)	REFERENCES	customers(customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
     FOREIGN KEY	(store_id)		REFERENCES	stores(store_id)	   ON DELETE CASCADE ON UPDATE CASCADE,
     FOREIGN KEY	(staff_id)		REFERENCES	staffs(staff_id)	   ON DELETE NO ACTION ON UPDATE NO ACTION
	);
     
CREATE TABLE order_items
	(order_id	INT,
     item_id	INT,
     product_id	INT NOT NULL,
     quantity	INT NOT NULL,
     list_price	DECIMAL(10,2) NOT NULL,
     discount	DECIMAL(4,2) NOT NULL DEFAULT 0,
     
     PRIMARY KEY (order_id, item_id),
     FOREIGN KEY (order_id)		REFERENCES	orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
     FOREIGN KEY (product_id)	REFERENCES production.products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
	);

-- 3. Drop Table If exists
DROP TABLE IF EXISTS orders;
DROP SCHEMA IF EXISTS sale_bikestore;

-- 4. Import Data
INSERT INTO brands(brand_id, brand_name)
	VALUES	(1, 'Electra'),
			(2,'Haro'),
			(3,'Heller'),
			(4,'Pure Cycles'),
			(5,'Ritchey'),
			(6,'Strider'),
			(7,'Sun Bicycles'),
			(8,'Surly'),
			(9,'Trek');

INSERT INTO sale_bikestore.categories(category_id,category_name) VALUES(1,'Children Bicycles');
INSERT INTO sale_bikestore.categories(category_id,category_name) VALUES(2,'Comfort Bicycles');
INSERT INTO sale_bikestore.categories(category_id,category_name) VALUES(3,'Cruisers Bicycles');
INSERT INTO sale_bikestore.categories(category_id,category_name) VALUES(4,'Cyclocross Bicycles');
INSERT INTO sale_bikestore.categories(category_id,category_name) VALUES(5,'Electric Bikes');
INSERT INTO sale_bikestore.categories(category_id,category_name) VALUES(6,'Mountain Bikes');
INSERT INTO sale_bikestore.categories(category_id,category_name) VALUES(7,'Road Bikes');

ALTER SCHEMA sale_bikestore TO production;

/*
AUTO_INCREMENT              -- allow MySQL to automatically assign incremental values to the category_id column whenever a new row is inserted.
    ON DELETE CASCADE       -- if a category is deleted from the categories table, all corresponding rows in the current table will also be deleted.
    ON UPDATE CASCADE       --  if the category_id value is updated in the categories table, the corresponding values in the current table will be updated accordingly.
    ON DELETE NO ACTION     -- if a staff member with the corresponding staff_id is deleted from the sales.staffs table, the deletion will not be allowed if there are rows in the current table referencing that staff member.
    ON UPDATE NO ACTION     -- if the staff_id value is updated in the sales.staffs table, the update will not be allowed if there are rows in the current table referencing that staff member.
*/
