-- KPI views for Tableau dashboards.
-- Run after 02_load_from_csv.sql.

USE gamestudiobi_dw;

DROP VIEW IF EXISTS vw_finance_monthly_kpis;
DROP VIEW IF EXISTS vw_finance_daily_kpis;
DROP VIEW IF EXISTS vw_live_event_impact_kpis;
DROP VIEW IF EXISTS vw_business_scenario_impact_kpis;
DROP VIEW IF EXISTS vw_marketing_daily_kpis;
DROP VIEW IF EXISTS vw_marketing_campaign_kpis;
DROP VIEW IF EXISTS vw_product_retention_kpis;
DROP VIEW IF EXISTS vw_product_daily_kpis;
DROP VIEW IF EXISTS vw_executive_monthly_kpis;
DROP VIEW IF EXISTS vw_executive_daily_kpis;

CREATE VIEW vw_executive_daily_kpis AS
SELECT
    d.date_key,
    d.full_date,
    d.active_event_key,
    d.active_event_name,
    d.active_event_type,
    d.active_scenario_key,
    d.active_scenario_name,
    d.active_scenario_type,
    COALESCE(ds.dau, 0) AS dau,
    COALESCE(rm.mau, 0) AS mau,
    COALESCE(ds.sessions, 0) AS sessions,
    COALESCE(dp.payers, 0) AS payers,
    COALESCE(fin.revenue, 0) AS revenue,
    COALESCE(fin.forecast_revenue, 0) AS forecast_revenue,
    COALESCE(fin.operating_costs, 0) AS operating_costs,
    COALESCE(fin.infrastructure_costs, 0) AS infrastructure_costs,
    COALESCE(fin.marketing_costs, 0) AS marketing_costs,
    COALESCE(fin.budget, 0) AS budget,
    COALESCE(ds.average_session_length, 0) AS average_session_length,
    CASE
        WHEN COALESCE(rm.mau, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(fin.revenue, 0) / rm.mau, 4)
    END AS arpu,
    CASE
        WHEN COALESCE(fin.revenue, 0) = 0 THEN 0
        ELSE ROUND(
            (
                COALESCE(fin.revenue, 0)
                - COALESCE(fin.operating_costs, 0)
                - COALESCE(fin.infrastructure_costs, 0)
                - COALESCE(fin.marketing_costs, 0)
            ) / fin.revenue,
            4
        )
    END AS gross_margin
FROM dim_date d
LEFT JOIN (
    SELECT
        login_date_key AS date_key,
        COUNT(DISTINCT player_key) AS dau,
        COUNT(*) AS sessions,
        ROUND(AVG(session_length_minutes), 2) AS average_session_length
    FROM fact_sessions
    GROUP BY login_date_key
) ds
    ON ds.date_key = d.date_key
LEFT JOIN (
    SELECT
        purchase_date_key AS date_key,
        COUNT(DISTINCT player_key) AS payers
    FROM fact_purchases
    GROUP BY purchase_date_key
) dp
    ON dp.date_key = d.date_key
LEFT JOIN (
    SELECT
        d2.date_key,
        COUNT(DISTINCT s.player_key) AS mau
    FROM dim_date d2
    LEFT JOIN fact_sessions s
        ON DATE(s.login_timestamp)
        BETWEEN DATE_SUB(d2.full_date, INTERVAL 29 DAY) AND d2.full_date
    GROUP BY d2.date_key
) rm
    ON rm.date_key = d.date_key
LEFT JOIN fact_finance fin
    ON fin.finance_date_key = d.date_key;

CREATE VIEW vw_executive_monthly_kpis AS
SELECT
    d.year_number,
    d.month_number,
    d.month_name,
    MIN(d.full_date) AS month_start_date,
    CAST(SUM(k.revenue) AS DECIMAL(14, 2)) AS revenue,
    CAST(SUM(k.forecast_revenue) AS DECIMAL(14, 2)) AS forecast_revenue,
    CAST(SUM(k.operating_costs) AS DECIMAL(14, 2)) AS operating_costs,
    CAST(SUM(k.infrastructure_costs) AS DECIMAL(14, 2)) AS infrastructure_costs,
    CAST(SUM(k.marketing_costs) AS DECIMAL(14, 2)) AS marketing_costs,
    CAST(SUM(k.budget) AS DECIMAL(14, 2)) AS budget,
    ROUND(AVG(k.dau), 2) AS average_dau,
    MAX(k.mau) AS peak_mau,
    ROUND(AVG(k.average_session_length), 2) AS average_session_length,
    ROUND(AVG(k.arpu), 4) AS average_arpu
