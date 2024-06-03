
-- USE lucky_shrub;

----------------------------------------------------------------------------------------------------------------------------------
<p align = "center";> 
	MODULE 1 - FUNCTIONS AND TRIGGERS
</p>

<p style="text-align:center">
	MODULE 1 - FUNCTIONS AND TRIGGERS
</p>

---------------------------------------

-- 1. Stored Procedure

-- SAMPLE 
```
DELIMITER //
	CREATE PROCEDURE GetAllClients()
	BEGIN
		SELECT * FROM Clients;
	END //
DELIMITER;
```
-- call out created procedure
CALL GetAllClients();

-- SQL SERVER 
	CREATE PROCEDURE DemandByRegions
		@country VARCHAR(25)
	AS
		BEGIN
			SELECT	reg.Country
					, reg.City
					, COUNT(ord.customer_index) AS orders
			FROM	Sales_Orders ord
						INNER JOIN regions reg	ON ord.delivery_region_index = reg.region_index
			WHERE	@country = reg.Country
			GROUP BY	reg.Country
						, reg.City
			ORDER BY orders DESC
		END;
------------------------------------------
-- 2. Stored Function

-- SAMPLE 
DELIMITER //
	CREATE FUNCTION GetCostAverage() RETURNS DECIMAL(5,2) DETERMINISTIC 
	BEGIN
		RETURN (SELECT AVG(Cost) FROM Orders);
	END //
DELIMITER;

-- Call out reated function
SELECT GetCostAverage();
-----------------------------------------------
-- TASK 1: Create a SQL function that prints the cost value of a specific order based on the user input of the OrderID.

CREATE FUNCTION FindCost(id INT) 
	RETURNS DECIMAL(5,2) DETERMINISTIC RETURN 
    (	SELECT	Cost
		  FROM 	orders 
		 WHERE	id = OrderID);

SELECT FindCost(10)

-- TASK 2: Create a stored procedure called GetDiscount. 
-- This stored procedure must return the final cost of the customer's order after the discount value has been deducted. 

DELIMITER //
CREATE PROCEDURE GetDiscount(id INT)
	BEGIN
		DECLARE Cost_After_Discount DECIMAL(7,2);
        DECLARE current_cost DECIMAL(7,2);
        DECLARE order_quantity INT;
        SELECT Quantity INTO order_quantity FROM orders WHERE id = OrderID;
        SELECT Cost INTO current_cost FROM orders WHERE id = OrderID;
        IF order_quantity >= 20 THEN
			SET Cost_After_Discount = current_cost - current_cost*0.2;
		ELSEIF order_quantity >= 10 THEN
			SET Cost_After_Discount = current_cost - current_cost*0.1;
		ELSE
			SET Cost_After_Discount = current_cost;
		END IF;
	SELECT Cost_After_Discount;
	END //
DELIMITER ;

CALL GetDiscount(10)
------------------------------------------
-- Drop stored procedure if it existed
IF EXISTS	(
	SELECT *
	FROM sys.objects 
	WHERE object_id = OBJECT_ID(N'procedure_name')
		 AND type IN (N'P', N'PC')
)
	DROP PROCEDURE dbo.procedure_name;
------------------------------------------
-- 3. MySQL triggers and events

-- TASK 1: 
DELIMITER //
CREATE TRIGGER ProductSellPriceInsertCheck
AFTER INSERT
ON products FOR EACH ROW
BEGIN
	IF NEW.SellPrice <= NEW.BuyPrice THEN
		INSERT INTO notifications(Notification, DATETIME)
			VALUES(CONCAT('A SellPrice same or less then the BuyPrice was inserted for ProductID ', NEW.ProductID), NOW());
	END IF;
END //

DELIMITER ;



INSERT INTO products (ProductID, ProductName, BuyPrice, SellPrice, NumofItems)
	VALUES	("P7", "product P7", 40, 40, 100)

-- TASK 2: 

DELIMITER //
CREATE TRIGGER ProductSellPriceUpdateCheck
	AFTER UPDATE 
	ON products FOR EACH ROW
	BEGIN
		IF NEW.SellPrice <= NEW.BuyPrice THEN
			INSERT INTO notifications(Notification, DATETIME)
				VALUES (CONCAT(NEW.ProductID, ' was updated with a SellPrice of ', NEW.SellPrice), NOW());
		END IF;
	END //
DELIMITER ;


