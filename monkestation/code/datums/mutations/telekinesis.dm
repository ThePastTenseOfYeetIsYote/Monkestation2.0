/datum/mutation/human/telekinesis
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/telekinesis/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	if(GET_MUTATION_POWER(src) > 1)
		UnregisterSignal(owner, COMSIG_LIVING_TRY_PULL)

/datum/mutation/human/telekinesis/modify()
	. = ..()
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.update_mutations_overlay()
	if(GET_MUTATION_POWER(src) > 1)
		RegisterSignal(owner, COMSIG_LIVING_TRY_PULL, PROC_REF(on_try_pull))

/datum/mutation/human/telekinesis/get_visual_indicator()
	if(GET_MUTATION_SYNCHRONIZER(src) < 1) // Stealth
		return FALSE

	return visual_indicators[type][1]

/datum/mutation/human/telekinesis/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/human/telekinesis/proc/on_try_pull(mob/user, atom/movable/target, force)
	SIGNAL_HANDLER
	if(!istype(user))
		return

	return !user.Adjacent(target) && COMSIG_LIVING_CANCEL_PULL

/mob/attack_tk(mob/user, power_chromosome = FALSE)
	if(!power_chromosome)
		return
	if(istate & ISTATE_SECONDARY) // Blocks grabbing from a distance, its buggy to say the least
		return

	. = ..()
	if(. & COMPONENT_CANCEL_ATTACK_CHAIN)
		user.changeNext_move(CLICK_CD_MELEE)