FROM vw_executive_daily_kpis k
JOIN dim_date d
    ON d.date_key = k.date_key
GROUP BY
    d.year_number,
    d.month_number,
    d.month_name;

CREATE VIEW vw_product_daily_kpis AS
SELECT
    d.date_key,
    d.full_date,
    d.active_event_key,
    d.active_event_name,
    d.active_event_type,
    d.active_scenario_key,
    d.active_scenario_name,
    d.active_scenario_type,
    COUNT(DISTINCT s.player_key) AS dau,
    COUNT(s.session_key) AS sessions,
    ROUND(AVG(s.session_length_minutes), 2) AS average_session_length,
    COALESCE(SUM(s.planets_visited), 0) AS planets_visited,
    COALESCE(SUM(s.missions_started), 0) AS missions_started,
    COALESCE(SUM(s.missions_completed), 0) AS missions_completed,
    CASE
        WHEN COALESCE(SUM(s.missions_started), 0) = 0 THEN 0
        ELSE ROUND(SUM(s.missions_completed) / SUM(s.missions_started), 4)
    END AS mission_completion_rate,
    COALESCE(SUM(s.resources_collected), 0) AS resources_collected,
    COALESCE(SUM(s.deaths), 0) AS deaths,
    COALESCE(SUM(s.base_pieces_placed), 0) AS base_pieces_placed
FROM dim_date d
LEFT JOIN fact_sessions s
    ON s.login_date_key = d.date_key
GROUP BY
    d.date_key,
    d.full_date,
    d.active_event_key,
    d.active_event_name,
    d.active_event_type,
    d.active_scenario_key,
    d.active_scenario_name,
    d.active_scenario_type;

CREATE VIEW vw_product_retention_kpis AS
SELECT
    rb.cohort_month,
    COUNT(*) AS cohort_size,
    SUM(rb.retained_day_1) AS retained_day_1_players,
    ROUND(AVG(rb.retained_day_1), 4) AS retained_day_1_rate,
    SUM(rb.retained_day_7) AS retained_day_7_players,
    ROUND(AVG(rb.retained_day_7), 4) AS retained_day_7_rate,
    SUM(rb.retained_day_30) AS retained_day_30_players,
    ROUND(AVG(rb.retained_day_30), 4) AS retained_day_30_rate
FROM (
    SELECT
        pc.cohort_month,
        pc.player_key,
        MAX(
            CASE
                WHEN a.login_date_key = CAST(DATE_FORMAT(DATE_ADD(pc.registration_date, INTERVAL 1 DAY), '%Y%m%d') AS UNSIGNED)
                    THEN 1
                ELSE 0
            END
        ) AS retained_day_1,
        MAX(
            CASE
                WHEN a.login_date_key = CAST(DATE_FORMAT(DATE_ADD(pc.registration_date, INTERVAL 7 DAY), '%Y%m%d') AS UNSIGNED)
                    THEN 1
                ELSE 0
            END
        ) AS retained_day_7,
        MAX(
            CASE
                WHEN a.login_date_key = CAST(DATE_FORMAT(DATE_ADD(pc.registration_date, INTERVAL 30 DAY), '%Y%m%d') AS UNSIGNED)
                    THEN 1
                ELSE 0
            END
        ) AS retained_day_30
    FROM (
        SELECT
            p.player_key,
            reg.full_date AS registration_date,
            reg.month_start_date AS cohort_month
        FROM dim_player p
        JOIN dim_date reg
            ON reg.date_key = p.registration_date_key
    ) pc
    LEFT JOIN (
        SELECT DISTINCT
            player_key,
            login_date_key
        FROM fact_sessions
    ) a
        ON a.player_key = pc.player_key
    GROUP BY
        pc.cohort_month,
        pc.player_key
) rb
GROUP BY rb.cohort_month
ORDER BY rb.cohort_month;

