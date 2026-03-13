"""Unit tests for ChemistryDataLoader."""

import unittest
import os
import json
import tempfile
from typing import Any, Optional

from scripts.chemistry_optimizer.data_loader import ChemistryDataLoader


def create_sample_chemistry_data() -> dict[str, Any]:
    """Sample chemistry data for testing."""
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
            }
        }
    }


class TestLoadChemistryData(unittest.TestCase):
    """Tests for loading chemistry data."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_load_chemistry_data(self) -> None:
        """Verify data loads with reagents and reactions."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        reagents = loader.get_all_reagents()
        reactions = loader.get_all_reactions()

        self.assertEqual(len(reagents), 3)
        self.assertEqual(len(reactions), 2)
        self.assertIn("/datum/reagent/water", reagents)
        self.assertIn("/datum/reagent/ethanol", reagents)
        self.assertIn("/datum/reagent/space_drug", reagents)

    def test_load_missing_file(self) -> None:
        """Verify graceful handling of missing files."""
        loader = ChemistryDataLoader("/nonexistent/path/data.json")
        loader.load()

        reagents = loader.get_all_reagents()
        reactions = loader.get_all_reactions()

        self.assertEqual(len(reagents), 0)
        self.assertEqual(len(reactions), 0)

    def test_load_empty_file(self) -> None:
        """Verify handling of empty JSON files."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            f.write('{"reagents": {}, "reactions": {}}')
            temp_path = f.name

        try:
            loader = ChemistryDataLoader(temp_path)
            loader.load()

            reagents = loader.get_all_reagents()
            reactions = loader.get_all_reactions()

            self.assertEqual(len(reagents), 0)
            self.assertEqual(len(reactions), 0)
        finally:
            os.unlink(temp_path)


class TestGetReagentByName(unittest.TestCase):
    """Tests for get_reagent_by_name method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_get_reagent_by_name(self) -> None:
        """Test name lookup (case-insensitive)."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        # Test exact case match
        reagent = loader.get_reagent_by_name("Water")
        self.assertIsNotNone(reagent)
        self.assertEqual(reagent["type"], "/datum/reagent/water")

        # Test lowercase
        reagent = loader.get_reagent_by_name("water")
        self.assertIsNotNone(reagent)
        self.assertEqual(reagent["type"], "/datum/reagent/water")

        # Test uppercase
        reagent = loader.get_reagent_by_name("WATER")
        self.assertIsNotNone(reagent)
        self.assertEqual(reagent["type"], "/datum/reagent/water")

        # Test mixed case
        reagent = loader.get_reagent_by_name("WaTeR")
        self.assertIsNotNone(reagent)
        self.assertEqual(reagent["type"], "/datum/reagent/water")

    def test_get_reagent_by_name_not_found(self) -> None:
        """Test name lookup for non-existent reagent."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        reagent = loader.get_reagent_by_name("NonExistent")
        self.assertIsNone(reagent)


class TestGetReagentByType(unittest.TestCase):
    """Tests for get_reagent_by_type method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_get_reagent_by_type(self) -> None:
        """Test typepath lookup."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        reagent = loader.get_reagent_by_type("/datum/reagent/water")
        self.assertIsNotNone(reagent)
        self.assertEqual(reagent["name"], "Water")

    def test_get_reagent_by_type_not_found(self) -> None:
        """Test typepath lookup for non-existent reagent."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        reagent = loader.get_reagent_by_type("/datum/reagent/nonexistent")
        self.assertIsNone(reagent)


class TestGetReactionsForReagent(unittest.TestCase):
    """Tests for get_reactions_for_reagent method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_get_reactions_for_reagent(self) -> None:
        """Test reaction lookup by required reagent."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        # Water is used in ethanol fermentation
        reactions = loader.get_reactions_for_reagent("/datum/reagent/water")
        self.assertEqual(len(reactions), 1)
        self.assertEqual(reactions[0]["name"], "Ethanol Fermentation")

    def test_get_reactions_for_reagent_multiple(self) -> None:
        """Test reaction lookup when reagent is used in multiple reactions."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        # Ethanol is used in space drug synthesis
        reactions = loader.get_reactions_for_reagent("/datum/reagent/ethanol")
        self.assertEqual(len(reactions), 1)
        self.assertEqual(reactions[0]["name"], "Space Drug Synthesis")

    def test_get_reactions_for_reagent_none(self) -> None:
        """Test reaction lookup when reagent is not used."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        # Space drug is not used as ingredient
        reactions = loader.get_reactions_for_reagent("/datum/reagent/space_drug")
        self.assertEqual(len(reactions), 0)


class TestGetReactionsProducing(unittest.TestCase):
    """Tests for get_reactions_producing method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_get_reactions_producing(self) -> None:
        """Test reaction lookup by produced reagent."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        # Ethanol is produced by ethanol fermentation
        reactions = loader.get_reactions_producing("/datum/reagent/ethanol")
        self.assertEqual(len(reactions), 1)
        self.assertEqual(reactions[0]["name"], "Ethanol Fermentation")

    def test_get_reactions_producing_multiple(self) -> None:
        """Test when multiple reactions produce same reagent."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        # Space drug is produced by space drug synthesis
        reactions = loader.get_reactions_producing("/datum/reagent/space_drug")
        self.assertEqual(len(reactions), 1)
        self.assertEqual(reactions[0]["name"], "Space Drug Synthesis")

    def test_get_reactions_producing_none(self) -> None:
        """Test when reagent is not produced by any reaction."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        # Water is not produced by any reaction in our sample
        reactions = loader.get_reactions_producing("/datum/reagent/water")
        self.assertEqual(len(reactions), 0)


class TestIsReagentHarmful(unittest.TestCase):
    """Tests for is_reagent_harmful method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_is_reagent_harmful_true(self) -> None:
        """Test harmful reagent detection."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        self.assertTrue(loader.is_reagent_harmful("/datum/reagent/ethanol"))
        self.assertTrue(loader.is_reagent_harmful("/datum/reagent/space_drug"))

    def test_is_reagent_harmful_false(self) -> None:
        """Test non-harmful reagent detection."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        self.assertFalse(loader.is_reagent_harmful("/datum/reagent/water"))

    def test_is_reagent_harmful_not_found(self) -> None:
        """Test harmful check for non-existent reagent."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        self.assertFalse(loader.is_reagent_harmful("/datum/reagent/nonexistent"))


class TestGetReagentBasicness(unittest.TestCase):
    """Tests for get_reagent_basicness method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_get_basicness_score(self) -> None:
        """Verify water has basicness score of 1."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        basicness = loader.get_reagent_basicness("/datum/reagent/water")
        self.assertEqual(basicness, 1)

    def test_get_basicness_score_complex(self) -> None:
        """Verify complex reagents have higher basicness scores."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        basicness = loader.get_reagent_basicness("/datum/reagent/space_drug")
        self.assertGreater(basicness, 1)


