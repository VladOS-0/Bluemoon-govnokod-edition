/**
 * Планшетик у вардена, способный печатать лицензии
 * В дальнейшем должен стать чем-то большим...
 */

GLOBAL_LIST_EMPTY(warden_assistant_devices_list)

/obj/item/warden_assistant
	name = "Security Management Device"
	desc = "Большой и явно очень дорогой планшет с множеством сканеров, антенн, принтеров и прочих систем ввода-вывода с использованием блюспейс технологий. Выглядит как изобретение безумного учёного, но на службе защитников станции. Судя по всему, его корпус частично позаимствован у легендарного ПДА 2492 года \"Nokia 9000\" и может выдержать прямое попадание блюспейс-артиллерии."
	icon = 'modular_bluemoon/vlad0s_staff/icon/misc.dmi'
	icon_state = "warden_assistant"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = INDESTRUCTIBLE

	var/paper_amount = 0

	var/scanner_on = FALSE

	var/user_name = ""
	var/user_assignment = ""

	var/permit_issued_name = ""
	var/permit_issued_assignment = ""
	var/permit_issued_allowed_weapons = ""
	var/permit_issued_notes = ""

	var/list/obj/item/clothing/accessory/permit/registered_permits = list()

/obj/item/warden_assistant/Initialize(mapload)
	. = ..()
	GLOB.warden_assistant_devices_list += src

/obj/item/warden_assistant/Destroy()
	. = ..()
	GLOB.warden_assistant_devices_list -= src
	registered_permits = list()

/obj/item/warden_assistant/ui_status(mob/user)
	if(!can_use_assistant(user))
		return UI_CLOSE
	else
		return UI_INTERACTIVE

/obj/item/warden_assistant/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WardenAssistant")
		ui.open()

/obj/item/warden_assistant/ui_data(mob/user)
	var/list/data = list()
	data["paper_amount"] = paper_amount
	/*data["registered_permits"] = list()
	for(var/obj/item/clothing/accessory/permit/permit_in_base in registered_permits)
		if(!permit_in_base || !permit_in_base.permit_id)
			data["registered_permits"][permit_in_base.permit_id]["permit_id"] = permit_in_base.permit_id
			data["registered_permits"][permit_in_base.permit_id]["permit_name"] = permit_in_base.name
			data["registered_permits"][permit_in_base.permit_id]["permit_name"] = permit_in_base.name*/
	data["user_name"] = user_name
	data["user_assignment"] = user_assignment

	data["permit_issued_name"] = permit_issued_name
	data["permit_issued_assignment"] = permit_issued_assignment
	data["permit_issued_allowed_weapons"] = permit_issued_allowed_weapons
	data["permit_issued_notes"] = permit_issued_notes
	return data

/obj/item/warden_assistant/ui_act(action, params)
	if(..())
		return
	if(!can_use_assistant(usr))
		return
	switch(action)
		if("submit_license")
			return FALSE

/obj/item/warden_assistant/AltClick(mob/user)
	. = ..()
	if(scanner_on)
		to_chat(user, span_notice("Вы отключаете сканер [src]"))
		scanner_on = FALSE

/obj/item/warden_assistant/attack(mob/living/M, mob/living/user, attackchain_flags, damage_multiplier)
	. = ..()
	if(scanner_on)
		if(ishuman(M))
			var/mob/living/carbon/human/scanned = M
			var/obj/item/card/id/scanned_card = scanned.get_id_card()
			if(scanned_card && scanned_card.name && scanned_card.assignment)
				permit_issued_name = scanned_card.name
				permit_issued_assignment = scanned_card.assignment
				user.visible_message(span_notice("[user] сканирует [M] при помощи [src]."))
				playsound(src, 'sound/machines/beep.ogg', 20)
				scanner_on = FALSE

/obj/item/warden_assistant/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/paper) && do_after(user, 1 SECONDS, O))
		if(O.resistance_flags & INDESTRUCTIBLE)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 20)
			return
		user.visible_message(span_notice("[user] вставляет [O] в маленький лоток для бумаги в [src]."))
		playsound(src, 'sound/machines/beep.ogg', 20)
		qdel(O)
		paper_amount++
		return TRUE
	return ..()

/obj/item/warden_assistant/proc/register_permit(obj/item/clothing/accessory/permit/new_permit, notify = TRUE)
	if(!new_permit || !new_permit.owner_name || !new_permit.owner_assignment || !new_permit.permit_id)
		return
	registered_permits[new_permit.permit_id] = new_permit
	if(notify)
		playsound(src, 'sound/machines/ping.ogg', 20)
		balloon_alert_to_viewers("Зарегистрировано разрешение на оружие #[new_permit.permit_id]")

/obj/item/warden_assistant/proc/unregister_permit(obj/item/clothing/accessory/permit/old_permit, notify = TRUE)
	if(!old_permit|| !old_permit.permit_id)
		return
	if(old_permit in registered_permits)
		registered_permits[old_permit.permit_id] = null
	if(notify)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20)
		balloon_alert_to_viewers("Разрешение на оружие #[old_permit.permit_id] отозвано")

/obj/item/warden_assistant/proc/can_use_assistant(mob/user)
	if(QDELETED(src))
		return FALSE
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_user = user
	if(is_blind(human_user))
		return FALSE
	if(!(src in human_user.held_items))
		return FALSE
	var/obj/item/card/id/human_user_card = human_user.get_id_card()
	if(!human_user_card)
		return FALSE
	if(!human_user_card.registered_name || !human_user_card.assignment)
		return FALSE
	if(ACCESS_ARMORY in human_user_card.GetAccess())
		return TRUE

