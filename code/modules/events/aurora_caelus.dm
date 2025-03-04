/datum/round_event_control/aurora_caelus
	name = "Aurora Caelus"
	typepath = /datum/round_event/aurora_caelus
	max_occurrences = 1
	weight = 0
	earliest_start = 5 MINUTES
	category = EVENT_CATEGORY_FRIENDLY
	description = "A colourful display can be seen through select windows. And the kitchen."

/datum/round_event_control/aurora_caelus/can_spawn_event(players, allow_magic = FALSE, fake_check = FALSE) //MONKESTATION ADDITION: fake_check = FALSE
	if(!SSmapping.empty_space)
		return FALSE
	return ..()

/datum/round_event/aurora_caelus
	announce_when = 1
	start_when = 9
	end_when = 50
	var/list/aurora_colors = list("#A2FF80", "#A2FF8B", "#A2FF96", "#A2FFA5", "#A2FFB6", "#A2FFC7", "#A2FFDE", "#A2FFEE")
	var/aurora_progress = 0 //this cycles from 1 to 8, slowly changing colors from gentle green to gentle blue

/datum/round_event/aurora_caelus/announce()
	priority_announce("[station_name()]: A harmless cloud of ions is approaching your station, and will exhaust their energy battering the hull. Nanotrasen has approved a short break for all employees to relax and observe this very rare event. During this time, starlight will be bright but gentle, shifting between quiet green and blue colors. Any staff who would like to view these lights for themselves may proceed to the area nearest to them with viewing ports to open space. We hope you enjoy the lights.",
	sound = 'sound/misc/notice2.ogg',
	sender_override = "Nanotrasen Meteorology Division")
	for(var/V in GLOB.player_list)
		var/mob/M = V
		if((M.client.prefs.read_preference(/datum/preference/toggle/sound_midi)) && is_station_level(M.z))
			M.playsound_local(M, 'sound/ambience/aurora_caelus.ogg', 20, FALSE, pressure_affected = FALSE)

/datum/round_event/aurora_caelus/start()
	for(var/area/affected_area as anything in GLOB.areas)
		if(affected_area.area_flags & AREA_USES_STARLIGHT)
			for(var/turf/open/space/spess in affected_area.get_turfs_from_all_zlevels())
				spess.set_light(l_outer_range = spess.light_outer_range * 3, l_power = spess.light_power * 0.5)
		if(istype(affected_area, /area/station/service/kitchen))
			for(var/turf/open/kitchen in affected_area.get_turfs_from_all_zlevels())
				kitchen.set_light(1, 0.75)
			if(!prob(1) && !check_holidays(APRIL_FOOLS))
				continue
			var/obj/machinery/oven/roast_ruiner = locate() in affected_area
			if(roast_ruiner)
				roast_ruiner.balloon_alert_to_viewers("oh egads!")
				var/turf/ruined_roast = get_turf(roast_ruiner)
				ruined_roast.atmos_spawn_air("plasma=100;TEMP=1000")
				message_admins("Aurora Caelus event caused an oven to ignite at [ADMIN_VERBOSEJMP(ruined_roast)].")
				log_game("Aurora Caelus event caused an oven to ignite at [loc_name(ruined_roast)].")
				announce_to_ghosts(roast_ruiner)
			for(var/mob/living/carbon/human/seymour as anything in GLOB.human_list)
				if(seymour.mind && istype(seymour.mind.assigned_role, /datum/job/cook))
					seymour.say("My roast is ruined!!!", forced = "ruined roast")
					seymour.emote("scream")


/datum/round_event/aurora_caelus/tick()
	if(activeFor % 5 == 0)
		aurora_progress++
		var/aurora_color = aurora_colors[aurora_progress]
		for(var/area/affected_area as anything in GLOB.areas)
			if(affected_area.area_flags & AREA_USES_STARLIGHT)
				for(var/turf/open/space/spess in affected_area.get_turfs_from_all_zlevels())
					spess.set_light(l_color = aurora_color)
			if(istype(affected_area, /area/station/service/kitchen))
				for(var/turf/open/kitchen_floor in affected_area.get_turfs_from_all_zlevels())
					kitchen_floor.set_light(l_color = aurora_color)

/datum/round_event/aurora_caelus/end()
	for(var/area in GLOB.areas)
		var/area/affected_area = area
		if(affected_area.area_flags & AREA_USES_STARLIGHT)
			for(var/turf/open/space/spess in affected_area.get_turfs_from_all_zlevels())
				fade_to_black(spess)
		if(istype(affected_area, /area/station/service/kitchen))
			for(var/turf/open/superturfentent in affected_area.get_turfs_from_all_zlevels())
				fade_to_black(superturfentent)
	priority_announce("The aurora caelus event is now ending. Starlight conditions will slowly return to normal. When this has concluded, please return to your workplace and continue work as normal. Have a pleasant shift, [station_name()], and thank you for watching with us.",
	sound = 'sound/misc/notice2.ogg',
	sender_override = "Nanotrasen Meteorology Division")

/datum/round_event/aurora_caelus/proc/fade_to_black(turf/open/space/spess)
	set waitfor = FALSE
	var/new_light = initial(spess.light_outer_range)
	while(spess.light_outer_range > new_light)
		spess.set_light(l_outer_range = spess.light_outer_range - 0.2)
		sleep(30)
	spess.set_light(l_outer_range = new_light, l_power = initial(spess.light_power), l_color = initial(spess.light_color))
