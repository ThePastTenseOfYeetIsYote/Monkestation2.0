"""Chemistry data loader for loading and indexing chemistry data."""

import json
import math
from typing import Any, Optional


MIN_DISPENSE = 5
"""Minimum dispensing amount in units (5u)."""


class ChemistryDataLoader:
    """Load and index chemistry data from JSON files.

    Provides methods for looking up reagents by name or type, finding reactions,
    checking reagent properties, and rounding amounts to dispensing increments.
    """

    def __init__(self, data_path: str) -> None:
        """Initialize the loader with path to JSON file.

        Args:
            data_path: Path to the chemistry data JSON file.
        """
        self._data_path = data_path
        self._reagents: dict[str, dict[str, Any]] = {}
        self._reactions: dict[str, dict[str, Any]] = {}
        self._name_index: dict[str, str] = {}  # name (lowercase) -> type path
        self._reactions_by_reagent: dict[str, list[dict[str, Any]]] = {}
        self._reactions_producing: dict[str, list[dict[str, Any]]] = {}

    def load(self) -> None:
        """Load and index chemistry data from the JSON file.

        Handles missing files gracefully by loading empty data.
        """
        try:
            with open(self._data_path, 'r') as f:
                data = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            data = {"reagents": {}, "reactions": {}}

        self._reagents = data.get("reagents", {})
        self._reactions = data.get("reactions", {})

        self._build_indexes()

    def _build_indexes(self) -> None:
        """Build lookup indexes for efficient querying.

        Creates:
        - Name index for case-insensitive name lookup
        - Reactions by reagent index (which reactions use this reagent)
        - Reactions producing index (which reactions produce this reagent)
        """
        self._name_index = {}
        self._reactions_by_reagent = {}
        self._reactions_producing = {}

        # Build name index
        for type_path, reagent_data in self._reagents.items():
            name = reagent_data.get("name", "").lower()
            if name:
                self._name_index[name] = type_path

        # Build reaction indexes
        for reaction_type, reaction_data in self._reactions.items():
            # Index by required reagents
            required_reagents = reaction_data.get("required_reagents", {})
            if isinstance(required_reagents, dict):
                for reagent_type in required_reagents.keys():
                    if reagent_type not in self._reactions_by_reagent:
                        self._reactions_by_reagent[reagent_type] = []
                    self._reactions_by_reagent[reagent_type].append(reaction_data)

            # Index by results (what this reaction produces)
            results = reaction_data.get("results", [])
            if isinstance(results, list):
                for reagent_type in results:
                    if reagent_type not in self._reactions_producing:
                        self._reactions_producing[reagent_type] = []
                    self._reactions_producing[reagent_type].append(reaction_data)

    def get_reagent_by_name(self, name: str) -> Optional[dict[str, Any]]:
        """Get reagent by display name (case-insensitive).

        Args:
            name: The display name of the reagent.

        Returns:
            The reagent data dict, or None if not found.
        """
        type_path = self._name_index.get(name.lower())
        if type_path:
            return self._reagents.get(type_path)
        return None

    def get_reagent_by_type(self, type_path: str) -> Optional[dict[str, Any]]:
        """Get reagent by typepath.

        Args:
            type_path: The full type path (e.g., "/datum/reagent/water").

        Returns:
            The reagent data dict, or None if not found.
        """
        return self._reagents.get(type_path)

    def get_reactions_for_reagent(self, reagent_type: str) -> list[dict[str, Any]]:
        """Get reactions that use this reagent as an ingredient.

        Args:
            reagent_type: The type path of the reagent.

        Returns:
            List of reaction data dicts that require this reagent.
        """
        return self._reactions_by_reagent.get(reagent_type, [])

    def get_reactions_producing(self, reagent_type: str) -> list[dict[str, Any]]:
        """Get reactions that produce this reagent.

        Args:
            reagent_type: The type path of the reagent.

        Returns:
            List of reaction data dicts that produce this reagent.
        """
        return self._reactions_producing.get(reagent_type, [])

    def is_reagent_harmful(self, reagent_type: str) -> bool:
        """Check if reagent is harmful.

        Args:
            reagent_type: The type path of the reagent.

        Returns:
            True if the reagent is harmful, False otherwise.
        """
        reagent = self._reagents.get(reagent_type)
        if reagent:
            return reagent.get("harmful", False)
        return False

    def get_reagent_basicness(self, reagent_type: str) -> int:
        """Get basicness score for a reagent.

        Lower scores indicate more basic/fundamental reagents.
        Score of 1 means the reagent is a basic building block.

        Args:
            reagent_type: The type path of the reagent.

        Returns:
            The basicness score (1 = most basic), or 0 if not found.
        """
        reagent = self._reagents.get(reagent_type)
        if reagent:
            return reagent.get("basicness", 0)
        return 0

    def is_reagent_basic(self, reagent_type: str) -> bool:
        """Check if reagent is basic (basicness score = 1).

        Args:
            reagent_type: The type path of the reagent.

        Returns:
            True if the reagent is basic (score = 1), False otherwise.
        """
        return self.get_reagent_basicness(reagent_type) == 1

    def round_to_dispense(self, amount: float) -> int:
        """Round amount up to nearest 5u increment.

        Args:
            amount: The amount to round.

        Returns:
            The rounded amount (multiple of MIN_DISPENSE).
        """
        if amount <= 0:
            return 0

        return int(math.ceil(amount / MIN_DISPENSE) * MIN_DISPENSE)

    def get_all_reagents(self) -> dict[str, dict[str, Any]]:
        """Get all reagents.

        Returns:
            Dict mapping type paths to reagent data.
        """
        return self._reagents

    def get_all_reactions(self) -> dict[str, dict[str, Any]]:
        """Get all reactions.

        Returns:
            Dict mapping reaction types to reaction data.
        """
        return self._reactions
