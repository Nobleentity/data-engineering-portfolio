-- Window function patterns and worked solutions (T-SQL / SQL Server)
-- Run 01_setup_week1practice.sql first.

-- ===== Part 1 — The mental model: windows vs GROUP BY =====
SELECT customer_id, SUM(amount) AS total
FROM orders WHERE status = 'completed' AND customer_id = 1
GROUP BY customer_id;

-- ===== Part 1 — The mental model: windows vs GROUP BY =====
SELECT order_id, amount,
       SUM(amount) OVER (PARTITION BY customer_id) AS customer_total
FROM orders WHERE status = 'completed' AND customer_id = 1;

-- ===== Part 2 — Anatomy of OVER() =====
FUNCTION(...) OVER (
  [PARTITION BY col1, col2, ...]
  [ORDER BY col ...]
  [frame clause]
)

-- ===== Part 3 — Ranking functions: ROW_NUMBER, RANK, DENSE_RANK, NTILE =====
SELECT c.name, SUM(o.amount) AS total,
       RANK() OVER (ORDER BY SUM(o.amount) DESC) AS rnk
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'completed'
GROUP BY c.name
ORDER BY rnk;

-- ===== Part 3 — Ranking functions: ROW_NUMBER, RANK, DENSE_RANK, NTILE =====
SELECT name, july_revenue,
       ROW_NUMBER() OVER (ORDER BY july_revenue DESC) AS rn,
       RANK()       OVER (ORDER BY july_revenue DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY july_revenue DESC) AS drnk
FROM (SELECT c.name, SUM(o.amount) AS july_revenue
      FROM customers c JOIN orders o ON o.customer_id = c.customer_id
      WHERE o.status = 'completed' AND strftime('%Y-%m', o.order_date) = '2024-07'
      GROUP BY c.name);

-- ===== Part 3 — Ranking functions: ROW_NUMBER, RANK, DENSE_RANK, NTILE =====
SELECT order_id, amount,
       NTILE(4) OVER (ORDER BY amount DESC) AS quartile
FROM orders WHERE status = 'completed';

