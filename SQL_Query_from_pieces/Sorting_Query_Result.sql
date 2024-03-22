---- SORTING BY SUBSTRING

-- 1.1. Sort value by the last 2 characters in the job field
  -- DB2 | MySQL | Oracle | PostgreSQL
ORDER BY  SUBSTR(job, length(job) -1)

  -- SQL Server
ORDER BY  SUBSTRING(job, len(job) -1, 2)


-- 1.2. Sorting mixed alphanumeric data

CREATE VIEW V	AS
	SELECT CONCAT(ename, ' ', deptno) AS data
	FROM	emp;
	
	SELECT * FROM V;

