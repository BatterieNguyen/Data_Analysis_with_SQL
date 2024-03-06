-- Profiling Data
-- 1. Distributions

-- 1.1. Histograms // Frequencies 
-- (GROUP BY)

-- 1.2. Binning 
-- Arbitrary-sized Bin (CASE WHEN)


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
