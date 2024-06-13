-- TEST ASSIGNMENT

-- Exercise 1: Counting Tests

    -- Figure out how many tests we have running right now

SELECT    DISTINCT parameter_value AS test_id
FROM         dsv1069.events
WHERE        event_name = 'test_assignment' AND parameter_name = 'test_id';

-- Exercise 2: Sanity Check - Missing Data

    -- Check for potential problems with test assignments --> Make sure there is no data obviously missing

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

-- Exercise 3: Assignment Events Table

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
__Why?__
- Hypothesis is a question which you will answer with data.
- How to measure product success
- How to measure user behaviors you wish to affect

__What to measure__
| Feature Level Engagement | Did users interact with the product you altered in a new way? |
| -------- | ---------- | 
| Overall Engagement | Did the feature change alter the way the users interact overall ? |
| Business Metrics | How does the company make money? Did this change affect the business's costs or ability to collect revenue? |

__Exercise 1: Compute Order Binary__

__Whether a user created an order after their test assignment__

__Even if a user had zero orders, we should have a row that count their number of orders as zero. --> If the user is not in te experiment they should not be included__
```
SELECT
    test_events.test_id,
    test_events.test_assignment,
    test_events.user_id,
    MAX(CASE  WHEN  orders.created_at > test_events.event_time  THEN 1
              ELSE 0
              END) AS orders_after_assignment_binary
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
LEFT JOIN
    dsv1069.orders    ON orders.user_id = test_events.user_id
GROUP BY
    test_events.test_id,
    test_events.test_assignment,
    test_events.user_id;
```
__Exercise 2: Compute Mean Metrics__

__Add following metrics:__
1. The number of orders/ invoices
2. the number of items/ line-items ordered
3. The total revenue from the orders after treatment

```
SELECT
    test_events.test_id,
    test_events.test_assignment,
    test_events.user_id,
    COUNT(DISTINCT  (CASE   WHEN  orders.created_at > test_events.event_time  THEN invoice_id
                            ELSE NULL
                            END)) AS orders_after_assignment,
    COUNT(DISTINCT  (CASE   WHEN  orders.created_at > test_events.event_time  THEN lien_item_id
                            ELSE NULL
                            END)) AS items_after_assignment,
    SUM(CASE  WHEN  orders.created_at > test_events.event_time  THEN price
              ELSE 0
              END) AS total_evenue
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
LEFT JOIN
    dsv1069.orders    ON orders.user_id = test_events.user_id
GROUP BY
    test_events.test_id,
    test_events.test_assignment,
    test_events.user_id;
```
# ANALYZING RESULTS
__Metric Types__
| __Proportion Metrics__ | | 
| ------ | ------- |
| Example | Order Binary |
| Answers | How many users made an order? |
| Values | 1 // 0 |
| Average Value | In [0, 1] |
| Can Answer | Did the variant cause more users to place an order |

| __Mean Metrics__ | | 
| ------ | ------- |
| Example | Number of Orders |
| Answers | How many orders did a user made? |
| Values | Non-negative integer |
| Average Value | In [0, infinity] |
| Can Answer | Did the variant cause more users to create more orders |

__Exercise 1: Proportion Metrics__

__For the proportion metric order binary compute the following:__
- The count of users per treatment for test_id = 7
- The count of users with orders per treatment group
```
SELECT
    test_assignment,
    COUNT(user_id)        AS users,
    SUM(order_binary)    AS orders_completed
FROM
    (SELECT
        assignments.user_id,
        assignments.test_id,
        assignments.test_assignment,
        MAX(    CASE WHEN orders.created_at > assignments.event_time
                    THEN 1
                    ELSE 0
                    END) AS order_binary
    FROM
        (SELECT
                event_id, event_time, user_id, platform
         FROM
                dsv1069.events
     WHERE
            event_name = 'test_assignment'
        GROUP BY
            event_id, event_time, user_id, platform
        ORDER BY
            event_id
        ) assignments
    LEFT OUTER JOIN
        dsv1069.orders    ON assignments.user_id = orders.user_id
    GROUP BY
        assignments.test_id,
        assignments.test_assignment,
        assignments.user_id
    ) order_binary
WHERE
    test_id = 7
GROUP BY
    test_assignment;        
```
__Exercise 2: Proportion Metric__

