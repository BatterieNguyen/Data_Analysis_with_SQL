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




