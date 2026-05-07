WITH transactions_enriched AS (
    SELECT 
        client_id,
        transaction_date,
        amount,
        type,
        CASE 
            WHEN type = 'deposit' THEN amount
            WHEN type = 'withdrawal' THEN -amount
        END AS net_change
    FROM client_transactions
    WHERE transaction_date >= CURRENT_DATE - INTERVAL '90 days'
),
daily_balance AS (
    SELECT 
        client_id,
        transaction_date,
        net_change,
        SUM(net_change) OVER (PARTITION BY client_id ORDER BY transaction_date 
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
    FROM transactions_enriched
)
SELECT 
    client_id,
    transaction_date,
    net_change,
    running_balance,
    LAG(running_balance, 1, 0) OVER (PARTITION BY client_id ORDER BY transaction_date) AS prev_day_balance,
    running_balance - LAG(running_balance, 1, 0) OVER (PARTITION BY client_id ORDER BY transaction_date) AS daily_delta
FROM daily_balance
ORDER BY client_id, transaction_date DESC
LIMIT 1000;
