GLOBAL_VAR_INIT(irc_count, 0)

/**
 * Компонент
 */
/datum/component/int_robotic_chassis
	var/id = 0
	var/mob/living/carbon/human/master
	var/already_customised = FALSE

/datum/component/int_robotic_chassis/Initialize()
	if(!istype(parent, /mob/living/carbon/human/species/ipc))
		return COMPONENT_INCOMPATIBLE
	id = ++GLOB.irc_count

/**
 * Дизайн в фабрикаторе
 */
/datum/design/irc_chassis
	name = "IRC Chassis"
	desc = "Integrated Robotic Chassis - is a framework of IPC, but just for your slavery-like entertainment."
	id = "irc_chassis"
	build_type = MECHFAB
	construction_time = 200
	materials = list(/datum/material/iron = 12000, /datum/material/glass = 1000, /datum/material/silver = 2000, /datum/material/gold = 1500, /datum/material/titanium = 8000)
	build_path = /obj/item/irc_chassis
	category = list("IPC Organs")

/**
 * Айтем, создающийся по дизайну. Спавнит ИПЦ без конечностей и внутренних компонентов, привязывает к нему компонент,
 * после чего самоудаляется.
 */
/obj/item/irc_chassis
	name = "IRC chassis"
	desc = "Integrated Robotic Chassis - is a framework of IPC, but just for your slavery-like entertainment."
	icon = 'icons/mob/augmentation/augments.dmi'
	icon_state = "chest_m"
	w_class = WEIGHT_CLASS_GIGANTIC
	resistance_flags = INDESTRUCTIBLE

/obj/item/irc_chassis/Initialize(mapload)
	. = ..()
	var/turf/floor = get_turf(src)
	var/mob/living/carbon/human/species/ipc/our_creation = new /mob/living/carbon/human/species/ipc(floor)
	ADD_TRAIT(our_creation, TRAIT_DEATHCOMA, "IRC")
	our_creation.death(FALSE) // Мертворождённый КПБ...
	REMOVE_TRAIT(our_creation, TRAIT_DEATHCOMA, "IRC")
	var/list/organs = our_creation.internal_organs
	for(var/internal_organ in organs)
		var/obj/item/organ/I = internal_organ
		I.Remove()
		I.forceMove(floor)
		qdel(I)
	for(var/obj/item/bodypart/bodypart in our_creation.bodyparts)
		if(istype(bodypart, /obj/item/bodypart/chest) || istype(bodypart, /obj/item/bodypart/head))
			continue
		bodypart.drop_limb()
		qdel(bodypart)
	our_creation.AddComponent(/datum/component/int_robotic_chassis)
	var/datum/component/int_robotic_chassis/IRC_component = our_creation.GetComponent(/datum/component/int_robotic_chassis)
	our_creation.real_name = "Integrated Robotic Chassis No[IRC_component.id]"
	our_creation.gender = MALE
	our_creation.hair_style == "Bald"
	our_creation.regenerate_icons()
	return INITIALIZE_HINT_QDEL

/**
 * Кастомизатор
 */
/obj/item/irc_customizer
	name = "IRC Customizer"
	desc = "A fancy tool for extremely lonely roboticists."
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_mining1"
	item_state = "adv_mining1"
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_POCKETS | ITEM_SLOT_SUITSTORE
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=4000, /datum/material/glass=2000, /datum/material/bluespace=1000)
	var/possible_synth_races = list()
	var/mob/living/carbon/human/owner

/obj/item/irc_customizer/Initialize(mapload)
	. = ..()
	for(var/spath in subtypesof(/datum/species))
		var/datum/species/S = spath
		if(TRAIT_ROBOTIC_ORGANISM in initial(S.inherent_traits) && !initial(S.blacklisted))
			possible_synth_races += S

/obj/item/irc_customizer/attack_self(mob/user)
	. = ..()
	if(!istype(user, /mob/living/carbon/human))
		return
	if(!owner)
		owner = user
		say("Девайс привязан к субъекту: [owner]")
	ui_interact(user)

/obj/item/irc_customizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IRCCustomizer")
		ui.open()

/obj/item/irc_customizer/ui_data(mob/user)
	var/list/data = list()
	data["auth_id"] = auth_id

	return data

/obj/item/irc_customizer/ui_act(action, params)
	switch(action)
		if("log-in")
		if("log-out")




