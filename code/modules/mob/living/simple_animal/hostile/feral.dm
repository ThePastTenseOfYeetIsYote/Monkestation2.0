/mob/living/simple_animal/hostile/feral
	name = "feral cat"
	desc = "Kitty!! Wait, no no DON'T BITE-"
	health = 30
	maxHealth = 30
	melee_damage_lower = 7
	melee_damage_upper = 15
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	held_state = "cat2"
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile
	faction = list(FACTION_CAT, ROLE_SYNDICATE)

/mob/living/simple_animal/hostile/feraltabby
	name = "feral cat"
	desc = "Kitty!! Wait, no no DON'T BITE-"
	health = 45
	maxHealth = 45
	melee_damage_lower = 10
	melee_damage_upper = 20
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	held_state = "cat"
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile
	faction = list(FACTION_CAT, ROLE_SYNDICATE)
