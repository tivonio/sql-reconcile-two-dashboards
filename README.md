# Why Two Dashboards Show Different Revenue Numbers (Debugging with SQL)

This repo contains the complete SQL walkthrough for "Why Two Dashboards Show Different Revenue Numbers".

It uses the **Pagila** sample dataset to demonstrate a common analytics problem:

- A marketing-style view reports results on an **activity timeline** (when the rental happened)
- A finance-style view reports results on a **payment timeline** (when money was recorded)

In Pagila, these timelines do not fully overlap, which creates a realistic “two dashboards disagree” scenario.

## What you will reproduce

You will confirm:

- Rentals run from **Feb 14, 2022 to Aug 23, 2022**
- Payments run from **Jan 23, 2022 to Jul 27, 2022** (no payments recorded in August)
- August activity can look strong while Finance shows **$0** in August because the payment timeline ends in July
- August rental dollars are recorded under earlier payment months (Jan–Jul)

---

## Repo contents

### `pagila/`
- `pagila-schema.sql` — creates tables, views, constraints
- `pagila-data.sql` — inserts data

### `sql/`
Run these in order:

1. `00_pagila_check.sql`  
   Confirms Pagila is loaded and shows what’s inside (tables, row counts, date ranges)

2.  `01_marketing_dashboard.sql`  
   Marketing-style metrics (activity and customers)

3. `02_finance_dashboard.sql`  
   Finance-style metrics (payments and operational signals)

4. `03_reconcile.sql`  
   Side-by-side comparison: activity-timed vs cash-timed revenue + mismatch drill-down

5. `04_reconcile_checks.sql`  
   “Detective work” that explains why the dashboards disagree (date ranges + drill-downs)

---

## Prerequisites

- Docker Desktop
- A running PostgreSQL container named: `pg-pagila`
- `psql` available inside the container (standard for official postgres images)
- Optionally: VS Code + PostgreSQL extension

---

## Quickstart (PowerShell)

### 1) Confirm the container is running
```powershell
docker ps
