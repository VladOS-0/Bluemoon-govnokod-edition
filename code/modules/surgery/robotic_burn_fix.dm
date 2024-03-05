
// BLUEMOON ADDED

///Fixes robots' burn wounds
/datum/surgery/robotic_burn_repair
	name = "Repair Burned Limb"
	steps = list(/datum/surgery_step/mechanic_open, /datum/surgery_step/pry_off_plating, /datum/surgery_step/replace_wires, /datum/surgery_step/add_plating, /datum/surgery_step/detach_burned_plates, /datum/surgery_step/mechanic_close)
	target_mobtypes = list(/mob/living/carbon/human)
	requires_bodypart = BODYPART_ROBOTIC
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	requires_real_bodypart = TRUE
	targetable_wound = /datum/wound/burn

/datum/surgery/robotic_burn_repair/can_start(mob/living/user, mob/living/carbon/target)
	if(..())
		var/obj/item/bodypart/targeted_bodypart = target.get_bodypart(user.zone_selected)
		var/datum/wound/burn/burn_wound = targeted_bodypart.get_wound_type(targetable_wound)
		return burn_wound


// Хирургический шаг

/datum/surgery_step/detach_burned_plates
	name = "Удалить обгоревшее покрытие (Лом)"
	implements = list(TOOL_CROWBAR = 100, TOOL_SAW = 70)
	time = 75

/datum/surgery_step/force_reboot/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You prepare to begin disconnecting [target]'s burned cover...</span>",
		"[user] prepares to diconnect [target]'s burned cover with [tool]...",
		"[user] pries [target]'s plates off with [tool]...")

/datum/surgery_step/force_reboot/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		display_results(user, target, "<span class='notice'>You successfully disconnect [target]'s burned plates!</span>",
			"[user] disconnects burned cover from [target]'s shell.",
			"[user] cuts off something from [target]...")
		target.adjustFireLoss(-50, 0)
		target.updatehealth()
		qdel(surgery.operated_wound)
	else
		to_chat(user, "<span class='warning'>[target] has no burns there!</span>")
	return TRUE

/datum/surgery_step/force_reboot/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You pry off too much of [target]'s shell, damaging their systems!</span>",
		"[user] prepares to diconnect [target]'s burned cover, but failes, damaging their shell!",
		"[user] fails to disconnect plates, damaging them instead...")
	target.adjustBruteLoss(30)
	playsound(target, 'sound/misc/crack.ogg', 50)
	return FALSE