-- TASK 3:
DELIMITER //
CREATE TRIGGER NotifyProductDelete
	AFTER DELETE
	ON products FOR EACH ROW
    BEGIN
		INSERT INTO notifications(Notification, DATETIME)
			VALUES (CONCAT('The product with ID: ', OLD.ProductID, ' was deleted from the product table.'), NOW());
	END //
DELIMITER ;

DELETE FROM Products WHERE ProductID='P7';

----------------------------------------------------------------------------------------------------------------------------------
-- MODULE 3 - DATA OPTIMIZATION --
----------------------------------

-- SELECT statement optimization in MySQL
-- Task 1

SELECT OrderID, ProductID, Quantity, Date
FROM orders

-- => Do not select all column if not necessary

-- Task 2: optimize this query by creating an index named IdxClientID on the required column of the Orders table

CREATE INDEX IdxClientID ON orders(ClientID);

EXPLAIN SELECT * 
FROM Orders 
WHERE ClientID='Cl1';

-- Task 3: there’s an index on the FullName column which the query cannot use because it contains a leading wildcard (%) in the WHERE clause condition.

ALTER TABLE Employees ADD COLUMN ReverseFullname VARCHAR(255);

UPDATE Employees
	SET ReverseFullname = CONCAT(
		SUBSTRING_INDEX(Fullname, ' ', -1), 	-- Extract last name
        ' ', 									-- Add space
        SUBSTRING_INDEX(Fullname, ' ', 1)		-- Extract first name
	);

CREATE INDEX IdxReverseFullname ON Employees(ReverseFullname);

SELECT * 
FROM Employees 
WHERE ReverseFullName LIKE 'Tolo%';

EXPLAIN SELECT * 
FROM Employees 
WHERE ReverseFullName LIKE 'Tolo%';



----------------------------------------------------------------------------------------------------------------------------------
# Module3_MySQL_for_Data_Analytics

-- Task 1
SELECT CONCAT(SUM(Quantity), " (2020)") AS "P4 product: Quantity Sold"
FROM	orders 
WHERE YEAR(Date) = 2020 AND ProductID = "P4"
UNION
SELECT	CONCAT(SUM(Quantity), " (2021)" )
FROM	orders
WHERE	Year(Date) = 2021 AND ProductID = "P4"
UNION
SELECT	CONCAT(SUM(Quantity), " (2022)" )
FROM	orders
WHERE	Year(Date) = 2022 AND ProductID = "P4";

-- Task 2
SELECT	c.ClientID, c.ContactNumber, 
		a.Street, a.County, 
        o.OrderID, o.ProductID, 
        p.ProductName, 
        o.Cost, o.Date 
FROM	Clients c	INNER JOIN	Addresses a ON c.AddressID = a.AddressID 
					INNER JOIN	Orders o 	ON c.ClientID = o.ClientID 
					INNER JOIN 	Products p 	ON o.ProductID = p.ProductID 
WHERE YEAR (o.Date) = 2021 OR YEAR (o.Date) = 2022 
ORDER BY o.Date;

-- Task 3
CREATE FUNCTION FindSoldQuantity (product_id VARCHAR(10), YearInput INT) 
	returns INT DETERMINISTIC 
RETURN (SELECT SUM(Quantity) 
		FROM Orders 
        WHERE ProductID = product_id AND YEAR(Date) = YearInput);
        
SELECT FindSoldQuantity ("P3", 2021);

----------------------------------------------------------------------------------------------------------------------------------
-- MODULE 4 - CONDUCT A DATA ANALYSIS FOR A CLIENT PERSONA --
-------------------------------------------------------------

# Task 1: 
# Lucky Shrub need to find out what their average sale price, or cost was for a product in 2022.
# You can help them with this task by creating a FindAverageCost() function that returns the average sale price value of all products in a specific year. 
# This should be based on the user input.

CREATE FUNCTION	FindAverageCost(year INT)
	RETURNS DECIMAL(5, 2) DETERMINISTIC 
RETURN	(	SELECT AVG(Cost)
			FROM	orders
            WHERE	year = YEAR(Date));

SELECT FindAverageCost(2022);

# Task 2:
# Lucky Shrub need to evaluate the sales patterns for bags of artificial grass over the last three years. Help them out using the following steps:
# Step 1: Create the EvaluateProduct stored procedure that outputs the total number of items sold during the last three years for the P1 Product ID. 
# 			Input the ProductID when invoking the procedure.
# Step 2: Call the procedure.
# Step 3: Output the values into outside variables.

