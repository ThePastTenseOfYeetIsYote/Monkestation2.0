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
	. = ..()
	if(.)
		return

	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(eye_implanted))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(eye_removed))

	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
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

	eyes.flash_protect = FLASH_PROTECTION_FLASH

/datum/mutation/human/flash_protection/proc/eye_removed(mob/living/source, obj/item/organ/removed, special)
	SIGNAL_HANDLER

	var/obj/item/organ/internal/eyes/eyes = removed
	if(!istype(eyes))
		return

	eyes.flash_protect = initial(eyes.flash_protect)