__Create an item view binary metric for the proportion metric item_view compute the following:__
- The count of users with orders per treatment group
- The count of users with item-views per treatment group
```
SELECT
    test_assignment,
    COUNT(user_id)        AS users,
    SUM(views_binary)    AS views_binary
FROM
    (SELECT
        assignments.user_id,
        assignments.test_id,
        assignments.test_assignment,
        MAX(    CASE WHEN views.event_time > assignments.event_time
                    THEN 1
                    ELSE 0
                    END) AS views_binary
    FROM
        (SELECT
                event_id, event_time, user_id, platform
         FROM
                dsv1069.events
     WHERE
            event_name = 'test_assignment'
        GROUP BY
            event_id, event_time, user_id, platform
        ORDER BY
            event_id
        ) assignments
    LEFT OUTER JOIN
        (SELECT *
         FROM dsv069.events
         WHERE event_name = 'view_item'
        )    views
    ON assignments.user_id = views.user_id
    GROUP BY
        assignments.test_id,
        assignments.test_assignment,
        assignments.user_id
    ) order_binary
WHERE
    test_id = 7
GROUP BY
    test_assignment;        
```
__Exercise 3: Time Capped Binary Metrics__
- Use the previous part of this assignment with an item view binary metric
- Alter the metric to compute the users who viewed an item WITHIN 30 days of their treatment event
```
SELECT
    test_assignment,
    COUNT(user_id)           AS users,
    SUM(views_binary)        AS views_binary,
    SUM(views_binary_30d)    AS views_binary_30d
FROM
    (SELECT
        assignments.user_id,
        assignments.test_id,
        assignments.test_assignment,
        MAX(    CASE WHEN views.event_time > assignments.event_time
                    THEN 1
                    ELSE 0
                    END) AS views_binary
        MAX(    CASE WHEN views.event_time > assignments.event_time
                        AND    DATE_PART('day', view.event_time - assignment.event_time) <= 30)
                        THEN 1
                        ELSE 0
                    END) AS views_binary_30d
    FROM
        (SELECT
                event_id, event_time, user_id, platform
         FROM
                dsv1069.events
     WHERE
            event_name = 'test_assignment'
        GROUP BY
            event_id, event_time, user_id, platform
        ORDER BY
            event_id
        ) assignments
    LEFT OUTER JOIN
        (SELECT *
         FROM dsv069.events
         WHERE event_name = 'view_item'
        )    views
    ON assignments.user_id = views.user_id
    GROUP BY
        assignments.test_id,
        assignments.test_assignment,
        assignments.user_id
    ) order_binary
WHERE
    test_id = 7
GROUP BY
    test_assignment;  
```
__Exercise 4: Mean Value Metrics__

__For the mean value metrics invoices, line items, and total revenue compute the following:
- The count of users per treatment group
- The average value of the metric per treatment group
- The standard deviation of the metric per treatment group
```
SELECT
    test_id,
    test_assignment,
    COUNT(user_id) AS users,
    AVG(invoices) AS avg_invoices,
    STDDEV(invoices) AS stddev_invoices
FROM
    (SELECT
        assignments.user_id,
        assignments.test_id,
        assignments.test_assignment,
        COUNT(DISTINCT CASE
                        WHEN orders.created_at > assignments.event_time THEN orders.invoice_id
                        ELSE NULL
                        END) AS invoices,
        COUNT(DISTINCT CASE
                        WHEN orders.created_at > assignments.event_time THEN orders.line_item_id
                        ELSE NULL
                        END) AS line_items,
        COALESCE(SUM(CASE
                        WHEN orders.created_at > assignments.event_time THEN orders.price
                        ELSE 0
                        END), 0) AS total_revenue
    FROM
        (SELECT
            event_id, event_time, user_id,
            MAX(CASE
                    WHEN parameter_name = 'test_id' THEN CAST(parameter_value AS INT)
                    ELSE NULL
                    END) AS test_id,
            MAX(CASE
                    WHEN parameter_name = 'test_assignment' THEN CAST(parameter_value AS INT)
                    ELSE NULL
                    END) AS test_assignment

          FROM
            dsv1069.events
          GROUP BY
            event_id, event_time, user_id
          ORDER BY
            event_id
        ) assignments
        LEFT OUTER JOIN
            dsv1069.orders    ON assignments.user_id = orders.user_id
        GROUP BY
            assignments.user_id,
            assignments.test_id,
            assignments.test_assignment
        ) mean_metrics
GROUP BY
        test_id,
        test_assignment
ORDER BY
        test_id;
```
# Final Project

