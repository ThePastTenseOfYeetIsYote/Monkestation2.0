#!/usr/bin/env python3
"""Command-line interface for chemistry recipe optimization.

Provides a user-friendly interface to optimize chemistry recipes
for efficient production of target reagents.
"""

import argparse
import json
import os
import sys
from typing import Any, Optional

# Add parent directory to path for module imports
_script_dir = os.path.dirname(os.path.abspath(__file__))
_parent_dir = os.path.dirname(os.path.dirname(_script_dir))
if _parent_dir not in sys.path:
    sys.path.insert(0, _parent_dir)

from scripts.chemistry_optimizer.data_loader import ChemistryDataLoader
from scripts.chemistry_optimizer.optimizer import (
    OptimizationRequest,
    OptimizationResult,
    RecipeOptimizer,
)


def format_result(result: OptimizationResult, loader: ChemistryDataLoader) -> str:
    """Format optimization result for console display.

    Args:
        result: The optimization result to format.
        loader: ChemistryDataLoader for looking up reagent properties.

    Returns:
        Formatted string for console display.
    """
    lines: list[str] = []

    if not result.success:
        lines.append("Optimization FAILED")
        lines.append("")
        for warning in result.warnings:
            lines.append(f"  ! {warning}")
        return "\n".join(lines)

    # Header
    lines.append("=" * 60)
    lines.append("CHEMISTRY RECIPE OPTIMIZATION RESULT")
    lines.append("=" * 60)
    lines.append("")

    # Summary
    lines.append("SUMMARY")
    lines.append("-" * 40)
    lines.append(f"  Efficiency Score: {result.efficiency_score:.2f}")
    lines.append(f"  Total Input: {result.total_input:.1f}u")
    lines.append(f"  Total Output: {result.total_output:.1f}u")
    lines.append("")

    # Basic Reagents Needed
    lines.append("BASIC REAGENTS NEEDED")
    lines.append("-" * 40)
    if result.input_reagents:
        for input_item in result.input_reagents:
            reagent_type = input_item.get("type", "")
            amount = input_item.get("amount", 0)
            reagent_data = loader.get_reagent_by_type(reagent_type)
            reagent_name = reagent_data.get("name", reagent_type) if reagent_data else reagent_type
            is_basic = loader.is_reagent_basic(reagent_type)
            basic_marker = " ⭐" if is_basic else ""
            lines.append(f"  {reagent_name}: {amount:.0f}u{basic_marker}")
    else:
        lines.append("  (No basic reagents required)")
    lines.append("")

    # Recipes Used
    lines.append("RECIPES")
    lines.append("-" * 40)
    for recipe in result.recipes_used:
        recipe_name = recipe.get("name", "Unknown Recipe")
        lines.append(f"  {recipe_name}")

        # Show inputs rounded to 5u
        required_reagents = recipe.get("required_reagents", {})
        if required_reagents:
            lines.append("    Inputs:")
            for reagent_type, base_amount in required_reagents.items():
                reagent_data = loader.get_reagent_by_type(reagent_type)
                reagent_name = reagent_data.get("name", reagent_type) if reagent_data else reagent_type
                # Round to 5u for display
                rounded_amount = loader.round_to_dispense(base_amount)
                lines.append(f"      {reagent_name}: {rounded_amount}u")
    lines.append("")

    # Byproducts
    lines.append("BYPRODUCTS")
    lines.append("-" * 40)
    if result.byproducts:
        seen_byproducts: dict[str, int] = {}
        for byproduct in result.byproducts:
            byproduct_type = byproduct.get("type", "")
            byproduct_name = byproduct.get("name", "Unknown")
            byproduct_count = byproduct.get("count", 1)
            is_harmful = loader.is_reagent_harmful(byproduct_type)
            harmful_marker = " ☣️" if is_harmful else ""

            key = f"{byproduct_name}{harmful_marker}"
            seen_byproducts[key] = seen_byproducts.get(key, 0) + byproduct_count

        for byproduct_name, count in seen_byproducts.items():
            lines.append(f"  {byproduct_name}: {count}")
    else:
        lines.append("  (No byproducts)")
    lines.append("")

    # Warnings
    if result.warnings:
        lines.append("WARNINGS")
        lines.append("-" * 40)
        for warning in result.warnings:
            lines.append(f"  ! {warning}")
        lines.append("")

    lines.append("=" * 60)

    return "\n".join(lines)


def load_request_from_file(file_path: str) -> Optional[dict[str, Any]]:
    """Load optimization request from JSON file.

    Args:
        file_path: Path to the JSON file.

    Returns:
        Dict with request parameters, or None if loading failed.
    """
    try:
        with open(file_path, 'r') as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error loading input file: {e}", file=sys.stderr)
        return None


def save_result_to_file(result_dict: dict[str, Any], file_path: str) -> bool:
    """Save optimization result to JSON file.

    Args:
        result_dict: The result dict to save.
        file_path: Path to the output file.

    Returns:
        True if saved successfully, False otherwise.
    """
    try:
        with open(file_path, 'w') as f:
            json.dump(result_dict, f, indent=2)
        return True
    except (IOError, OSError) as e:
        print(f"Error saving output file: {e}", file=sys.stderr)
        return False


