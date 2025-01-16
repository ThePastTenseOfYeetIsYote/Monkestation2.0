/datum/mutation/human/spores
	name = "Agaricale Pores" // Pores, not spores. ITS NOT SPORES!!!!!
	desc = "An ancient mutation that gives florans the ability to produce spores."
	quality = POSITIVE
	difficulty = 12
	text_gain_indication = span_notice("You feel your pores more sensitively..?")
	species_allowed = list(SPECIES_FLORAN)
	instability = 30
	power_path = /datum/action/cooldown/spores

	energy_coeff = 1

/datum/action/cooldown/spores
	name = "Release Spores"
	desc = "Release your blood in a mist using pores."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "smoke"

	cooldown_time = 1 MINUTE
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/spores/Activate(mob/living/carbon/cast_on)
	. = ..()
	var/datum/blood_type/blood = cast_on.get_blood_type()

	var/blood_path = isnull(blood) ? /datum/reagent/drug/mushroomhallucinogen : blood.reagent_type
	var/amount = min(cast_on.blood_volume, 15) // We dont need to check if its below 15 realistically since you'd be dead, but whatever
	var/range = floor(sqrt(amount / 2))

	cast_on.blood_volume -= amount
	do_chem_smoke(range, amount, owner, get_turf(cast_on), blood_path)
	playsound(cast_on, 'sound/effects/smoke.ogg', 50, 1, -3)
	return TRUE
