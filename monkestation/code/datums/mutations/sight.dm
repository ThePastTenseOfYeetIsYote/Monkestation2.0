/datum/mutation/human/laser_eyes
	power_coeff = 1
	energy_coeff = 1

/// Laser eyes made by a geneticist
/datum/mutation/human/laser_eyes/unstable
	name = "Unstable Laser Eyes"
	instability = 60

/datum/mutation/human/meson_vision
	name = "Meson Visual Enhancement"
	desc = "A mutation that manipulates the subject's eyes in a way that makes them able to see behind walls to a limited degree."
	quality = POSITIVE
	text_gain_indication = span_notice("More information seems to reach your eyes...")
	text_lose_indication = span_notice("The amount of information reaching your eyes fades...")
	instability = 20

/datum/mutation/human/meson_vision/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	owner.add_traits(list(TRAIT_MADNESS_IMMUNE, TRAIT_MESON_VISION), GENETIC_MUTATION)
	owner.update_sight()

/datum/mutation/human/meson_vision/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	owner.remove_traits(list(TRAIT_MADNESS_IMMUNE, TRAIT_MESON_VISION), GENETIC_MUTATION)
	owner.update_sight()

/datum/mutation/human/night_vision
	name = "Scotopic Visual Enhancement"
	desc = "A mutation that manipulates the subject's eyes in a way that makes them able to see in the dark."
	quality = POSITIVE
	text_gain_indication = span_notice("Were the lights always that bright?")
	text_lose_indication = span_notice("The ambient light level returns to normal...")
	instability = 25

/datum/mutation/human/night_vision/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	ADD_TRAIT(owner, TRAIT_NIGHT_VISION, GENETIC_MUTATION)
	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.refresh()

	owner.update_sight()

/datum/mutation/human/night_vision/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	REMOVE_TRAIT(owner, TRAIT_NIGHT_VISION, GENETIC_MUTATION)
	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.refresh()

	owner.update_sight()

/datum/mutation/human/flash_protection
	name = "Protected Cornea"
	desc = "A mutation that causes reinforcement to subject's eyes, allowing them to protect against disorientation from bright flashes via distributing excessive photons hitting the subject's eyes."
	locked = TRUE
	quality = POSITIVE
	text_gain_indication = span_notice("You stop noticing the glare from lights...")
	text_lose_indication = span_notice("Lights begin glaring again...")
	instability = 30

/datum/mutation/human/flash_protection/on_acquiring(mob/living/carbon/human/owner)
	if(!owner)
		return TRUE

	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes && eyes.status == ORGAN_ROBOTIC)
		return TRUE

	. = ..()
	if(.)
		return

	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(eye_implanted))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(eye_removed))
	if(eyes)
		eyes.flash_protect = FLASH_PROTECTION_FLASH

/datum/mutation/human/flash_protection/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	UnregisterSignal(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.flash_protect = initial(eyes.flash_protect)

/datum/mutation/human/flash_protection/proc/eye_implanted(mob/living/source, obj/item/organ/gained, special)
	SIGNAL_HANDLER

	var/obj/item/organ/internal/eyes/eyes = gained
	if(!istype(eyes))
		return

	if(eyes.status == ORGAN_ROBOTIC)
		return

	eyes.flash_protect = FLASH_PROTECTION_FLASH

/datum/mutation/human/flash_protection/proc/eye_removed(mob/living/source, obj/item/organ/removed, special)
	SIGNAL_HANDLER

	var/obj/item/organ/internal/eyes/eyes = removed
	if(!istype(eyes))
		return

	eyes.flash_protect = initial(eyes.flash_protect)

/datum/mutation/human/weaker_xray
	name = "X-Ray Vision"
	desc = "A strange genome that allows the user to see between the spaces of walls at the cost of their eye health."
	power_path = /datum/action/cooldown/toggle_xray
	instability = 60
	locked = TRUE

/datum/action/cooldown/toggle_xray
	name = "Toggle X-ray"
	desc = "Concentrate your eyes to see through the walls, this makes your eyes take damage and be weaker to flashes."
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "augmented_eyesight"
	var/toggle = FALSE

/datum/action/cooldown/toggle_xray/Grant(mob/granted_to)
	. = ..()
	if(!owner)
		return

	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(eye_implanted))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(eye_removed))

/datum/action/cooldown/toggle_xray/Remove(mob/removed_from)
	if(owner)
		UnregisterSignal(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
		if(toggle)
			toggle_off()
	return ..()

/datum/action/cooldown/toggle_xray/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		if(feedback)
			to_chat(owner, span_warning("You don't have eyes to use X-ray with!"))
		return FALSE

	if(eyes.organ_flags & ORGAN_FAILING)
		if(feedback)
			to_chat(owner, span_warning("You can't use your X-ray vision whilst blind!"))
		return FALSE

	if(eyes.status == ORGAN_ROBOTIC)
		if(feedback)
			owner.balloon_alert(owner, "eyes robotic!")
		return FALSE

	return TRUE

/datum/action/cooldown/toggle_xray/Activate(atom/target)
	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		return

	toggle = !toggle
	if(toggle)
		to_chat(owner, span_notice("You feel your eyes sting as you force them to see through solid matter."))
		eyes.flash_protect--
		eyes.apply_organ_damage(5)
		ADD_TRAIT(owner, TRAIT_XRAY_VISION, GENETIC_MUTATION)
		owner.update_sight()
		START_PROCESSING(SSobj, src)
	else
		to_chat(owner, span_notice("You adjust your eyes to no longer see past the walls."))
		toggle_off()

/datum/action/cooldown/toggle_xray/process(seconds_per_tick)
	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		toggle = !toggle
		toggle_off()
		return

	eyes.apply_organ_damage(seconds_per_tick * 2)
	if(eyes.organ_flags & ORGAN_FAILING)
		toggle = !toggle
		toggle_off()

/datum/action/cooldown/toggle_xray/StartCooldownSelf(override_cooldown_time) // Since we're using process, this cant happen
	return

/datum/action/cooldown/toggle_xray/proc/toggle_off()
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, GENETIC_MUTATION)
	STOP_PROCESSING(SSobj, src)
	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.flash_protect++

	owner.update_sight()

/datum/action/cooldown/toggle_xray/proc/eye_implanted(mob/living/source, obj/item/organ/gained, special)
	SIGNAL_HANDLER

	var/obj/item/organ/internal/eyes/eyes = gained
	if(!istype(eyes))
		return

	eyes.flash_protect--

/datum/action/cooldown/toggle_xray/proc/eye_removed(mob/living/source, obj/item/organ/removed, special)
	SIGNAL_HANDLER

	var/obj/item/organ/internal/eyes/eyes = removed
	if(!istype(eyes))
		return

	eyes.flash_protect = initial(eyes.flash_protect)
	if(toggle)
		toggle = !toggle
		toggle_off()
