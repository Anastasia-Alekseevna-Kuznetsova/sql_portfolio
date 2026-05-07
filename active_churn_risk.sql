WITH last_payment_date AS (
    SELECT 
        client_id,
        MAX(payment_date) AS last_payment
    FROM payments
    GROUP BY client_id
),
payment_history AS (
    SELECT 
        client_id,
        payment_date,
        LAG(payment_date) OVER (PARTITION BY client_id ORDER BY payment_date) AS prev_payment
    FROM payments
),
avg_gap AS (
    SELECT 
        client_id,
        AVG(payment_date - prev_payment) AS avg_days_between_payments
    FROM payment_history
    WHERE prev_payment IS NOT NULL
    GROUP BY client_id
)
SELECT 
    lp.client_id,
    lp.last_payment,
    CURRENT_DATE - lp.last_payment AS days_since_last,
    ag.avg_days_between_payments,
    CASE 
        WHEN CURRENT_DATE - lp.last_payment > 2 * COALESCE(ag.avg_days_between_payments, 30) THEN 'High risk'
        WHEN CURRENT_DATE - lp.last_payment > COALESCE(ag.avg_days_between_payments, 15) THEN 'Medium risk'
        ELSE 'Active'
    END AS churn_risk
FROM last_payment_date lp
LEFT JOIN avg_gap ag ON lp.client_id = ag.client_id
WHERE CURRENT_DATE - lp.last_payment > 15
ORDER BY days_since_last DESC;
