WITH monthly_margin AS (
    SELECT 
        p.product_name,
        DATE_TRUNC('month', s.sale_date) AS month,
        SUM(s.revenue) AS revenue,
        SUM(s.cost) AS cost,
        SUM(s.revenue - s.cost) AS margin
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    GROUP BY p.product_name, DATE_TRUNC('month', s.sale_date)
)
SELECT 
    product_name,
    month,
    margin,
    ROUND(100.0 * margin / revenue, 2) AS margin_pct,
    LAG(margin, 1) OVER (PARTITION BY product_name ORDER BY month) AS prev_margin,
    ROUND(100.0 * (margin - LAG(margin, 1) OVER (PARTITION BY product_name ORDER BY month)) / 
          LAG(margin, 1) OVER (PARTITION BY product_name ORDER BY month), 2) AS margin_change_pct
FROM monthly_margin
ORDER BY product_name, month;
