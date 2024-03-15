### IMPORT DATA FROM LOCAL_HOST
___Syntax___
```
DROP TABLE IF EXISTS us_retail_sales;

# create table
CREATE TABLE us_retail_sales	
      (
      	sales_month DATE,
      	naics_code VARCHAR(255),
      	kind_of_business VARCHAR(255),
      	reason_for_null VARCHAR(255),
      	sales DECIMAL (10, 2)
      );

/*
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
*/
-- import data from CSV file
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
### 2. SET UP CONSTRAINTS FOR COLUMNS
