"""Recipe optimization core for chemistry crafting."""

from dataclasses import dataclass, field
from typing import Any

from scripts.chemistry_optimizer.data_loader import ChemistryDataLoader, MIN_DISPENSE


@dataclass
class OptimizationRequest:
    """Request for recipe optimization.

    Attributes:
        targets: List of target reagents to produce with amounts.
        avoid: List of reagent names or typepaths to avoid.
        max_byproducts: Maximum allowed byproducts in the recipe.
        prefer_cold: Whether to prefer cold recipes.
        prefer_safe: Whether to avoid dangerous reactions.
        prefer_basic: Whether to prefer recipes using basic reagents.
    """

    targets: list[dict]
    avoid: list[str] = field(default_factory=list)
    max_byproducts: int = 3
    prefer_cold: bool = False
    prefer_safe: bool = True
    prefer_basic: bool = True


@dataclass
class OptimizationResult:
    """Result of recipe optimization.

    Attributes:
        success: Whether optimization succeeded.
        recipes_used: List of recipes to use for optimization.
        total_input: Total input units required.
        total_output: Total output units produced.
        byproducts: List of byproducts created.
        efficiency_score: Overall efficiency score (higher is better).
        warnings: List of warning messages.
        input_reagents: List of basic reagents needed with amounts.
    """

    success: bool
    recipes_used: list[dict] = field(default_factory=list)
    total_input: float = 0.0
    total_output: float = 0.0
    byproducts: list[dict] = field(default_factory=list)
    efficiency_score: float = 0.0
    warnings: list[str] = field(default_factory=list)
    input_reagents: list[dict] = field(default_factory=list)


