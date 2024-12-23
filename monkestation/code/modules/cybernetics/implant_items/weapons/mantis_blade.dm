/obj/item/mantis_blade
	name = "C.H.R.O.M.A.T.A. mantis blade"
	desc = "Powerful inbuilt blade, hidden just beneath the skin. Singular brain signals directly link to this bad boy, allowing it to spring into action in just seconds."
	icon_state = "mantis"
	inhand_icon_state = "mantis"
	icon = 'monkestation/code/modules/cybernetics/icons/items_and_weapons.dmi'
	lefthand_file = 'monkestation/code/modules/cybernetics/icons/swords_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/cybernetics/icons/swords_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags_1 = CONDUCT_1
	force = 12
	wound_bonus = 20
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_KNIFE
	max_integrity = 200

/obj/item/mantis_blade/equipped(mob/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_HANDS)
		return
	var/side = user.get_held_index_of_item(src)

	if(side == LEFT_HANDS)
		transform = null
	else
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/mantis_blade/attack(mob/living/M, mob/living/user)
	. = ..()
	if(user.get_active_held_item() != src)
		return

	var/obj/item/some_item = user.get_inactive_held_item()

	if(!istype(some_item,type))
		return

	some_item.attack(M, user)

/obj/item/mantis_blade/attack_self(mob/user)
	switch(tool_behaviour)
		if(TOOL_CROWBAR)
			tool_behaviour = TOOL_KNIFE
			balloon_alert(user, "cutting mode activated")

		if(TOOL_KNIFE)
			tool_behaviour = TOOL_CROWBAR
			balloon_alert(user, "prying mode activated")

/obj/item/mantis_blade/proc/check_can_crowbar(mob/user)
	var/obj/item/some_item = user.get_inactive_held_item()

	if(!istype(some_item,type))
		return FALSE
	return TRUE

/obj/item/mantis_blade/syndicate
	name = "A.R.A.S.A.K.A. mantis blade"
	icon_state = "syndie_mantis"
	inhand_icon_state = "syndie_mantis"
	force = 15
	block_chance = 20
	bare_wound_bonus = 30
	armour_penetration = 35
	COOLDOWN_DECLARE(lunge)

/obj/item/mantis_blade/syndicate/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!COOLDOWN_FINISHED(src, lunge) || world.time < user.next_move)
		return

	if(proximity_flag || get_dist(user,target) > 3 || !isliving(target))
		return

	var/obj/item/some_item = user.get_inactive_held_item()
	if(!istype(some_item,type))
		return
	var/obj/item/mantis_blade/syndicate/other = some_item

	for(var/i in 1 to get_dist(user,target))
		if(!step_towards(user,target) && get_dist(user,target) >= 1)
			return

	COOLDOWN_START(src, lunge, 10 SECONDS)
	COOLDOWN_START(other, lunge, 10 SECONDS)
	if(isliving(user))
		var/mob/living/living = user
		living.stamina?.adjust(-30) // cost of a lunge

	attack(target, user)




/////////SHIELD MANTIS BLADES/////////////////
/obj/item/mantis_blade/shield
	name = "A.E.G.I.S. shield blade"
	desc = "Mantis blades with bigger and wider blades, allowing user to block incoming projectiles and attacks. Because of that, the edge of blades is rather dull and large which makes it worse at wounding and requires much more time between each slash."
	icon_state = "shield_mantis"
	inhand_icon_state = "shield_mantis"
	lefthand_file = 'monkestation/code/modules/cybernetics/icons/swords_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/cybernetics/icons/swords_righthand.dmi'
	force = 10
	wound_bonus = 10
	attack_speed = 12
	var/in_stance = FALSE  //Toggle for the defensive stance.

/obj/item/mantis_blade/shield/attack_self(mob/living/user)
	if (!in_stance)
		var/obj/item/r_hand = user.get_held_items_for_side(RIGHT_HANDS, FALSE)
		var/obj/item/l_hand = user.get_held_items_for_side(LEFT_HANDS, FALSE)
		if(!istype(l_hand, r_hand))//Checks for if your hands are the same type (which they would be if you were dual wielding the shields.)
			to_chat(user, span_warning("You must dual wield blades to enter the stance."))
			return
		user.apply_status_effect(/datum/status_effect/shield_mantis_defense)
		in_stance = TRUE
		to_chat(user, span_notice("You enter defensive stance with your mantis blades."))
		return
	user.remove_status_effect(/datum/status_effect/shield_mantis_defense)
	in_stance = FALSE
	to_chat(user, span_notice("You stop blocking with your blades."))

/obj/item/mantis_blade/shield/dropped(mob/living/user)
	. = ..()
	if (!user.has_status_effect(/datum/status_effect/shield_mantis_defense))
		return
	user.remove_status_effect(/datum/status_effect/shield_mantis_defense)

/datum/status_effect/shield_mantis_defense
	id = "mantis_defensive"
	alert_type = /atom/movable/screen/alert/status_effect/realignment
	//storing held items for when it was applied
	var/obj/item/mantis_blade/shield/r_hand = null
	var/obj/item/mantis_blade/shield/l_hand = null

/datum/status_effect/shield_mantis_defense/on_apply()
	. = ..()
	r_hand = owner.get_held_items_for_side(RIGHT_HANDS, FALSE)
	l_hand = owner.get_held_items_for_side(LEFT_HANDS, FALSE)
	r_hand.block_chance += 40
	l_hand.block_chance += 40
	ADD_TRAIT(owner, TRAIT_CANT_ATTACK, id)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/shield_blades)

/datum/status_effect/shield_mantis_defense/on_remove()
	. = ..()
	r_hand.block_chance = initial(r_hand.block_chance) //Resets block chance for right and left hand
	l_hand.block_chance = initial(l_hand.block_chance)
	REMOVE_TRAIT(owner, TRAIT_CANT_ATTACK, id)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/shield_blades)
	//Reset for stances here
	r_hand.in_stance = FALSE
	l_hand.in_stance = FALSE

//blocking with blades slow you down
/datum/movespeed_modifier/shield_blades
	multiplicative_slowdown = 2


