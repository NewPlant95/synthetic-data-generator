"""Probabilistic behaviour assignment for player cohorts."""

from __future__ import annotations

import numpy as np
import pandas as pd

from config import (
    PlayerTypeBehaviourProfile,
    ProbabilityDistributionConfig,
    SessionLengthDistributionConfig,
    SimulationConfig,
)


BEHAVIOUR_COLUMNS = [
    "DailyLoginProbability",
    "AverageSessionLengthMinutes",
    "PurchaseProbability",
    "ChurnProbability",
    "MissionCompletionProbability",
]


def assign_player_behaviours(
    player_frame: pd.DataFrame,
    config: SimulationConfig,
) -> pd.DataFrame:
    """Assign per-player behaviour values based on configured player-type profiles."""
    _validate_player_frame(player_frame)

    behaviour_frame = player_frame.loc[:, ["PlayerID", "Player Type"]].copy()
    rng = np.random.default_rng(config.random_seed + 1)

    for player_type, profile in config.behaviour_profiles.items():
        player_mask = behaviour_frame["Player Type"] == player_type
        player_count = int(player_mask.sum())
        if player_count == 0:
            continue

        behaviour_frame.loc[player_mask, "DailyLoginProbability"] = (
            _sample_probability_distribution(
                profile.daily_login_probability,
                rng,
                player_count,
            )
        )
        behaviour_frame.loc[player_mask, "AverageSessionLengthMinutes"] = (
            _sample_session_length_distribution(
                profile.average_session_length_minutes,
                rng,
                player_count,
            )
        )
        behaviour_frame.loc[player_mask, "PurchaseProbability"] = (
            _sample_probability_distribution(
                profile.purchase_probability,
                rng,
                player_count,
            )
        )
        behaviour_frame.loc[player_mask, "ChurnProbability"] = (
            _sample_probability_distribution(
                profile.churn_probability,
                rng,
                player_count,
            )
        )
        behaviour_frame.loc[player_mask, "MissionCompletionProbability"] = (
            _sample_probability_distribution(
                profile.mission_completion_probability,
                rng,
                player_count,
            )
        )

    behaviour_frame[BEHAVIOUR_COLUMNS] = behaviour_frame[BEHAVIOUR_COLUMNS].astype(
        {
            "DailyLoginProbability": "float64",
            "AverageSessionLengthMinutes": "float64",
            "PurchaseProbability": "float64",
            "ChurnProbability": "float64",
            "MissionCompletionProbability": "float64",
        }
    )
    behaviour_frame["AverageSessionLengthMinutes"] = behaviour_frame[
        "AverageSessionLengthMinutes"
    ].round(2)
    return behaviour_frame


def summarise_behaviours_by_player_type(
    behaviour_frame: pd.DataFrame,
) -> pd.DataFrame:
    """Return mean behavioural metrics by player type."""
    required_columns = {"Player Type", *BEHAVIOUR_COLUMNS}
    missing_columns = required_columns.difference(behaviour_frame.columns)
    if missing_columns:
        missing_list = ", ".join(sorted(missing_columns))
        msg = f"behaviour_frame is missing required columns: {missing_list}"
        raise ValueError(msg)

    return (
        behaviour_frame.groupby("Player Type", as_index=False)[BEHAVIOUR_COLUMNS]
        .mean(numeric_only=True)
        .sort_values("Player Type")
        .reset_index(drop=True)
    )


def _validate_player_frame(player_frame: pd.DataFrame) -> None:
    required_columns = {"PlayerID", "Player Type"}
    missing_columns = required_columns.difference(player_frame.columns)
    if missing_columns:
        missing_list = ", ".join(sorted(missing_columns))
        msg = f"player_frame is missing required columns: {missing_list}"
        raise ValueError(msg)


def _sample_probability_distribution(
    distribution: ProbabilityDistributionConfig,
    rng: np.random.Generator,
    sample_size: int,
) -> np.ndarray:
    return rng.beta(distribution.alpha, distribution.beta, size=sample_size)


def _sample_session_length_distribution(
    distribution: SessionLengthDistributionConfig,
    rng: np.random.Generator,
    sample_size: int,
) -> np.ndarray:
    shape = (distribution.mean_minutes / distribution.std_dev_minutes) ** 2
    scale = (distribution.std_dev_minutes**2) / distribution.mean_minutes
    sampled_minutes = rng.gamma(shape=shape, scale=scale, size=sample_size)
    return np.clip(sampled_minutes, a_min=5.0, a_max=None)
