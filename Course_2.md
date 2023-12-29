-----------
# DATA WRANGLING, ANALYSIS, AND AB TESTING WITH SQL
-----------
## Week 1 - Data Unknown Quality
### 1. Error Codes
### 2. Flexible Data Formats
__Types of tables__

Event Table
- Receipt of real things that happened
- __Not__ edited or updated once created

Users Table
- Do not need to be stored in editable format
#### _Exercise_
__1. Write a query to format the view_item event into a table with the appropriate columns__

GOAL: figure out how to do it for multiple parameters
```
SELECT  event_id, event_time, user_id, platform,
        (CASE WHEN parameter_name = 'item_id'
              THEN CAST(parameter_value AS INT)
              ELSE NULL
          END) AS item_id
FROM    dsv1069.events
WHERE   event_name = 'view_user'
ORDER BY  event_id;
```
__2. __

GOAL: Add a column 'referrer' 
```
SELECT  event_id, event_time, user_id, platform,
        (CASE WHEN parameter_name = 'item_id'
              THEN CAST(parameter_value AS INT)
              ELSE NULL
          END) AS item_id,
        (CASE WHEN parameter_name = 'refferer'
              THEN parameter_value
              ELSE NULL
          END) AS referrer
FROM    dsv1069.events
WHERE   event_name = 'view_item'
ORDER BY  event_id;
```

__3. __

GOAL:
```
SELECT  event_id, event_time, user_id, platform,
        MAX(CASE WHEN parameter_name = 'item_id'
              THEN CAST(parameter_value AS INT)
              ELSE NULL
          END) AS item_id,
        MAX(CASE WHEN parameter_name = 'refferer'
              THEN parameter_value
              ELSE NULL
          END) AS referrer
FROM    dsv1069.events
WHERE   event_name = 'view_item'
GROUP BY  event_id, event_time, user_id, platform
ORDER BY  event_id;
```
### 3. Unreliable Data + Nulls
#### _Exercise_
__1. Using any methods to determine if the event table can be trusted__
```
SELECT  DATE(event_time) AS Date
        ,COUNT(*)        AS rows
FROM    dsv1069.events_201701
GROUP BY  DATE(event_time);
```
__2. Using any methods to determine if the event table can be trusted__

HINT: When did we start recording events on mobile. In this case, mobile logging has not been implemented until recently.
```
SELECT  DATE(event_time) AS Date
        , event_name
        , COUNT(*)        AS rows
FROM    dsv1069.events_ex2
GROUP BY  DATE(event_time), event_name;
```
__3. Imagine that yu need to count item views by day. You found this table item_views_by_category_temp. Should you use it to answer question?__

GOAL: Count item views by days by Category.
```
SELECT  SUM(view_events) AS event_count
FROM    dsv1069.item_view_by_Category_temp
```
``` 
SELECT  COUNT(DISTINCT event_id) AS event_count
FROM    dsv1069.events
WHERE   event_name = 'item_view'    
```
__=>__ The event count was 10 bigger than item views by category. => It is __not__ good to use that table.

__4. Using any methods to decide if this table is ready to be used as a source of truth.__

HINT: for web events, the user_id is null
```
SELECT  DATE(event_time) AS Date
        , COUNT(*)       AS rows
        , COUNT(event_id)  AS event_count
        , COUNT(user_id)  AS user_count
FROM     dsv1069.raw_events
GROUP BY DATE(event_time);
```
```
SELECT  DATE(event_time) AS Date
        , platform
        , COUNT(user_id)  AS user_count
FROM     dsv1069.raw_events
GROUP BY DATE(event_time);
```
__5. Is this the right way to join orders to users? Is this the right way this join.__

HINT: Use COALESCE on user_id 
```
SELECT  COUNT(*)
FROM    dsv1069.orders JOIN  dsv1069.users
                        ON  orders.user_id = COALESCE(users.parent_user_id, users.id)
```
### 4. Answering Ambiguous Questions
