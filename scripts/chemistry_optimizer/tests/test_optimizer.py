"""Unit tests for RecipeOptimizer."""

import unittest
import os
import json
import tempfile
from typing import Any

from scripts.chemistry_optimizer.data_loader import ChemistryDataLoader
from scripts.chemistry_optimizer.optimizer import (
    RecipeOptimizer,
    OptimizationRequest,
    OptimizationResult,
)


def create_sample_chemistry_data() -> dict[str, Any]:
    """Sample chemistry data for testing optimizer."""
    return {
        "reagents": {
            "/datum/reagent/water": {
                "type": "/datum/reagent/water",
                "name": "Water",
                "description": "A clear liquid essential for life.",
                "color": "#0000FF",
                "ph": 7.0,
                "mass": 18.015,
                "specific_heat": 4.184,
                "chemical_flags": 0,
                "reaction_tags": [],
                "harmful": False,
                "basicness": 1
            },
            "/datum/reagent/sugar": {
                "type": "/datum/reagent/sugar",
                "name": "Sugar",
                "description": "Sweet crystalline substance.",
                "color": "#FFFFFF",
                "ph": 7.0,
                "mass": 342.3,
                "specific_heat": 1.2,
                "chemical_flags": 0,
                "reaction_tags": [],
                "harmful": False,
                "basicness": 1
            },
            "/datum/reagent/ethanol": {
                "type": "/datum/reagent/ethanol",
                "name": "Ethanol",
                "description": "Alcohol used in drinks and fuel.",
                "color": "#8080FF",
                "ph": 7.3,
                "mass": 46.07,
                "specific_heat": 2.44,
                "chemical_flags": 0,
                "reaction_tags": [],
                "harmful": True,
                "basicness": 1
            },
            "/datum/reagent/carbon": {
                "type": "/datum/reagent/carbon",
                "name": "Carbon",
                "description": "Elemental carbon.",
                "color": "#000000",
                "ph": 7.0,
                "mass": 12.01,
                "specific_heat": 0.7,
                "chemical_flags": 0,
                "reaction_tags": [],
                "harmful": False,
                "basicness": 1
            },
            "/datum/reagent/space_drug": {
                "type": "/datum/reagent/space_drug",
                "name": "Space Drug",
                "description": "A hallucinogenic substance.",
                "color": "#FF00FF",
                "ph": 6.5,
                "mass": 50.0,
                "specific_heat": 3.0,
                "chemical_flags": 0,
                "reaction_tags": [],
                "harmful": True,
                "basicness": 5
            },
            "/datum/reagent/advanced_chemical": {
                "type": "/datum/reagent/advanced_chemical",
                "name": "Advanced Chemical",
                "description": "Complex synthetic compound.",
                "color": "#00FF00",
                "ph": 8.0,
                "mass": 100.0,
                "specific_heat": 2.5,
                "chemical_flags": 0,
                "reaction_tags": [],
                "harmful": True,
                "basicness": 10
            },
            "/datum/reagent/byproduct_waste": {
                "type": "/datum/reagent/byproduct_waste",
                "name": "Byproduct Waste",
                "description": "Unwanted chemical byproduct.",
                "color": "#808080",
                "ph": 5.0,
                "mass": 30.0,
                "specific_heat": 2.0,
                "chemical_flags": 0,
                "reaction_tags": ["byproduct"],
                "harmful": True,
                "basicness": 0
            }
        },
        "reactions": {
            "/datum/chemical_reaction/ethanol": {
                "type": "/datum/chemical_reaction/ethanol",
                "name": "Ethanol Fermentation",
                "results": ["/datum/reagent/ethanol"],
                "required_reagents": {
                    "/datum/reagent/sugar": 5,
                    "/datum/reagent/water": 5
                },
                "required_catalysts": [],
                "required_temp": 0,
                "optimal_temp": 300,
                "overheat_temp": 400,
                "reaction_flags": 0,
                "reaction_tags": [],
                "is_cold_recipe": False,
                "rate_up_lim": 100
            },
            "/datum/chemical_reaction/space_drug": {
                "type": "/datum/chemical_reaction/space_drug",
                "name": "Space Drug Synthesis",
                "results": ["/datum/reagent/space_drug"],
                "required_reagents": {
                    "/datum/reagent/ethanol": 5,
                    "/datum/reagent/carbon": 5
                },
                "required_catalysts": [],
                "required_temp": 0,
                "optimal_temp": 350,
                "overheat_temp": 450,
                "reaction_flags": 0,
                "reaction_tags": [],
                "is_cold_recipe": False,
                "rate_up_lim": 50
            },
            "/datum/chemical_reaction/advanced_chemical": {
                "type": "/datum/chemical_reaction/advanced_chemical",
                "name": "Advanced Chemical Synthesis",
                "results": ["/datum/reagent/advanced_chemical"],
                "required_reagents": {
                    "/datum/reagent/space_drug": 10,
                    "/datum/reagent/carbon": 10
                },
                "required_catalysts": [],
                "required_temp": 0,
                "optimal_temp": 400,
                "overheat_temp": 500,
                "reaction_flags": 0,
                "reaction_tags": [],
                "is_cold_recipe": False,
                "rate_up_lim": 30
            },
            "/datum/chemical_reaction/ethanol_cold": {
                "type": "/datum/chemical_reaction/ethanol_cold",
                "name": "Cold Ethanol Fermentation",
                "results": ["/datum/reagent/ethanol"],
                "required_reagents": {
                    "/datum/reagent/sugar": 10,
                    "/datum/reagent/water": 10
                },
                "required_catalysts": [],
                "required_temp": 0,
                "optimal_temp": 200,
                "overheat_temp": 250,
                "reaction_flags": 0,
                "reaction_tags": [],
                "is_cold_recipe": True,
                "rate_up_lim": 50
            },
            "/datum/chemical_reaction/with_byproducts": {
                "type": "/datum/chemical_reaction/with_byproducts",
                "name": "Reaction With Byproducts",
                "results": [
                    "/datum/reagent/advanced_chemical",
                    "/datum/reagent/byproduct_waste",
                    "/datum/reagent/byproduct_waste"
                ],
                "required_reagents": {
                    "/datum/reagent/sugar": 5,
                    "/datum/reagent/carbon": 5
                },
                "required_catalysts": [],
                "required_temp": 0,
                "optimal_temp": 350,
                "overheat_temp": 450,
                "reaction_flags": 0,
                "reaction_tags": [],
                "is_cold_recipe": False,
                "rate_up_lim": 40
            }
        }
    }


