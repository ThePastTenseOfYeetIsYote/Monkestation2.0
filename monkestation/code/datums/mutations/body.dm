/datum/mutation/human/dwarfism
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/dwarfism/modify()
	. = ..()
	if(GET_MUTATION_POWER(src) > 1)
		ADD_TRAIT(owner, TRAIT_FAST_CLIMBER, GENETIC_MUTATION)
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		ADD_TRAIT(owner, TRAIT_STABLE_DWARF, GENETIC_MUTATION)

/datum/mutation/human/dwarfism/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	if(GET_MUTATION_POWER(src) > 1)
		REMOVE_TRAIT(owner, TRAIT_FAST_CLIMBER, GENETIC_MUTATION)
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		REMOVE_TRAIT(owner, TRAIT_STABLE_DWARF, GENETIC_MUTATION)

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

/datum/mutation/human/gigantism
	power_coeff = 1
	var/datum/component/tackling_component

/datum/mutation/human/gigantism/Destroy()
	tackling_component = null
	return ..()

/datum/mutation/human/gigantism/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(. || GET_MUTATION_POWER(src) <= 1)
		return
	QDEL_NULL(tackling_component)

/datum/mutation/human/gigantism/modify()
	. = ..()
	if(GET_MUTATION_POWER(src) > 1) // Psst, the tackling component's stats are just copied from the gorilla gloves, but doubled stamina cost
		tackling_component = owner.AddComponent(/datum/component/tackler, stamina_cost = 60, base_knockdown = 1.25 SECONDS, range = 5, speed = 1, skill_mod = 2, min_distance = 0)

/datum/mutation/human/spastic
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/human/spastic/modify()
	. = ..()
	var/datum/status_effect/spasms/status_effect = locate(/datum/status_effect/spasms) in owner.status_effects
	if(status_effect)
		status_effect.mutation_synchronizer = GET_MUTATION_SYNCHRONIZER(src)
		status_effect.mutation_power = GET_MUTATION_POWER(src)
		status_effect.mutation_energy = GET_MUTATION_ENERGY(src)

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

/datum/mutation/human/radproof
	name = "Radproof"
	desc = "Adapts the host's body to be better suited at preventing cancer caused by radioactivity at the expense of it's ability to handle toxic matter."
	quality = POSITIVE
	text_gain_indication = span_warning("You can't feel it in your bones!")
	instability = 35
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/radproof/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	ADD_TRAIT(owner, TRAIT_RADIMMUNE, GENETIC_MUTATION)
	owner.physiology?.tox_mod *= 1.5

/datum/mutation/human/radproof/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	REMOVE_TRAIT(owner, TRAIT_RADIMMUNE, GENETIC_MUTATION)
	owner.physiology?.tox_mod /= 1.5
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.physiology?.tox_mod /= 0.85
	if(GET_MUTATION_POWER(src) > 1)
		REMOVE_TRAIT(owner, TRAIT_RADHEALING, GENETIC_MUTATION)

/datum/mutation/human/radproof/modify()
	. = ..()
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.physiology?.tox_mod *= 0.85
	if(GET_MUTATION_POWER(src) > 1)
		ADD_TRAIT(owner, TRAIT_RADHEALING, GENETIC_MUTATION)

/datum/mutation/human/thickskin
	name = "Thick skin"
	desc = "The user's skin acquires a leathery texture, and becomes more resilient to harm."
	quality = POSITIVE
	text_gain_indication = span_notice("Your skin feels dry and heavy.")
	text_lose_indication = span_notice("Your skin feels soft again...")
	instability = 30
	difficulty = 18
	power_coeff = 1

/datum/mutation/human/thickskin/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	owner.physiology?.brute_mod *= 0.8
	owner.physiology?.burn_mod *= 0.9

/datum/mutation/human/thickskin/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	owner.physiology?.brute_mod /= 0.8
	owner.physiology?.burn_mod /= 0.9
	if(GET_MUTATION_POWER(src) > 1)
		owner.physiology?.brute_mod /= 0.9
		owner.physiology?.burn_mod /= 0.95

