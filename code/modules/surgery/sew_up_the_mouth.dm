/datum/surgery/sew_up_the_mouth
	name = "Зашить Рот"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/incise, /datum/surgery_step/sew_up_the_mouth, /datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)
	requires_bodypart_type = BODYPART_ORGANIC

/datum/surgery_step/sew_up_the_mouth
	name = "Зашить или Прижечь Рот"
	implements = list(TOOL_CAUTERY = 100, /obj/item/gun/energy/laser = 90, /obj/item/stack/medical/suture = 85, TOOL_WELDER = 70,
		/obj/item = 30) // 30% success with any hot item.
	time = 24
	preop_sound = 'sound/surgery/cautery1.ogg'
	success_sound = 'sound/surgery/cautery2.ogg'

/datum/surgery_step/sew_up_the_mouth/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Вы начинаете зашивать <b>[ru_parse_zone(target_zone)]</b> <b>[target]</b>...</span>",
		"<b>[user]</b> начинает зашивать <b>[ru_parse_zone(target_zone)]</b> <b>[target]</b>.",
		"<b>[user]</b> начинает зашивать <b>[ru_parse_zone(target_zone)]</b> <b>[target]</b>.")

/datum/surgery_step/sew_up_the_mouth/tool_check(mob/user, obj/item/tool)
	if(implement_type == TOOL_WELDER || implement_type == /obj/item)
		return tool.get_temperature()
	return TRUE

/datum/surgery_step/sew_up_the_mouth/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	sew_up_the_mouth(target)
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/bodypart/BP = H.get_bodypart(target_zone)
		if(BP)
			BP.generic_bleedstacks -= 3
	return ..()

/datum/surgery_step/proc/sew_up_the_mouth(mob/living/carbon/target)
	ADD_TRAIT(target, TRAIT_MUTE, GENETIC_MUTATION)

/datum/surgery/unsew_up_the_mouth
	name = "Расшить Рот"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/unsew_up_the_mouth, /datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)
	requires_bodypart_type = BODYPART_ORGANIC

/datum/surgery_step/unsew_up_the_mouth
	name = "Расшить Рот"
	implements = list(TOOL_SCALPEL = 100, /obj/item/melee/transforming/energy/sword = 75, /obj/item/kitchen/knife = 65,
		/obj/item/shard = 45, /obj/item = 30) // 30% success with any sharp item.
	time = 24
	preop_sound = 'sound/surgery/cautery1.ogg'
	success_sound = 'sound/surgery/cautery2.ogg'

/datum/surgery_step/unsew_up_the_mouth/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Вы начинаете расшивать <b>[ru_parse_zone(target_zone)]</b> <b>[target]</b>...</span>",
		"<b>[user]</b> начинает расшивать <b>[ru_parse_zone(target_zone)]</b> <b>[target]</b>.",
		"<b>[user]</b> начинает расшивать <b>[ru_parse_zone(target_zone)]</b> <b>[target]</b>.")

/datum/surgery_step/unsew_up_the_mouth/tool_check(mob/user, obj/item/tool)
	if(implement_type == TOOL_WELDER || implement_type == /obj/item)
		return tool.get_temperature()
	return TRUE

/datum/surgery_step/unsew_up_the_mouth/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	unsew_up_the_mouth(target)
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/bodypart/BP = H.get_bodypart(target_zone)
		if(BP)
			BP.generic_bleedstacks -= 3
	return ..()

/datum/surgery_step/proc/unsew_up_the_mouth(mob/living/carbon/target)
	REMOVE_TRAIT(target, TRAIT_MUTE, GENETIC_MUTATION)


/**
 * BLUEMOON ADD START
 * Зашивание рта для синтов
 *
 *
 */
/datum/surgery/robotic_disable_voicebox
	name = "Voicebox Disabling"
	desc = "A surgical procedure which permanently inhibits the aggression center of the brain, making the patient unwilling to cause direct harm."
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/voicebox_detaching,
		/datum/surgery_step/mechanic_close
		)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)
	requires_bodypart_type = BODYPART_ROBOTIC

