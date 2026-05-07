WITH first_payment AS (
    SELECT 
        client_id,
        DATE_TRUNC('month', MIN(payment_date)) AS cohort_month
    FROM payments
    GROUP BY client_id
),
cohort_size AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT client_id) AS total_clients
    FROM first_payment
    GROUP BY cohort_month
),
retention AS (
    SELECT 
        fp.cohort_month,
        DATE_TRUNC('month', p.payment_date) AS activity_month,
        COUNT(DISTINCT p.client_id) AS active_clients
    FROM first_payment fp
    JOIN payments p ON fp.client_id = p.client_id
    GROUP BY fp.cohort_month, activity_month
)
SELECT 
    r.cohort_month,
    EXTRACT(MONTH FROM age(r.activity_month, r.cohort_month)) AS month_number,
    r.active_clients,
    cs.total_clients,
    ROUND(100.0 * r.active_clients / cs.total_clients, 2) AS retention_rate
FROM retention r
JOIN cohort_size cs ON r.cohort_month = cs.cohort_month
ORDER BY r.cohort_month, month_number;