/datum/mutation/human/thickskin/modify()
	. = ..()
	if(GET_MUTATION_POWER(src) > 1)
		owner.physiology?.brute_mod *= 0.9
		owner.physiology?.burn_mod *= 0.95

/datum/mutation/human/hypermarrow
	name = "Hyperactive Bone Marrow"
	desc = "A mutation that stimulates the subject's bone marrow causes it to work three times faster than usual."
	quality = POSITIVE
	text_gain_indication = span_notice("You feel your bones ache for a moment.")
	text_lose_indication = span_notice("You feel something in your bones calm down.")
	instability = 20
	difficulty = 12
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/hypermarrow/on_acquiring(mob/living/carbon/human/owner)
	if(HAS_TRAIT(owner, TRAIT_NOBLOOD))
		return TRUE // No bone marrow to regenerate blood in the first place
	return ..()

/datum/mutation/human/hypermarrow/on_life(seconds_per_tick, times_fired)
	if(HAS_TRAIT(owner, TRAIT_NOBLOOD))
		return
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume += (GET_MUTATION_POWER(src) * seconds_per_tick - 1)
		owner.adjust_nutrition((GET_MUTATION_POWER(src) * GET_MUTATION_SYNCHRONIZER(src) * seconds_per_tick - 0.8) * HUNGER_FACTOR)

/datum/mutation/human/densebones
	name = "Bone Densification"
	desc = "A mutation that gives the subject a rare form of increased bone density, making their entire body slightly more resilient to low kinetic blows."
	quality = POSITIVE
	text_gain_indication = span_notice("You feel your bones get denser.")
	text_lose_indication = span_notice("You feel your bones get lighter.")
	instability = 25
	difficulty = 16
	power_coeff = 1

/datum/mutation/human/densebones/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	var/datum/armor/owner_armor = owner.get_armor()
	var/list/armorlist = owner_armor.get_rating_list()
	armorlist[MELEE] += 5
	armorlist[WOUND] += 10

	owner.set_armor(owner_armor.generate_new_with_specific(armorlist))

/datum/mutation/human/densebones/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	var/datum/armor/owner_armor = owner.get_armor()
	var/list/armorlist = owner_armor.get_rating_list()
	armorlist[MELEE] -= 5
	armorlist[WOUND] -= 10

	owner.set_armor(owner_armor.generate_new_with_specific(armorlist))
	if(GET_MUTATION_POWER(src) > 1)
		REMOVE_TRAIT(owner, TRAIT_HARDLY_WOUNDED, GENETIC_MUTATION)

/datum/mutation/human/densebones/modify()
	. = ..()
	if(GET_MUTATION_POWER(src) > 1)
		ADD_TRAIT(owner, TRAIT_HARDLY_WOUNDED, GENETIC_MUTATION)

/datum/mutation/human/cerebral
	name = "Cerebral Neuroplasticity"
	desc = "A mutation that reorganizes the subject's brain, giving them more stamina while allowing for a slightly quicker recovery speed if exhausted."
	locked = TRUE
	quality = POSITIVE
	text_gain_indication = span_notice("You feel your brain get sturdier.")
	text_lose_indication = span_notice("You feel your brain getting weaker. ")
	instability = 60
	power_coeff = 1

/datum/mutation/human/cerebral/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	owner.physiology?.stamina_mod *= 0.7
	owner.physiology?.stun_mod *= 0.85

/datum/mutation/human/cerebral/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	owner.physiology?.stamina_mod /= 0.7
	owner.physiology?.stun_mod /= 0.85
	if(GET_MUTATION_POWER(src) > 1)
		owner.physiology?.stamina_mod /= 0.85
		owner.physiology?.stun_mod /= 0.925

/datum/mutation/human/cerebral/modify()
	. = ..()
	if(GET_MUTATION_POWER(src) > 1)
		owner.physiology?.stamina_mod *= 0.85
		owner.physiology?.stun_mod *= 0.925
