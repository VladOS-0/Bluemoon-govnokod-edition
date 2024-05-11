#define GET_CATEGORY(X) (/datum/mail_pattern/##X)

#define MAIL_CATEGORY_MISC "misc"
#define MAIL_CATEGORY_ANTAG "antag"
#define MAIL_CATEGORY_MONEY "money"
#define MAIL_CATEGORY_FAMILY "family"
#define MAIL_CATEGORY_JOB "job"
#define MAIL_CATEGORY_SHOP "shop"
#define MAIL_CATEGORY_SPAM "spam"
#define MAIL_CATEGORY_LEWD "lewd"

#define MAIL_ALL_CATEGORIES "ВСЕ"

#define MAIL_TYPE_ENVELOPE "envelope"
#define MAIL_TYPE_PACKAGE "package"

#define MAIL_SENDER_RANDOM_NAME "random_name"
#define MAIL_SENDER_RANDOM_FEMALE "random_female"
#define MAIL_SENDER_RANDOM_MALE "random_male"

GLOBAL_LIST_INIT(mail_categories_with_weights, list(
	MAIL_CATEGORY_MISC = 3,
	MAIL_CATEGORY_ANTAG = 5000,
	MAIL_CATEGORY_MONEY = 5,
	MAIL_CATEGORY_FAMILY = 5000,
	MAIL_CATEGORY_JOB = 7,
	MAIL_CATEGORY_SHOP = 4,
	MAIL_CATEGORY_SPAM = 4,
	MAIL_CATEGORY_LEWD = 3
))

/datum/mail_pattern
	var/name = "_Дефолтный паттерн"
	var/description = "Базовый паттерн для писем"

	var/sender = MAIL_SENDER_RANDOM_NAME

	/// Envelope / Package
	var/envelope_type = MAIL_TYPE_ENVELOPE

	/// Envelope, to which this pattern assigned
	var/obj/item/mail/parent

	/// Category of letter
	var/category = MAIL_CATEGORY_MISC
	/// Weight (chance) of getting this lettertype
	var/weight = 0

	/// Name for text letter in envelope
	var/letter_title = "БЛАНК ПОЛУЧЕНИЯ"
	/// HTML for text letter in envelope
	var/letter_html = ""
	/// Description for text letter in envelope
	var/letter_desc = "Слегка помятая исписанная бумажка с явным перегибом по середине. Видимо, его достали из конверта."
	/// Icon file for text letter in envelope
	var/letter_icon = 'icons/obj/bureaucracy.dmi'
	/// Icon state for text letter in envelope
	var/letter_icon_state = "paperslip_words"

	/// Created items during pattern applying. If items should be customised, override apply() proc
	var/list/obj/item/initial_contents = list()

	//
	// ОГРАНИЧЕНИЯ
	//

	// ... НА РЕЖИМ ИГРЫ

	/// List of whitelisted roundtypes (Extended, Dynamic Hard, etc). Pattern will be available only during them
	var/list/whitelisted_roundtypes = list()
	/// List of blacklisted roundtypes (Extended, Dynamic Hard, etc). Pattern will not be available during them
	var/list/blacklisted_roundtypes = list()

	// ... НА КВИРКИ

	/// List of whitelisted quirks. Pattern will be available only if owner has one of them
	var/list/whitelisted_quirks = list()
	/// List of blacklisted quirks. Pattern will not be available if owner has one of them
	var/list/blacklisted_quirks = list()

	// ... НА РАСЫ

	/// List of whitelisted species. Pattern will be available only if owner has one of them
	var/list/whitelisted_species = list()
	/// List of blacklisted species. Pattern will not be available if owner has one of them
	var/list/blacklisted_species = list()

	// ... НА ПРОФЕССИИ. Передаётся строками из player.mind.assigned_role

	/// List of whitelisted jobs. Pattern will be available only if owner assigned role is one of them
	var/list/whitelisted_jobs = list()
	/// List of blacklisted jobs. Pattern will not be available if owner assigned role is one of them
	var/list/blacklisted_jobs = list()

	// ... НА МАЙНДШИЛД

	/// Will the mindshield implant in the recipient disable this pattern?
	var/mindshield_prohibited = FALSE
	/// Is the mindshield implant required to get this pattern?
	var/mindshield_required = FALSE


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
	var/list/modified_patterns_list = regenerate_all_weights(recipient, picked_mail_category)
	if(modified_patterns_list.len == 0)
		return FALSE
	var/datum/mail_pattern/chosen_pattern = pickweight(modified_patterns_list)
	parent.pattern = new chosen_pattern(parent)
	parent = null
	qdel(src)


