// BLUEMOON ADD - настройки для квирков
#define QUIRK_OPTION_STRING_SEPARATOR "__~__"
#define QUIRK_OPTION_GLOBAL_STRING_SEPARATOR "; "

/datum/quirk_option
	var/datum/quirk/quirk
	var/name = "base_option"
	var/options_show_title = "Выберите настройки для квирка"
	var/options_show_desc = "Выберите что-то из следующего списка."
	var/list/options = list()
	var/default_option = ""
	var/current_choice = ""

/datum/quirk_option/proc/apply()
	var/list/quirk_options = quirk.quirk_holder?.client?.prefs?.quirk_options
	if(!quirk_options)
		current_choice = default_option
	else
		current_choice = find_option_in_list(quirk_options)
		if(!current_choice)
			current_choice = default_option
	// Здесь мог бы быть ваш код
	return

/datum/quirk_option/proc/prefs_show_options(user)
	var/user_input = input(user, options_show_desc, options_show_title) as null|anything in options
	if(user_input)
		var/chosen_option = options[user_input]
		if(!chosen_option)
			return FALSE
		var/restrictions = check_restrictions(user, chosen_option)
		var/converted_prefs_string = prefs_convert(chosen_option)
		if(restrictions)
			to_chat(user, "<span class='warning'>[restrictions]</span>")
			return FALSE
		if(converted_prefs_string)
			current_choice = converted_prefs_string
			return current_choice
	return FALSE

/datum/quirk_option/proc/check_restrictions(user, user_input)
	return FALSE

/datum/quirk_option/proc/prefs_convert(option)
	if(option && quirk.name && name)
		var/pref_string = quirk.name + QUIRK_OPTION_STRING_SEPARATOR + name + QUIRK_OPTION_STRING_SEPARATOR + option
		return pref_string
	return FALSE

/datum/quirk_option/proc/find_n_replace(list/all_options, new_string)
	if(!all_options || !new_string)
		return
	var/list/final_list = list()
	if(all_options.len == 0)
		final_list += new_string
		return final_list
	var/list/new_option_parameters = splittext(new_string, QUIRK_OPTION_STRING_SEPARATOR)
	if(!new_option_parameters || new_option_parameters.len < 3)
		stack_trace("Tried to insert corrupted quirk option \"[new_string]\" in DB")
		return FALSE
	for(var/option_str in all_options)
		var/list/option_parameters = splittext(option_str, QUIRK_OPTION_STRING_SEPARATOR)
		if(!option_parameters || option_parameters.len < 3)
			stack_trace("Сorrupted quirk option \"[option_str]\" appeared in DB")
			continue
		if(option_parameters[1] == new_option_parameters[1] && option_parameters[2] == new_option_parameters[2])
			final_list = all_options.Copy()
			final_list -= option_str
			final_list += new_string
			return final_list
	final_list = all_options.Copy()
	final_list += new_string
	return final_list

/datum/quirk_option/proc/find_option_in_list(list/all_options)
	if(!all_options)
		return ""
	if(all_options.len == 0)
		return ""
	for(var/option_str in all_options)
		var/list/option_parameters = splittext(option_str, QUIRK_OPTION_STRING_SEPARATOR)
		if(!option_parameters || option_parameters.len < 3)
			stack_trace("Сorrupted quirk option \"[option_str]\" appeared in DB")
			continue
		if(option_parameters[1] == quirk.name && option_parameters[2] == name)
			if(option_parameters[3])
				return option_parameters[3]
	return ""
