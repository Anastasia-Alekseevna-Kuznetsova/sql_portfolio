WITH revenue_analysis AS (
	SELECT 
		product_name,
		transaction_date,
        amount,
        AVG(amount) OVER (PARTITION BY product_name) as avg_amount_by_product,
        SUM(amount) OVER (PARTITION BY product_name) as total_revenue_by_product
	FROM transactions
)
SELECT * FROM revenue_analysis;

SELECT 
    p.product_name,
    SUM(t.amount) as total_revenue,
    LAG(SUM(t.amount), 1, 0) OVER (ORDER BY MIN(t.transaction_date)) as prev_revenue,
    ROUND(((SUM(t.amount) - LAG(SUM(t.amount), 1, 0) OVER (ORDER BY MIN(t.transaction_date))) / 
           LAG(SUM(t.amount), 1, 0) OVER (ORDER BY MIN(t.transaction_date))) * 100, 2) as revenue_growth_pct
FROM transactions t
JOIN products p ON t.product_id = p.product_id
WHERE t.transaction_date >= '2025-01-01'
GROUP BY p.product_name
ORDER BY revenue_growth_pct DESC
LIMIT 3;
