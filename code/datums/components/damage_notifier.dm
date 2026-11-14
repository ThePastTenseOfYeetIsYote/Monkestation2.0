/// Max call stack frames walked when looking for what caused a damage change
#define DAMAGE_NOTIFIER_MAX_FRAMES 30

/**
 * Damage Notifier Component
 *
 * Reports every damage and healing change on a tagged carbon to the admins that tagged it:
 * damage type, amount, bodypart or organ, resulting health and the proc/object/user that caused it.
 *
 * Sources are the [/datum/admins] holders watching the parent. Added by [/datum/admins/proc/add_tagged_datum],
 * removed by [/datum/admins/proc/remove_tagged_datum]; the component deletes itself when the last watcher leaves.
 */
/datum/component/damage_notifier
	dupe_mode = COMPONENT_DUPE_SOURCES

	/// Damage pipeline procs skipped when walking the call stack for the cause of a damage change
	var/static/list/pipeline_procs = list(
		"_SendSignal" = TRUE,
		"on_damage_changed" = TRUE,
		"find_cause" = TRUE,
		"set_current" = TRUE,
		"adjust" = TRUE,
		"adjust_to" = TRUE,
		"revitalize" = TRUE,
		"set_brute_dam" = TRUE,
		"set_burn_dam" = TRUE,
		"set_initial_damage" = TRUE,
		"receive_damage" = TRUE,
		"heal_damage" = TRUE,
		"apply_organ_damage" = TRUE,
		"set_organ_damage" = TRUE,
		"adjustBruteLoss" = TRUE,
		"adjustFireLoss" = TRUE,
		"adjustToxLoss" = TRUE,
		"adjustOxyLoss" = TRUE,
		"adjustCloneLoss" = TRUE,
		"adjustOrganLoss" = TRUE,
		"setBruteLoss" = TRUE,
		"setFireLoss" = TRUE,
		"setToxLoss" = TRUE,
		"setOxyLoss" = TRUE,
		"setCloneLoss" = TRUE,
		"setOrganLoss" = TRUE,
		"apply_damage" = TRUE,
		"apply_damages" = TRUE,
		"take_overall_damage" = TRUE,
		"heal_overall_damage" = TRUE,
		"take_bodypart_damage" = TRUE,
		"heal_bodypart_damage" = TRUE,
		"heal_damage_type" = TRUE,
		"heal_ordered_damage" = TRUE,
	)

/datum/component/damage_notifier/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/damage_notifier/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_DAMAGE_CHANGED, PROC_REF(on_damage_changed))

/datum/component/damage_notifier/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_DAMAGE_CHANGED)

/// Reports a damage or healing change on our parent to every watching admin
/datum/component/damage_notifier/proc/on_damage_changed(mob/living/carbon/source, damage_type, delta, atom/damaged_part)
	SIGNAL_HANDLER

	var/amount = round(abs(delta), DAMAGE_PRECISION)
	if(!amount)
		return

	// list(proc name, proc src) of the first proc outside the damage pipeline
	var/list/cause = find_cause()
	var/datum/cause_src = cause?[2]
	// Organs decaying inside a corpse every tick is noise, not damage anyone dealt
	if(cause?[1] == "on_death" && isorgan(cause_src))
		return

	var/change = delta > 0 ? span_red("took [amount]") : span_green("healed [amount]")
	var/part_label = damaged_part ? " ([damaged_part.name])" : ""

	var/status
	switch(damage_type)
		if(STAMINA)
			status = "Stamina [round(source.stamina.current, DAMAGE_PRECISION)]/[source.stamina.maximum]"
		if(BRAIN, ORGAN_DAMAGE)
			var/obj/item/organ/organ = damaged_part
			status = "[organ.name] [round(organ.damage, DAMAGE_PRECISION)]/[organ.maxHealth] | Health [source.calculate_health()]/[source.maxHealth]"
		else
			status = "Health [source.calculate_health()]/[source.maxHealth]"

	var/cause_text = ""
	if(cause)
		cause_text = " | via [cause[1]]()"
		if(cause_src && cause_src != parent)
			cause_text += " of [cause_src] ([cause_src.type])"
	if(ismob(usr) && usr != parent)
		cause_text += " by [key_name_admin(usr)]"
	var/message = span_adminnotice("<b>DAMAGE:</b> [source] [change] [get_damage_type_name(damage_type)][part_label] | [status][cause_text]")
	for(var/datum/admins/watcher as anything in sources)
		watcher.receive_damage_report(message)

/// Walks the call stack past the damage pipeline. Returns list(proc name, proc src) for the first proc outside it, or null
/datum/component/damage_notifier/proc/find_cause()
	var/frames = 0
	for(var/callee/frame = caller; frame && frames < DAMAGE_NOTIFIER_MAX_FRAMES; frame = frame.caller)
		frames++
		if(!frame.proc)
			continue
		var/proc_path = "[frame.proc.type]"
		var/proc_name = copytext(proc_path, findlasttext(proc_path, "/") + 1)
		if(pipeline_procs[proc_name])
			continue
		return list(proc_name, frame.src)
	return null

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
		if(BRAIN)
			return span_purple("Brain")
		if(ORGAN_DAMAGE)
			return span_orange("Organ")
	return "[damage_type]"

#undef DAMAGE_NOTIFIER_MAX_FRAMES
