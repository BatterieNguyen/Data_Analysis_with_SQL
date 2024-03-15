USE practices;

/****************************************************************************************/
-- US RETAIL SALES DATASET


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

