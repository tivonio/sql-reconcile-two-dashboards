# Why Two Dashboards Show Different Revenue Numbers (Debugging with SQL)

This repo contains the complete SQL walkthrough for ["Why Two Dashboards Show Different Revenue Numbers"](https://tivon.io/2026/01/19/why-two-dashboards-show-different-revenue-numbers-debugging-with-sql/) (published on tivon.io).

It uses the **Pagila** sample dataset to demonstrate a common analytics problem:

- A marketing-style view reports results on an **activity timeline** (when rentals happened)
- A finance-style view reports results on a **payment timeline** (when money was recorded)

In Pagila, these timelines do not fully overlap, which creates a realistic "two dashboards disagree" scenario.

---

## What you will reproduce

You will confirm that:

- Rentals run from **Feb 14, 2022 to Aug 23, 2022**
- Payments run from **Jan 23, 2022 to Jul 27, 2022** (no payments recorded in August)
- August activity can look strong while Finance shows **$0** in August because the payment timeline ends in July
- Some August rental dollars are recorded under earlier payment months (Jan to Jul)

---

## Repo contents

### `pagila/`
These scripts load the dataset.

- `01_pagila-schema.sql` - creates tables, views, constraints
- `02_pagila_data.sql` - inserts data

### `sql/`
Run these in order:

1. `00_pagila_check.sql`  
   Confirms Pagila is loaded and shows what's inside (tables, row counts, date ranges)

2. `01_marketing_dashboard.sql`  
   Marketing-style metrics (activity and customers)

3. `02_finance_dashboard.sql`  
   Finance-style metrics (payments and operational signals)

4. `03_reconcile.sql`  
   Side-by-side comparison: activity-timed vs cash-timed revenue, plus mismatch drill-down

5. `04_reconcile_checks.sql`  
   Detective work that explains why the dashboards disagree (date ranges and drill-downs)

---

## Prerequisites

- Docker Desktop
- A PostgreSQL container named `pg-pagila`
- `psql` available inside the container (standard for official postgres images)
- Optional: VS Code + PostgreSQL extension (or SQLTools)

---

## Quickstart (PowerShell)

### 1) Clone the repo
```powershell
cd $HOME
git clone https://github.com/tivonio/sql-reconcile-two-dashboards.git
cd sql-reconcile-two-dashboards
```

### 2) Start PostgreSQL with Docker Compose (recommended)

If your repo includes a `docker-compose.yml`, run:
```powershell
docker compose up -d
```

Confirm the container is running:
```powershell
docker ps
```

You should see a container named `pg-pagila`.

> If you are not using Docker Compose, you can still run Postgres with `docker run`.
> The key requirement for this README is that you end up with a running container named `pg-pagila`.

---

## Load the Pagila dataset

There are two common ways to load Pagila. Pick one.

### Option A (recommended): load from inside the container using mounted files

This is the cleanest workflow for a GitHub repo:
- Your repo folder is mounted into the container (for example: `/workspace`)
- You run `psql -f` against files inside the container

If your container mounts the repo to `/workspace`, run:

```powershell
docker exec -it pg-pagila psql -U postgres -d postgres -c "CREATE DATABASE pagila;"
docker exec -it pg-pagila psql -U postgres -d pagila -f /workspace/pagila/01_pagila-schema.sql
docker exec -it pg-pagila psql -U postgres -d pagila -f /workspace/pagila/02_pagila_data.sql
```

If your mount path is different, replace `/workspace` with your actual mount location.

### Option B: copy scripts into the container, then run them

If you are not mounting the repo into the container, copy the scripts in:

```powershell
docker cp .\pagila\01_pagila-schema.sql pg-pagila:/tmp/01_pagila-schema.sql
docker cp .\pagila\02_pagila_data.sql   pg-pagila:/tmp/02_pagila_data.sql
```

Then run them:

```powershell
docker exec -it pg-pagila psql -U postgres -d postgres -c "CREATE DATABASE pagila;"
docker exec -it pg-pagila psql -U postgres -d pagila -f /tmp/01_pagila-schema.sql
docker exec -it pg-pagila psql -U postgres -d pagila -f /tmp/02_pagila_data.sql
```

---

## Run the analysis SQL files

### Option 1: Run via `psql` in the container

Run each script in order:

```powershell
docker exec -it pg-pagila psql -U postgres -d pagila -f /workspace/sql/00_pagila_check.sql
docker exec -it pg-pagila psql -U postgres -d pagila -f /workspace/sql/01_marketing_dashboard.sql
docker exec -it pg-pagila psql -U postgres -d pagila -f /workspace/sql/02_finance_dashboard.sql
docker exec -it pg-pagila psql -U postgres -d pagila -f /workspace/sql/03_reconcile.sql
docker exec -it pg-pagila psql -U postgres -d pagila -f /workspace/sql/04_reconcile_checks.sql
```

Again, if your mount path is not `/workspace`, replace it.

### Option 2 (recommended for learning): Run inside VS Code

1. Open the repo folder in VS Code.
2. Use the PostgreSQL extension to connect to the container database.
   - Host: `localhost`
   - Port: `5432` (or whatever your compose maps)
   - Database: `pagila`
   - User: `postgres`
3. Open a file in `sql/` and run the statements from the editor.

This keeps your workflow inside `.sql` files, which is ideal for learning and for clean GitHub diffs.

---

## Reset the project (start over clean)

Resetting is useful when you want to reproduce the walkthrough from scratch.

### If you used Docker Compose
```powershell
docker compose down -v
docker compose up -d
```

### If you did not use Compose
You will need to remove the container and its volume (if any), then recreate it.
Exact commands depend on how you created the container.

---

## Notes

- The Pagila scripts can take a minute to load depending on your machine.
- If you see permission or path issues, the most common cause is that the SQL files are not accessible inside the container.
  Use either a proper volume mount (Option A) or `docker cp` (Option B).
  
