/* 01_marketing_dashboard.sql
   Goal: marketing-style metrics (activity and customer behavior).
*/

-- 1) Rentals per month (activity volume)
SELECT
  DATE_TRUNC('month', r.rental_date)::date AS month,
  COUNT(*) AS rentals
FROM public.rental r
GROUP BY 1
ORDER BY 1;

-- 2) Active customers per month
-- A customer is “active” in a month if they rented at least once that month.
SELECT
  DATE_TRUNC('month', r.rental_date)::date AS month,
  COUNT(DISTINCT r.customer_id) AS active_customers
FROM public.rental r
GROUP BY 1
ORDER BY 1;

-- 3) New customers per month (signups)
SELECT
  DATE_TRUNC('month', c.create_date)::date AS month,
  COUNT(*) AS new_customers
FROM public.customer c
GROUP BY 1
ORDER BY 1;

-- 4) Top categories by number of rentals
SELECT
  cat.name AS category,
  COUNT(*) AS rentals
FROM public.rental r
JOIN public.inventory i      ON i.inventory_id = r.inventory_id
JOIN public.film f           ON f.film_id = i.film_id
JOIN public.film_category fc ON fc.film_id = f.film_id
JOIN public.category cat     ON cat.category_id = fc.category_id
GROUP BY 1
ORDER BY rentals DESC
LIMIT 10;

-- 5) Top customers by number of rentals
SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  COUNT(*) AS rentals
FROM public.rental r
JOIN public.customer c ON c.customer_id = r.customer_id
GROUP BY 1,2,3
ORDER BY rentals DESC
LIMIT 10;

