#define MAIL_CATEGORY_MISC "mail_misc"
#define MAIL_CATEGORY_SYNDIE "mail_syndie"
#define MAIL_CATEGORY_MONEY "mail_money"
#define MAIL_CATEGORY_FAMILY "mail_family"
#define MAIL_CATEGORY_JOB "mail_job"
#define MAIL_CATEGORY_SHOP "mail_shop"
#define MAIL_CATEGORY_SPAM "mail_spam"
#define MAIL_CATEGORY_LEWD "mail_lewd"

#define MAIL_TYPE_ENVELOPE "envelope"
#define MAIL_TYPE_PACKAGE "package"

GLOBAL_LIST_INIT(mail_categories_with_weights, list(
	MAIL_CATEGORY_MISC = 3,
	MAIL_CATEGORY_SYNDIE = 5000,
	MAIL_CATEGORY_MONEY = 5,
	MAIL_CATEGORY_FAMILY = 5000,
	MAIL_CATEGORY_JOB = 7,
	MAIL_CATEGORY_SHOP = 4,
	MAIL_CATEGORY_SPAM = 4,
	MAIL_CATEGORY_LEWD = 3
))

/datum/mail_pattern
	var/id = "default"
	var/name = "_Дефолтный паттерн"
	var/description = "Базовый паттерн для писем"

	var/sender = "НЕИЗВЕСТЕН"

	/// Envelope / Package
	var/envelope_type = MAIL_TYPE_ENVELOPE

	var/obj/item/mail/parent

	/// Category of letter
	var/category = MAIL_CATEGORY_MISC
	/// Weight (chance) of getting this lettertype
	var/weight = 0

	/// Name for text letter in envelope
	var/letter_title = "БЛАНК ПОЛУЧЕНИЯ"
	/// HTML for text letter in envelope
	var/letter_html = "Данный бланк подтверждает получение посылки адресатом."
	/// Description for text letter in envelope
	var/letter_desc = "Слегка помятая исписанная бумажка с явным перегибом по середине. Видимо, его достали из конверта."
	/// Icon file for text letter in envelope
	var/letter_icon = 'icons/obj/bureaucracy.dmi'
	/// Icon state for text letter in envelope
	var/letter_icon_state = "paperslip_words"

	/// Created items during initialization. If items should be customised, override create_contents proc
	var/list/obj/item/initial_contents = list()

/datum/mail_pattern/New(obj/item/mail/_parent)
	. = ..()
	parent = _parent

/datum/mail_pattern/Destroy(force, ...)
	parent = null
	initial_contents = null
	. = ..()

/datum/mail_pattern/proc/choose_pattern(mob/living/carbon/human/recipient)
	. = TRUE
	if(!istype(recipient) || !istype(parent))
		return FALSE
	var/list/local_categories_with_weights = GLOB.mail_categories_with_weights.Copy()
	/**
	 *	if(recipient.client.prefs.preferred_mail_category)
	 *		picked_mail_category[preferred_mail_category] *= 3
	 */
	var/picked_mail_category = pickweight(local_categories_with_weights)
	var/list/modified_patterns_list = regenerate_weights(recipient, picked_mail_category)
	if(modified_patterns_list.len == 0)
		return FALSE
	var/datum/mail_pattern/chosen_pattern = pickweight(modified_patterns_list)
	parent.pattern = new chosen_pattern(parent)
	parent = null
	qdel(src)


/// Returns 'pattern type = modified weight' assoc list for specific recipient.
/// Filtering goes for specific category
/// Modification of weight for specific pattern can be specified in switch-case construction in this proc
/// This modification can filter out incompatible (cookies for synths) patterns or take in accout recipient's prefs
/datum/mail_pattern/proc/regenerate_weights(mob/living/carbon/human/recipient, category = MAIL_CATEGORY_MISC)
	. = list()
	var/list/datum/mail_pattern/patterns_list = typesof(/datum/mail_pattern)

	for(var/P in patterns_list)
		var/datum/mail_pattern/pattern = P
		if(initial(pattern.category) != category)
			continue
		if(istype(parent, /obj/item/mail/envelope) && initial(pattern.envelope_type) != MAIL_TYPE_ENVELOPE)
			continue
		if(!istype(parent, /obj/item/mail/envelope) && initial(pattern.envelope_type) == MAIL_TYPE_ENVELOPE)
			continue

		var/pattern_id = initial(pattern.id)
		var/pattern_weight = initial(pattern.weight)

		// ГЛАВНЫЙ SWITCH-CASE. ЕСЛИ ВЫ ХОТИТЕ СДЕЛАТЬ ОСОБЫЕ ПРОВЕРКИ ДЛЯ СВОИХ ПАТТЕРНОВ ПИСЕМ
		// ВПИСЫВАЙТЕ ВСЁ СЮДА ПО ШАБЛОНУ В СООТВЕТСТВУЮЩУЮ КАТЕГОРИЮ
		switch(category)
			if(MAIL_CATEGORY_MISC)
				switch(pattern_id)
					if("")
						continue
			if(MAIL_CATEGORY_SYNDIE)
				switch(pattern_id)
					if("")
						continue
			if(MAIL_CATEGORY_MONEY)
				switch(pattern_id)
					if("")
						continue
			if(MAIL_CATEGORY_FAMILY)
				switch(pattern_id)
					if("babushka_cookies")
						if(isrobotic(recipient) || HAS_TRAIT(recipient, TRAIT_NOHUNGER))
							pattern_weight = 0
			if(MAIL_CATEGORY_SHOP)
				switch(pattern_id)
					if("")
						continue
			if(MAIL_CATEGORY_SPAM)
				switch(pattern_id)
					if("")
						continue
			if(MAIL_CATEGORY_LEWD)
				switch(pattern_id)
					if("")
						continue
		// КОНЕЦ ГЛАВНОГО SWITCH-CASE

		if(pattern_weight == 0)
			continue

		.[pattern] = pattern_weight

	return .