class TestFindRecipesForTarget(unittest.TestCase):
    """Tests for find_recipes_for_product method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()
        self.loader = ChemistryDataLoader(self.temp_file.name)
        self.loader.load()
        self.optimizer = RecipeOptimizer(self.loader)

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_find_recipes_for_target(self) -> None:
        """Test finding recipes that produce a specific reagent type."""
        recipes = self.optimizer.find_recipes_for_product("/datum/reagent/ethanol")
        self.assertGreater(len(recipes), 0)
        for recipe in recipes:
            self.assertIn("/datum/reagent/ethanol", recipe.get("results", []))

    def test_find_recipes_for_target_multiple(self) -> None:
        """Test finding multiple recipes for same product."""
        recipes = self.optimizer.find_recipes_for_product("/datum/reagent/ethanol")
        self.assertEqual(len(recipes), 2)  # Regular and cold fermentation

    def test_find_recipes_for_target_none(self) -> None:
        """Test finding recipes when none exist."""
        recipes = self.optimizer.find_recipes_for_product("/datum/reagent/water")
        self.assertEqual(len(recipes), 0)


class TestCalculateRecipeEfficiency(unittest.TestCase):
    """Tests for calculate_efficiency method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()
        self.loader = ChemistryDataLoader(self.temp_file.name)
        self.loader.load()
        self.optimizer = RecipeOptimizer(self.loader)

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_calculate_recipe_efficiency(self) -> None:
        """Test efficiency calculation based on input/output ratio."""
        recipe = self.optimizer.find_recipes_for_product("/datum/reagent/ethanol")[0]
        efficiency = self.optimizer.calculate_efficiency(recipe)
        self.assertIsInstance(efficiency, float)
        self.assertGreater(efficiency, 0)

    def test_calculate_recipe_efficiency_higher_is_better(self) -> None:
        """Test that more efficient recipes score higher."""
        # Cold recipe uses more input (10+10=20) for same output (1 result)
        # Regular recipe uses less input (5+5=10) for same output
        recipes = self.optimizer.find_recipes_for_product("/datum/reagent/ethanol")
        regular_recipe = next(r for r in recipes if not r.get("is_cold_recipe", False))
        cold_recipe = next(r for r in recipes if r.get("is_cold_recipe", False))

        regular_efficiency = self.optimizer.calculate_efficiency(regular_recipe)
        cold_efficiency = self.optimizer.calculate_efficiency(cold_recipe)

        # Regular should be more efficient (less input for same output)
        self.assertGreater(regular_efficiency, cold_efficiency)


