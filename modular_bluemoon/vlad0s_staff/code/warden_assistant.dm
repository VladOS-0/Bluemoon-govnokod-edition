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
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	resistance_flags = INDESTRUCTIBLE

	var/paper_amount = 0
	var/list/obj/item/clothing/accessory/permit/registered_permits = list()

/obj/item/warden_assistant/Initialize(mapload)
	. = ..()
	GLOB.warden_assistant_devices_list += src

/obj/item/warden_assistant/Destroy()
	. = ..()
	GLOB.warden_assistant_devices_list -= src
	registered_permits = list()

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
	return data

/obj/item/warden_assistant/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("submit_license")
			return FALSE

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
	registered_permits[permit_id] = new_permit
	if(notify)
		playsound(src, 'sound/machines/ping.ogg', 20)
		balloon_alert_to_viewers("Зарегистрировано разрешение на оружие #[permit_id]")

/obj/item/warden_assistant/proc/unregister_permit(obj/item/clothing/accessory/permit/old_permit, notify = TRUE)
	if(!old_permit|| !new_permit.permit_id)
		return
	if(old_permit in registered_permits)
		registered_permits[permit_id] = null
	if(notify)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20)
		balloon_alert_to_viewers("Разрешение на оружие #[permit_id] отозвано")
