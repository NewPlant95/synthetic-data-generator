USE gamestudiobi_dw;

-- Small KPI pack built on top of the KPI views.
-- These are ready-to-run queries for Tableau extracts or ad hoc QA.

-- Executive dashboard: monthly health.
SELECT
    year_number,
    month_number,
    month_name,
    revenue,
    forecast_revenue,
    operating_costs,
    infrastructure_costs,
    marketing_costs,
    budget,
    average_dau,
    peak_mau,
    average_arpu
FROM vw_executive_monthly_kpis
ORDER BY year_number, month_number;

-- Product dashboard: retention by cohort month.
SELECT
    cohort_month,
    cohort_size,
    retained_day_1_rate,
    retained_day_7_rate,
    retained_day_30_rate
FROM vw_product_retention_kpis
ORDER BY cohort_month;

-- Marketing dashboard: best campaigns by ROAS.
SELECT
    campaign_name,
    channel,
    spend,
    registrations,
    acquired_revenue,
    roas,
    cac,
    payer_conversion_rate
FROM vw_marketing_campaign_kpis
ORDER BY roas DESC, acquired_revenue DESC;

-- Finance dashboard: daily actuals versus budget and forecast.
SELECT
    full_date,
    revenue,
    forecast_revenue,
    revenue_vs_forecast,
    total_costs,
    budget,
    budget_variance,
    gross_profit,
    gross_margin
FROM vw_finance_daily_kpis
ORDER BY full_date;

-- Live-service event impact: before, during, and after-event DAU and revenue.
SELECT
    event_name,
    event_type,
    start_date,
    end_date,
    avg_dau_pre_event,
    avg_dau_during_event,
    avg_dau_post_event,
    dau_lift_vs_pre_event,
    avg_revenue_pre_event,
    avg_revenue_during_event,
    avg_revenue_post_event
FROM vw_live_event_impact_kpis
ORDER BY start_date;