/datum/surgery/robotic_disable_voicebox/can_start(mob/user, mob/living/carbon/target, obj/item/tool)
	. = ..()
	return isrobotic(target)

/datum/surgery_step/voicebox_detaching
	name = "Отсоединить Синтезатор (Мультитул)"
	implements = list(TOOL_MULTITOOL = 100, TOOL_SCREWDRIVER = 10, /obj/item/stack/cable_coil = 60)
	time = 50

/datum/surgery_step/voicebox_detaching/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You start connecting [target]'s voicebox...</span>",
		"[user] begins to connect [target]'s voicebox.",
		"[user] begins to perform surgery on [target]'s voicebox.")

/datum/surgery_step/voicebox_detaching/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/tongue/robot/voicebox = target.getorganslot(ORGAN_SLOT_TONGUE)
	if(!voicebox || !istype(voicebox))
		to_chat(user, "<span class='warning'>There is no voicebox in [target]'s body!</span>")
		return FALSE
	display_results(user, target, "<span class='notice'>You succesfully connected [target]'s voicebox!</span>",
		"[user] connected [target]'s voicebox.",
		"[user] finishes surgery on [target].")
	REMOVE_TRAIT(target, TRAIT_MUTE, GENETIC_MUTATION)
	return TRUE

/datum/surgery_step/voicebox_detaching/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/tongue/robot/voicebox = target.getorganslot(ORGAN_SLOT_TONGUE)
	if(!voicebox || !istype(voicebox))
		to_chat(user, "<span class='warning'>There is no voicebox in [target]'s body!</span>")
		return FALSE
	display_results(user, target, "<span class='notice'>You attach the wrong wire!</span>",
		"[user] fails to connect [target]'s voicebox.",
		"[user] finishes surgery on [target].")
	do_fake_sparks(3,3,target)
	return FALSE


/datum/surgery/robotic_enable_voicebox
	name = "Voicebox Repair"
	desc = "Repairs voicebox's connections, destroyed by surgical intervention"
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/voicebox_reattach,
		/datum/surgery_step/mechanic_close
		)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)
	requires_bodypart_type = BODYPART_ROBOTIC


/datum/surgery/robotic_enable_voicebox/can_start(mob/user, mob/living/carbon/target, obj/item/tool)
	. = ..()
	return isrobotic(target)

/datum/surgery_step/voicebox_reattach
	name = "Подсоединить Синтезатор (Плоскогубцы)"
	implements = list(TOOL_WIRECUTTER = 100, TOOL_SCALPEL = 80, /obj/item/melee/transforming/energy/sword = 75, /obj/item/kitchen/knife = 65,
		/obj/item/shard = 45, /obj/item = 30)
	time = 60

/datum/surgery_step/voicebox_reattach/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You start disconnecting [target]'s voicebox...</span>",
		"[user] begins to disconnect [target]'s voicebox.",
		"[user] begins to perform surgery on [target]'s voicebox.")

/datum/surgery_step/voicebox_reattach/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/tongue/robot/voicebox = target.getorganslot(ORGAN_SLOT_TONGUE)
	if(!voicebox || !istype(voicebox))
		to_chat(user, "<span class='warning'>There is no voicebox in [target]'s body!</span>")
		return FALSE
	display_results(user, target, "<span class='notice'>You succesfully disconnected [target]'s voicebox!</span>",
		"[user] disconnected [target]'s voicebox.",
		"[user] finishes surgery on [target].")
	ADD_TRAIT(target, TRAIT_MUTE, GENETIC_MUTATION)
	return TRUE

/datum/surgery_step/voicebox_reattach/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/tongue/robot/voicebox = target.getorganslot(ORGAN_SLOT_TONGUE)
	if(!voicebox || !istype(voicebox))
		to_chat(user, "<span class='warning'>There is no voicebox in [target]'s body!</span>")
		return FALSE
	display_results(user, target, "<span class='notice'>You cut the wrong wire!</span>",
		"[user] fails to disconnect [target]'s voicebox.",
		"[user] finishes surgery on [target].")
	do_fake_sparks(3,3,target)
	return FALSE
// BLUEMOON ADD END