# Approach 1:
DELIMITER //
CREATE PROCEDURE	EvaluateProduct_1(Id_input VARCHAR(10))
BEGIN
	DECLARE	Quantity_Sold_2020	INT;
    DECLARE	Quantity_Sold_2021	INT;
    DECLARE Quantity_Sold_2022	INT;
    (	SELECT	SUM(Quantity) INTO	Quantity_Sold_2020
		FROM	orders
		WHERE	ProductID = Id_input AND YEAR(Date) = 2020);
	(	SELECT	SUM(Quantity) INTO	Quantity_Sold_2021
		FROM	orders
		WHERE	ProductID = Id_input AND YEAR(Date) = 2021);
	(	SELECT	SUM(Quantity) INTO	Quantity_Sold_2022
		FROM	orders
		WHERE	ProductID = Id_input AND YEAR(Date) = 2022);
	SELECT	Quantity_Sold_2020,
			Quantity_Sold_2021,
            Quantity_Sold_2022;
END	//
DELIMITER ;

CALL EvaluateProduct_1("P1");

# Approach 2:
DELIMITER //
CREATE PROCEDURE	EvaluateProduct_2(	
		IN	Id_input		VARCHAR(10),
		OUT	Qty_Sold_2020	INT,
		OUT	Qty_Sold_2021	INT,
		OUT	Qty_Sold_2022	INT)
BEGIN
	(	SELECT	SUM(Quantity) INTO Qty_Sold_2020
		FROM	orders	
        WHERE	Id_input = ProductID AND YEAR(Date) = 2020);
	(	SELECT	SUM(Quantity) INTO Qty_Sold_2021
		FROM	orders	
        WHERE	Id_input = ProductID AND YEAR(Date) = 2021);
	(	SELECT	SUM(Quantity) INTO Qty_Sold_2022
		FROM	orders	
        WHERE	Id_input = ProductID AND YEAR(Date) = 2022);
	SELECT	Qty_Sold_2020,
			Qty_Sold_2021,
            Qty_Sold_2022;
END //
DELIMITER ;

CALL EvaluateProduct_2('P1', @sold_items_2020, @sold_items_2021, @sold_items_2022);

# Task 3:
# Lucky Shrub need to automate the orders process in their database. 
# The database must insert a new record of data in response to the insertion of a new order in the Orders table. 
# This new record of data must contain a new ID and the current date and time.
# You can help Lucky Shrub by creating a trigger called UpdateAudit. 
# This trigger must be invoked automatically AFTER a new order is inserted into the Orders table.

# Remember: The AuditID is an auto increment key. Therefore, you don't need to insert it manually.
# For example, when you insert three new orders in the Orders table, then three records of data are automatically inserted into the Audit table. 
# This is shown in the following screenshot:

DELIMITER //
CREATE TRIGGER	UpdateAudit
	AFTER INSERT
    ON orders FOR EACH ROW
BEGIN
	INSERT INTO Audit	(OrderDateTime)
		VALUES	(CURRENT_TIMESTAMP);
END //
DELIMITER ;

# Task 4:
# Lucky Shrub need location data for their clients and employees.
# To help them out, create an optimized query that outputs the following data:
# 		The full name of all clients and employees from the Clients and Employees tables in the Lucky Shrub database.  
# 		The address of each person from the Addresses table.  

SELECT	e.Fullname,
		a.Street, a.County
  FROM	employees e	INNER JOIN	addresses a ON e.AddressID = a.AddressID
UNION
SELECT	c.FullName,
		a.Street, a.County		
  FROM	clients	c	INNER JOIN	addresses a ON c.AddressID = a.AddressID;

# Task 5:
# Lucky Shrub need to find out what quantities of wood panels they are selling. 
# The wood panels product has a Product ID of P2. 
# The following query returns the total quantity of this product as sold in the years 2020, 2021 and 2022:

SELECT CONCAT (SUM(Cost), " (2020)") AS "Total sum of P2 Product" FROM Orders WHERE YEAR (Date) = 2020 AND ProductID = "P2" 
UNION 
SELECT CONCAT (SUM(Cost), "(2021)") FROM Orders WHERE YEAR (Date) = 2021 AND ProductID = "P2" 
UNION 
SELECT CONCAT (SUM (Cost), "(2022)") FROM Orders WHERE YEAR (Date) = 2022 AND ProductID = "P2";

SELECT * FROM orders;

WITH P2_Sales AS
	(  SELECT	Quantity, Cost, 
				Year(DATE) AS year
		 FROM	orders
		WHERE	ProductID = "P2")
  
  SELECT	year,
			SUM(Cost) AS "Sales of P2"
	FROM	P2_Sales