class RecipeOptimizer:
    """Optimize chemistry recipes for efficiency and resource usage.

    Uses a greedy scoring algorithm to select the best recipes based on
    efficiency, basicness, safety, and user preferences.
    """

    def __init__(self, loader: ChemistryDataLoader) -> None:
        """Initialize the optimizer with a data loader.

        Args:
            loader: ChemistryDataLoader instance with loaded chemistry data.
        """
        self._loader = loader

    def find_recipes_for_product(self, product_type: str) -> list[dict[str, Any]]:
        """Find recipes that produce the specified reagent type.

        Args:
            product_type: The typepath of the reagent to produce.

        Returns:
            List of recipe dicts that produce this reagent.
        """
        return self._loader.get_reactions_producing(product_type)

    def find_recipes_for_reagent_name(self, product_name: str) -> list[dict[str, Any]]:
        """Find recipes that produce the reagent by name.

        Args:
            product_name: The display name of the reagent (case-insensitive).

        Returns:
            List of recipe dicts that produce this reagent.
        """
        reagent = self._loader.get_reagent_by_name(product_name)
        if reagent is None:
            return []

        type_path = reagent.get("type", "")
        return self.find_recipes_for_product(type_path)

    def calculate_efficiency(self, recipe: dict[str, Any]) -> float:
        """Calculate efficiency score for a recipe.

        Efficiency is based on the ratio of output to input.
        Higher scores indicate more efficient recipes.

        Args:
            recipe: The recipe dict to evaluate.

        Returns:
            Efficiency score (higher is better).
        """
        required_reagents = recipe.get("required_reagents", {})
        results = recipe.get("results", [])

        if not required_reagents or not results:
            return 0.0

        # Calculate total input amount
        total_input = sum(required_reagents.values())

        # Output is number of results (each result is typically 1 unit conceptually)
        # For simplicity, we use the number of target results as output measure
        total_output = len(results)

        if total_input == 0:
            return 0.0

        # Efficiency = output / input (higher ratio is better)
        return total_output / total_input

    def calculate_basicness_score(self, recipe: dict[str, Any]) -> float:
        """Calculate basicness score for a recipe.

        Lower scores indicate recipes using more basic/foundational reagents.
        Score is the average basicness of all required reagents.

        Args:
            recipe: The recipe dict to evaluate.

        Returns:
            Basicness score (lower is more basic).
        """
        required_reagents = recipe.get("required_reagents", {})

        if not required_reagents:
            return 0.0

        total_basicness = 0.0
        count = 0

        for reagent_type in required_reagents.keys():
            basicness = self._loader.get_reagent_basicness(reagent_type)
            if basicness > 0:
                total_basicness += basicness
                count += 1

        if count == 0:
            return 0.0

        return total_basicness / count

    def recipe_contains_avoided(
        self, recipe: dict[str, Any], avoid_types: list[str]
    ) -> bool:
        """Check if recipe contains any avoided reagents.

        Args:
            recipe: The recipe dict to check.
            avoid_types: List of typepaths to avoid.

        Returns:
            True if recipe contains avoided reagents, False otherwise.
        """
        required_reagents = recipe.get("required_reagents", {})
        avoid_set = set(avoid_types)

        for reagent_type in required_reagents.keys():
            if reagent_type in avoid_set:
                return True

        return False

    def get_recipe_byproducts(
        self, recipe: dict[str, Any], target_types: list[str]
    ) -> list[dict[str, Any]]:
        """Get byproducts from a recipe (results that aren't targets).

        Args:
            recipe: The recipe dict to analyze.
            target_types: List of target reagent typepaths.

        Returns:
            List of byproduct dicts with type and count.
        """
        results = recipe.get("results", [])
        target_set = set(target_types)

        byproducts: list[dict[str, Any]] = []
        byproduct_counts: dict[str, int] = {}

        for result_type in results:
            if result_type not in target_set:
                byproduct_counts[result_type] = byproduct_counts.get(result_type, 0) + 1

        for reagent_type, count in byproduct_counts.items():
            reagent_data = self._loader.get_reagent_by_type(reagent_type)
            byproducts.append({
                "type": reagent_type,
                "name": reagent_data.get("name", "Unknown") if reagent_data else "Unknown",
                "count": count
            })

        return byproducts

    def calculate_required_inputs(
        self, recipe: dict[str, Any], target_amount: float
    ) -> dict[str, int]:
        """Calculate required input amounts for a target amount.

        All amounts are rounded up to 5u increments.

        Args:
            recipe: The recipe dict to use.
            target_amount: The desired output amount.

        Returns:
            Dict mapping reagent typepaths to required amounts (rounded to 5u).
        """
        required_reagents = recipe.get("required_reagents", {})
        results = recipe.get("results", [])

        if not required_reagents or not results:
            return {}

        # Calculate how many batches we need
        # Each batch produces len(results) units conceptually
        batches_needed = target_amount / len(results)

        inputs: dict[str, int] = {}
        for reagent_type, base_amount in required_reagents.items():
            # Scale by batches needed
            scaled_amount = base_amount * batches_needed
            # Round up to 5u increment
            rounded_amount = self._loader.round_to_dispense(scaled_amount)
            inputs[reagent_type] = rounded_amount

        return inputs

    def _resolve_avoid_types(self, avoid_names: list[str]) -> list[str]:
        """Convert reagent names to typepaths for avoidance checking.

        Args:
            avoid_names: List of reagent names or typepaths to avoid.

        Returns:
            List of resolved typepaths (unknown names are ignored).
        """
        resolved: list[str] = []

        for name in avoid_names:
            # Check if it's already a typepath
            if name.startswith("/datum/"):
                resolved.append(name)
            else:
                # Try to resolve by name
                reagent = self._loader.get_reagent_by_name(name)
                if reagent is not None:
                    type_path = reagent.get("type", "")
                    if type_path:
                        resolved.append(type_path)

        return resolved

    def _calculate_recipe_score(
        self, recipe: dict[str, Any], request: OptimizationRequest
    ) -> float:
        """Calculate overall score for a recipe based on request preferences.

        Uses greedy scoring algorithm combining:
        - Efficiency (output/input ratio)
        - Basicness (preference for basic reagents)
        - Safety (avoiding harmful reagents)
        - Temperature preference (cold vs hot)
        - Byproduct count

        Args:
            recipe: The recipe dict to score.
            request: The optimization request with preferences.

        Returns:
            Overall score (higher is better).
        """
        score = 0.0

        # Base efficiency score (weighted heavily)
        efficiency = self.calculate_efficiency(recipe)
        score += efficiency * 10.0

        # Basicness score (lower is better, so we invert)
        if request.prefer_basic:
            basicness = self.calculate_basicness_score(recipe)
            # Invert so lower basicness = higher score
            score += (10.0 - basicness) * 2.0

        # Safety score
        if request.prefer_safe:
            required_reagents = recipe.get("required_reagents", {})
            harmful_count = 0
            for reagent_type in required_reagents.keys():
                if self._loader.is_reagent_harmful(reagent_type):
                    harmful_count += 1
            # Penalize harmful reagents
            score -= harmful_count * 3.0

        # Temperature preference
        is_cold = recipe.get("is_cold_recipe", False)
        if request.prefer_cold and is_cold:
            score += 5.0
        elif not request.prefer_cold and is_cold:
            score -= 2.0  # Slight penalty if cold not preferred

        # Byproduct penalty
        results = recipe.get("results", [])
        if results:
            # Assume first result is the target, rest are byproducts
            byproduct_count = len(results) - 1
            score -= byproduct_count * 2.0

        return score

    def optimize(self, request: OptimizationRequest) -> OptimizationResult:
        """Main optimization entry point.

        Finds the best recipes to produce the requested targets while
        respecting avoidance constraints and preferences.

        Args:
            request: The optimization request with targets and preferences.

        Returns:
            OptimizationResult with the best recipes and resource requirements.
        """
        warnings: list[str] = []
        recipes_used: list[dict[str, Any]] = []
        all_byproducts: list[dict[str, Any]] = []
        total_input = 0.0
        total_output = 0.0
        input_reagents: dict[str, float] = {}

        # Resolve avoid names to typepaths
        avoid_types = self._resolve_avoid_types(request.avoid)

        for target in request.targets:
            reagent_name = target.get("reagent", "")
            target_amount = target.get("amount", 0.0)

            if not reagent_name:
                warnings.append(f"Empty reagent name in target: {target}")
                continue

            # Find recipes for this reagent
            recipes = self.find_recipes_for_reagent_name(reagent_name)

            if not recipes:
                warnings.append(f"No recipes found for: {reagent_name}")
                continue

            # Score and filter recipes
            scored_recipes: list[tuple[float, dict[str, Any]]] = []
            for recipe in recipes:
                # Check avoidance
                if self.recipe_contains_avoided(recipe, avoid_types):
                    continue

                # Check byproduct limit
                results = recipe.get("results", [])
                byproduct_count = len(results) - 1 if results else 0
                if byproduct_count > request.max_byproducts:
                    continue

                # Calculate score
                score = self._calculate_recipe_score(recipe, request)
                scored_recipes.append((score, recipe))

            if not scored_recipes:
                warnings.append(
                    f"No valid recipes for {reagent_name} after filtering"
                )
                continue

            # Sort by score (highest first) and pick best
            scored_recipes.sort(key=lambda x: x[0], reverse=True)
            best_recipe = scored_recipes[0][1]

            recipes_used.append(best_recipe)

            # Calculate inputs needed
            inputs = self.calculate_required_inputs(best_recipe, target_amount)
            for reagent_type, amount in inputs.items():
                input_reagents[reagent_type] = (
                    input_reagents.get(reagent_type, 0.0) + amount
                )
                total_input += amount

            # Calculate output
            results = best_recipe.get("results", [])
            # Find target type path
            target_reagent = self._loader.get_reagent_by_name(reagent_name)
            target_type = target_reagent.get("type", "") if target_reagent else ""

            output_count = results.count(target_type) if target_type else len(results)
            total_output += target_amount

            # Track byproducts
            byproducts = self.get_recipe_byproducts(best_recipe, [target_type])
            all_byproducts.extend(byproducts)

        # Check if we succeeded
        success = len(recipes_used) > 0 and len(warnings) < len(request.targets)

        # Calculate overall efficiency
        efficiency_score = 0.0
        if total_input > 0 and recipes_used:
            efficiency_score = total_output / total_input

        # Convert input reagents to list format
        input_reagent_list = [
            {"type": reagent_type, "amount": amount}
            for reagent_type, amount in input_reagents.items()
        ]

        return OptimizationResult(
            success=success,
            recipes_used=recipes_used,
            total_input=total_input,
            total_output=total_output,
            byproducts=all_byproducts,
            efficiency_score=efficiency_score,
            warnings=warnings,
            input_reagents=input_reagent_list,
        )