__Assignment Tasks__

We are running an experiment at an item-level, which means all users who visit will see the same page, but the layout of different item pages may differ. Please follow the steps below and good luck!

1. Compare the final_assignments_qa table to the assignment events we captured for user_level_testing. Write an answer to the following question: Does this table have everything you need to compute metrics like 30-day view-binary?

___=> Answer is No because the created_at column is missing.___

2. Write a query and table creation statement to make final_assignments_qa look like the final_assignments table. If you discovered something missing in part 1, you may fill in the value with a place holder of the appropriate data type.

___=>___ 
```
SELECT  item_id,
        test_a  AS test_assignment,
        (CASE
              WHEN test_a  IS NOT NULL  THEN 'test_a'
              ELSE NULL
              END)  AS test_number,
        (CASE
              WHEN test_a  IS NOT NULL  THEN '2013-01-05 00:00:00'
              ELSE NULL
              END)  AS test_start_date
FROM    dsv1069.final_assignments_qa
UNION
SELECT  item_id,
        test_b  AS test_assignment,
        (CASE
              WHEN test_b  IS NOT NULL  THEN 'test_b'
              ELSE NULL
              END)  AS test_number,
        (CASE
              WHEN test_b  IS NOT NULL  THEN '2013-01-05 00:00:00'
              ELSE NULL
              END)  AS test_start_date
FROM    dsv1069.final_assignments_qa
UNION
SELECT  item_id,
        test_c  AS test_assignment,
        (CASE
              WHEN test_c  IS NOT NULL  THEN 'test_c'
              ELSE NULL
              END)  AS test_number,
        (CASE
              WHEN test_c  IS NOT NULL  THEN '2013-01-05 00:00:00'
              ELSE NULL
              END)  AS test_start_date
FROM    dsv1069.final_assignments_qa
UNION
SELECT  item_id,
        test_d  AS test_assignment,
        (CASE
              WHEN test_d  IS NOT NULL  THEN 'test_d'
              ELSE NULL
              END)  AS test_number,
        (CASE
              WHEN test_d  IS NOT NULL  THEN '2013-01-05 00:00:00'
              ELSE NULL
              END)  AS test_start_date
FROM    dsv1069.final_assignments_qa
UNION
SELECT  item_id,
        test_e  AS test_assignment,
        (CASE
              WHEN test_e  IS NOT NULL  THEN 'test_e'
              ELSE NULL
              END)  AS test_number,
        (CASE
              WHEN test_e  IS NOT NULL  THEN '2013-01-05 00:00:00'
              ELSE NULL
              END)  AS test_start_date
FROM    dsv1069.final_assignments_qa
SELECT  item_id,
        test_f  AS test_assignment,
        (CASE
              WHEN test_f  IS NOT NULL  THEN 'test_f'
              ELSE NULL
              END)  AS test_number,
        (CASE
              WHEN test_f  IS NOT NULL  THEN '2013-01-05 00:00:00'
              ELSE NULL
              END)  AS test_start_date
FROM    dsv1069.final_assignments_qa;                 
```
3. Use the final_assignments table to calculate the order binary for the 30 day window after the test assignment for item_test_2 (You may include the day the test started)

