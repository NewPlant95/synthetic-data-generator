# Expected Patterns

This file is the check list for the narrative signals intentionally built into `FakeGameStudio`.

Use it when you inspect the generated CSVs and want to separate real structure from noise.

## How To Read The Data

The data is not meant to be flat. It contains planned lifts, drops, and cohort effects that should show up in multiple tables at the same time.

Look for:

- changes that line up with scenario start and end dates
- gradual ramp-up and ramp-down instead of instant jumps
- matching movement across sessions, purchases, reviews, and finance
- different behavior by player type
- item-level shifts during promotions

## Planned Business Stories

### 1. Creator Launch Push

Dates: `2024-01-15` to `2024-02-07`

What should show up:

- more registrations and top-of-funnel volume
- higher DAU during the window
- revenue rising with acquisition volume
- the acquired cohort churning faster than baseline
- slightly weaker recommendation sentiment than the other positive scenarios

What to confirm against:

- `dim_business_scenario.csv`
- `dim_date.csv`
- `dim_player.csv`
- `fact_sessions.csv`
- `fact_purchases.csv`
- `fact_reviews.csv`

### 2. Viral Social Wave

Dates: `2024-05-06` to `2024-05-24`

What should show up:

- a sharp but temporary growth spike
- improvement driven more by player volume than by monetization per player
- slightly better review sentiment
- no major churn penalty

### 3. Foundry Systems Update

Dates: `2024-06-10` to `2024-07-07`

What should show up:

- returning players coming back in larger numbers
- longer sessions
- better review scores and recommendations
- lower churn than baseline

This is the cleanest positive engagement story in the dataset.

### 4. Summer Cosmetics Promotion

Dates: `2024-08-01` to `2024-08-14`

What should show up:

- more purchase lines
- a higher share of cosmetic items
- lower average revenue per transaction
- only a modest engagement bump
- little to no retention change

This is a pricing and basket-mix pattern, not a retention story.

### 5. Deep Space Expansion

Dates: `2024-09-05` to `2024-09-30`

What should show up:

- engagement rising mainly among existing players
- longer sessions
- better reviews
- a modest acquisition bump, not the main effect

This is the most obvious content-lands-well narrative.

### 6. Server Instability Incident

Dates: `2024-10-03` to `2024-10-07`

What should show up:

- a visible dip in sessions
- weaker revenue during the incident window
- worse review sentiment
- a recovery after the outage ends

This should look abrupt compared with the smoother positive scenarios.

### 7. Balance Patch Backlash

Dates: `2024-11-08` to `2024-11-25`

What should show up:

- shorter sessions
- weaker retention
- higher churn
- lower review scores
- revenue that does not collapse immediately, but loses quality

This is the main negative patch narrative.

## Live-Service Event Signals

These are separate from the business scenarios and should appear as event-window lifts in the date and session data.

- `Expedition Alpha`: `2024-03-01` to `2024-03-31`
  - higher login rate
  - slightly longer sessions
  - better purchase activity

- `Halloween Event`: `2024-10-20` to `2024-10-31`
  - uplift in login frequency
  - mild session extension
  - modest purchase lift

- `Winter Update`: `2024-12-10` to `2024-12-31`
  - stronger login lift
  - longer sessions
  - the strongest purchase lift of the event set

## Player-Type Patterns

The simulation also bakes in cohort differences by player type.

- `Explorer`
  - more exploration-oriented activity
  - more planets visited
  - higher likelihood of exploration and survey missions

- `Builder`
  - more base-building behavior
  - more building-related missions
  - more structure placement activity

- `Trader`
  - more trade-oriented behavior
  - more market and logistics style purchases
  - stronger association with value-seeking item choices

- `Casual`
  - shorter sessions on average
  - lower purchase frequency
  - more relaxed difficulty mix

- `Hardcore`
  - longer sessions
  - higher combat intensity
  - stronger purchase and review activity
  - higher churn risk if a negative scenario hits

## Commerce Patterns

The purchase table is not random.

What to look for:

- cosmetic items over-index during the summer promotion
- expedition-style or upgrade items appear more around engagement-heavy periods
- purchase volume rises during positive scenarios and live events
- average revenue per purchase can fall even while total revenue rises

The item catalog is player-type aware, so different cohorts should not buy the same mix.

## Finance Patterns

`fact_finance.csv` is derived from the activity tables.

What to look for:

- revenue follows purchases
- marketing costs move with campaign activity
- scenario effects should show up in daily finance totals
- positive growth does not always mean higher efficiency

If purchases rise but margin does not, that is still a valid story in this model.

## Validation Patterns

The QA outputs should tell you whether the generated dataset is internally consistent.

You should expect:

- foreign keys to pass
- purchase and review links to pass
- revenue reconciliation to pass
- churn checks to pass unless you intentionally alter the config or code

If these fail, the data issue is structural, not narrative.

## QA-Short

If you want the shortest possible check, confirm these four things:

1. the dates line up with the scenario windows
2. the session and purchase curves move in the same direction as the scenario
3. reviews improve after positive content and worsen after bad incidents
4. the item mix shifts during the cosmetics promotion
