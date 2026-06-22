-- MySQL 8 star-schema warehouse for GameStudioBI.
-- Run this before loading CSVs.

CREATE DATABASE IF NOT EXISTS gamestudiobi_dw;
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

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS fact_finance;
DROP TABLE IF EXISTS fact_reviews;
DROP TABLE IF EXISTS fact_purchases;
DROP TABLE IF EXISTS fact_sessions;
DROP TABLE IF EXISTS fact_marketing;
DROP TABLE IF EXISTS dim_player;
DROP TABLE IF EXISTS dim_campaign;
DROP TABLE IF EXISTS dim_business_events;
DROP TABLE IF EXISTS dim_business_scenario;
DROP TABLE IF EXISTS dim_live_event;
DROP TABLE IF EXISTS dim_date;

DROP TABLE IF EXISTS stg_fact_finance_raw;
DROP TABLE IF EXISTS stg_fact_reviews_raw;
DROP TABLE IF EXISTS stg_fact_purchases_raw;
DROP TABLE IF EXISTS stg_fact_sessions_raw;
DROP TABLE IF EXISTS stg_dim_player_raw;
DROP TABLE IF EXISTS stg_fact_marketing_raw;
DROP TABLE IF EXISTS stg_dim_business_events_raw;
DROP TABLE IF EXISTS stg_dim_business_scenario_raw;
DROP TABLE IF EXISTS stg_dim_live_event_raw;
DROP TABLE IF EXISTS stg_dim_date_raw;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE stg_dim_date_raw (
    datekey INT,
    fulldate DATE,
    dayofmonth TINYINT,
    dayofweeknumber TINYINT,
    dayname VARCHAR(20),
    weekofyear TINYINT,
    monthnumber TINYINT,
    monthname VARCHAR(20),
    quarternumber TINYINT,
    yearnumber INT,
    isweekend VARCHAR(10),
    activeeventid VARCHAR(20),
    activeeventname VARCHAR(255),
    activeeventtype VARCHAR(100),
    activescenarioid VARCHAR(20),
    activescenarioname VARCHAR(255),
    activescenariotype VARCHAR(100),
    monthstartdate DATE,
    quarterstartdate DATE
) ENGINE = InnoDB;

CREATE TABLE stg_dim_business_scenario_raw (
    scenarioid BIGINT,
    scenarioname VARCHAR(255),
    scenariotype VARCHAR(100),
    startdate DATE,
    enddate DATE,
    rampupdays INT,
    rampdowndays INT,
    description TEXT,
    expectedimpact TEXT,
    affectedmetrics TEXT,
    primarychannel VARCHAR(100),
    acquisitionlift DECIMAL(8, 4),
    marketingefficiencylift DECIMAL(8, 4),
    marketingspendlift DECIMAL(8, 4),
    loginlift DECIMAL(8, 4),
    sessionlengthlift DECIMAL(8, 4),
    purchaselift DECIMAL(8, 4),
    purchasepricelift DECIMAL(8, 4),
    cosmeticpurchaselift DECIMAL(8, 4),
    churnlift DECIMAL(8, 4),
    cohortchurnlift DECIMAL(8, 4),
    reviewscoreshift DECIMAL(8, 4),
    reviewrecommendationshift DECIMAL(8, 4)
) ENGINE = InnoDB;

CREATE TABLE stg_dim_business_events_raw (
    eventid BIGINT,
    eventname VARCHAR(255),
    eventtype VARCHAR(100),
    startdate DATE,
    enddate DATE,
    description TEXT,
    expectedbusinessimpact TEXT
) ENGINE = InnoDB;

CREATE TABLE stg_dim_live_event_raw (
    eventid BIGINT,
    eventname VARCHAR(255),
    eventtype VARCHAR(100),
    startdate DATE,
    enddate DATE,
    loginlift DECIMAL(8, 4),
    sessionlengthlift DECIMAL(8, 4),
    purchaselift DECIMAL(8, 4)
) ENGINE = InnoDB;

