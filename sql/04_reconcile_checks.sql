/* 04_reconcile_checks.sql
   Goal: explain WHY marketing vs finance revenue timelines disagree.
*/

-- Check 1) Confirm date ranges (what months exist?)
SELECT
    MIN(rental_date) AS min_rental,
    MAX(rental_date) AS max_rental
FROM public.rental;

SELECT
    MIN(payment_date) AS min_payment,
    MAX(payment_date) AS max_payment
FROM public.payment;

-- Check 2) Are early 2022 payments tied to rentals BEFORE 2022?
-- This can explain why finance has revenue in early months while marketing shows 0.
SELECT
  DATE_TRUNC('month', p.payment_date)::date AS payment_month,
  SUM(p.amount) AS dollars
FROM public.payment p
JOIN public.rental r ON r.rental_id = p.rental_id
WHERE p.payment_date >= '2022-01-01'
  AND p.payment_date <  '2022-07-01'
  AND r.rental_date  <  '2022-01-01'
GROUP BY 1
ORDER BY 1;

-- Check 3) Where did August rentals get booked (payment month)?
-- This explains why marketing sees August activity while finance shows 0 for August.
SELECT
  DATE_TRUNC('month', r.rental_date)::date  AS rental_month,
  DATE_TRUNC('month', p.payment_date)::date AS payment_month,
  SUM(p.amount) AS dollars
FROM public.payment p
JOIN public.rental r ON r.rental_id = p.rental_id
WHERE DATE_TRUNC('month', r.rental_date)::date = '2022-08-01'
GROUP BY 1,2
ORDER BY 3 DESC;

-- Check 4) Quick sample rows where months differ (good for screenshots / examples)
SELECT
  r.rental_id,
  r.rental_date,
  p.payment_date,
  p.amount,
  DATE_TRUNC('month', r.rental_date)::date  AS rental_month,
  DATE_TRUNC('month', p.payment_date)::date AS payment_month
FROM public.payment p
JOIN public.rental r ON r.rental_id = p.rental_id
WHERE DATE_TRUNC('month', r.rental_date) <> DATE_TRUNC('month', p.payment_date)
ORDER BY p.payment_date DESC
LIMIT 50;

-- Check 5) Confirm Finance's timeline (payment months present)
SELECT
  DATE_TRUNC('month', payment_date)::date AS payment_month,
  SUM(amount) AS revenue
FROM public.payment
GROUP BY 1
ORDER BY 1;

-- Check 6) How often are payments dated before rental? (data quality flag)
SELECT
  COUNT(*) FILTER (WHERE p.payment_date < r.rental_date) AS payments_before_rental,
  COUNT(*) AS total_payments
FROM public.payment p
JOIN public.rental r ON r.rental_id = p.rental_id;
