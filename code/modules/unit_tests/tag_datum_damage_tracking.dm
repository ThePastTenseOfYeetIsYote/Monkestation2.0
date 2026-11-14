#define TRACKER_TEST_CKEY "tagdamagetrackingunittest"

/// Admin holder that records damage reports instead of sending them to a client
/datum/admins/unit_test_damage_tracker
	var/list/reports = list()

/datum/admins/unit_test_damage_tracker/receive_damage_report(message)
	reports += message

/// Tests that tagging a carbon with Tag Datum reports every kind of damage and healing to the admin, and untagging stops it
/datum/unit_test/tag_datum_damage_tracking

/datum/unit_test/tag_datum_damage_tracking/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/datum/admins/unit_test_damage_tracker/watcher = new(list(), TRACKER_TEST_CKEY)

	watcher.add_tagged_datum(dummy)
	TEST_ASSERT_NOTNULL(dummy.GetComponent(/datum/component/damage_notifier), "Tagging a carbon did not start damage tracking")

	check_report(watcher, "brute damage", "took", "Brute", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, apply_damage), 10, BRUTE))
	check_report(watcher, "brute healing", "healed", "Brute", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, adjustBruteLoss), -5))
	check_report(watcher, "burn damage", "took", "Burn", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, apply_damage), 10, BURN))
	check_report(watcher, "burn healing", "healed", "Burn", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, adjustFireLoss), -5))
	check_report(watcher, "toxin damage", "took", "Toxin", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, adjustToxLoss), 10))
	check_report(watcher, "toxin healing", "healed", "Toxin", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, adjustToxLoss), -5))
	check_report(watcher, "oxygen damage", "took", "Oxygen", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, adjustOxyLoss), 10))
	check_report(watcher, "oxygen healing", "healed", "Oxygen", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, setOxyLoss), 0))
	check_report(watcher, "clone damage", "took", "Clone", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, adjustCloneLoss), 10))
	check_report(watcher, "clone healing", "healed", "Clone", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, adjustCloneLoss), -5))
	check_report(watcher, "stamina damage", "took", "Stamina", CALLBACK(dummy.stamina, TYPE_PROC_REF(/datum/stamina_container, adjust), -20))
	check_report(watcher, "stamina healing", "healed", "Stamina", CALLBACK(dummy.stamina, TYPE_PROC_REF(/datum/stamina_container, adjust), 10))
	check_report(watcher, "brain damage", "took", "Brain", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, adjustOrganLoss), ORGAN_SLOT_BRAIN, 10))
	check_report(watcher, "brain healing", "healed", "Brain", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, adjustOrganLoss), ORGAN_SLOT_BRAIN, -5))
	check_report(watcher, "organ damage", "took", "Organ", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, adjustOrganLoss), ORGAN_SLOT_LIVER, 10))
	check_report(watcher, "organ healing", "healed", "Organ", CALLBACK(dummy, TYPE_PROC_REF(/mob/living, adjustOrganLoss), ORGAN_SLOT_LIVER, -5))

	watcher.remove_tagged_datum(dummy, silent = TRUE)
	TEST_ASSERT_NULL(dummy.GetComponent(/datum/component/damage_notifier), "Untagging a carbon did not stop damage tracking")
	watcher.reports.Cut()
	dummy.apply_damages(brute = 10, burn = 10, tox = 10, oxy = 10, clone = 10, stamina = 10, brain = 10)
	TEST_ASSERT_EQUAL(length(watcher.reports), 0, "Damage was still reported after the carbon was untagged")

	GLOB.deadmins -= TRACKER_TEST_CKEY
	qdel(watcher)

/// Runs the damage change and asserts the watcher got a report of the right direction and damage type
/datum/unit_test/tag_datum_damage_tracking/proc/check_report(datum/admins/unit_test_damage_tracker/watcher, description, direction, type_label, datum/callback/damage_change)
	watcher.reports.Cut()
	damage_change.Invoke()
	if(!length(watcher.reports))
		TEST_FAIL("No report was sent for [description]")
		return
	for(var/report in watcher.reports)
		if(findtext(report, direction) && findtext(report, type_label))
			return
	TEST_FAIL("No [description] report contained \"[direction]\" and \"[type_label]\". Reports: [jointext(watcher.reports, " || ")]")

#undef TRACKER_TEST_CKEY
