-- Profiling Data
-- 1. Distributions

-- 1.1. Histograms // Frequencies 
-- (GROUP BY)

-- 1.2. Binning 
-- Arbitrary-sized Bin (CASE WHEN)
WITH total AS (
	SELECT	order_id,
			SUM(quantity) AS total_demand,
			CASE
				WHEN SUM(list_price) <= 2000 THEN '0 - 2000'
				WHEN SUM(list_price) <= 4000 THEN '2000 - 4000'
				WHEN SUM(list_price) <= 6000 THEN '4000 - 6000'
				WHEN SUM(list_price) <= 8000 THEN '6000 - 8000'
				WHEN SUM(list_price) <= 10000 THEN '8000 - 10000'	
				ELSE 'More than 10000' END AS payment_range
	FROM	sales.order_items
	GROUP BY order_id
	)
SELECT	payment_range,
		COUNT(order_id) AS num_of_orders 
FROM	total
GROUP BY payment_range
ORDER BY payment_range ASC;

-- Fixed Size
-- ROUND()

-- LOG()

-- NTILE(num_of_bins) OVER (PARTITION BY field_name  ORDER BY  field_name)
SELECT	bins,
		MIN(order_amount) AS lower_bound,
		MAX(order_amount) AS upper_bound,
		COUNT(order_id)	AS num_of_orders
FROM	(
		SELECT	ord.customer_id, ord.order_id,
				SUM(ite.list_price) AS order_amount,
				NTILE(10) OVER (ORDER BY SUM(ite.list_price)) AS bins
		FROM	sales.orders ord
				INNER JOIN	sales.order_items ite ON ord.order_id = ite.order_id
		GROUP BY ord.customer_id, ord.order_id) bin_range
GROUP BY bins 
ORDER BY 1;

-- PERCENT_TANK() OVER (PARTITION BY field_name ORDER BY field_name) 