/datum/mail_pattern/proc/text_customisation(text = "", mob/living/carbon/human/recipient)
	if(!istype(recipient) || !istype(parent))
		return
	var/output = text
	if(recipient.gender)
		output = replacetext(output, "%%СЯ%%", recipient.ru_sya())
		output = replacetext(output, "%%ОН%%", recipient.ru_who())
		output = replacetext(output, "%%ЕГО%%", recipient.ru_ego())
		output = replacetext(output, "%%НЕГО%%", recipient.ru_nego())
		output = replacetext(output, "%%НЁМ%%", recipient.ru_na())
		output = replacetext(output, "%%ЕМУ%%", recipient.ru_emu())
		output = replacetext(output, "%%А%%", recipient.ru_a())
		output = replacetext(output, "%%ЕН%%", recipient.ru_en())
		// " %-внучок | внучка%- "
		var/list/text_pieces = splittext(output,  "%-")
		var/list/formatted_text_pieces = list()
		if(text_pieces.len  > 1)
			for(var/piece in text_pieces)
				if(piece[1] == ">")
					piece = replacetext(piece, ">",  "")
					var/list/parts_of_replacer = splittext(piece,  " | ")
					if(recipient.gender == FEMALE)
						piece = parts_of_replacer[2]
					else
						piece = parts_of_replacer[1]
				formatted_text_pieces += piece
			output = jointext(formatted_text_pieces, "")

	return output


/datum/mail_pattern/proc/apply(mob/living/carbon/human/recipient)
	if(!istype(parent))
		return

	letter_title = text_customisation(letter_title, recipient)
	letter_html = text_customisation(letter_html, recipient)

	parent.sender_name = sender

	var/obj/item/paper/letter = new /obj/item/paper(parent)
	letter.show_written_words = FALSE
	letter.name = letter_title
	letter.add_raw_text(letter_html)
	letter.desc = letter_desc
	letter.icon = letter_icon
	letter.icon_state = letter_icon_state
	letter.update_appearance()
	for(var/good in initial_contents)
		new good(parent)

/datum/mail_pattern/proc/special_open_check(mob/living/carbon/human/recipient)
	return TRUE

/datum/mail_pattern/proc/on_mail_open(mob/living/carbon/human/recipient)
	return

/datum/mail_pattern/misc
	category = MAIL_CATEGORY_MISC

/datum/mail_pattern/syndie
	category = MAIL_CATEGORY_SYNDIE

/datum/mail_pattern/money
	category = MAIL_CATEGORY_MONEY

/datum/mail_pattern/family
	category = MAIL_CATEGORY_FAMILY

/datum/mail_pattern/job
	category = MAIL_CATEGORY_JOB

/datum/mail_pattern/shop
	category = MAIL_CATEGORY_SHOP

/datum/mail_pattern/spam
	category = MAIL_CATEGORY_SPAM

/datum/mail_pattern/lewd
	category = MAIL_CATEGORY_LEWD

#undef MAIL_CATEGORY_MISC
#undef MAIL_CATEGORY_SYNDIE
#undef MAIL_CATEGORY_MONEY
#undef MAIL_CATEGORY_FAMILY
#undef MAIL_CATEGORY_JOB
#undef MAIL_CATEGORY_SHOP
#undef MAIL_CATEGORY_SPAM
#undef MAIL_CATEGORY_LEWD
#undef MAIL_TYPE_ENVELOPE
#undef MAIL_TYPE_PACKAGE
