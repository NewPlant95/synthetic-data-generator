# SQL

This directory contains a MySQL 8 star-schema warehouse for `GameStudioBI`.

## Files

- `01_create_star_schema.sql` - creates staging tables, dimensions, facts, keys, and indexes
- `02_load_from_csv.sql` - loads CSV files from `output/` with `LOAD DATA LOCAL INFILE` and transforms them into warehouse tables
- `03_create_kpi_views.sql` - creates Tableau-ready KPI views for Executive, Product, Marketing, and Finance dashboards
- `04_kpi_pack.sql` - small SQL KPI pack with ready-to-run dashboard queries

## Warehouse shape

Database:

- `gamestudiobi_dw`

Dimensions:

- `dim_date`
- `dim_business_events`
- `dim_business_scenario`
- `dim_live_event`
- `dim_campaign`
- `dim_player`

Facts:

- `fact_marketing`
- `fact_sessions`
- `fact_purchases`
- `fact_reviews`
- `fact_finance`

## Load order

1. Run `01_create_star_schema.sql`
2. Generate fresh CSV outputs with `python data_gen.py`
3. Run `02_load_from_csv.sql`
4. Run `03_create_kpi_views.sql`
5. Optionally use `04_kpi_pack.sql` for QA or Tableau extracts

## Notes

- The load script expects MySQL 8 and `LOCAL INFILE` to be enabled.
- Run imports from the project root so the relative `output/*.csv` paths resolve correctly.
- If your client or server blocks `LOCAL INFILE`, enable it in your MySQL client and server configuration first.
