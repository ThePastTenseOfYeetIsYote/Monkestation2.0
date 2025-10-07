/obj/item/organ/external/floran_leaves
	name = "floran leaves"
	desc = "you shouldn't see this"
	organ_flags = ORGAN_UNREMOVABLE | ORGAN_HIDDEN
	icon_state = "floran_leaves"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_floran_leaves"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_FLORAN_LEAVES

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/floran_leaves

/datum/bodypart_overlay/mutant/floran_leaves
	layers = EXTERNAL_ADJACENT
	feature_key = "floran_leaves"
	color_source = ORGAN_COLOR_MUTSECONDARY

	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR_SECONDARY
	fallback_key = MUTANT_COLOR


/datum/bodypart_overlay/mutant/floran_leaves/get_global_feature_list()
	return GLOB.floran_leaves_list

/datum/bodypart_overlay/mutant/floran_leaves/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/floran_leaves/can_draw_on_bodypart(mob/living/carbon/human/human)
	. = ..()
	if(human.wear_suit && (human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return FALSE