/**
 * Returns 'pattern type = modified weight' assoc list for specific recipient
 * If you want zero-chance patterns to be included in list, use include_zeros. Used in adminpanel.
 * Filtering goes for specific categories, category or list of them passed in the 'categories' parameter.
 * If 'MAIL_ALL_CATEGORIES' parameter was selected search goes for all categories
 * Modification of weight for specific pattern can be specified in switch-case construction in this proc
 * This modification can filter out incompatible (cookies for synths) patterns or take in accout recipient's prefs
 * */
/datum/mail_pattern/proc/regenerate_all_weights(mob/living/carbon/human/recipient, categories = MAIL_ALL_CATEGORIES, include_zeros = FALSE)
	. = list()

	var/list/sanitized_categories = sanitize_islist(categories, list(categories))
	var/list/patterns_list = list()

	if(sanitized_categories[1] == MAIL_ALL_CATEGORIES)
		patterns_list = typesof(/datum/mail_pattern)
	else
		for(var/category in sanitized_categories)
			var/list/types_of_category = typesof(GET_CATEGORY(category))
			for(var/pattern_path in types_of_category)
				patterns_list += pattern_path

	for(var/P in patterns_list)
		var/weight = regenerate_weight_for_pattern(P, recipient)
		if(!include_zeros && weight == 0)
			continue
		.[P] = weight

	return .

/datum/mail_pattern/proc/parse_weights_to_html(list/weights_assoc_list)
	var/html = "<html><body>"
	if(!islist(weights_assoc_list) || !weights_assoc_list.len)
		return "<center><br><br><b>Доступные паттерны отсутствуют!</b></center>"
	var/list/patterns_in_categories = list()
	for(var/P in weights_assoc_list)
		var/datum/mail_pattern/pattern = P
		if(initial(pattern.category) in patterns_in_categories)
			patterns_in_categories[initial(pattern.category)][pattern] = weights_assoc_list[pattern]
		else
			patterns_in_categories[initial(pattern.category)] = list(pattern = weights_assoc_list[pattern])
	for(var/category in patterns_in_categories)
		html += "<br><br><b color='[category_colorize(category)]'>[category_to_text(category)]</b><hr>"
		for(var/P in patterns_in_categories[category])
			var/datum/mail_pattern/pattern = P
			var/pattern_weight = patterns_in_categories[category][pattern]
			html += "<br><i color='[category_colorize(category)]'>[initial(pattern.name)]</i> - [pattern_weight ? pattern_weight : "<span color='#ff2828ff'>НЕДОСТУПЕН</span>"]"
	html += "</body></html>"
	return html

/datum/mail_pattern/proc/category_colorize(category = MAIL_CATEGORY_MISC)
	switch(category)
		if(MAIL_CATEGORY_MISC)
			return "#ffffffff"
		if(MAIL_CATEGORY_ANTAG)
			return "#ff2828ff"
		if(MAIL_CATEGORY_FAMILY)
			return "#02eaffff"
		if(MAIL_CATEGORY_JOB)
			return "#3dff08ff"
		if(MAIL_CATEGORY_MONEY)
			return "#f2ff00ff"
		if(MAIL_CATEGORY_SHOP)
			return "#4e3dffff"
		if(MAIL_CATEGORY_SPAM)
			return "#ff9d00ff"
		if(MAIL_CATEGORY_LEWD)
			return "#ff19d9ff"

