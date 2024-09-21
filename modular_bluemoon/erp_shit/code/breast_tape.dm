/obj/item/clothing/underwear/shirt/bra/breast_tape
	name = "breast tape"
	desc = "Kinky variation of bra, which barely hides anything."
	body_parts_covered = NONE
	icon = 'modular_bluemoon/erp_shit/icons/breast_tape.dmi'
	mob_overlay_icon = 'modular_bluemoon/erp_shit/icons/breast_tape.dmi'
	icon_state = "pair_a"
	var/altered = FALSE

/obj/item/clothing/underwear/shirt/bra/breast_tape/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете изменить стиль [name] на альтернативный при помощи <b>Alt+Click</b>.")

/obj/item/clothing/underwear/shirt/bra/breast_tape/equipped(mob/user, slot)
	update_size(user)
	. = ..()

/obj/item/clothing/underwear/shirt/bra/breast_tape/AltClick(mob/user)
	. = ..()
	altered = !altered
	if(!ishuman(loc))
		icon_state = "pair_a"
		if(altered)
			icon_state += "_alt"
		update_appearance()
		return
	update_size(loc)

/obj/item/clothing/underwear/shirt/bra/breast_tape/proc/update_size(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/equipper = user
	var/obj/item/organ/genital/breasts/boobies = equipper.getorganslot(ORGAN_SLOT_BREASTS)
	if(!boobies)
		return // no boobies?
	var/boobies_state = boobies.size_to_state()
	if(boobies_state == "плоского")
		return
	icon_state = "pair_[boobies_state]"
	if(altered)
		icon_state += "_alt"
	update_appearance()
	equipper.update_appearance()
