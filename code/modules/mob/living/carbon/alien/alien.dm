/mob/living/carbon/alien
	name = "alien"
	icon = 'icons/mob/nonhuman-player/alien.dmi'
	gender = FEMALE //All xenos are girls!!
	dna = null
	faction = list(ROLE_ALIEN)
	sight = SEE_MOBS
	verb_say = "hisses"
	initial_language_holder = /datum/language_holder/alien
	bubble_icon = "alien"
	type_of_meat = /obj/item/food/meat/slab/xeno
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE

	status_flags = CANUNCONSCIOUS|CANPUSH

	temperature_insulation = 0.5 // minor heat insulation
	bodytemp_heat_damage_limit = CELCIUS_TO_KELVIN(85 CELCIUS)

	var/leaping = FALSE
	gib_type = /obj/effect/decal/cleanable/xenoblood/xgibs
	unique_name = TRUE

	var/static/regex/alien_name_regex = new("alien (larva|sentinel|drone|hunter|praetorian|queen)( \\(\\d+\\))?")

/mob/living/carbon/alien/Initialize(mapload)
	add_verb(src, /mob/living/proc/mob_sleep)
	add_verb(src, /mob/living/proc/toggle_resting)

	create_bodyparts() //initialize bodyparts

	create_internal_organs()

	add_traits(list(TRAIT_NEVER_WOUNDED, TRAIT_VENTCRAWLER_ALWAYS), INNATE_TRAIT)

	. = ..()

/mob/living/carbon/alien/create_internal_organs()
	organs += new /obj/item/organ/internal/brain/alien
	organs += new /obj/item/organ/internal/alien/hivenode
	organs += new /obj/item/organ/internal/tongue/alien
	organs += new /obj/item/organ/internal/eyes/alien
	organs += new /obj/item/organ/internal/liver/alien
	organs += new /obj/item/organ/internal/ears
	..()

/mob/living/carbon/alien/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) // beepsky won't hunt aliums
	return -10

/mob/living/carbon/alien/body_temperature_alerts()
	if(bodytemperature > bodytemp_heat_damage_limit)
		throw_alert(ALERT_XENO_FIRE, /atom/movable/screen/alert/alien_fire)
	else
		clear_alert(ALERT_XENO_FIRE)

/mob/living/carbon/alien/getTrail()
	if(getBruteLoss() < 200)
		return pick (list("xltrails_1", "xltrails2"))
	else
		return pick (list("xttrails_1", "xttrails2"))
/*----------------------------------------
Proc: AddInfectionImages()
Des: Gives the client of the alien an image on each infected mob.
----------------------------------------*/
/mob/living/carbon/alien/proc/AddInfectionImages()
	if (client)
		for (var/i in GLOB.mob_living_list)
			var/mob/living/L = i
			if(HAS_TRAIT(L, TRAIT_XENO_HOST))
				var/obj/item/organ/internal/body_egg/alien_embryo/A = L.get_organ_by_type(/obj/item/organ/internal/body_egg/alien_embryo)
				if(A)
					var/I = image('icons/mob/nonhuman-player/alien.dmi', loc = L, icon_state = "infected[A.stage]")
					client.images += I
	return


/*----------------------------------------
Proc: RemoveInfectionImages()
Des: Removes all infected images from the alien.
----------------------------------------*/
/mob/living/carbon/alien/proc/RemoveInfectionImages()
	if(client)
		var/list/image/to_remove
		for(var/image/client_image as anything in client.images)
			var/searchfor = "infected"
			if(findtext(client_image.icon_state, searchfor, 1, length(searchfor) + 1))
				to_remove += client_image
		client.images -= to_remove
	return

/mob/living/carbon/alien/canBeHandcuffed()
	if(num_hands < 2)
		return FALSE
	return TRUE

/mob/living/carbon/alien/get_visible_suicide_message()
	return "[src] is thrashing wildly! It looks like [p_theyre()] trying to commit suicide."

/mob/living/carbon/alien/get_blind_suicide_message()
	return "You hear thrashing."

/mob/living/carbon/alien/proc/alien_evolve(mob/living/carbon/alien/new_xeno)
	visible_message(
		span_alertalien("[src] begins to twist and contort!"),
		span_noticealien("You begin to evolve!"),
	)
	new_xeno.setDir(dir)
	if(numba && unique_name)
		new_xeno.numba = numba
		new_xeno.set_name()
	if(!alien_name_regex.Find(name))
		new_xeno.name = name
		new_xeno.real_name = real_name
	if(mind)
		mind.name = new_xeno.real_name
		mind.transfer_to(new_xeno)
	var/datum/component/nanites/nanites = GetComponent(/datum/component/nanites)
	if(nanites)
		new_xeno.AddComponent(/datum/component/nanites, nanites.nanite_volume)
		SEND_SIGNAL(new_xeno, COMSIG_NANITE_SYNC, nanites)
	qdel(src)

/mob/living/carbon/alien/can_hold_items(obj/item/I)
	return (I && (I.item_flags & XENOMORPH_HOLDABLE || ISADVANCEDTOOLUSER(src)) && ..())

/mob/living/carbon/alien/on_lying_down(new_lying_angle)
	. = ..()
	update_icons()

/mob/living/carbon/alien/on_standing_up()
	. = ..()
	update_icons()