CREATE TABLE stg_fact_marketing_raw (
    campaignid BIGINT,
    campaignname VARCHAR(255),
    channel VARCHAR(100),
    campaignkind VARCHAR(50),
    campaignstartdate DATE,
    campaignenddate DATE,
    scenarioid VARCHAR(20),
    scenarioname VARCHAR(255),
    scenariotype VARCHAR(100),
    spend DECIMAL(14, 2),
    impressions BIGINT,
    clicks BIGINT,
    installs BIGINT,
    registrations BIGINT
) ENGINE = InnoDB;

CREATE TABLE stg_dim_player_raw (
    playerid BIGINT,
    registrationdate DATE,
    country VARCHAR(100),
    age TINYINT,
    platform VARCHAR(50),
    campaignid BIGINT,
    acquisition_channel VARCHAR(100),
    acquisitionscenarioid VARCHAR(20),
    acquisitionscenarioname VARCHAR(255),
    acquisitionscenariotype VARCHAR(100),
    player_type VARCHAR(50)
) ENGINE = InnoDB;

CREATE TABLE stg_fact_sessions_raw (
    sessionid BIGINT,
    playerid BIGINT,
    logintime DATETIME,
    logouttime DATETIME,
    sessionlength INT,
    eventid VARCHAR(20),
    eventname VARCHAR(255),
    eventtype VARCHAR(100),
    scenarioid VARCHAR(20),
    scenarioname VARCHAR(255),
    scenariotype VARCHAR(100),
    biome VARCHAR(50),
    missiontype VARCHAR(50),
    difficulty VARCHAR(30),
    multiplayersession VARCHAR(10),
    shipclass VARCHAR(50),
    planetsvisited INT,
    missionsstarted INT,
    missionscompleted INT,
    resourcescollected INT,
    deaths INT,
    basepiecesplaced INT
) ENGINE = InnoDB;

CREATE TABLE stg_fact_purchases_raw (
    purchaseid BIGINT,
    playerid BIGINT,
    item VARCHAR(255),
    quantity INT,
    price DECIMAL(12, 2),
    revenue DECIMAL(14, 2),
    purchasedate DATETIME
) ENGINE = InnoDB;

CREATE TABLE stg_fact_reviews_raw (
    reviewid BIGINT,
    playerid BIGINT,
    hoursplayed DECIMAL(12, 2),
    recommended VARCHAR(10),
    reviewscore TINYINT,
    reviewdate DATE
) ENGINE = InnoDB;

CREATE TABLE stg_fact_finance_raw (
    financedate DATE,
    revenue DECIMAL(14, 2),
    operatingcosts DECIMAL(14, 2),
    infrastructurecosts DECIMAL(14, 2),
    marketingcosts DECIMAL(14, 2),
    forecastrevenue DECIMAL(14, 2),
    budget DECIMAL(14, 2)
) ENGINE = InnoDB;

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_of_month TINYINT NOT NULL,
    day_of_week_number TINYINT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    week_of_year TINYINT NOT NULL,
    month_number TINYINT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter_number TINYINT NOT NULL,
    year_number INT NOT NULL,
    is_weekend TINYINT(1) NOT NULL,
    active_event_key BIGINT NULL,
    active_event_name VARCHAR(255) NOT NULL,
    active_event_type VARCHAR(100) NOT NULL,
    active_scenario_key BIGINT NULL,
    active_scenario_name VARCHAR(255) NOT NULL,
    active_scenario_type VARCHAR(100) NOT NULL,
    month_start_date DATE NOT NULL,
    quarter_start_date DATE NOT NULL
) ENGINE = InnoDB;

