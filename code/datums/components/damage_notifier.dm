/**
 * Damage Notifier Component
 *
 * Displays clean damage/healing reports in admin chat for tagged mobs.
 * Only active for carbons tagged via the Tag Datum system.
 * Shows damage type, amount, bodypart (for limbs), and resulting health.
 */
/datum/component/damage_notifier

/datum/component/damage_notifier/Initialize()
	. = ..()
	if (!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/damage_notifier/RegisterWithParent()
	// Brute and burn via bodypart damage (punching, weapons, etc.)
	RegisterSignal(parent, COMSIG_CARBON_LIMB_DAMAGED, PROC_REF(on_limb_damage))
	// Brute healing — COMSIG_CARBON_TAKE_BRUTE_DAMAGE only fires when amount < 0
	RegisterSignal(parent, COMSIG_CARBON_TAKE_BRUTE_DAMAGE, PROC_REF(on_brute_heal))
	// Non-bodypart damage types
	RegisterSignal(parent, COMSIG_LIVING_ADJUST_TOX_DAMAGE, PROC_REF(on_damage_adjusted))
	RegisterSignal(parent, COMSIG_LIVING_ADJUST_OXY_DAMAGE, PROC_REF(on_damage_adjusted))
	RegisterSignal(parent, COMSIG_LIVING_ADJUST_CLONE_DAMAGE, PROC_REF(on_damage_adjusted))
	RegisterSignal(parent, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, PROC_REF(on_damage_adjusted))

/datum/component/damage_notifier/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CARBON_LIMB_DAMAGED)
	UnregisterSignal(parent, COMSIG_CARBON_TAKE_BRUTE_DAMAGE)
	UnregisterSignal(parent, COMSIG_LIVING_ADJUST_TOX_DAMAGE)
	UnregisterSignal(parent, COMSIG_LIVING_ADJUST_OXY_DAMAGE)
	UnregisterSignal(parent, COMSIG_LIVING_ADJUST_CLONE_DAMAGE)
	UnregisterSignal(parent, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE)

/// Called when a carbon's bodypart takes damage — captures brute and burn from hits
/datum/component/damage_notifier/proc/on_limb_damage(datum/source, obj/item/bodypart/limb, brute, burn)
	SIGNAL_HANDLER

	var/mob/living/carbon/carbon_parent = parent
	if (!carbon_parent.tracked)
		return

	if (brute > 0)
		send_notification(carbon_parent, BRUTE, brute, limb)
	if (burn > 0)
		send_notification(carbon_parent, BURN, burn, limb)

/// Called when a carbon is healed of brute damage (COMSIG_CARBON_TAKE_BRUTE_DAMAGE fires only on healing)
/datum/component/damage_notifier/proc/on_brute_heal(datum/source, amount)
	SIGNAL_HANDLER

	var/mob/living/carbon/carbon_parent = parent
	if (!carbon_parent.tracked || amount >= 0)
		return

	send_notification(carbon_parent, BRUTE, amount)

/// Called for toxin/oxy/clone damage adjustments
/datum/component/damage_notifier/proc/on_damage_adjusted(datum/source, damage_type, amount, forced)
	SIGNAL_HANDLER

	var/mob/living/carbon/carbon_parent = parent
	if (!carbon_parent.tracked || amount == 0)
		return

	send_notification(carbon_parent, damage_type, amount)

/// Builds and sends a damage/heal report to all admins tracking this mob
/datum/component/damage_notifier/proc/send_notification(mob/living/carbon/carbon_parent, damage_type, amount, obj/item/bodypart/limb)
	var/new_health = carbon_parent.health - amount
	var/max_health = carbon_parent.maxHealth

	// Direction and amount
	var/direction = amount > 0 ? "▼" : "▲"
	var/display_amount = abs(amount)
	var/damage_name = get_damage_type_name(damage_type)

	// Bodypart label (only for limb damage)
	var/limb_label = ""
	if (limb)
		limb_label = " [limb.name]"

	// Health summary — skip for stamina since it tracks separately from mob health
	var/health_summary = ""
	if (damage_type != STAMINA)
		health_summary = " →  [new_health]/[max_health]"

	var/msg = "[carbon_parent.name] [damage_name][limb_label] [direction][display_amount][health_summary]"

	for(var/client/admin as anything in GLOB.admins)
		if(LAZYFIND(admin.holder.tagged_datums, carbon_parent))
			to_chat(admin, msg)

/// Returns the colored damage type name
/datum/component/damage_notifier/proc/get_damage_type_name(damage_type)
	switch(damage_type)
		if(BRUTE)
			return span_red("Brute")
		if(BURN)
			return span_orange("Burn")
		if(TOX)
			return span_green("Toxin")
		if(OXY)
			return span_blue("Oxygen")
		if(CLONE)
			return span_purple("Clone")
		if(STAMINA)
			return span_yellow("Stamina")
		else
			return "Unknown"
