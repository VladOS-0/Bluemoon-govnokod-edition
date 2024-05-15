/**
 *
 * ПОШЛОЕ
 *
 */

/datum/mail_pattern/lewd/heart_cum
	name = "Сердечко (with Cum)"
	description = "<3 + бутылка сами-знаете-с-чем"

	weight = MAIL_WEIGHT_RARE

	letter_title = "Записка из письма"
	letter_desc = "Она немного липкая"
	letter_html = "<center><span style='font-size: 80px; color: #ba346e;'>&lt;3</span></center>"
	sender = "???"
	letter_sign = null

	letter_icon_state = "cpaper"

	bad_feeling = "Письмо пахнет дешёвыми духами. Это чтобы что-то скрыть?"

	initial_contents = list()

	blacklisted_species = MAIL_RECIPIENT_SYNTH

/datum/mail_pattern/lewd/heart_cum/apply(mob/living/carbon/human/recipient)
	. = ..()
	var/obj/item/reagent_containers/food/condiment/milk/milky = new(parent)
	milky.reagents.remove_reagent(/datum/reagent/consumable/milk, 50)
	milky.reagents.add_reagent(/datum/reagent/consumable/semen, 50)
	milky.name = "Странная коробочка"
	milky.desc = "Молоко?.."

/datum/mail_pattern/lewd/heart_cum/regenerate_weight(mob/living/carbon/human/recipient)
	. = ..()
	if(.)
		if(HAS_TRAIT(recipient, TRAIT_DUMB_CUM_CRAVE) || recipient.has_quirk(/datum/quirk/succubus))
			. *= 3
