// scripts/chemistry_optimizer/export_chemistry_data.dm

/proc/export_chemistry_data()
    var/list/data = list()
    
    // Export all reagents with "basicness" score
    var/list/reagents_list = list()
    for(var/reagent_type in GLOB.chemical_reagents_list)
        var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_type]
        
        // Calculate basicness score (lower = more basic)
        var/basicness = calculate_reagent_basicness(reagent_type)
        
        var/list/reagent_data = list(
            "type" = reagent.type,
            "name" = reagent.name,
            "description" = reagent.description,
            "color" = reagent.color,
            "ph" = reagent.ph,
            "mass" = reagent.mass,
            "specific_heat" = reagent.specific_heat,
            "chemical_flags" = reagent.chemical_flags,
            "reaction_tags" = reagent.reaction_tags,
            "harmful" = reagent.harmful,
            "basicness" = basicness
        )
        reagents_list[reagent.type] = reagent_data
    
    data["reagents"] = reagents_list
    
    // Export all reactions
    var/list/reactions_list = list()
    for(var/reaction_type in GLOB.chemical_reactions_list)
        var/datum/chemical_reaction/reaction = GLOB.chemical_reactions_list[reaction_type]
        var/list/reaction_data = list(
            "type" = reaction.type,
            "name" = reaction.name,
            "results" = reaction.results,
            "required_reagents" = reaction.required_reagents,
            "required_catalysts" = reaction.required_catalysts,
            "required_temp" = reaction.required_temp,
            "optimal_temp" = reaction.optimal_temp,
            "overheat_temp" = reaction.overheat_temp,
            "reaction_flags" = reaction.reaction_flags,
            "reaction_tags" = reaction.reaction_tags,
            "is_cold_recipe" = reaction.is_cold_recipe,
            "rate_up_lim" = reaction.rate_up_lim
        )
        reactions_list[reaction_type] = reaction_data
    
    data["reactions"] = reactions_list
    
    // Write to JSON file
    var/json_output = JSONencode(data)
    file2text("scripts/chemistry_optimizer/data/chemistry_data.json", json_output)
    
    world << "Exported [reagents_list.len] reagents and [reactions_list.len] reactions to chemistry_data.json"

/proc/calculate_reagent_basicness(reagent_type)
    // Lower score = more basic/fundamental
    // Basic reagents: water, carbon, oxygen, nitrogen, hydrogen, etc.
    var/list/basic_reagents = list(
        "/datum/reagent/water",
        "/datum/reagent/carbon",
        "/datum/reagent/oxygen",
        "/datum/reagent/nitrogen",
        "/datum/reagent/hydrogen",
        "/datum/reagent/sulfur",
        "/datum/reagent/phosphorus",
        "/datum/reagent/iron",
        "/datum/reagent/copper",
        "/datum/reagent/silver",
        "/datum/reagent/gold",
        "/datum/reagent/uranium",
        "/datum/reagent/radium",
        "/datum/reagent/chlorine",
        "/datum/reagent/sodium",
        "/datum/reagent/potassium",
        "/datum/reagent/calcium",
        "/datum/reagent/aluminum",
        "/datum/reagent/silicon",
        "/datum/reagent/consumable/sugar",
        "/datum/reagent/ethanol",
        "/datum/reagent/lithium"
    )
    
    if(reagent_type in basic_reagents)
        return 1
    
    // Count how many recipes produce this reagent
    // Fewer recipes = more basic (can't be crafted from much)
    var/produced_count = 0
    for(var/reaction_type in GLOB.chemical_reactions_list)
        var/datum/chemical_reaction/reaction = GLOB.chemical_reactions_list[reaction_type]
        if(reagent_type in reaction.results)
            produced_count++
    
    if(produced_count == 0)
        return 1  // Cannot be crafted = most basic
    
    // More recipes to produce = more complex
    return 2 + produced_count
