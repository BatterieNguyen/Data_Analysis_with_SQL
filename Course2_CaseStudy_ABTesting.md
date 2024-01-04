# TEST ASSIGNMENT

__Exercise 1: Counting Tests__

__Figure out how many tests we have running right now__
```
SELECT
    DISTINCT parameter_value AS test_id
FROM
    dsv1069.events
WHERE
    event_name = 'test_assignment' AND parameter_name = 'test_id';
```
__Exercise 2: Sanity Check - Missing Data__

__Check for potential problems with test assignments --> Make sure there is no data obviously missing__
```
SELECT 
    parameter_value    AS test_id,
    DATE(event_time)   AS day,
    COUNT(*)		   AS event_rows
FROM
    dsv1069.events
WHERE
    event_name = 'test_assignment'    AND parameter_name = 'test_id'
GROUP BY
    parameter_value, DATE(event_time);
```
__Exercise 3: Assignment Events Table__

__Write a query returns a table of assignment and dates for each test__
```
SELECT
    event_id, event_time, user_id, platform,
    MAX(CASE
        WHEN parameter_name = 'test_id' THEN CAST(parameter_value AS INT)
        ELSE NULL
        END) AS test_id,
    MAX(CASE
        WHEN parameter_name = 'test_assignment' THEN parameter_value
        ELSE NULL
        END) AS test_assignment
FROM
    dsv1069.events
WHERE
    event_name = 'test_assignment'
GROUP BY
    event_id, event_time, user_id, platform
ORDER BY
    event_id;
```

__Exercise 4: Santity Check Assignments__

__Check for potential assignmewnt problems with test_id 5 --> Make sure users are assigned only treatment group__
```
SELECT
    test_id, user_id,
    COUNT(DISTINCT test_assignment) AS assignments

FROM
    (SELECT
        event_id, event_time, user_id, platform,
        MAX(CASE
            WHEN parameter_name = 'test_id' THEN CAST(parameter_value AS INT)
            ELSE NULL
            END) AS test_id,
        MAX(CASE
            WHEN parameter_name = 'test_assignment' THEN parameter_value
            ELSE NULL
            END) AS test_assignment
    FROM
        dsv1069.events
    WHERE
        event_name = 'test_assignment'
    GROUP BY
        event_id, event_time, user_id, platform
    ORDER BY
        event_id
    ) test_events
GROUP BY
    test_id, user_id
ORDER BY
    assignments DESC;
```
# CREATE A NEW METRIC

# ANALYZING RESULTS
