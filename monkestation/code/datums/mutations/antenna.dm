/datum/mutation/human/antenna
	power_coeff = 1

/datum/mutation/human/antenna/modify()
	. = ..()
	if(GET_MUTATION_POWER(src) == 1)
		return

	var/obj/item/implant/radio/antenna/linked_radio = radio_weakref.resolve()
	if(!linked_radio)
		return

	var/list/random_keys = list(
		/obj/item/encryptionkey/headset_eng,
		/obj/item/encryptionkey/headset_med,
		/obj/item/encryptionkey/headset_sci,
		/obj/item/encryptionkey/headset_cargo,
		/obj/item/encryptionkey/headset_service,
	)
	var/obj/item/encryptionkey/lucky_winner = pick(random_keys) // Let's go gambling!
	linked_radio.radio.keyslot = new lucky_winner
	linked_radio.radio.recalculateChannels()

/datum/mutation/human/mindreader
	energy_coeff = 1
