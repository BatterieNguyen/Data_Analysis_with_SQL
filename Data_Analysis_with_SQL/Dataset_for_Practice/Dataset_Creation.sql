USE practices;

/****************************************************************************************/
-- US RETAIL SALES DATASET

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

/*
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
*/

-- Import data from CSV file
BULK INSERT	us_retail_sales
FROM 'D:/0. Let''s Stress/DATA ANALYSIS/SQL/SQLServer/us_retail_sales.csv'
WITH (
  	  FORMAT = 'CSV',
      FIELDTERMINATOR = ',',
      ROWTERMINATOR = '0x0a',
      FIRSTROW = 2
      );

/****************************************************************************************/
-- LEGISLATORS DATASET
DROP TABLE IF EXISTS legislators;

-- Create table 
CREATE TABLE	legislators
	(
		full_name	VARCHAR(255),
		first_name	VARCHAR(255),
		last_name	VARCHAR(255),
		middle_name	VARCHAR(255),
		nick_name	VARCHAR(255),
		suffix		VARCHAR(255),
		other_names_end	DATE,
		other_names_middle	VARCHAR(255),
		other_names_last	VARCHAR(255),
		birthday	DATE,
		gender		VARCHAR(10),
		id_bioguide	VARCHAR(25)	PRIMARY KEY,
		id_bioguide_previous_0 VARCHAR(25),
		id_govtrack	INT,
		id_icpsr	INT,
		id_wikipedia	VARCHAR(255),
		id_wikidata VARCHAR(25),
		id_google_entity_id	VARCHAR(255),
		id_house_history	BIGINT,
		id_house_history_alternate INT,
		id_thomas	INT,
		id_cspan	INT,
		id_votesmart	INT,
		id_lis VARCHAR(255),
		id_ballotpedia	VARCHAR(255),
		id_opensecrets VARCHAR(255),
		id_fec_0	VARCHAR(255),
		id_fec_1	VARCHAR(255),
		id_fec_2	VARCHAR(255)
	);

/*
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
*/

-- Import data from local CSV file
BULK INSERT		legislators
FROM	'D:/0. Let''s Stress/DATA ANALYSIS/SQL/SQLServer/legislators.csv'
WITH	(
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			FIRSTROW = 2
		);

-- LEGISLATOR_TERMS DATASET
DROP TABLE IF EXISTS legislator_terms;

CREATE TABLE legislator_terms
	(
		id_bioguide varchar(25)
		,term_number int 
		,term_id varchar(25) primary key
		,term_type varchar(25)
		,term_start date
		,term_end date
		,state varchar(25)
		,district int
		,class int
		,party varchar(255)
		,how varchar(255)
		,url varchar(255)--terms_1_url
		,address varchar(255) --terms_1_address
		,phone varchar(25) --terms_1_phone
		,fax varchar(25) --terms_1_fax
		,contact_form varchar(255) --terms_1_contact_form
		,office varchar(255) --terms_1_office
		,state_rank varchar(25) --terms_1_state_rank
		,rss_url varchar(255) --terms_1_rss_url
		,caucus varchar(255) -- terms_1_caucus
	);

BULK INSERT legislator_terms
FROM	'D:/0. Let''s Stress/DATA ANALYSIS/SQL/SQLServer/legislators_terms.csv'
WITH	(
			FORMAT = 'CSV',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			FIRSTROW = 2
		);

