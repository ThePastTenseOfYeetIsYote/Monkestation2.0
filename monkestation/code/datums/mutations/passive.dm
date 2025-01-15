/datum/mutation/human/biotechcompat
	power_coeff = 1

/datum/mutation/human/biotechcompat/modify()
	. = ..()
	if(GET_MUTATION_POWER(src) > 1)
		owner.adjust_skillchip_complexity_modifier(floor(GET_MUTATION_POWER(src)))

/datum/mutation/human/biotechcompat/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	if(GET_MUTATION_POWER(src) > 1)
		owner.adjust_skillchip_complexity_modifier(-floor(GET_MUTATION_POWER(src)))
