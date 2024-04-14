GLOBAL_VAR_INIT(irc_count, 0)

proc/is_irc(mob/target)
	if(!ismob(target))
		return FALSE
	var/mob/living/carbon/human/species/customisable_mob = target
	if(!istype(customisable_mob))
		return FALSE
	if(!isrobotic(customisable_mob))
		return FALSE
	var/datum/component/int_robotic_chassis/IRC_component = customisable_mob.GetComponent(/datum/component/int_robotic_chassis)
	if(!IRC_component)
		return FALSE
	return TRUE
/**
 * Компонент
 */
/datum/component/int_robotic_chassis
	var/id = 0
	var/mob/living/carbon/human/master
	var/already_customised = FALSE
	var/customisation_stage = 1

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
	our_creation.age = 18 // Вы не поверите, товарищ майор...
	our_creation.dna.features["mcolor"] = "000000"
	our_creation.dna.features["ipc_screen"] = "Console"
	our_creation.dna.species.say_mod = "beeps"
	our_creation.facial_hair_style = "Shaved"
	our_creation.hair_style = "Bald"
	our_creation.grant_language(/datum/language/machine, TRUE, TRUE, LANGUAGE_MIND)
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
	var/possible_synth_races = list(
		/datum/species/ipc,
		/datum/species/mammal/synthetic,
		/datum/species/synthliz
	)
	var/mob/living/carbon/human/owner
	var/mob/living/carbon/human/species/target
	var/current_ui = "General"

/obj/item/irc_customizer/attack_self(mob/user)
	. = ..()
	if(!istype(user, /mob/living/carbon/human))
		return
	if(!owner)
		owner = user
		say("Девайс привязан к субъекту: [owner]")
	if(owner != user)
		say("Доступ запрещён.")
		return
	current_ui = "General"
	ui_interact(user)

/obj/item/irc_customizer/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!ismob(target))
		return
	if(!do_after(user, 20, target))
		return
	var/mob/living/carbon/human/species/customisable_mob = target
	if(!is_irc(customisable_mob))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, FALSE)
		say("Субъект не является КРБ.")
		return
	var/datum/component/int_robotic_chassis/IRC_component = customisable_mob.GetComponent(/datum/component/int_robotic_chassis)
	if(IRC_component.already_customised)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, FALSE)
		say("Кастомизация уже завершена.")
		return
	if(customisable_mob.stat != DEAD)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, FALSE)
		say("Субъект должен быть отключён (\"мёртв\").")
		return
	if(customisable_mob.mind)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, FALSE)
		say("Изымите позитронный мозг.")
		return
	target = customisable_mob
	say("Обработка субъекта: [customisable_mob.name]...")
	playsound(src, 'sound/machines/chime.ogg', 20, FALSE)
	SStgui.close_uis(src)
	current_ui = "Customization"
	ui_interact(user)

/obj/item/irc_customizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IRCCustomizer")
		ui.open()

/obj/item/irc_customizer/ui_data(mob/user)
	var/list/data = list()
	data["owner"] = owner
	data["page"] = current_ui
	data["IRCData"] = null
	if(current_ui == "IRCCustomizer" && target && is_irc(target))
		data["IRCData"]["name"] = target.real_name
		var/datum/component/int_robotic_chassis/IRC_component = target.GetComponent(/datum/component/int_robotic_chassis)
		data["IRCData"]["ID"] = IRC_component.id
		data["IRCData"]["currentStage"]= IRC_component.customisation_stage
	return data

/obj/item/irc_customizer/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()
	var/list/possible_races_names = list()
	for(var/datum/species/race in possible_synth_races)
		possible_races_names += initial(race.name)
	data["possible_races"] = possible_races_names
	return data

/obj/item/irc_customizer/ui_act(action, params)
	. = ..()
	if(current_ui == "General")
		switch(action)
			if("erase-all")
				owner = null
				SStgui.close_uis(src)
				return
	if(current_ui == "IRCCustomizer")
		switch(action)
			if("handle_JSON")
				var/JSON = params["JSON"]
				handle_JSON(JSON)

/obj/item/irc_customizer/proc/handle_JSON(list/JSON)
	var/list/payload = json_decode(JSON)
	switch(payload["stage"])
		if("1")
			stage1(payload["choices"])

/obj/item/irc_customizer/proc/stage1(list/params)
	var/race_name = params["chosen_race"]
	var/list/possible_races_assoc = list()
	for(var/datum/species/race in possible_synth_races)
		possible_races_assoc[initial(race.name)] = race
	var/datum/species/chosen_race = possible_races_assoc[race_name]
	if(!chosen_race)
		say("Произошла ошибка с выбором расы субъекта.")
		return
	if(!owner || !target || !do_after(owner, 30, target) || !is_irc(target))
		return
	var/datum/component/int_robotic_chassis/IRC_component = target.GetComponent(/datum/component/int_robotic_chassis)
	if(IRC_component.customisation_stage != 1 || IRC_component.already_customised)
		return
	target.set_species(chosen_race, icon_update=TRUE)
	target = null
	playsound(src, 'sound/machines/chime.ogg', 20, FALSE)
	say("Вид субъекта успешно изменён.")
	SStgui.close_uis(src)
	current_ui = "General"







