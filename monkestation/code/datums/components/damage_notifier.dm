/**
 * Damage Notifier Component
 *
 * A debug component that displays chat messages when a carbon mob takes damage or receives healing.
 * Shows the damage type, amount, direction, and current health.
 */
/datum/component/damage_notifier
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/damage_notifier/Initialize()
	. = ..()
	if (!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/damage_notifier/RegisterWithParent()
	// For carbons, brute/burn damage goes through bodyparts, so we need CARBON_LIMB_DAMAGED
	RegisterSignal(parent, COMSIG_CARBON_LIMB_DAMAGED, PROC_REF(on_limb_damage))
	// These still use the living signals
	RegisterSignal(parent, COMSIG_LIVING_ADJUST_TOX_DAMAGE, PROC_REF(on_damage_adjusted))
	RegisterSignal(parent, COMSIG_LIVING_ADJUST_OXY_DAMAGE, PROC_REF(on_damage_adjusted))
	RegisterSignal(parent, COMSIG_LIVING_ADJUST_CLONE_DAMAGE, PROC_REF(on_damage_adjusted))
	RegisterSignal(parent, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, PROC_REF(on_damage_adjusted))
	// Also catch burn damage from non-bodypart sources (reagents, etc)
	RegisterSignal(parent, COMSIG_LIVING_ADJUST_BURN_DAMAGE, PROC_REF(on_damage_adjusted))
	// And catch the carbon-specific brute damage signal
	RegisterSignal(parent, COMSIG_CARBON_TAKE_BRUTE_DAMAGE, PROC_REF(on_carbon_brute_take))

/datum/component/damage_notifier/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CARBON_LIMB_DAMAGED)
	UnregisterSignal(parent, COMSIG_LIVING_ADJUST_TOX_DAMAGE)
	UnregisterSignal(parent, COMSIG_LIVING_ADJUST_OXY_DAMAGE)
	UnregisterSignal(parent, COMSIG_LIVING_ADJUST_CLONE_DAMAGE)
	UnregisterSignal(parent, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE)
	UnregisterSignal(parent, COMSIG_LIVING_ADJUST_BURN_DAMAGE)
	UnregisterSignal(parent, COMSIG_CARBON_TAKE_BRUTE_DAMAGE)

/// Called when a carbon's bodypart takes damage (brute or burn from punching, etc)
/datum/component/damage_notifier/proc/on_limb_damage(datum/source, obj/item/bodypart/limb, brute, burn)
	SIGNAL_HANDLER

	var/mob/living/carbon/carbon_parent = parent
	var/max_health = carbon_parent.maxHealth

	// Handle brute damage
	if (brute != 0)
		send_notification(carbon_parent, BRUTE, brute, max_health)
	// Handle burn damage
	if (burn != 0)
		send_notification(carbon_parent, BURN, burn, max_health)

/// Called when carbon takes brute damage (negative amount = healing)
/datum/component/damage_notifier/proc/on_carbon_brute_take(datum/source, amount)
	SIGNAL_HANDLER
	var/mob/living/carbon/carbon_parent = parent
	var/max_health = carbon_parent.maxHealth
	send_notification(carbon_parent, BRUTE, amount, max_health)

/// Called for toxin/oxy/clone/stamina/burn damage
/datum/component/damage_notifier/proc/on_damage_adjusted(source, damage_type, amount, forced)
	SIGNAL_HANDLER

	if (forced || amount == 0)
		return

	var/mob/living/carbon/carbon_parent = parent
	var/max_health = carbon_parent.maxHealth
	send_notification(carbon_parent, damage_type, amount, max_health)

/// Sends the damage notification
/datum/component/damage_notifier/proc/send_notification(mob/living/carbon/carbon_parent, damage_type, amount, max_health)
	var/current_health = carbon_parent.health
	var/new_health = current_health - amount

	// Determine direction and format
	var/arrow = amount > 0 ? "▼" : "▲"
	var/amount_display = abs(amount)
	var/action = amount > 0 ? " took" : " healed"

	// Get damage type display with color
	var/damage_name = get_damage_type_name(damage_type)

	var/msg = "[carbon_parent.name][action] [arrow][amount_display] [damage_name] ([new_health]/[max_health])"
	// Try both to_chat and visible_message for maximum visibility
	to_chat(carbon_parent, msg)
	carbon_parent.visible_message(msg)

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
