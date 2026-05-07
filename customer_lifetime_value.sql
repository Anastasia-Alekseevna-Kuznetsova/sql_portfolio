WITH customer_revenue AS (
    SELECT 
        client_id,
        SUM(amount) AS total_revenue,
        COUNT(DISTINCT transaction_id) AS tx_count,
        MAX(transaction_date) AS last_tx
    FROM transactions
    GROUP BY client_id
),
segments AS (
    SELECT 
        client_id,
        total_revenue,
        CASE 
            WHEN total_revenue > 50000 THEN 'Premium'
            WHEN total_revenue BETWEEN 10000 AND 50000 THEN 'Standard'
            ELSE 'Economy'
        END AS segment,
        tx_count,
        last_tx
    FROM customer_revenue
)
SELECT 
    segment,
    COUNT(client_id) AS clients,
    ROUND(AVG(total_revenue), 2) AS avg_ltv,
    ROUND(AVG(tx_count), 1) AS avg_transactions,
    ROUND(AVG(CURRENT_DATE - last_tx), 0) AS avg_days_since_last
FROM segments
GROUP BY segment
ORDER BY avg_ltv DESC;
