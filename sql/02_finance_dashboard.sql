/* 02_finance_dashboard.sql
   Goal: finance-style metrics (money and operational signals).
*/

-- 1) Revenue per month (based on payment_date)
SELECT
  DATE_TRUNC('month', p.payment_date)::date AS month,
  SUM(p.amount) AS revenue
FROM public.payment p
GROUP BY 1
ORDER BY 1;

-- 2) Revenue by store
SELECT
  s.store_id,
  SUM(p.amount) AS revenue
FROM public.payment p
JOIN public.staff st ON st.staff_id = p.staff_id
JOIN public.store s  ON s.store_id = st.store_id
GROUP BY 1
ORDER BY revenue DESC;

-- 3) Revenue by staff
SELECT
  p.staff_id,
  st.first_name,
  st.last_name,
  SUM(p.amount) AS revenue
FROM public.payment p
JOIN public.staff st ON st.staff_id = p.staff_id
GROUP BY 1,2,3
ORDER BY revenue DESC;

-- 4) Late returns rate (proxy for operational friction)
-- Late if return_date is after rental_date + rental_duration days.
SELECT
  DATE_TRUNC('month', r.rental_date)::date AS month,
  COUNT(*) AS total_rentals,
  COUNT(*) FILTER (
    WHERE r.return_date IS NOT NULL
      AND r.return_date > r.rental_date + (f.rental_duration || ' days')::interval
  ) AS late_returns,
  ROUND(
    100.0 * COUNT(*) FILTER (
      WHERE r.return_date IS NOT NULL
        AND r.return_date > r.rental_date + (f.rental_duration || ' days')::interval
    ) / NULLIF(COUNT(*), 0),
    2
  ) AS late_return_pct
FROM public.rental r
JOIN public.inventory i ON i.inventory_id = r.inventory_id
JOIN public.film f      ON f.film_id = i.film_id
GROUP BY 1
ORDER BY 1;