GROUP BY	year
ORDER BY	year ASC;

WITH
	P2_Sales_2020 AS
		( SELECT	CONCAT(SUM(Cost), " (2020)") AS "Total Sales of P2 Product"
			FROM	orders
		   WHERE	ProductID = "P2" AND YEAR(Date) = 2020),
	P2_Sales_2021 AS
		( SELECT	CONCAT(SUM(Cost), " (2021)") AS "Total Sales of P2 Product"
			FROM	orders
		   WHERE	ProductID = "P2" AND YEAR(Date) = 2021),
	P2_Sales_2022 AS
		( SELECT	CONCAT(SUM(Cost), " (2022)") AS "Total Sales of P2 Product"
			FROM	orders
		   WHERE	ProductID = "P2" AND YEAR(Date) = 2022)

SELECT * FROM P2_Sales_2020
UNION
SELECT * FROM P2_Sales_2021
UNION
SELECT * FROM P2_Sales_2022;

# Task 6:
# Lucky Shrub want to know more about the activities of the clients who use their online store. 
# The system logs the ClientID and the ProductID information for each activity in a JSON Properties column inside the Activity table. 
# This occurs while clients browse through Lucky Shrub products online.
# Utilize the Properties data to output the following information:
#		The full name and contact number of each client from the Clients table.
#		The ProductID for all clients who performed activities.
# Tip:
#		Use the following code to access the property value with double quotations from the JSON datatype: ->'$.PropertyName
#		Use the following code to access the property value without double quotations from the JSON datatype: ->>'$. PropertyName

	SELECT	act.Properties ->> '$.ClientID'		AS	ClientID,
			act.Properties ->> '$.ProductID' 	AS	ProductID,
			c.FullName, c.ContactNumber
	  FROM	clients c	RIGHT JOIN	activity act	
				ON	c.ClientID = act.Properties ->> '$.ClientID';


# Task 7:
# Lucky Shrub need to find out how much revenue their top selling product generated. 
# Create a stored procedure called GetProfit that returns the overall profits generated by a specific product in a specific year. 
# This should be based on the user input of the ProductID and Year. 

DELIMITER //
CREATE PROCEDURE GetProfit(Id_product VARCHAR(10), year INT)
BEGIN
	DECLARE Profit	DECIMAL(7,2) DEFAULT 0.0;
    DECLARE Buy_Price, Sell_Price DECIMAL(7,2) DEFAULT 0.0;
    DECLARE	Quantity_Sold INT	DEFAULT 0;
    (	SELECT	BuyPrice INTO Buy_Price
		FROM	products
        WHERE	ProductID = Id_product);
	(	SELECT	SellPrice INTO Sell_Price
		FROM	products
        WHERE	ProductID = Id_product);
	(	SELECT	SUM(Quantity) INTO Quantity_Sold
		FROM	orders
        WHERE	ProductID = Id_product AND year = YEAR(Date));
	
    SET Profit = Quantity_Sold*(Sell_Price - Buy_Price);
    
    SELECT	Quantity_Sold, Profit;
END //
DELIMITER ;
	
CALL	GetProfit("P2", 2022);


# Task 8:
# Lucky Shrub need a summary of their client's details, including their addresses, order details and the products they purchased. 
# Help them out by creating a virtual table called DataSummary that joins together the four tables that contain this data. 
# These four tables are as follows:
#		Clients,
#		Addresses,
#		Orders,
#		Products.
# The virtual table must display the following data:
#		The full name and contact number for each client from the Clients table.
#		The county that each client lives in from the Addresses table.
#		The name of the product they purchased from the Products table.
#		The ProductID, cost and date of each order from the Orders table.
#		The virtual table should show relevant data for year 2022 only. Order the data by the cost of the highest order. 

CREATE VIEW Customer_Persona AS
		SELECT	c.Fullname, c.ContactNumber,
				a.County,
				p.ProductName,
				o.ProductID, o.Cost, o.Date
		  FROM	clients c	INNER JOIN	addresses a	ON c.AddressID = a.AddressID
							INNER JOIN	orders o	ON o.ClientID = c.ClientID
							INNER JOIN	products p	ON p.ProductID = o.ProductID
		 WHERE	YEAR(o.Date) = 2022
	  ORDER BY	o.Cost DESC;
    
SELECT * FROM Customer_Persona;

                        
                        
