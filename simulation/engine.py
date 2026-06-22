"""Simulation entry points."""

from __future__ import annotations

from config import SimulationConfig


def describe_simulation(config: SimulationConfig) -> dict[str, str | int]:
    """Return a lightweight summary of the configured simulation window."""
    return {
        "player_count": config.player_count,
        "simulation_start_date": config.simulation_start_date.isoformat(),
        "simulation_end_date": config.simulation_end_date.isoformat(),
        "status": "Scaffold only. Data generation not implemented.",
    }