CREATE TABLE dim_business_scenario (
    scenario_key BIGINT PRIMARY KEY,
    scenario_name VARCHAR(255) NOT NULL,
    scenario_type VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    ramp_up_days INT NOT NULL,
    ramp_down_days INT NOT NULL,
    description TEXT NOT NULL,
    expected_impact TEXT NOT NULL,
    affected_metrics TEXT NOT NULL,
    primary_channel VARCHAR(100) NOT NULL,
    acquisition_lift DECIMAL(8, 4) NOT NULL,
    marketing_efficiency_lift DECIMAL(8, 4) NOT NULL,
    marketing_spend_lift DECIMAL(8, 4) NOT NULL,
    login_lift DECIMAL(8, 4) NOT NULL,
    session_length_lift DECIMAL(8, 4) NOT NULL,
    purchase_lift DECIMAL(8, 4) NOT NULL,
    purchase_price_lift DECIMAL(8, 4) NOT NULL,
    cosmetic_purchase_lift DECIMAL(8, 4) NOT NULL,
    churn_lift DECIMAL(8, 4) NOT NULL,
    cohort_churn_lift DECIMAL(8, 4) NOT NULL,
    review_score_shift DECIMAL(8, 4) NOT NULL,
    review_recommendation_shift DECIMAL(8, 4) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE dim_business_events (
    event_key BIGINT PRIMARY KEY,
    event_name VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    description TEXT NOT NULL,
    expected_business_impact TEXT NOT NULL
) ENGINE = InnoDB;

CREATE TABLE dim_live_event (
    event_key BIGINT PRIMARY KEY,
    event_name VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    login_lift DECIMAL(8, 4) NOT NULL,
    session_length_lift DECIMAL(8, 4) NOT NULL,
    purchase_lift DECIMAL(8, 4) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE dim_campaign (
    campaign_key BIGINT PRIMARY KEY,
    campaign_name VARCHAR(255) NOT NULL,
    channel VARCHAR(100) NOT NULL,
    campaign_kind VARCHAR(50) NOT NULL,
    campaign_start_date DATE NOT NULL,
    campaign_end_date DATE NOT NULL,
    scenario_key BIGINT NULL,
    CONSTRAINT fk_dim_campaign_scenario
        FOREIGN KEY (scenario_key) REFERENCES dim_business_scenario (scenario_key)
) ENGINE = InnoDB;

CREATE TABLE dim_player (
    player_key BIGINT PRIMARY KEY,
    registration_date_key INT NOT NULL,
    country VARCHAR(100) NOT NULL,
    age TINYINT NOT NULL,
    platform VARCHAR(50) NOT NULL,
    campaign_key BIGINT NOT NULL,
    acquisition_channel VARCHAR(100) NOT NULL,
    acquisition_scenario_key BIGINT NULL,
    player_type VARCHAR(50) NOT NULL,
    CONSTRAINT fk_dim_player_registration_date
        FOREIGN KEY (registration_date_key) REFERENCES dim_date (date_key),
    CONSTRAINT fk_dim_player_campaign
        FOREIGN KEY (campaign_key) REFERENCES dim_campaign (campaign_key),
    CONSTRAINT fk_dim_player_acquisition_scenario
        FOREIGN KEY (acquisition_scenario_key) REFERENCES dim_business_scenario (scenario_key)
) ENGINE = InnoDB;

CREATE TABLE fact_marketing (
    campaign_key BIGINT PRIMARY KEY,
    spend DECIMAL(14, 2) NOT NULL,
    impressions BIGINT NOT NULL,
    clicks BIGINT NOT NULL,
    installs BIGINT NOT NULL,
    registrations BIGINT NOT NULL,
    CONSTRAINT fk_fact_marketing_campaign
        FOREIGN KEY (campaign_key) REFERENCES dim_campaign (campaign_key)
) ENGINE = InnoDB;

CREATE TABLE fact_sessions (
    session_key BIGINT PRIMARY KEY,
    player_key BIGINT NOT NULL,
    login_date_key INT NOT NULL,
    login_timestamp DATETIME NOT NULL,
    logout_timestamp DATETIME NOT NULL,
    session_length_minutes INT NOT NULL,
    event_key BIGINT NULL,
    event_name VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    scenario_key BIGINT NULL,
    scenario_name VARCHAR(255) NOT NULL,
    scenario_type VARCHAR(100) NOT NULL,
    biome VARCHAR(50) NOT NULL,
    mission_type VARCHAR(50) NOT NULL,
    difficulty VARCHAR(30) NOT NULL,
    multiplayer_session TINYINT(1) NOT NULL,
    ship_class VARCHAR(50) NOT NULL,
    planets_visited INT NOT NULL,
    missions_started INT NOT NULL,
    missions_completed INT NOT NULL,
    resources_collected INT NOT NULL,
    deaths INT NOT NULL,
    base_pieces_placed INT NOT NULL,
    CONSTRAINT fk_fact_sessions_player
        FOREIGN KEY (player_key) REFERENCES dim_player (player_key),
    CONSTRAINT fk_fact_sessions_login_date
        FOREIGN KEY (login_date_key) REFERENCES dim_date (date_key),
    CONSTRAINT fk_fact_sessions_event
        FOREIGN KEY (event_key) REFERENCES dim_live_event (event_key),
    CONSTRAINT fk_fact_sessions_scenario
        FOREIGN KEY (scenario_key) REFERENCES dim_business_scenario (scenario_key)
) ENGINE = InnoDB;

CREATE TABLE fact_purchases (
    purchase_key BIGINT PRIMARY KEY,
    player_key BIGINT NOT NULL,
    purchase_date_key INT NOT NULL,
    item VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    revenue DECIMAL(14, 2) NOT NULL,
    purchase_timestamp DATETIME NOT NULL,
    CONSTRAINT fk_fact_purchases_player
        FOREIGN KEY (player_key) REFERENCES dim_player (player_key),
    CONSTRAINT fk_fact_purchases_purchase_date
        FOREIGN KEY (purchase_date_key) REFERENCES dim_date (date_key)
) ENGINE = InnoDB;

CREATE TABLE fact_reviews (
    review_key BIGINT PRIMARY KEY,
    player_key BIGINT NOT NULL,
    review_date_key INT NOT NULL,
    hours_played DECIMAL(12, 2) NOT NULL,
    recommended TINYINT(1) NOT NULL,
    review_score TINYINT NOT NULL,
    review_date DATE NOT NULL,
    CONSTRAINT fk_fact_reviews_player
        FOREIGN KEY (player_key) REFERENCES dim_player (player_key),
    CONSTRAINT fk_fact_reviews_review_date
        FOREIGN KEY (review_date_key) REFERENCES dim_date (date_key)
) ENGINE = InnoDB;

CREATE TABLE fact_finance (
    finance_date_key INT PRIMARY KEY,
    revenue DECIMAL(14, 2) NOT NULL,
    operating_costs DECIMAL(14, 2) NOT NULL,
    infrastructure_costs DECIMAL(14, 2) NOT NULL,
    marketing_costs DECIMAL(14, 2) NOT NULL,
    budget DECIMAL(14, 2) NOT NULL,
    forecast_revenue DECIMAL(14, 2) NOT NULL,
    CONSTRAINT fk_fact_finance_date
        FOREIGN KEY (finance_date_key) REFERENCES dim_date (date_key)
) ENGINE = InnoDB;

CREATE INDEX idx_dim_player_campaign_key
    ON dim_player (campaign_key);

CREATE INDEX idx_dim_player_registration_date_key
    ON dim_player (registration_date_key);

CREATE INDEX idx_dim_player_acquisition_scenario_key
    ON dim_player (acquisition_scenario_key);

CREATE INDEX idx_fact_sessions_player_date
    ON fact_sessions (player_key, login_date_key);

CREATE INDEX idx_fact_sessions_login_date
    ON fact_sessions (login_date_key);

CREATE INDEX idx_fact_sessions_event_key
    ON fact_sessions (event_key);

CREATE INDEX idx_fact_sessions_scenario_key
    ON fact_sessions (scenario_key);

CREATE INDEX idx_fact_purchases_player_date
    ON fact_purchases (player_key, purchase_date_key);

CREATE INDEX idx_fact_purchases_purchase_date
    ON fact_purchases (purchase_date_key);

CREATE INDEX idx_fact_reviews_player_date
    ON fact_reviews (player_key, review_date_key);

CREATE INDEX idx_fact_finance_date
    ON fact_finance (finance_date_key);
