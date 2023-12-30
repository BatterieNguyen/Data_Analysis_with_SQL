-----------
# DATA WRANGLING, ANALYSIS, AND AB TESTING WITH SQL
-----------
## Module 1 - Data Unknown Quality
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
Define metrics => An __AB Test__ can help to determine if the change is an improvement
#### _Exercise: Counting Users_
__1. Using the users table to answer the question "How many new users are added each day?__
```
SELECT DATE(created_at)  AS Day
        , COUNT(*) AS Users
FROM    dsv1069.users
GROUP BY Day
ORDER BY Day ASC;
```
__2. Without worrying about deleted user or merged users, count the number of users added each day__
```
SELECT DATE(created_at)  AS Day
        , COUNT(id) AS Users
FROM    dsv1069.users
GROUP BY Day
ORDER BY Day ASC;
```
__3. Considering the following uery. Is this the right way to count merged or deleted users? If all of our users were deleted tomorrow what would the result look like?__
```
SELECT DATE(created_at)  AS Day
        , COUNT(*) AS Users
FROM    dsv1069.users
WHERE   deleted_at IS NULL
        AND (id <> parent_user_id OR parent_user_id IS NULL)
GROUP BY Day
ORDER BY Day ASC;
```
__4. Count the number of users deleted each day. Then count the number of users removed due to merging in a mimilar way.__
```
SELECT DATE(created_at)  AS Day
        , COUNT(*) AS Users
FROM    dsv1069.users
WHERE   deleted_at IS NOT NULL
GROUP BY Day
ORDER BY Day ASC;
```
__5. Use the pieces buil as subtables and create a table that has a column for the date, the number of users created, the number of users deleted and the number of users merged that day.__
```
SELECT  new.Day
        , new.new_added_users
        , COALESCE(deleted.deleted_users, 0) AS deleted_users
        , COALESCE(merged.merged_users, 0) AS merged_users
        , (new.new_added_users - COALESCE(deleted.deleted_users, 0) - COALESCE(merged.merged_users, 0))
                AS net_added_users
FROM
(        SELECT DATE(created_at) AS Day
                , COUNT(*) AS new_added_users
        FROM    dsv1069.users
        GROUP BY Day) new
LEFT JOIN
(        SELECT DATE(deleted_at) AS Day
                , COUNT(*) AS deleted_users
        FROM   dsv1069.users
        WHERE  deleted_at IS NOT NULL
        GROUP BY Day) deleted
ON        deleted.Day = new.Day
LEFT JOIN
(        SELECT DATE(mergedd_at) AS Day
                , COUNT(*) AS merged_users
        FROM   dsv1069.users
        WHERE  (id <> parent_user_id AND parent_user_id IS NOT NULL)
        GROUP BY Day) merged
ON merged.Day = new.Day
```
__6. Refine your query from #5 to have informative column names and so that null columns return 0.__

DONE.

__7. What if there were days where no users were created, but some users were deleted or merged. Doe the previous query still work? NO, it does not. Use the dates_rollup as a backbon for this query, so that we will not miss any dates.__

DONE.

-----------
## Module 2 - Creating Clean Datasets
### 1. Data Type

### 2. Dependency
__Dependency__: When the data in query refers to data in a preceding table.

__Stale__: WHen the data in a table does not reflect the most up-to-date information.

__Pipeline__: Events --> viewed_item events table --> Most Recently Viewed Item.

__Extract-Transform-Load (ETL)__: Used to describe the steps happening during table creation.

__Job__: The task given to a database to perform ETL.

__Backfill__: To run a table creation/ update task on a range of dates in the past.

### 3. View-item Table
__Filtering and Cleaning__
- Remove events generated while testing internally
- Trim long-tail categorical data
- Replace nulls with appropriate values

__The purpose of creating table__
- Cleanliness - Will make it easier to read future queries
- Efficiency - Computing once; result the results
- Standardiation - Counting the same way

__Dependencies__
- Upstream Metric
  - Need to be fresh __before__ recomputing view_item_events
  - Users Table, Orders Table
- Downstream Metric
  - Need to be fresh __after__ recomputing view_item_events
  - Tables we have not built yet: AB Testing metrics, or a most recently viewed items table
  - Dashboard tables, Prediction scores computed using these features

__Note__: 
- Different to creating a table, creating a view table does __not__ require to specify the __data type__.

#### _Syntax_
__Create a viewed table__
```
CREATE TABLE view_item_events_1
AS
        SELECT {columns}
        FROM {table};
```
__Check datatype and Null of table__
```
DESCRIBE view_item_events_1;
```
__Replace into table__
```
REPLACE INTO view_item_events
```
### 4. Hierachy of Data
__The Hierachy of needs__
| __From Bottom to Top__ | Description |
| ----------- | ------------ |
| __Collect__ | Intrusmentation, Logging, Sensors, External Data, User Generated Content |
| __Move/ Store__ | Reliable Data Flow, Infrastructure, Piplines, ETL, Structured and Unstructured Data Storage |
| __Explore/ Transform__ | Cleaning, Anomaly etection, Prep |
| __Aggregate/ Label Data__ | Analytics, Metrics, Segments, Aggregates, Features, Training Data |
| __Learn/ Optimize__ | A/B Testing, Experimentation, Simple ML Agorithms |
| | AI, DEEP LEARNING |

### 5. User Snapshot Table

### 6. Partitions in Hive
__Hadoop__
- is a whole ecosystem of tools that work with a distributed file system (HDFS).
- If data is big, you can store it across multiple servers: clusters.
- Hadoop helps nodes communicate with each other.

__Hive__
- Takes a SQL-like code (HQL) and turns it into a mapreduce job that can run on HDFS.

__Partitions__
- Feature of Hadoop => think of it like a pre-sorting into folders
- Not change the way you query the table.
- make updates // retrieval // joins faster.
-----------
## Module 3 - SQL Problem Solving
__A strategy for tackling any complicated query__

Figure out potential questions --> Identify what end table looks like --> Identify tables need to be built --> Build subqueries (build viewd-item events and put it in own tables) --> Test Joins --> Give columns distinct names --> 
-----------
## Module 4 - Case Study: AB Testing