__=>__
```
SELECT  test_assignment,
        COUNT(DISTINCT item_id)  AS number_of_items,
        SUM(order_binary)        AS items_ordered_30d
FROM
        (SELECT  item_test_2.item_id,
                 item_test_2.test_assignment,
                  item_test_2.test_number,
                 item_test_2.test_start_date,
                 item_test_2.created_at
                 MAX(CASE
                          WHEN (created_at > test_start_date
                                  AND DATE_PART('day', created_at - test_start_date) <= 30) 
                          THEN 1 ELSE 0
                          END)  AS order_binary                
       FROM
            (SELECT final_assignments.*,
                    DATE(orders.created_at)  AS created_at
              FROM  dsv1069.final_assignments AS final_assignments
              LEFT JOIN  dsv1069.orders  AS orders  ON final_assignments.item_id = orders.item_id
              WHERE  test_number = 'item_test_2'
            )  AS item_test_2
        GROUP BY item_test_2.item_id,
                 item_test_2.test_assignment,
                 item_test_2.test_number,
                 item_test_2.test_start_date,
                 item_test_2.created_at
        )  AS order_binary
GROUP BY test_assignment;
```

4. Use the final_assignments table to calculate the view binary, and average views for the 30 day window after the test assignment for item_test_2. (You may include the day the test started)

___=>___
```
SELECT item_test_2.item_id,
       item_test_2.test_assignment,
       item_test_2.test_number,
       MAX(CASE
               WHEN (view_date > test_start_date
                     AND DATE_PART('day', view_date - test_start_date) <= 30) THEN 1
               ELSE 0
           END) AS view_binary
FROM
  (SELECT final_assignments.*,
          DATE(events.event_time) AS view_date
   FROM dsv1069.final_assignments AS final_assignments
   LEFT JOIN
       (SELECT event_time,
               CASE
                   WHEN parameter_name = 'item_id' THEN CAST(parameter_value AS NUMERIC)
                   ELSE NULL
               END AS item_id
      FROM dsv1069.events
      WHERE event_name = 'view_item') AS events
     ON final_assignments.item_id = events.item_id
   WHERE test_number = 'item_test_2') AS item_test_2
GROUP BY item_test_2.item_id,
         item_test_2.test_assignment,
         item_test_2.test_number
LIMIT 100;
```
5. Use the [abba A/B Testing](https://thumbtack.github.io/abba/demo/abba.html) to compute the lifts in metrics and the p-values for the binary metrics ( 30 day order binary and 30 day view binary) using a interval 95% confidence.

___=>___
```
SELECT test_assignment,
       test_number,
       COUNT(DISTINCT item) AS number_of_items,
       SUM(view_binary_30d) AS view_binary_30d
FROM
  (SELECT final_assignments.item_id AS item,
          test_assignment,
          test_number,
          test_start_date,
          MAX((CASE
                   WHEN date(event_time) - date(test_start_date) BETWEEN 0 AND 30 THEN 1
                   ELSE 0
               END)) AS view_binary_30d
   FROM dsv1069.final_assignments
   LEFT JOIN dsv1069.view_item_events
     ON final_assignments.item_id = view_item_events.item_id
   WHERE test_number = 'item_test_2'
   GROUP BY final_assignments.item_id,
            test_assignment,
            test_number,
            test_start_date) AS view_binary
GROUP BY test_assignment,
         test_number,
         test_start_date;
```        

6. Use Mode’s Report builder feature to write up the test. Your write-up should include a title, a graph for each of the two binary metrics you’ve calculated. The lift and p-value (from the AB test calculator) for each of the two metrics, and a complete sentence to interpret the significance of each of the results.

___=>___
- View Binary: We can say with 95% confidence that the lift value is 2% and the p_value is 0.2. There is not a significant difference in the number of views within 30days of the assigned treatment date between the two treatments.
- Order binary: There is no detectable change in this metric. The p-value is 0.86 meaning that there is a no significant difference in the number of orders within 30days of the assigned treatment date between      the two treatments.
