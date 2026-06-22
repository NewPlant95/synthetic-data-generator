-- Load generated CSV files into the MySQL warehouse.
-- Run this from the project root with mysql --local-infile=1 after 01_create_star_schema.sql.

USE gamestudiobi_dw;

TRUNCATE TABLE stg_dim_date_raw;
TRUNCATE TABLE stg_dim_live_event_raw;
TRUNCATE TABLE stg_dim_business_events_raw;
TRUNCATE TABLE stg_dim_business_scenario_raw;
TRUNCATE TABLE stg_fact_marketing_raw;
TRUNCATE TABLE stg_dim_player_raw;
TRUNCATE TABLE stg_fact_sessions_raw;
TRUNCATE TABLE stg_fact_purchases_raw;
TRUNCATE TABLE stg_fact_reviews_raw;
TRUNCATE TABLE stg_fact_finance_raw;

LOAD DATA LOCAL INFILE 'output/dim_date.csv'
INTO TABLE stg_dim_date_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'output/dim_live_event.csv'
INTO TABLE stg_dim_live_event_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'output/dim_business_events.csv'
INTO TABLE stg_dim_business_events_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'output/dim_business_scenario.csv'
INTO TABLE stg_dim_business_scenario_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'output/fact_marketing.csv'
INTO TABLE stg_fact_marketing_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'output/dim_player.csv'
INTO TABLE stg_dim_player_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'output/fact_sessions.csv'
INTO TABLE stg_fact_sessions_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'output/fact_purchases.csv'
INTO TABLE stg_fact_purchases_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'output/fact_reviews.csv'
INTO TABLE stg_fact_reviews_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'output/fact_finance.csv'
INTO TABLE stg_fact_finance_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE fact_finance;
TRUNCATE TABLE fact_reviews;
TRUNCATE TABLE fact_purchases;
TRUNCATE TABLE fact_sessions;
TRUNCATE TABLE fact_marketing;
TRUNCATE TABLE dim_player;
TRUNCATE TABLE dim_campaign;
TRUNCATE TABLE dim_business_events;
TRUNCATE TABLE dim_business_scenario;
TRUNCATE TABLE dim_live_event;
TRUNCATE TABLE dim_date;

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO dim_date (
    date_key,
    full_date,
    day_of_month,
    day_of_week_number,
    day_name,
    week_of_year,
    month_number,
    month_name,
    quarter_number,
    year_number,
    is_weekend,
    active_event_key,
    active_event_name,
    active_event_type,
    active_scenario_key,
    active_scenario_name,
    active_scenario_type,
    month_start_date,
    quarter_start_date
)
SELECT
    datekey,
    fulldate,
    dayofmonth,
    dayofweeknumber,
    dayname,
    weekofyear,
    monthnumber,
    monthname,
    quarternumber,
    yearnumber,
    CASE
        WHEN LOWER(isweekend) = 'true' THEN 1
        ELSE 0
    END,
    CAST(NULLIF(activeeventid, '') AS UNSIGNED),
    COALESCE(activeeventname, ''),
    COALESCE(activeeventtype, ''),
    CAST(NULLIF(activescenarioid, '') AS UNSIGNED),
    COALESCE(activescenarioname, ''),
    COALESCE(activescenariotype, ''),
    monthstartdate,
    quarterstartdate
FROM stg_dim_date_raw
ORDER BY datekey;

INSERT INTO dim_business_scenario (
    scenario_key,
    scenario_name,
    scenario_type,
    start_date,
    end_date,
    ramp_up_days,
    ramp_down_days,
    description,
    expected_impact,
    affected_metrics,
    primary_channel,
    acquisition_lift,
    marketing_efficiency_lift,
    marketing_spend_lift,
    login_lift,
    session_length_lift,
    purchase_lift,
    purchase_price_lift,
    cosmetic_purchase_lift,
    churn_lift,
    cohort_churn_lift,
    review_score_shift,
    review_recommendation_shift
)
SELECT
    scenarioid,
    scenarioname,
    scenariotype,
    startdate,
    enddate,
    rampupdays,
    rampdowndays,
    description,
    expectedimpact,
    affectedmetrics,
    COALESCE(primarychannel, ''),
    acquisitionlift,
    marketingefficiencylift,
    marketingspendlift,
    loginlift,
    sessionlengthlift,
    purchaselift,
    purchasepricelift,
    cosmeticpurchaselift,
    churnlift,
    cohortchurnlift,
    reviewscoreshift,
    reviewrecommendationshift
FROM stg_dim_business_scenario_raw
ORDER BY scenarioid;

INSERT INTO dim_business_events (
    event_key,
    event_name,
    event_type,
    start_date,
    end_date,
    description,
    expected_business_impact
)
SELECT
    eventid,
    eventname,
    eventtype,
    startdate,
    enddate,
    description,
    expectedbusinessimpact
