# SQL Server Window Functions — Patterns & Solutions

A deep-dive practice set in **T-SQL (SQL Server / SSMS)** covering the window-function patterns that come up constantly in data engineering and analytics work — and in interviews.

## What's inside
- `sql/01_setup_week1practice.sql` — run once: creates the `Week1Practice` database and sample sales data
- `sql/02_window_function_patterns_and_solutions.sql` — patterns with fully worked solutions:
  - Ranking: `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`
  - Aggregate windows: running totals, moving averages
  - Navigation: `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE`
  - Top-N per group
  - Period-over-period comparison (month-over-month change)
  - **Gaps and islands** — finding 3+ consecutive active months per customer
  - Share of total with cumulative percentages

## How to run
1. Open SSMS, connect to `(localdb)\MSSQLLocalDB` or `localhost\SQLEXPRESS`
2. Run `01_setup_week1practice.sql` (F5)
3. Work through `02_...sql` block by block

## Verified results (from the practice dataset)
- July revenue: 675 · Full-year revenue: 1,835 · Average monthly revenue: 611.67