CREATE VIEW vw_marketing_campaign_kpis AS
SELECT
    c.campaign_key,
    c.campaign_name,
    c.channel,
    c.campaign_kind,
    c.campaign_start_date,
    c.campaign_end_date,
    c.scenario_key,
    bs.scenario_name,
    bs.scenario_type,
    m.spend,
    m.impressions,
    m.clicks,
    m.installs,
    m.registrations,
    CASE
        WHEN m.impressions = 0 THEN 0
        ELSE ROUND(m.clicks / m.impressions, 4)
    END AS ctr,
    CASE
        WHEN m.clicks = 0 THEN 0
        ELSE ROUND(m.installs / m.clicks, 4)
    END AS install_rate,
    CASE
        WHEN m.installs = 0 THEN 0
        ELSE ROUND(m.registrations / m.installs, 4)
    END AS registration_rate,
    CASE
        WHEN m.clicks = 0 THEN 0
        ELSE ROUND(m.spend / m.clicks, 2)
    END AS cpc,
    CASE
        WHEN m.installs = 0 THEN 0
        ELSE ROUND(m.spend / m.installs, 2)
    END AS cpi,
    CASE
        WHEN m.registrations = 0 THEN 0
        ELSE ROUND(m.spend / m.registrations, 2)
    END AS cac,
    cpr.acquired_players,
    cpr.paying_players,
    cpr.acquired_revenue,
    CASE
        WHEN m.spend = 0 THEN 0
        ELSE ROUND(cpr.acquired_revenue / m.spend, 4)
    END AS roas,
    CASE
        WHEN cpr.acquired_players = 0 THEN 0
        ELSE ROUND(cpr.paying_players / cpr.acquired_players, 4)
    END AS payer_conversion_rate
FROM dim_campaign c
JOIN fact_marketing m
    ON m.campaign_key = c.campaign_key
LEFT JOIN dim_business_scenario bs
    ON bs.scenario_key = c.scenario_key
LEFT JOIN (
    SELECT
        p.campaign_key,
        COUNT(DISTINCT p.player_key) AS acquired_players,
        COUNT(DISTINCT pur.player_key) AS paying_players,
        CAST(COALESCE(SUM(pur.revenue), 0) AS DECIMAL(14, 2)) AS acquired_revenue
    FROM dim_player p
    LEFT JOIN fact_purchases pur
        ON pur.player_key = p.player_key
    GROUP BY p.campaign_key
) cpr
    ON cpr.campaign_key = c.campaign_key;

CREATE VIEW vw_marketing_daily_kpis AS
SELECT
    d.date_key,
    d.full_date,
    c.campaign_key,
    c.campaign_name,
    c.channel,
    COALESCE(reg.registrations, 0) AS registrations,
    COALESCE(rev.revenue, 0) AS revenue
FROM dim_date d
CROSS JOIN dim_campaign c
LEFT JOIN (
    SELECT
        registration_date_key AS date_key,
        campaign_key,
        COUNT(*) AS registrations
    FROM dim_player
    GROUP BY
        registration_date_key,
        campaign_key
) reg
    ON reg.date_key = d.date_key
   AND reg.campaign_key = c.campaign_key
LEFT JOIN (
    SELECT
        pur.purchase_date_key AS date_key,
        p.campaign_key,
        CAST(SUM(pur.revenue) AS DECIMAL(14, 2)) AS revenue
    FROM fact_purchases pur
    JOIN dim_player p
        ON p.player_key = pur.player_key
    GROUP BY
        pur.purchase_date_key,
        p.campaign_key
) rev
    ON rev.date_key = d.date_key
   AND rev.campaign_key = c.campaign_key;

CREATE VIEW vw_finance_daily_kpis AS
SELECT
    d.date_key,
    d.full_date,
    fin.revenue,
    fin.forecast_revenue,
    ROUND(fin.revenue - fin.forecast_revenue, 2) AS revenue_vs_forecast,
    fin.operating_costs,
    fin.infrastructure_costs,
    fin.marketing_costs,
    ROUND(
        fin.operating_costs + fin.infrastructure_costs + fin.marketing_costs,
        2
    ) AS total_costs,
    fin.budget,
    ROUND(
        fin.budget
        - (fin.operating_costs + fin.infrastructure_costs + fin.marketing_costs),
        2
    ) AS budget_variance,
    ROUND(
        fin.revenue
        - (fin.operating_costs + fin.infrastructure_costs + fin.marketing_costs),
        2
    ) AS gross_profit,
    CASE
        WHEN fin.revenue = 0 THEN 0
        ELSE ROUND(
            (
                fin.revenue
                - (fin.operating_costs + fin.infrastructure_costs + fin.marketing_costs)
            ) / fin.revenue,
            4
        )
    END AS gross_margin
FROM fact_finance fin
JOIN dim_date d
    ON d.date_key = fin.finance_date_key;