FROM stg_dim_business_events_raw
ORDER BY eventid;

INSERT INTO dim_live_event (
    event_key,
    event_name,
    event_type,
    start_date,
    end_date,
    login_lift,
    session_length_lift,
    purchase_lift
)
SELECT
    eventid,
    eventname,
    eventtype,
    startdate,
    enddate,
    loginlift,
    sessionlengthlift,
    purchaselift
FROM stg_dim_live_event_raw
ORDER BY eventid;

INSERT INTO dim_campaign (
    campaign_key,
    campaign_name,
    channel,
    campaign_kind,
    campaign_start_date,
    campaign_end_date,
    scenario_key
)
SELECT DISTINCT
    campaignid,
    campaignname,
    channel,
    campaignkind,
    campaignstartdate,
    campaignenddate,
    CAST(NULLIF(scenarioid, '') AS UNSIGNED)
FROM stg_fact_marketing_raw
ORDER BY campaignid;

INSERT INTO dim_player (
    player_key,
    registration_date_key,
    country,
    age,
    platform,
    campaign_key,
    acquisition_channel,
    acquisition_scenario_key,
    player_type
)
SELECT
    playerid,
    CAST(DATE_FORMAT(registrationdate, '%Y%m%d') AS UNSIGNED),
    country,
    age,
    platform,
    campaignid,
    acquisition_channel,
    CAST(NULLIF(acquisitionscenarioid, '') AS UNSIGNED),
    player_type
FROM stg_dim_player_raw
ORDER BY playerid;

INSERT INTO fact_marketing (
    campaign_key,
    spend,
    impressions,
    clicks,
    installs,
    registrations
)
SELECT
    campaignid,
    spend,
    impressions,
    clicks,
    installs,
    registrations
FROM stg_fact_marketing_raw
ORDER BY campaignid;

INSERT INTO fact_sessions (
    session_key,
    player_key,
    login_date_key,
    login_timestamp,
    logout_timestamp,
    session_length_minutes,
    event_key,
    event_name,
    event_type,
    scenario_key,
    scenario_name,
    scenario_type,
    biome,
    mission_type,
    difficulty,
    multiplayer_session,
    ship_class,
    planets_visited,
    missions_started,
    missions_completed,
    resources_collected,
    deaths,
    base_pieces_placed
)
SELECT
    sessionid,
    playerid,
    CAST(DATE_FORMAT(DATE(logintime), '%Y%m%d') AS UNSIGNED),
    logintime,
    logouttime,
    sessionlength,
    CAST(NULLIF(eventid, '') AS UNSIGNED),
    COALESCE(eventname, ''),
    COALESCE(eventtype, ''),
    CAST(NULLIF(scenarioid, '') AS UNSIGNED),
    COALESCE(scenarioname, ''),
    COALESCE(scenariotype, ''),
    biome,
    missiontype,
    difficulty,
    CASE
        WHEN LOWER(multiplayersession) = 'true' THEN 1
        ELSE 0
    END,
    shipclass,
    planetsvisited,
    missionsstarted,
    missionscompleted,
    resourcescollected,
    deaths,
    basepiecesplaced
FROM stg_fact_sessions_raw
ORDER BY sessionid;

INSERT INTO fact_purchases (
    purchase_key,
    player_key,
    purchase_date_key,
    item,
    quantity,
    price,
    revenue,
    purchase_timestamp
)
SELECT
    purchaseid,
    playerid,
    CAST(DATE_FORMAT(DATE(purchasedate), '%Y%m%d') AS UNSIGNED),
    item,
    quantity,
    price,
    revenue,
    purchasedate
FROM stg_fact_purchases_raw
ORDER BY purchaseid;

INSERT INTO fact_reviews (
    review_key,
    player_key,
    review_date_key,
    hours_played,
    recommended,
    review_score,
    review_date
)
SELECT
    reviewid,
    playerid,
    CAST(DATE_FORMAT(reviewdate, '%Y%m%d') AS UNSIGNED),
    hoursplayed,
    CASE
        WHEN LOWER(recommended) = 'true' THEN 1
        ELSE 0
    END,
    reviewscore,
    reviewdate
FROM stg_fact_reviews_raw
ORDER BY reviewid;

INSERT INTO fact_finance (
    finance_date_key,
    revenue,
    operating_costs,
    infrastructure_costs,
    marketing_costs,
    budget,
    forecast_revenue
)
SELECT
    CAST(DATE_FORMAT(financedate, '%Y%m%d') AS UNSIGNED),
    revenue,
    operatingcosts,
    infrastructurecosts,
    marketingcosts,
    budget,
    forecastrevenue
FROM stg_fact_finance_raw
ORDER BY financedate;