/datum/mail_pattern/proc/category_to_text(category = MAIL_CATEGORY_MISC)
	switch(category)
		if(MAIL_CATEGORY_MISC)
			return "Разное"
		if(MAIL_CATEGORY_ANTAG)
			return "Антагонисты"
		if(MAIL_CATEGORY_FAMILY)
			return "Финансы"
		if(MAIL_CATEGORY_JOB)
			return "Семейные"
		if(MAIL_CATEGORY_MONEY)
			return "По работе"
		if(MAIL_CATEGORY_SHOP)
			return "Рассылки магазинов"
		if(MAIL_CATEGORY_SPAM)
			return "Спам"
		if(MAIL_CATEGORY_LEWD)
			return "Пошлости"

/// Returns weight of selected pattern in accordance to all filters and checks, applied to specific recipient
/datum/mail_pattern/proc/regenerate_weight_for_pattern(P, mob/living/carbon/human/recipient)
	var/datum/mail_pattern/pattern = P
	var/pattern_weight = initial(pattern.weight)

	// Фильтр на тип раунда

	if(whitelisted_roundtypes.len)
		if(!(GLOB.round_type in whitelisted_roundtypes))
			return 0
	if(blacklisted_roundtypes.len)
		if(GLOB.round_type in whitelisted_roundtypes)
			return 0

	// Фильтр на квирки

	if(whitelisted_quirks.len)
		var/whitelist_quirk_exists = FALSE
		for(var/quirk in whitelisted_quirks)
			if(quirk in recipient.roundstart_quirks)
				whitelist_quirk_exists = TRUE
				break
		if(!whitelist_quirk_exists)
			return 0
	if(blacklisted_quirks.len)
		for(var/quirk in blacklisted_quirks)
			if(quirk in recipient.roundstart_quirks)
				return 0

	// Фильтр на расы

	if(whitelisted_species.len)
		if(!(recipient.dna?.species in whitelisted_species))
			return 0
	if(blacklisted_species.len)
		if(recipient.dna?.species in blacklisted_species)
			return 0

	// Фильтр на профессии

	if(whitelisted_jobs.len)
		if(!(recipient.mind.assigned_role in whitelisted_jobs))
			return 0
	if(blacklisted_jobs.len)
		if(recipient.mind.assigned_role in blacklisted_jobs)
			return 0

	// Фильтр на майндшилд

	if(mindshield_prohibited && HAS_TRAIT(recipient, TRAIT_MINDSHIELD))
		return 0
	if(mindshield_required && !HAS_TRAIT(recipient, TRAIT_MINDSHIELD))
		return 0

	var/pattern_name = initial(pattern.name)

	// ГЛАВНЫЙ SWITCH-CASE С ПРОВЕРКАМИ, ЭКСКЛЮЗИВНЫМИ ДЛЯ ПАТТЕРНА.
	// ЕСЛИ ВЫ ХОТИТЕ СДЕЛАТЬ ОСОБЫЕ ПРОВЕРКИ ДЛЯ СВОИХ ПАТТЕРНОВ ПИСЕМ, ВПИСЫВАЙТЕ ВСЁ СЮДА ПО ШАБЛОНУ
	switch(pattern_name)
		if("")
			return 0
	// КОНЕЦ ГЛАВНОГО SWITCH-CASE

	return pattern_weight

/// Customising text piece for specific recipient
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

	if(envelope_type == MAIL_TYPE_PACKAGE)
		parent.convert_to_package()

	// 25% шанс получить неправильного адресата
	if(prob(25))
		sender = pick(list("Центральное Командование", "N/A", "Не указан", "УДАЛЕНО", "НЕИЗВЕСТНО", MAIL_SENDER_RANDOM_NAME))
	if(sender == MAIL_SENDER_RANDOM_NAME)
		sender = random_unique_name(pick(MALE, FEMALE), 1)
	else if(sender == MAIL_SENDER_RANDOM_FEMALE)
		sender = random_unique_name(FEMALE, 1)
	else if(sender == MAIL_SENDER_RANDOM_MALE)
		sender = random_unique_name(MALE, 1)
	parent.sender_name = sender

	if(letter_html)
		letter_title = text_customisation(letter_title, recipient)
		letter_html = text_customisation(letter_html, recipient)
		var/obj/item/paper/letter = new /obj/item/paper(parent)
		if(letter)
			letter.show_written_words = FALSE
			letter.name = letter_title
			letter.add_raw_text(letter_html)
			letter.desc = letter_desc
			letter.icon = letter_icon
			letter.icon_state = letter_icon_state
			letter.update_appearance()
			parent.included_letter = letter

	parent.sender_name = sender

	for(var/good in initial_contents)
		new good(parent)

