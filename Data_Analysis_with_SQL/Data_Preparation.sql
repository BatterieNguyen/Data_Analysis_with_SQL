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
SELECT	ord.customer_id, ord.order_id,
		NTILE(10) OVER (ORDER BY SUM(ite.list_price)) AS bins
FROM	sales.orders ord
		INNER JOIN	sales.order_items ite ON ord.order_id = ite.order_id
GROUP BY ord.customer_id, ord.order_id
ORDER BY 1;