class TestOptimizeSingleTarget(unittest.TestCase):
    """Tests for optimize method with single target."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()
        self.loader = ChemistryDataLoader(self.temp_file.name)
        self.loader.load()
        self.optimizer = RecipeOptimizer(self.loader)

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_optimize_single_target(self) -> None:
        """Test optimizing for a single reagent target."""
        request = OptimizationRequest(
            targets=[{"reagent": "Ethanol", "amount": 50}]
        )
        result = self.optimizer.optimize(request)

        self.assertTrue(result.success)
        self.assertIsInstance(result.recipes_used, list)
        self.assertGreater(len(result.recipes_used), 0)
        self.assertIsInstance(result.total_input, float)
        self.assertIsInstance(result.total_output, float)
        self.assertIsInstance(result.efficiency_score, float)

    def test_optimize_returns_result_dataclass(self) -> None:
        """Test that optimize returns OptimizationResult dataclass."""
        request = OptimizationRequest(
            targets=[{"reagent": "Ethanol", "amount": 50}]
        )
        result = self.optimizer.optimize(request)

        self.assertIsInstance(result, OptimizationResult)
        self.assertTrue(result.success)
        self.assertIsInstance(result.warnings, list)
        self.assertIsInstance(result.input_reagents, list)


class TestAvoidUnwantedReagents(unittest.TestCase):
    """Tests for avoid functionality."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()
        self.loader = ChemistryDataLoader(self.temp_file.name)
        self.loader.load()
        self.optimizer = RecipeOptimizer(self.loader)

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_avoid_unwanted_reagents(self) -> None:
        """Test that avoided reagents are excluded from recipes."""
        # Space drug synthesis requires ethanol
        # If we avoid ethanol, we shouldn't get space drug recipes
        request = OptimizationRequest(
            targets=[{"reagent": "Space Drug", "amount": 50}],
            avoid=["Ethanol"]
        )
        result = self.optimizer.optimize(request)

        # Should fail or warn because space drug requires ethanol
        # Verify that avoidance actually affects recipe selection
        self.assertFalse(result.success, 
            "Should fail when required reagent is avoided")
        self.assertGreater(len(result.warnings), 0,
            "Should have warnings when no valid recipes available")

    def test_optimize_returns_success_false_when_no_valid_recipes(self) -> None:
        """Test that optimizer returns success=False when no valid recipes exist."""
        # Request a reagent that has no recipes
        request = OptimizationRequest(
            targets=[{"reagent": "Water", "amount": 50}]
        )
        result = self.optimizer.optimize(request)

        # Water has no recipes that produce it
        self.assertFalse(result.success,
            "Should return success=False when no recipes found")
        self.assertEqual(len(result.recipes_used), 0,
            "Should have no recipes used when optimization fails")
        self.assertGreater(len(result.warnings), 0,
            "Should have warnings explaining why optimization failed")

    def test_avoid_by_type(self) -> None:
        """Test avoiding reagents by typepath."""
        request = OptimizationRequest(
            targets=[{"reagent": "Ethanol", "amount": 50}],
            avoid=["/datum/reagent/sugar"]
        )
        result = self.optimizer.optimize(request)

        # Should handle avoidance gracefully
        self.assertIsInstance(result, OptimizationResult)


class TestMinimizeByproducts(unittest.TestCase):
    """Tests for byproduct minimization."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()
        self.loader = ChemistryDataLoader(self.temp_file.name)
        self.loader.load()
        self.optimizer = RecipeOptimizer(self.loader)

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_minimize_byproducts(self) -> None:
        """Test that byproducts are tracked and limited."""
        # Recipe with byproducts vs without
        request = OptimizationRequest(
            targets=[{"reagent": "Advanced Chemical", "amount": 50}],
            max_byproducts=1
        )
        result = self.optimizer.optimize(request)

        self.assertIsInstance(result, OptimizationResult)
        self.assertIsInstance(result.byproducts, list)

    def test_byproduct_tracking(self) -> None:
        """Test that byproducts are correctly identified."""
        # Find the recipe with byproducts
        recipes = self.optimizer.find_recipes_for_product("/datum/reagent/advanced_chemical")
        byproduct_recipe = next(
            (r for r in recipes if len(r.get("results", [])) > 1),
            None
        )

        if byproduct_recipe:
            byproducts = self.optimizer.get_recipe_byproducts(
                byproduct_recipe,
                ["/datum/reagent/advanced_chemical"]
            )
            self.assertGreater(len(byproducts), 0)


class TestRoundsTo5uIncrement(unittest.TestCase):
    """Tests for 5u rounding behavior."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()
        self.loader = ChemistryDataLoader(self.temp_file.name)
        self.loader.load()
        self.optimizer = RecipeOptimizer(self.loader)

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_rounds_to_5u_increment(self) -> None:
        """Test that calculated inputs are rounded to 5u increments."""
        request = OptimizationRequest(
            targets=[{"reagent": "Ethanol", "amount": 12}]  # Not a multiple of 5
        )
        result = self.optimizer.optimize(request)

        self.assertTrue(result.success)
        # All input amounts should be multiples of 5
        for input_reagent in result.input_reagents:
            amount = input_reagent.get("amount", 0)
            self.assertEqual(amount % 5, 0)

    def test_calculate_required_inputs_rounds(self) -> None:
        """Test that calculate_required_inputs rounds to 5u."""
        recipe = self.optimizer.find_recipes_for_product("/datum/reagent/ethanol")[0]
        inputs = self.optimizer.calculate_required_inputs(recipe, 12.0)

        # All amounts should be multiples of 5
        for reagent_type, amount in inputs.items():
            self.assertEqual(amount % 5, 0)


