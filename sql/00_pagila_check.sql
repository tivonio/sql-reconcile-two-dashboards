/* 00_pagila_check.sql
   Goal: confirm Pagila is loaded and understand what’s inside.
*/

-- 1) Where am I?
SELECT
  current_database() AS db,
  current_schema() AS schema;

-- 2) What tables exist in public?
SELECT
  table_schema,
  table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 3) What columns exist in the main tables?
SELECT
  table_name,
  ordinal_position,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('customer', 'rental', 'payment', 'film', 'inventory')
ORDER BY table_name, ordinal_position;

-- 4) Quick row counts for the main tables
SELECT
  'customer'  AS table_name, COUNT(*) AS rows
FROM public.customer
UNION ALL
SELECT
  'rental',
  COUNT(*)
FROM public.rental
UNION ALL
SELECT
  'payment', COUNT(*)
FROM public.payment
UNION ALL
SELECT
  'film', COUNT(*)
FROM public.film
UNION ALL
SELECT
  'inventory', COUNT(*)
FROM public.inventory;

-- 5) Do we have any “orphan” records? (We want 0 here.)
-- rentals that point to a customer that does not exist
SELECT
  COUNT(*) AS orphan_rentals
FROM public.rental r
LEFT JOIN public.customer c ON c.customer_id = r.customer_id
WHERE c.customer_id IS NULL;

-- payments that point to a rental that does not exist
SELECT COUNT(*) AS orphan_payments
FROM public.payment p
LEFT JOIN public.rental r ON r.rental_id = p.rental_id
WHERE r.rental_id IS NULL;

-- 6) A small sample to see the shape of the data
SELECT
  r.rental_id,
  r.rental_date,
  r.return_date,
  c.customer_id,
  c.first_name,
  c.last_name
FROM public.rental r
JOIN public.customer c ON c.customer_id = r.customer_id
ORDER BY r.rental_date DESC
LIMIT 10;
