/**
 * Damage Notifier Component
 *
 * Displays chat messages when a tracked carbon mob takes damage or receives healing.
 * Only active for mobs tagged by an admin via the Tag Datum system.
 * Shows damage type, amount, direction (▼/▲), and projected health.
 */
/datum/component/damage_notifier

/datum/component/damage_notifier/Initialize()
	. = ..()
	if (!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/damage_notifier/RegisterWithParent()
	// Brute and burn from bodypart damage (punching, weapons, etc.)
	RegisterSignal(parent, COMSIG_CARBON_LIMB_DAMAGED, PROC_REF(on_limb_damage))
	// Brute healing — COMSIG_CARBON_TAKE_BRUTE_DAMAGE only fires when amount < 0
	RegisterSignal(parent, COMSIG_CARBON_TAKE_BRUTE_DAMAGE, PROC_REF(on_brute_heal))
	// Damage type adjustments — toxin, oxy, clone, stamina
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
		send_notification(carbon_parent, BRUTE, brute)
	if (burn > 0)
		send_notification(carbon_parent, BURN, burn)

/// Called when a carbon is healed of brute damage (COMSIG_CARBON_TAKE_BRUTE_DAMAGE fires only on healing)
/datum/component/damage_notifier/proc/on_brute_heal(datum/source, amount)
	SIGNAL_HANDLER

	var/mob/living/carbon/carbon_parent = parent
	if (!carbon_parent.tracked || amount >= 0)
		return

	send_notification(carbon_parent, BRUTE, amount)

/// Called for toxin/oxy/clone/stamina damage adjustments
/datum/component/damage_notifier/proc/on_damage_adjusted(datum/source, damage_type, amount, forced)
	SIGNAL_HANDLER

	var/mob/living/carbon/carbon_parent = parent
	if (!carbon_parent.tracked || amount == 0)
		return

	send_notification(carbon_parent, damage_type, amount)

/// Sends damage notification to all admins tracking this mob
/datum/component/damage_notifier/proc/send_notification(mob/living/carbon/carbon_parent, damage_type, amount)
	var/current_health = carbon_parent.health
	var/new_health = current_health - amount
	var/arrow = amount > 0 ? "▼" : "▲"
	var/amount_display = abs(amount)
	var/action = amount > 0 ? "took" : "healed"
	var/damage_name = get_damage_type_name(damage_type)
	var/msg = "[carbon_parent.name] [action] [arrow][amount_display] [damage_name] ([new_health]/[carbon_parent.maxHealth])"

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