/datum/mail_pattern/proc/special_open_check(mob/living/carbon/human/recipient)
	return TRUE

/datum/mail_pattern/proc/on_mail_open(mob/living/carbon/human/recipient)
	return

// Костыль для компилятора
/datum/mail_pattern/category
	category = MAIL_CATEGORY_MISC

/datum/mail_pattern/misc
	category = MAIL_CATEGORY_MISC

/datum/mail_pattern/antag
	category = MAIL_CATEGORY_ANTAG

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

/**
 *
 * ПАНЕЛЬКА ДЛЯ АДМИНОВ, ПОЗВОЛЯЮЩАЯ СОЗДАВАТЬ ПИСЬМА ПО ШАБЛОНУ
 *
 */

/client/proc/mail_panel()
	set name = "Mail Panel"
	set desc = "Позволяет создавать письма и посылки для определённых игроков."
	set category = "Admin.Game"
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Mail Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	if(!istype(usr, /mob))
		to_chat(usr, span_warning("Вы должны быть мобом, чтобы использовать почтовую панель!"))
		return
	var/datum/mail_panel_gui/tgui = new(usr)
	tgui.ui_interact(usr)

/datum/mail_panel_gui
	var/mob/holder
	var/list/players_assoc_list = list()
	var/list/player_names = list()
	var/mob/living/carbon/human/chosen_recipient = null

/datum/mail_panel_gui/New(mob/user)
	holder = user
	load_player_list()

/datum/mail_panel_gui/Destroy(force, ...)
	holder = null
	players_assoc_list = null
	player_names = null
	chosen_recipient = null
	. = ..()

/datum/mail_panel_gui/proc/load_player_list()
	players_assoc_list = list()
	player_names = list()
	if(istype(holder, /mob/living/carbon/human))
		players_assoc_list["_Для меня!"] = holder
		player_names += "_Для меня!"
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!istype(player))
			continue
		if(player == holder)
			continue
		players_assoc_list[player.real_name] = player
		player_names += player.real_name
	player_names = sort_list(player_names)

/datum/mail_panel_gui/ui_state(mob/user)
	if(!istype(holder, /mob))
		return UI_CLOSE
	return GLOB.admin_state

/datum/mail_panel_gui/ui_close()
	qdel(src)

/datum/mail_panel_gui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mail Admin Panel")
		ui.open()

/datum/mail_panel_gui/ui_data(mob/user)
	var/list/data = list()

	data[""] = src

	return data

/datum/mail_panel_gui/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()

	data["player_names"] = player_names

	return data

/datum/mail_panel_gui/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("update_data")
			load_player_list()
			update_static_data(holder)
		if("check_weights_for_recipient")
			if(!istype(chosen_recipient))
				to_chat(holder, span_warning("Получатель не указан или не валиден!"))

#undef MAIL_CATEGORY_MISC
#undef MAIL_CATEGORY_ANTAG
#undef MAIL_CATEGORY_MONEY
#undef MAIL_CATEGORY_FAMILY
#undef MAIL_CATEGORY_JOB
#undef MAIL_CATEGORY_SHOP
#undef MAIL_CATEGORY_SPAM
#undef MAIL_CATEGORY_LEWD
#undef MAIL_TYPE_ENVELOPE
#undef MAIL_TYPE_PACKAGE
#undef MAIL_ALL_CATEGORIES
#undef MAIL_SENDER_RANDOM_NAME
#undef MAIL_SENDER_RANDOM_FEMALE
#undef MAIL_SENDER_RANDOM_MALE
