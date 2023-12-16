/**
 * Напитки для синтетиков
**/

/datum/reagent/consumable/synthdrink
	name = "Positronic Oil"
	description = "A strange mixture of oils, intended for robots. It may have interesting effects on positronic brain's mechanisms when mixed with other reagents..."
	color = "#000000"
	chemical_flags = REAGENT_ORGANIC_PROCESS | REAGENT_ROBOTIC_PROCESS
	nutriment_factor = 0
	pH = 7.33
	boiling_point = 351.38
	taste_mult = 3
	taste_description = "motor oil"
	var/synthetic_taste = "сладкого, сладкого масла..." // Данный вкус будет писаться особым шрифтом при потреблении синтетиками
	glass_name = "glass of positronic oil"
	glass_desc = "A glass of what synthetic crewmembers can call a drink. Smells of motor oil."
	value = REAGENT_VALUE_VERY_COMMON
	accelerant_quality = 5

/datum/reagent/consumable/synthdrink/define_gas() // Небольшая копипаста с этанола
	var/datum/gas/G = new
	G.id = GAS_MOTOR_OIL
	G.name = "Motor oil"
	G.enthalpy = -234800
	G.specific_heat = 38
	G.fire_products = list(GAS_CO2 = 1, GAS_H2O = 1.5)
	G.fire_burn_rate = 1 / 3
	G.fire_temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	G.color = "#151510"
	G.breath_reagent = /datum/reagent/consumable/synthdrink
	G.group = GAS_GROUP_CHEMICALS
	return G

/datum/reagent/consumable/synthdrink/get_gas()
	var/datum/auxgm/cached_gas_data = GLOB.gas_data
	. = GAS_MOTOR_OIL
	if(!(. in cached_gas_data.ids))
		var/datum/gas/G = define_gas()
		if(istype(G))
			cached_gas_data.add_gas(G)
		else
			return null

/datum/reagent/consumable/synthdrink/on_mob_add(mob/living/M, amount)
	. = ..()
	// Органики явно не любят пить бензин
	if(!isrobotic(M))
		if(!HAS_TRAIT(src, TRAIT_AGEUSIA))
			to_chat(M, "<span class='warning'>Фу! Это было отвратительно!</span>")
			M.adjust_disgust(30)
		else
			to_chat(M, "<span class='warning'>Вы чувствуете, что проглотили странную слегка липковатую жидкость...</span>")
		return

	// Синтетики
	if(!HAS_TRAIT(src, TRAIT_AGEUSIA))
		to_chat(M, "<span class='synth'>Ваши гастрономические сенсоры ощущают вкус [synthetic_taste]</span>")
	else
		to_chat(M, "<span class='warning'>Ваши сенсоры не могут распознать попавший в систему реагент...</span>")
	synthetic_on_add(M) // Уникальные последствия от принятия отдельных реагентов для синтетиков

/datum/reagent/consumable/synthdrink/on_mob_life(mob/living/carbon/M)
	// Органики продолжают страдать
	if(!isrobotic(M))
		if (prob(5))
			to_chat(M, "<span class='warning'>Ваш живот крутит...</span>")
			M.adjust_disgust(5)
		if (prob(10))
			M.adjustToxLoss(5)
		if (prob(5))
			if(!HAS_TRAIT(src, TRAIT_NOHUNGER))
				M.vomit(50, FALSE, TRUE, 1, FALSE)
				M.reagents.remove_reagent(type, 25)
				to_chat(M, "<span class='warning'>Ваш живот внезапно скручивает и вы сблёвываете поток какой-то технической жидкости. Фу...</span>")
			else
				to_chat(M, "<span class='warning'>Вы чувствуете неприятное ощущение у себя в животе...</span>")
				M.adjustToxLoss(5)
		return ..()

	// Синтетики
	synthetic_on_life(M)
	return ..()

// То, какие эффекты будет оказывать напиток на синтетиков постоянно
/datum/reagent/consumable/synthdrink/proc/synthetic_on_life(mob/living/carbon/M)
	return

// То, какие эффекты будет оказывать напиток на синтетиков при принятии
/datum/reagent/consumable/synthdrink/proc/synthetic_on_add(mob/living/carbon/M)
	return

/datum/reagent/consumable/synthdrink/synthanol
	name = "Synthanol"
	description = "Some kind of oily substance, smelling of ethanol"
	color = "#009cfc"
	synthetic_taste = "попойки на роботостроительном заводе..."
	glass_name = "glass of synthanol"
	glass_desc = "An interesting mixture capable of inducing a positronic mind into a state similar to alcohol intoxication"
	var/boozepwr = 70
	accelerant_quality = 5

/datum/reagent/consumable/synthdrink/synthanol/synthetic_on_life(mob/living/carbon/M)
	if(HAS_TRAIT(M, TRAIT_TOXIC_ALCOHOL))
		M.adjustToxLoss((boozepwr/25)*REM,forced = TRUE)
		if(prob(3) && !HAS_TRAIT(src, TRAIT_AGEUSIA))
			to_chat(M, "<span class='warning'>Ваш процессор реагентов сообщает о присутствии вредоносной смеси в системе. Рекомендована срочная очистка во избежание коррозийных процессов.</span>")
	else if(M.drunkenness < volume * boozepwr * ALCOHOL_THRESHOLD_MODIFIER)
		var/booze_power = boozepwr
		if(HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE)) // Робот-алкаш - горе в семье
			booze_power *= 0.7
		M.drunkenness = max((M.drunkenness + (sqrt(volume) * booze_power * ALCOHOL_RATE)), 0)

/datum/reagent/consumable/synthdrink/synthanol/synthetic_on_add(mob/living/carbon/M)
	if(HAS_TRAIT(M, TRAIT_TOXIC_ALCOHOL) && !HAS_TRAIT(src, TRAIT_AGEUSIA))
		to_chat(M, "<span class='warning'>Ваши сенсоры обнаруживают ядовитый для вас синтанол в выпитой вами жидкости!</span>")