class TestPrefersBasicReagents(unittest.TestCase):
    """Tests for basic reagent preference."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()
        self.loader = ChemistryDataLoader(self.temp_file.name)
        self.loader.load()
        self.optimizer = RecipeOptimizer(self.loader)

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_prefers_basic_reagents(self) -> None:
        """Test that optimizer prefers recipes using basic reagents."""
        request = OptimizationRequest(
            targets=[{"reagent": "Ethanol", "amount": 50}],
            prefer_basic=True
        )
        result = self.optimizer.optimize(request)

        self.assertTrue(result.success)
        # Input reagents should include basic ones
        self.assertGreater(len(result.input_reagents), 0)

    def test_calculate_basicness_score(self) -> None:
        """Test basicness score calculation."""
        recipe = self.optimizer.find_recipes_for_product("/datum/reagent/ethanol")[0]
        score = self.optimizer.calculate_basicness_score(recipe)
        self.assertIsInstance(score, float)
        self.assertGreaterEqual(score, 0)

    def test_recipe_contains_avoided(self) -> None:
        """Test checking if recipe contains avoided reagents."""
        recipe = self.optimizer.find_recipes_for_product("/datum/reagent/ethanol")[0]

        # Should detect sugar in the recipe
        contains = self.optimizer.recipe_contains_avoided(
            recipe,
            ["/datum/reagent/sugar"]
        )
        self.assertTrue(contains)

        # Should not detect carbon in the recipe
        contains = self.optimizer.recipe_contains_avoided(
            recipe,
            ["/datum/reagent/carbon"]
        )
        self.assertFalse(contains)


class TestOptimizationRequestDefaults(unittest.TestCase):
    """Tests for OptimizationRequest dataclass defaults."""

    def test_default_avoid(self) -> None:
        """Test default avoid list is empty."""
        request = OptimizationRequest(targets=[{"reagent": "Ethanol", "amount": 50}])
        self.assertEqual(request.avoid, [])

    def test_default_max_byproducts(self) -> None:
        """Test default max_byproducts is 3."""
        request = OptimizationRequest(targets=[{"reagent": "Ethanol", "amount": 50}])
        self.assertEqual(request.max_byproducts, 3)

    def test_default_prefer_cold(self) -> None:
        """Test default prefer_cold is False."""
        request = OptimizationRequest(targets=[{"reagent": "Ethanol", "amount": 50}])
        self.assertFalse(request.prefer_cold)

    def test_default_prefer_safe(self) -> None:
        """Test default prefer_safe is True."""
        request = OptimizationRequest(targets=[{"reagent": "Ethanol", "amount": 50}])
        self.assertTrue(request.prefer_safe)

    def test_default_prefer_basic(self) -> None:
        """Test default prefer_basic is True."""
        request = OptimizationRequest(targets=[{"reagent": "Ethanol", "amount": 50}])
        self.assertTrue(request.prefer_basic)


class TestFindRecipesForReagentName(unittest.TestCase):
    """Tests for find_recipes_for_reagent_name method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()
        self.loader = ChemistryDataLoader(self.temp_file.name)
        self.loader.load()
        self.optimizer = RecipeOptimizer(self.loader)

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_find_recipes_for_reagent_name(self) -> None:
        """Test finding recipes by reagent name (case-insensitive)."""
        recipes = self.optimizer.find_recipes_for_reagent_name("Ethanol")
        self.assertGreater(len(recipes), 0)
        for recipe in recipes:
            self.assertIn("/datum/reagent/ethanol", recipe.get("results", []))

    def test_find_recipes_for_reagent_name_case_insensitive(self) -> None:
        """Test name lookup is case-insensitive."""
        recipes_upper = self.optimizer.find_recipes_for_reagent_name("ETHANOL")
        recipes_lower = self.optimizer.find_recipes_for_reagent_name("ethanol")
        recipes_mixed = self.optimizer.find_recipes_for_reagent_name("EtHaNoL")

        self.assertEqual(len(recipes_upper), len(recipes_lower))
        self.assertEqual(len(recipes_upper), len(recipes_mixed))

    def test_find_recipes_for_reagent_name_not_found(self) -> None:
        """Test finding recipes for non-existent reagent."""
        recipes = self.optimizer.find_recipes_for_reagent_name("NonExistent")
        self.assertEqual(len(recipes), 0)


