
## SORTING

### Sorting by Substrings
sort value by the last 2 characters in the job field
DB2 | MySQL | Oracle | PostgreSQL
```
ORDER BY  SUBSTR(job, length(job) -1)
```
SQL Server
```
ORDER BY  SUBSTRING(job, len(job) -1, 2)
```

Sorting mixed alphanumeric data
