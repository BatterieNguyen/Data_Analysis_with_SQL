-- SQL Server 

DROP table if exists date_dim;

CREATE TABLE date_dim
(
    [date] DATE,
    date_key INT,
    day_of_month INT,
    day_of_year INT,
    day_of_week INT,
    day_name VARCHAR(20),
    day_short_name VARCHAR(3),
    week_number INT,
    week_of_month INT,
    [week] DATE,
    month_number INT,
    month_name VARCHAR(20),
    month_short_name VARCHAR(3),
    first_day_of_month DATE,
    last_day_of_month DATE,
    quarter_number INT,
    quarter_name VARCHAR(3),
    first_day_of_quarter DATE,
    last_day_of_quarter DATE,
    [year] INT,
    decade INT,
    century INT
);

DECLARE @startDate DATE = '1770-01-01';
DECLARE @endDate DATE = '2030-12-31';

WHILE @startDate <= @endDate
BEGIN
    INSERT INTO date_dim
    SELECT
        @startDate AS [date],
        CONVERT(INT, CONVERT(VARCHAR(8), @startDate, 112)) AS date_key,
        DATEPART(DAY, @startDate) AS day_of_month,
        DATEPART(DAYOFYEAR, @startDate) AS day_of_year,
        DATEPART(WEEKDAY, @startDate) AS day_of_week,
        DATENAME(WEEKDAY, @startDate) AS day_name,
        LEFT(DATENAME(WEEKDAY, @startDate), 3) AS day_short_name,
        DATEPART(WEEK, @startDate) AS week_number,
        DATEPART(WEEK, @startDate) - DATEPART(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, @startDate), 0)) + 1 AS week_of_month,
        DATEADD(DAY, -DATEPART(WEEKDAY, @startDate) + 1, @startDate) AS [week],
        DATEPART(MONTH, @startDate) AS month_number,
        DATENAME(MONTH, @startDate) AS month_name,
        LEFT(DATENAME(MONTH, @startDate), 3) AS month_short_name,
        DATEADD(MONTH, DATEDIFF(MONTH, 0, @startDate), 0) AS first_day_of_month,
        DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @startDate) + 1, 0)) AS last_day_of_month,
        DATEPART(QUARTER, @startDate) AS quarter_number,
        'Q' + CONVERT(VARCHAR(1), DATEPART(QUARTER, @startDate)) AS quarter_name,
        DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @startDate), 0) AS first_day_of_quarter,
        DATEADD(DAY, -1, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @startDate) + 1, 0)) AS last_day_of_quarter,
        DATEPART(YEAR, @startDate) AS [year],
        (DATEPART(YEAR, @startDate) / 10) * 10 AS decade,
        (DATEPART(YEAR, @startDate) / 100) + 1 AS century;

    SET @startDate = DATEADD(DAY, 1, @startDate);
END;