def result_to_dict(result: OptimizationResult) -> dict[str, Any]:
    """Convert OptimizationResult to JSON-serializable dict.

    Args:
        result: The optimization result to convert.

    Returns:
        JSON-serializable dictionary.
    """
    return {
        "success": result.success,
        "efficiency_score": result.efficiency_score,
        "total_input": result.total_input,
        "total_output": result.total_output,
        "input_reagents": result.input_reagents,
        "recipes_used": result.recipes_used,
        "byproducts": result.byproducts,
        "warnings": result.warnings,
    }


def _get_default_data_file_path() -> str:
    """Get default data file path relative to script location.

    Returns:
        Absolute path to the default chemistry data file.
    """
    script_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(script_dir, "data", "chemistry_data.json")


def create_argument_parser() -> argparse.ArgumentParser:
    """Create and configure the argument parser.

    Returns:
        Configured ArgumentParser instance.
    """
    parser = argparse.ArgumentParser(
        prog="recipe_optimizer",
        description="Optimize chemistry recipes for efficient production of target reagents.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s -r Ethanol -a 50
  %(prog)s -r Ethanol -r Space\\ Drug -a 30 --prefer-cold
  %(prog)s -i request.json -o results.json
  %(prog)s -r Ethanol --avoid Sugar --max-byproducts 1
        """,
    )

    # Target reagents
    parser.add_argument(
        "--reagent", "-r",
        action="append",
        dest="reagents",
        metavar="REAGENT",
        help="Target reagent name (can specify multiple times)",
    )

    # Amount per reagent
    parser.add_argument(
        "--amount", "-a",
        type=float,
        default=10.0,
        metavar="AMOUNT",
        help="Amount of each target reagent (default: 10)",
    )

    # Avoid list
    parser.add_argument(
        "--avoid",
        action="append",
        default=[],
        metavar="REAGENT",
        help="Reagent names to avoid (can specify multiple times)",
    )

    # Max byproducts
    parser.add_argument(
        "--max-byproducts",
        type=int,
        default=3,
        metavar="COUNT",
        help="Maximum byproducts allowed (default: 3)",
    )

    # Preferences
    parser.add_argument(
        "--prefer-cold",
        action="store_true",
        default=False,
        help="Prefer cold recipes",
    )

    parser.add_argument(
        "--prefer-safe",
        action="store_true",
        default=True,
        help="Avoid dangerous reactions (default: True)",
    )

    parser.add_argument(
        "--prefer-basic",
        action="store_true",
        default=True,
        help="Prefer basic reagents (default: True)",
    )

    # File I/O
    parser.add_argument(
        "--input", "-i",
        type=str,
        metavar="FILE",
        help="JSON file with request parameters",
    )

    parser.add_argument(
        "--output", "-o",
        type=str,
        metavar="FILE",
        help="Output file for results (JSON format)",
    )

    parser.add_argument(
        "--data-file",
        type=str,
        default=_get_default_data_file_path(),
        metavar="FILE",
        help="Path to chemistry data file (default: data/chemistry_data.json in script directory)",
    )

    return parser


def main() -> int:
    """Main entry point for the CLI.

    Returns:
        Exit code: 0 for success, 1 for failure.
    """
    parser = create_argument_parser()
    args = parser.parse_args()

    # Load request from file if provided
    request_data: Optional[dict[str, Any]] = None
    if args.input:
        request_data = load_request_from_file(args.input)
        if request_data is None:
            return 1

    # Build targets list from command line args
    targets: list[dict[str, Any]] = []
    if args.reagents:
        for reagent_name in args.reagents:
            targets.append({
                "reagent": reagent_name,
                "amount": args.amount,
            })

    # Merge with file input if provided
    if request_data:
        # File targets take precedence, merge with CLI targets
        file_targets = request_data.get("targets", [])
        cli_targets = targets

        # Combine targets (CLI targets appended to file targets)
        targets = file_targets + cli_targets

        # Override other parameters from file if not specified on CLI
        avoid = request_data.get("avoid", args.avoid)
        max_byproducts = request_data.get("max_byproducts", args.max_byproducts)
        prefer_cold = request_data.get("prefer_cold", args.prefer_cold)
        prefer_safe = request_data.get("prefer_safe", args.prefer_safe)
        prefer_basic = request_data.get("prefer_basic", args.prefer_basic)
        data_file = request_data.get("data_file", args.data_file)
    else:
        avoid = args.avoid
        max_byproducts = args.max_byproducts
        prefer_cold = args.prefer_cold
        prefer_safe = args.prefer_safe
        prefer_basic = args.prefer_basic
        data_file = args.data_file

    # Validate we have targets
    if not targets:
        print("Error: No target reagents specified. Use -r/--reagent or --input.", file=sys.stderr)
        parser.print_help()
        return 1

    # Load data
    loader = ChemistryDataLoader(data_file)
    loader.load()

    # Create optimizer
    optimizer = RecipeOptimizer(loader)

    # Create request
    request = OptimizationRequest(
        targets=targets,
        avoid=avoid,
        max_byproducts=max_byproducts,
        prefer_cold=prefer_cold,
        prefer_safe=prefer_safe,
        prefer_basic=prefer_basic,
    )

    # Run optimization
    result = optimizer.optimize(request)

    # Format output
    formatted_output = format_result(result, loader)

    # Output results
    if args.output:
        # Save to JSON file
        result_dict = result_to_dict(result)
        if save_result_to_file(result_dict, args.output):
            print(f"Results saved to: {args.output}")
        else:
            return 1
    else:
        # Print to console
        print(formatted_output)

    # Return appropriate exit code
    return 0 if result.success else 1


if __name__ == "__main__":
    sys.exit(main())