-- ===== Part 4 — Aggregate windows: running totals and moving averages =====
SELECT o.order_id, c.name, o.order_date, o.amount,
       SUM(o.amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS running_total
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
ORDER BY c.name, o.order_date;

-- ===== Part 4 — Aggregate windows: running totals and moving averages =====
SELECT order_id, order_date, amount,
       ROUND(AVG(amount) OVER (
         ORDER BY order_date
         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 2) AS moving_avg_3
FROM orders WHERE status = 'completed'
ORDER BY order_date;

-- ===== Part 5 — Navigation: LAG, LEAD, FIRST_VALUE, LAST_VALUE =====
SELECT o.order_id, c.name, o.order_date, o.amount,
       LAG(o.amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS prev_amount,
       o.amount - LAG(o.amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS diff
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
ORDER BY c.name, o.order_date;

-- ===== Part 5 — Navigation: LAG, LEAD, FIRST_VALUE, LAST_VALUE =====
SELECT DISTINCT c.name,
       FIRST_VALUE(o.amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS first_order,
       LAST_VALUE(o.amount) OVER (
         PARTITION BY o.customer_id ORDER BY o.order_date
         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS last_order
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'completed';

-- ===== Pattern A — Top-N per group =====
SELECT name, order_id, amount FROM (
  SELECT c.name, o.order_id, o.amount,
         ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.amount DESC) AS rn
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
  WHERE o.status = 'completed'
)
WHERE rn <= 2
ORDER BY name, amount DESC;

-- ===== Pattern B — Period-over-period comparison =====
WITH monthly AS (
  SELECT strftime('%Y-%m', order_date) AS month, SUM(amount) AS revenue
  FROM orders WHERE status = 'completed'
  GROUP BY 1
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1) AS pct_change
FROM monthly ORDER BY month;

-- ===== Pattern C — Gaps and islands (consecutive periods) =====
SELECT DISTINCT customer_id, strftime('%Y-%m', order_date) AS month
FROM orders WHERE status = 'completed' ORDER BY 1, 2;

-- ===== Pattern C — Gaps and islands (consecutive periods) =====
WITH months AS (
  SELECT DISTINCT customer_id, strftime('%Y-%m', order_date) AS month
  FROM orders WHERE status = 'completed'
),
numbered AS (
  SELECT customer_id, month,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY month) AS rn,
         substr(month, 1, 4) * 12 + substr(month, 6, 2) AS month_num
  FROM months
)
SELECT customer_id, month, rn, month_num, month_num - rn AS island_id
FROM numbered ORDER BY customer_id, month;

-- ===== Pattern C — Gaps and islands (consecutive periods) =====
WITH months AS (
  SELECT DISTINCT customer_id, strftime('%Y-%m', order_date) AS month
  FROM orders WHERE status = 'completed'
),
numbered AS (
  SELECT customer_id, month,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY month) AS rn
  FROM months
),
islands AS (
  SELECT customer_id,
         substr(month, 1, 4) * 12 + substr(month, 6, 2) - rn AS island_id
  FROM numbered
)
SELECT c.name
FROM islands i
JOIN customers c ON c.customer_id = i.customer_id
GROUP BY c.name, island_id
HAVING COUNT(*) >= 3;

-- ===== Pattern D — Share of total =====
WITH monthly AS (
  SELECT strftime('%Y-%m', order_date) AS month, SUM(amount) AS revenue
  FROM orders WHERE status = 'completed'
  GROUP BY 1
)
SELECT month,
       SUM(revenue) OVER (ORDER BY month) AS cumulative,
       ROUND(100.0 * SUM(revenue) OVER (ORDER BY month) / SUM(SUM(revenue)) OVER (), 1)
         AS pct_of_year
FROM monthly
GROUP BY month
ORDER BY month;

-- ===== Pattern D — Share of total =====
WITH monthly AS (
  SELECT strftime('%Y-%m', order_date) AS month, SUM(amount) AS revenue
  FROM orders WHERE status = 'completed'
  GROUP BY 1
)
SELECT month,
       SUM(revenue) OVER (ORDER BY month) AS cumulative,
       ROUND(100.0 * SUM(revenue) OVER (ORDER BY month) / SUM(revenue) OVER (), 1) AS pct_of_year
FROM monthly ORDER BY month;

-- ===== Solution 1 — Rank customers by total spend =====
SELECT c.name, SUM(o.amount) AS total,
       RANK() OVER (ORDER BY SUM(o.amount) DESC) AS rnk
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'completed'
GROUP BY c.name
ORDER BY rnk;

-- ===== Solution 2 — Running total per customer =====
SELECT o.order_id, c.name, o.order_date, o.amount,
       SUM(o.amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS running_total
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
ORDER BY c.name, o.order_date;

-- ===== Solution 3 — Previous order amount and difference =====
SELECT o.order_id, c.name, o.order_date, o.amount,
       LAG(o.amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS prev_amount,
       o.amount - LAG(o.amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS diff
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
ORDER BY c.name, o.order_date;

-- ===== Solution 4 — Top 2 orders per customer =====
SELECT name, order_id, amount FROM (
  SELECT c.name, o.order_id, o.amount,
         ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.amount DESC) AS rn
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
  WHERE o.status = 'completed'
)
WHERE rn <= 2
ORDER BY name, amount DESC;

-- ===== Solution 5 — Monthly revenue with month-over-month change =====
WITH monthly AS (
  SELECT strftime('%Y-%m', order_date) AS month, SUM(amount) AS revenue
  FROM orders WHERE status = 'completed'
  GROUP BY 1
)
SELECT month, revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1) AS pct_change
FROM monthly ORDER BY month;

-- ===== Solution 6 — Latest order more than double the average =====
WITH stats AS (
  SELECT customer_id,
         AVG(amount) AS avg_amt,
         MAX(order_date) AS last_date
  FROM orders WHERE status = 'completed'
  GROUP BY customer_id
)
SELECT c.name
FROM stats s
JOIN customers c ON c.customer_id = s.customer_id
JOIN orders o ON o.customer_id = s.customer_id
             AND o.order_date = s.last_date
             AND o.status = 'completed'
WHERE o.amount > 2 * s.avg_amt;

-- ===== Solution 7 — 3+ consecutive months (gaps and islands) =====
WITH months AS (
  SELECT DISTINCT customer_id, strftime('%Y-%m', order_date) AS month
  FROM orders WHERE status = 'completed'
),
numbered AS (
  SELECT customer_id, month,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY month) AS rn
  FROM months
),
islands AS (
  SELECT customer_id,
         substr(month, 1, 4) * 12 + substr(month, 6, 2) - rn AS island_id
  FROM numbered
)
SELECT c.name
FROM islands i
JOIN customers c ON c.customer_id = i.customer_id
GROUP BY c.name, island_id
HAVING COUNT(*) >= 3;

-- ===== Solution 8 — Cumulative revenue as % of year total =====
WITH monthly AS (
  SELECT strftime('%Y-%m', order_date) AS month, SUM(amount) AS revenue
  FROM orders WHERE status = 'completed'
  GROUP BY 1
)
SELECT month,
       SUM(revenue) OVER (ORDER BY month) AS cumulative,
       ROUND(100.0 * SUM(revenue) OVER (ORDER BY month) / SUM(revenue) OVER (), 1) AS pct_of_year
FROM monthly ORDER BY month;