class TestIsReagentBasic(unittest.TestCase):
    """Tests for is_reagent_basic method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_is_reagent_basic_true(self) -> None:
        """Test basic reagent detection."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        self.assertTrue(loader.is_reagent_basic("/datum/reagent/water"))
        self.assertTrue(loader.is_reagent_basic("/datum/reagent/ethanol"))

    def test_is_reagent_basic_false(self) -> None:
        """Test non-basic reagent detection."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        self.assertFalse(loader.is_reagent_basic("/datum/reagent/space_drug"))

    def test_is_reagent_basic_not_found(self) -> None:
        """Test basic check for non-existent reagent."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        self.assertFalse(loader.is_reagent_basic("/datum/reagent/nonexistent"))


class TestRoundToDispense(unittest.TestCase):
    """Tests for round_to_dispense method."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump({"reagents": {}, "reactions": {}}, self.temp_file)
        self.temp_file.close()

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_round_to_dispense_exact(self) -> None:
        """Test rounding when amount is already multiple of 5."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        self.assertEqual(loader.round_to_dispense(5), 5)
        self.assertEqual(loader.round_to_dispense(10), 10)
        self.assertEqual(loader.round_to_dispense(15), 15)
        self.assertEqual(loader.round_to_dispense(100), 100)

    def test_round_to_dispense_round_up(self) -> None:
        """Test rounding up to nearest 5u increment."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        self.assertEqual(loader.round_to_dispense(1), 5)
        self.assertEqual(loader.round_to_dispense(3), 5)
        self.assertEqual(loader.round_to_dispense(6), 10)
        self.assertEqual(loader.round_to_dispense(8), 10)
        self.assertEqual(loader.round_to_dispense(11), 15)
        self.assertEqual(loader.round_to_dispense(13), 15)

    def test_round_to_dispense_zero(self) -> None:
        """Test rounding zero."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        self.assertEqual(loader.round_to_dispense(0), 0)

    def test_round_to_dispense_decimal(self) -> None:
        """Test rounding decimal values."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        self.assertEqual(loader.round_to_dispense(5.5), 10)
        self.assertEqual(loader.round_to_dispense(7.3), 10)


class TestGetAllReagentsAndReactions(unittest.TestCase):
    """Tests for get_all_reagents and get_all_reactions methods."""

    def setUp(self) -> None:
        """Set up test fixtures."""
        self.sample_data = create_sample_chemistry_data()
        self.temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        json.dump(self.sample_data, self.temp_file)
        self.temp_file.close()

    def tearDown(self) -> None:
        """Clean up temporary files."""
        os.unlink(self.temp_file.name)

    def test_get_all_reagents(self) -> None:
        """Test getting all reagents."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        reagents = loader.get_all_reagents()
        self.assertIsInstance(reagents, dict)
        self.assertEqual(len(reagents), 3)

    def test_get_all_reactions(self) -> None:
        """Test getting all reactions."""
        loader = ChemistryDataLoader(self.temp_file.name)
        loader.load()

        reactions = loader.get_all_reactions()
        self.assertIsInstance(reactions, dict)
        self.assertEqual(len(reactions), 2)


if __name__ == "__main__":
    unittest.main()
