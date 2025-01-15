/datum/mutation/human/hulk
	synchronizer_coeff = 1

/datum/mutation/human/hulk/modify()
	. = ..()
	if(GET_MUTATION_SYNCHRONIZER(src) == 1)
		return

	owner.physiology?.cold_mod *= (GET_MUTATION_SYNCHRONIZER(src) * 1.5)
	owner.bodytemp_cold_damage_limit -= (BODYTEMP_HULK_COLD_DAMAGE_LIMIT_MODIFIER * GET_MUTATION_SYNCHRONIZER(src))

/datum/mutation/human/hulk/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	if(GET_MUTATION_SYNCHRONIZER(src) == 1)
		return

	owner.physiology?.cold_mod /= (GET_MUTATION_SYNCHRONIZER(src) * 1.5)
	owner.bodytemp_cold_damage_limit += (BODYTEMP_HULK_COLD_DAMAGE_LIMIT_MODIFIER * GET_MUTATION_SYNCHRONIZER(src))