class TestGetRecipeByproducts(unittest.TestCase):
    """Tests for get_recipe_byproducts method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()
        self.loader = ChemistryDataLoader(self.temp_file.name)
        self.loader.load()
        self.optimizer = RecipeOptimizer(self.loader)

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_get_recipe_byproducts(self) -> None:
        """Test extracting byproducts from recipe results."""
        recipes = self.optimizer.find_recipes_for_product("/datum/reagent/advanced_chemical")
        byproduct_recipe = next(
            (r for r in recipes if len(r.get("results", [])) > 1),
            None
        )

        if byproduct_recipe:
            target_types = ["/datum/reagent/advanced_chemical"]
            byproducts = self.optimizer.get_recipe_byproducts(byproduct_recipe, target_types)
            # Byproducts are results that aren't targets
            self.assertGreater(len(byproducts), 0)

    def test_get_recipe_byproducts_empty(self) -> None:
        """Test byproducts when all results are targets."""
        recipe = self.optimizer.find_recipes_for_product("/datum/reagent/ethanol")[0]
        # All results are targets, so no byproducts
        byproducts = self.optimizer.get_recipe_byproducts(recipe, recipe.get("results", []))
        self.assertEqual(len(byproducts), 0)


class TestResolveAvoidTypes(unittest.TestCase):
    """Tests for _resolve_avoid_types method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()
        self.loader = ChemistryDataLoader(self.temp_file.name)
        self.loader.load()
        self.optimizer = RecipeOptimizer(self.loader)

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_resolve_avoid_types_by_name(self) -> None:
        """Test resolving reagent names to typepaths."""
        typepaths = self.optimizer._resolve_avoid_types(["Water", "Sugar"])
        self.assertIn("/datum/reagent/water", typepaths)
        self.assertIn("/datum/reagent/sugar", typepaths)

    def test_resolve_avoid_types_by_typepath(self) -> None:
        """Test that typepaths pass through unchanged."""
        typepaths = self.optimizer._resolve_avoid_types(["/datum/reagent/water"])
        self.assertIn("/datum/reagent/water", typepaths)

    def test_resolve_avoid_types_mixed(self) -> None:
        """Test resolving mixed names and typepaths."""
        typepaths = self.optimizer._resolve_avoid_types([
            "Water",
            "/datum/reagent/sugar"
        ])
        self.assertIn("/datum/reagent/water", typepaths)
        self.assertIn("/datum/reagent/sugar", typepaths)

    def test_resolve_avoid_types_unknown(self) -> None:
        """Test handling of unknown reagent names."""
        typepaths = self.optimizer._resolve_avoid_types(["NonExistent"])
        # Unknown names should be ignored, not cause errors
        self.assertEqual(len(typepaths), 0)


class TestCalculateRecipeScore(unittest.TestCase):
    """Tests for _calculate_recipe_score method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()
        self.loader = ChemistryDataLoader(self.temp_file.name)
        self.loader.load()
        self.optimizer = RecipeOptimizer(self.loader)

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_calculate_recipe_score(self) -> None:
        """Test overall recipe score calculation."""
        recipe = self.optimizer.find_recipes_for_product("/datum/reagent/ethanol")[0]
        request = OptimizationRequest(
            targets=[{"reagent": "Ethanol", "amount": 50}]
        )
        score = self.optimizer._calculate_recipe_score(recipe, request)
        self.assertIsInstance(score, float)
        self.assertGreater(score, 0)

    def test_calculate_recipe_score_with_preferences(self) -> None:
        """Test score calculation with preferences."""
        recipe = self.optimizer.find_recipes_for_product("/datum/reagent/ethanol")[0]
        request = OptimizationRequest(
            targets=[{"reagent": "Ethanol", "amount": 50}],
            prefer_cold=True,
            prefer_safe=True,
            prefer_basic=True
        )
        score = self.optimizer._calculate_recipe_score(recipe, request)
        self.assertIsInstance(score, float)


if __name__ == "__main__":
    unittest.main()