CREATE VIEW vw_finance_monthly_kpis AS
SELECT
    d.year_number,
    d.month_number,
    d.month_name,
    MIN(d.full_date) AS month_start_date,
    CAST(SUM(fin.revenue) AS DECIMAL(14, 2)) AS revenue,
    CAST(SUM(fin.forecast_revenue) AS DECIMAL(14, 2)) AS forecast_revenue,
    CAST(SUM(fin.operating_costs) AS DECIMAL(14, 2)) AS operating_costs,
    CAST(SUM(fin.infrastructure_costs) AS DECIMAL(14, 2)) AS infrastructure_costs,
    CAST(SUM(fin.marketing_costs) AS DECIMAL(14, 2)) AS marketing_costs,
    CAST(SUM(fin.budget) AS DECIMAL(14, 2)) AS budget,
    CAST(
        SUM(
            fin.revenue
            - (fin.operating_costs + fin.infrastructure_costs + fin.marketing_costs)
        ) AS DECIMAL(14, 2)
    ) AS gross_profit
FROM fact_finance fin
JOIN dim_date d
    ON d.date_key = fin.finance_date_key
GROUP BY
    d.year_number,
    d.month_number,
    d.month_name;

CREATE VIEW vw_live_event_impact_kpis AS
SELECT
    e.event_key,
    e.event_name,
    e.event_type,
    e.start_date,
    e.end_date,
    ROUND(AVG(pre_event.dau), 2) AS avg_dau_pre_event,
    ROUND(AVG(during_event.dau), 2) AS avg_dau_during_event,
    ROUND(AVG(post_event.dau), 2) AS avg_dau_post_event,
    ROUND(
        (
            AVG(during_event.dau) - AVG(pre_event.dau)
        ) / NULLIF(AVG(pre_event.dau), 0),
        4
    ) AS dau_lift_vs_pre_event,
    ROUND(AVG(pre_event.revenue), 2) AS avg_revenue_pre_event,
    ROUND(AVG(during_event.revenue), 2) AS avg_revenue_during_event,
    ROUND(AVG(post_event.revenue), 2) AS avg_revenue_post_event
FROM dim_live_event e
LEFT JOIN vw_executive_daily_kpis pre_event
    ON pre_event.full_date BETWEEN DATE_SUB(e.start_date, INTERVAL 7 DAY)
    AND DATE_SUB(e.start_date, INTERVAL 1 DAY)
LEFT JOIN vw_executive_daily_kpis during_event
    ON during_event.full_date BETWEEN e.start_date AND e.end_date
LEFT JOIN vw_executive_daily_kpis post_event
    ON post_event.full_date BETWEEN DATE_ADD(e.end_date, INTERVAL 1 DAY)
    AND DATE_ADD(e.end_date, INTERVAL 7 DAY)
GROUP BY
    e.event_key,
    e.event_name,
    e.event_type,
    e.start_date,
    e.end_date;

CREATE VIEW vw_business_scenario_impact_kpis AS
SELECT
    s.scenario_key,
    s.scenario_name,
    s.scenario_type,
    s.start_date,
    s.end_date,
    ROUND(AVG(ed.dau), 2) AS average_dau_during_scenario,
    ROUND(AVG(ed.average_session_length), 2) AS average_session_length_during_scenario,
    CAST(SUM(ed.revenue) AS DECIMAL(14, 2)) AS revenue_during_scenario,
    ROUND(AVG(pd.mission_completion_rate), 4) AS mission_completion_rate_during_scenario,
    ROUND(AVG(fin.gross_margin), 4) AS average_gross_margin_during_scenario,
    ROUND(AVG(rv.review_score), 2) AS average_review_score_during_scenario
FROM dim_business_scenario s
LEFT JOIN vw_executive_daily_kpis ed
    ON ed.full_date BETWEEN s.start_date AND s.end_date
LEFT JOIN vw_product_daily_kpis pd
    ON pd.full_date BETWEEN s.start_date AND s.end_date
LEFT JOIN vw_finance_daily_kpis fin
    ON fin.full_date BETWEEN s.start_date AND s.end_date
LEFT JOIN (
    SELECT
        d.full_date,
        AVG(r.review_score) AS review_score
    FROM fact_reviews r
    JOIN dim_date d
        ON d.date_key = r.review_date_key
    GROUP BY d.full_date
) rv
    ON rv.full_date BETWEEN s.start_date AND s.end_date
GROUP BY
    s.scenario_key,
    s.scenario_name,
    s.scenario_type,
    s.start_date,
    s.end_date;
