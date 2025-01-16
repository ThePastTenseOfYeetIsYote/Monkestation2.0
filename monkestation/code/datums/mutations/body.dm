/datum/mutation/human/strong
	instability = 25
	power_coeff = 1
	var/list/affected_limbs = list(
		BODY_ZONE_L_ARM = null,
		BODY_ZONE_R_ARM = null,
		BODY_ZONE_L_LEG = null,
		BODY_ZONE_R_LEG = null,
	)

/datum/mutation/human/strong/Destroy()
	for(var/body_part as anything in affected_limbs)
		if(!isnull(affected_limbs[body_part]))
			unregister_limb(null, affected_limbs[body_part])
	return ..()

/datum/mutation/human/strong/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	RegisterSignal(owner, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(register_limb))
	RegisterSignal(owner, COMSIG_CARBON_POST_REMOVE_LIMB, PROC_REF(unregister_limb))
	for(var/body_part as anything in affected_limbs)
		var/obj/item/bodypart/limb = owner.get_bodypart(check_zone(body_part))
		if(!limb)
			continue

		register_limb(owner, limb, initial = TRUE)

/datum/mutation/human/strong/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	UnregisterSignal(owner, COMSIG_CARBON_POST_ATTACH_LIMB)
	UnregisterSignal(owner, COMSIG_CARBON_POST_REMOVE_LIMB)
	for(var/body_part as anything in affected_limbs)
		var/obj/item/bodypart/limb = owner.get_bodypart(check_zone(body_part))
		if(!limb)
			continue

		unregister_limb(owner, limb)

/datum/mutation/human/strong/modify()
	. = ..()
	if(GET_MUTATION_POWER(src) == 1)
		return

	for(var/body_part as anything in affected_limbs)
		var/obj/item/bodypart/limb = affected_limbs[body_part]
		limb.unarmed_damage_low += ((4 * GET_MUTATION_POWER(src)) - 4) // Bit cursed? Yep. Works with any mutation power? Yep.
		limb.unarmed_damage_high += ((4 * GET_MUTATION_POWER(src)) - 4)

/datum/mutation/human/strong/proc/register_limb(mob/living/carbon/human/owner, obj/item/bodypart/new_limb, special, initial = FALSE)
	SIGNAL_HANDLER
	if(new_limb.body_zone == BODY_ZONE_HEAD || new_limb.body_zone == BODY_ZONE_CHEST)
		return

	affected_limbs[new_limb.body_zone] = new_limb
	RegisterSignal(new_limb, COMSIG_QDELETING, PROC_REF(limb_gone))
	if(initial)
		new_limb.unarmed_damage_low += 4
		new_limb.unarmed_damage_high += 4
		return

	new_limb.unarmed_damage_low += (4 * GET_MUTATION_POWER(src))
	new_limb.unarmed_damage_high += (4 * GET_MUTATION_POWER(src))

/datum/mutation/human/strong/proc/unregister_limb(mob/living/carbon/human/owner, obj/item/bodypart/lost_limb, special)
	SIGNAL_HANDLER
	if(lost_limb.body_zone == BODY_ZONE_HEAD || lost_limb.body_zone == BODY_ZONE_CHEST)
		return

	affected_limbs[lost_limb.body_zone] = null
	UnregisterSignal(lost_limb, COMSIG_QDELETING)
	lost_limb.unarmed_damage_low -= (4 * GET_MUTATION_POWER(src))
	lost_limb.unarmed_damage_high -= (4 * GET_MUTATION_POWER(src))

/datum/mutation/human/strong/proc/limb_gone(obj/item/bodypart/deleted_limb)
	SIGNAL_HANDLER
	if(affected_limbs[deleted_limb.body_zone])
		affected_limbs[deleted_limb.body_zone] = null
		UnregisterSignal(deleted_limb, COMSIG_QDELETING)

/datum/mutation/human/stimmed
	instability = 20
	power_coeff = 1

/datum/mutation/human/stimmed/on_life(seconds_per_tick, times_fired)
	if(HAS_TRAIT(owner, TRAIT_STASIS) || owner.stat == DEAD)
		return

	owner.reagents.remove_all(GET_MUTATION_POWER(src) * REM * seconds_per_tick)

/datum/mutation/human/acidflesh
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/human/acidflesh/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(13 / GET_MUTATION_ENERGY(src), seconds_per_tick))
		if(COOLDOWN_FINISHED(src, msgcooldown))
			to_chat(owner, span_danger("Your acid flesh bubbles..."))
			COOLDOWN_START(src, msgcooldown, 20 SECONDS)
		if(prob(15))
			owner.acid_act(rand(30, 50) * GET_MUTATION_SYNCHRONIZER(src) * GET_MUTATION_POWER(src), 10)
			owner.visible_message(span_warning("[owner]'s skin bubbles and pops."), span_userdanger("Your bubbling flesh pops! It burns!"))
			playsound(owner,'sound/weapons/sear.ogg', 50, TRUE)

// you can't become double-giant
/datum/mutation/human/gigantism/on_acquiring(mob/living/carbon/human/acquirer)
	if(acquirer && HAS_TRAIT_FROM(acquirer, TRAIT_GIANT, QUIRK_TRAIT))
		return TRUE
	return ..()

/datum/mutation/human/extrastun
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/// Triggers on moved(). Randomly makes the owner trip
/datum/mutation/human/extrastun/proc/on_move()
	SIGNAL_HANDLER

	if(prob(99.25 + (0.25 * GET_MUTATION_SYNCHRONIZER(src) / GET_MUTATION_ENERGY(src)))) // The brawl mutation
		return
	if(owner.buckled || owner.body_position == LYING_DOWN || HAS_TRAIT(owner, TRAIT_IMMOBILIZED) || owner.throwing || owner.movement_type & (VENTCRAWLING | FLYING | FLOATING))
		return // Remove the 'edge' cases
	to_chat(owner, span_danger("You trip over your own feet."))
	owner.Knockdown((3 SECONDS) * GET_MUTATION_POWER(src))

/datum/mutation/human/headless
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/headless/modify()
	. = ..()
	var/obj/item/bodypart/chest = owner.get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return

	if(GET_MUTATION_POWER(src) > 1)
		chest.receive_damage(10 * GET_MUTATION_POWER(src))

	if(GET_MUTATION_SYNCHRONIZER(src) < 1) // Keep in mind, when getting HARS we are guaranteed at LEAST 15 brute damage
		chest.heal_damage(5 / GET_MUTATION_SYNCHRONIZER(src))
