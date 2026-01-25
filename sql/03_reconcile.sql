/* 03_reconcile.sql
   Goal: show why dashboards can disagree and how to debug it.

   Key idea:
   - Marketing often reports by when activity happened (rental_date).
   - Finance often reports by when money was recorded (payment_date).
   Same business, two timelines.
*/

-- 1) “Marketing-style revenue proxy” by rental month
-- Use payment amounts, but assign them to the month the rental happened.
-- This is not always how money is booked, but it matches “activity happened” thinking.
WITH marketing_view AS (
  SELECT
    DATE_TRUNC('month', r.rental_date)::date AS month,
    SUM(p.amount) AS revenue_assigned_to_rental_month
  FROM public.payment p
  JOIN public.rental r ON r.rental_id = p.rental_id
  GROUP BY 1
),

-- 2) “Finance-style revenue” by payment month
finance_view AS (
  SELECT
    DATE_TRUNC('month', p.payment_date)::date AS month,
    SUM(p.amount) AS revenue_by_payment_month
  FROM public.payment p
  GROUP BY 1
)

-- 3) Put them side by side and compute the gap
SELECT
  COALESCE(m.month, f.month) AS month,
  COALESCE(m.revenue_assigned_to_rental_month, 0) AS marketing_revenue,
  COALESCE(f.revenue_by_payment_month, 0) AS finance_revenue,
  COALESCE(m.revenue_assigned_to_rental_month, 0) - COALESCE(f.revenue_by_payment_month, 0) AS difference
FROM marketing_view m
FULL OUTER JOIN finance_view f
  ON f.month = m.month
ORDER BY month;

-- 4) Debug drill-down: show rentals that were paid in a different month than they were rented
SELECT
  r.rental_id,
  r.rental_date,
  p.payment_date,
  p.amount,
  (DATE_TRUNC('month', r.rental_date)::date) AS rental_month,
  (DATE_TRUNC('month', p.payment_date)::date) AS payment_month
FROM public.payment p
JOIN public.rental r ON r.rental_id = p.rental_id
WHERE DATE_TRUNC('month', r.rental_date) <> DATE_TRUNC('month', p.payment_date)
ORDER BY p.payment_date DESC
LIMIT 50;

