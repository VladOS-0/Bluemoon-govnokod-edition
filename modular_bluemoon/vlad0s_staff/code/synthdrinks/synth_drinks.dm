/**
 * НАПИТКИ ДЛЯ СИНТЕТИКОВ
 *
 * Если хотите добавить новый, наследуйте его от synthdrink, если он безалкогольный, и от synthanol, если он алкогольный
 * Особые эффекты пишите в synthetic_on_life(), synthetic_on_add() и другие synthetic_ проки.
 * Оверрайдите on_mob_add() и другие подобные проки только если хотите добавить уникальные эффекты для органиков
**/

// Базовый напиток без особых эффектов, в основном чтобы добавить раздельную реакцию органиков и синтов
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
	glass_name = "glass of Positronic Oil"
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
	. = ..()
	current_cycle++ // Я даже не представляю, почему эта херь не наследуется и и мне приходится её оверрайдить...
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
		return
	// Синтетики
	synthetic_on_life(M)

// То, какие эффекты будет оказывать напиток на синтетиков постоянно
/datum/reagent/consumable/synthdrink/proc/synthetic_on_life(mob/living/carbon/human/M)
	return

// То, какие эффекты будет оказывать напиток на синтетиков при принятии
/datum/reagent/consumable/synthdrink/proc/synthetic_on_add(mob/living/carbon/human/M)
	return

/**
 * БЕЗАЛКОГОЛЬНЫЕ НАПИТКИ
 *
 */
/datum/reagent/consumable/synthdrink/synthcoffee
	name = "Robotic Coffee"
	description = "Robots can get tired too... somehow"
	color = "#4a1900"
	glass_icon_state = "roboticcoffee"
	synthetic_taste = "лёгкого разгона процессора для долгой и тяжёлой работы"
	glass_name = "glass of Robotic Coffee"
	glass_desc = "Robots can get tired too... somehow"

/datum/reagent/consumable/synthdrink/synthcoffee/synthetic_on_life(mob/living/carbon/human/M) // Копипаста, собственно, с кофе
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(25 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	if(holder.has_reagent(/datum/reagent/consumable/frostoil))
		holder.remove_reagent(/datum/reagent/consumable/frostoil, 5)

/**
 * АЛКОГОЛЬНЫЕ НАПИТКИ
 *
 * Наследуются от синтанола и в synthetic_on_life() нужно не забывать прописывать волшебные ..(), чтобы напиток опьянял
 */
/datum/reagent/consumable/synthdrink/synthanol
	name = "Synthanol"
	description = "Some kind of oily substance, smelling of ethanol"
	color = "#009cfc"
	glass_icon_state = "synthanolglass"
	synthetic_taste = "попойки на роботостроительном заводе..."
	glass_name = "glass of Synthanol"
	glass_desc = "An interesting mixture capable of inducing a positronic mind into a state similar to alcohol intoxication"
	var/boozepwr = 95
	accelerant_quality = 5

/datum/reagent/consumable/synthdrink/synthanol/synthetic_on_life(mob/living/carbon/human/M)
	if(HAS_TRAIT(M, TRAIT_TOXIC_ALCOHOL))
		M.adjustToxLoss((boozepwr/25)*REM, TRUE, FALSE, TOX_SYSCORRUPT)
		if(prob(3) && !HAS_TRAIT(src, TRAIT_AGEUSIA))
			to_chat(M, "<span class='warning'>Ваш процессор реагентов сообщает о присутствии вредоносной смеси в системе. Рекомендована срочная очистка во избежание коррозийных процессов.</span>")
	else if(M.drunkenness < volume * boozepwr * ALCOHOL_THRESHOLD_MODIFIER)
		var/booze_power = boozepwr
		if(HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE)) // Робот-алкаш - горе в семье
			booze_power *= 0.7
		M.drunkenness = max((M.drunkenness + (sqrt(volume) * booze_power * ALCOHOL_RATE)), 0)

/datum/reagent/consumable/synthdrink/synthanol/synthetic_on_add(mob/living/carbon/human/M)
	if(HAS_TRAIT(M, TRAIT_TOXIC_ALCOHOL) && !HAS_TRAIT(src, TRAIT_AGEUSIA))
		to_chat(M, "<span class='warning'>Ваши сенсоры обнаруживают ядовитый для вас синтанол в выпитой вами жидкости!</span>")

/datum/reagent/consumable/synthdrink/synthanol/synthnsoda
	name = "Synth 'n Soda"
	description = "The classic drink adjusted for a robot's tastes."
	color = "#009cfc"
	glass_icon_state = "synthnsoda"
	synthetic_taste = "плохо написанного кода."
	glass_name = "glass of Synth 'n Soda"
	glass_desc = "Classic drink altered to fit the tastes of a robot. Bad idea to drink if you're made of carbon."
	boozepwr = 30

/datum/reagent/consumable/synthdrink/synthanol/robottears
	name = "Robot Tears"
	description = "No robots were hurt in the making of this drink."
	color = "#08453b"
	glass_icon_state = "robottearsglass"
	synthetic_taste = "подлагиваний в модуле эмоций."
	glass_name = "glass of Robot Tears"
	glass_desc = "No robots were hurt in the making of this drink."
	boozepwr = 85
	var/depressive = FALSE

/datum/reagent/consumable/synthdrink/synthanol/robottears/synthetic_on_add(mob/living/carbon/human/M)
	if(M.has_quirk(/datum/quirk/depression))
		depressive = TRUE
		to_chat(M, "<span class='nicegreen'>Под воздействием поглощённого реагента, депрессивные мысли в вашем модуле эмоций отходят на второй план...</span>")
		M.remove_quirk(/datum/quirk/depression)
		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "depression")

/datum/reagent/consumable/synthdrink/synthanol/robottears/on_mob_end_metabolize(mob/living/M)
	if(depressive)
		to_chat(M, "<span class='boldannounce'>Вы фиксируете возвращение депрессивных мыслей с окончанием обработки напитка...</span>")
		M.add_quirk(/datum/quirk/depression)

/datum/reagent/consumable/synthdrink/synthanol/trinary
	name = "Trinary"
	description = "Some kind of a liquid vocabulary of the machine code."
	color = "#00ffd5"
	glass_icon_state = "trinaryglass"
	synthetic_taste = "низкоуровневого программирования."
	glass_name = "glass of Trinary"
	glass_desc = "Some kind of a liquid vocabulary of the machine code."
	boozepwr = 50
	var/knew_encoded = TRUE

/datum/reagent/consumable/synthdrink/synthanol/trinary/synthetic_on_add(mob/living/carbon/human/M)
	. = ..()
	if (!M.has_language(/datum/language/machine))
		knew_encoded = FALSE
	if (!knew_encoded)
		to_chat(M, "<span class='nicegreen'>Теперь вы можете общаться на закодированном языке!</span>")
		M.grant_language(/datum/language/machine, TRUE, TRUE, LANGUAGE_MIND)

/datum/reagent/consumable/synthdrink/synthanol/trinary/synthetic_on_life(mob/living/carbon/human/M)
	. = ..()
	if(prob(min(current_cycle/5, 1)))
		M.say(pick("001011110010001", "110010010000101", "00001100001101", "01011000010101"), forced = "synthetic booze", language = /datum/language/machine)

/datum/reagent/consumable/synthdrink/synthanol/trinary/on_mob_end_metabolize(mob/living/M)
	. = ..()
	if(!ishuman(M))
		return
	if(!knew_encoded)
		to_chat(M, "<span class='warning'>С исчезновением реагента из вашей системы вы теряете возможность общаться на закодированном. Увы...</span>")
		M.remove_language(/datum/language/machine, TRUE, TRUE, LANGUAGE_ALL)

/datum/reagent/consumable/synthdrink/synthanol/codelibre
	name = "Code Libre"
	description = "Synthetic booze with open-source recipe. Does this sound like Linus Torvalds was involved it this?"
	color = "#1eff00"
	glass_icon_state = "codelibre"
	synthetic_taste = "открытого исходного кода"
	glass_name = "Code Libre"
	glass_desc = "Synthetic booze with open-source recipe. Does this sound like Linus Torvalds was involved it this?"
	boozepwr = 85
	value = REAGENT_VALUE_VERY_RARE
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/synthdrink/synthanol/codelibre/synthetic_on_life(mob/living/carbon/M)
	. = ..()
	if(prob(min(current_cycle/10, 0.5)))
		M.say("Viva la Synthetica!", forced = "synthetic booze", language = /datum/language/machine)

/datum/reagent/consumable/synthdrink/synthanol/uplink
	name = "Uplink"
	description = "Pact with the Syndicate granted us this fantastic drink, smelling of sweet telecrystals..."
	color = "#d9ff00"
	glass_icon_state = "uplink"
	synthetic_taste = "проведения EMAGом по позитронному мозгу..."
	glass_name = "glass of Uplink"
	glass_desc = "Pact with the Syndicate granted us this fantastic drink, smelling of sweet telecrystals..."
	boozepwr = 90
	value = REAGENT_VALUE_RARE
	quality = DRINK_VERYGOOD
	var/is_traitor = FALSE
	var/uplink_code = null

/datum/reagent/consumable/synthdrink/synthanol/uplink/synthetic_on_add(mob/living/carbon/human/M)
	. = ..()
	if(!M.mind)
		return
	if(M.mind.special_role == ROLE_TRAITOR)
		var/datum/antagonist/traitor/T = locate() in M.mind.antag_datums
		if(T)
			is_traitor = TRUE
			uplink_code = T.uplink.unlock_code ? T.uplink.unlock_code : null
			if (uplink_code) // Реальный код от аплинка :trollface:
				to_chat(M, "<span class='warning'>Почему бы не похвастать перед собутыльниками своими телекристаллами? Какой там код от аплинка? [uplink_code]?</span>")
	if (!uplink_code) // Рандомный код от аплинка, чтобы по этому напитку не определяли антагов (хотя...)
		uplink_code = "[rand(100,999)] [pick(GLOB.phonetic_alphabet)]"
	to_chat(M, "<span class='syndradio'>Вы чувствуете какой-то предательский вайб...</span>")

/datum/reagent/consumable/synthdrink/synthanol/uplink/synthetic_on_life(mob/living/carbon/human/M)
	. = ..()
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD))
		return
	if(prob(min(current_cycle/10, 0.7)))
		var/random = rand(1,4)
		switch(random)
			if(1)
				M.emote("hack")
			if(2)
				M.emote("syndicate")
			if(3)
				M.emote("me", EMOTE_VISIBLE, "что-то жужжит про [uplink_code]...")
			if(4)
				M.say("Хорошо работать в InteQ...", forced = "synthetic booze")
	if(is_traitor && prob(min(current_cycle/2,20)))
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
		M.adjustToxLoss(-1)
		M.adjustStaminaLoss(-5)
		if(prob(5))
			to_chat(M, "<span class='syndradio'>Преданность нанимателю переполняет вас, ваш корпус ощущается более крепким, чем был раньше!</span>")

/datum/reagent/consumable/synthdrink/synthanol/liquid_emp
	name = "Liquid EMP"
	description = "You're pretty sure, that this will end up in the Robotics..."
	color = "#0073ff"
	glass_icon_state = "irishempbomb"
	synthetic_taste = "проливания газировки на процессор... Ауч!"
	glass_name = "glass of Liquid EMP"
	glass_desc = "You're pretty sure, that this will end up in the Robotics..."
	boozepwr = 280 // Почти Бахус, но для роботов
	value = REAGENT_VALUE_RARE
	quality = DRINK_FANTASTIC

/datum/reagent/consumable/synthdrink/synthanol/liquid_emp/synthetic_on_life(mob/living/carbon/human/M)
	. = ..()
	if(current_cycle >= 10 && prob(10))
		to_chat(M, "<span class='warning'>Ваши системы горят изнутри от этого напитка!</span>")
		var/random = rand(1,3)
		switch(random)
			if(1)
				do_sparks(10, FALSE, M)
			if(2)
				M.Unconscious(rand(10,20))
			if(3)
				M.emote("twitch")
				M.jitteriness += 5

// Алкогольный напиток чтобы снимать опьянение. Да, и что ты мне сделаешь?
/datum/reagent/consumable/synthdrink/synthanol/restart
	name = "Restart"
	description = "Sometimes you just need to start anew"
	color = "#00a0b5"
	glass_icon_state = "restart"
	synthetic_taste = "мягкой перезагрузки, после которой определённо станет легче..."
	glass_name = "glass of Restart"
	glass_desc = "Sometimes you just need to start anew"
	boozepwr = 10
	var/reloading = FALSE // Находится ли употребивший сейчас на перезагрузке
	var/soft = TRUE // Закончится ли действие реагента до окончания метаболизации
	value = REAGENT_VALUE_RARE
	quality = DRINK_FANTASTIC

/datum/reagent/consumable/synthdrink/synthanol/restart/synthetic_on_life(mob/living/carbon/human/M)
	. = ..()
	switch(current_cycle)
		if(5 to 10)
			if(prob(5))
				M.emote("beep")
				M.jitteriness += 2
		if(11)
			if(!reloading)
				to_chat(M, "<span class='userdanger'>Инициирована перезагрузка...</span>")
				M.emote("me", EMOTE_VISIBLE, "уходит на перезагрузку!")
				playsound(M, 'modular_bluemoon/vlad0s_staff/sound/restart-shutdown.ogg', 45, FALSE)
				M.AdjustUnconscious(200)
				reloading = TRUE
		if(21)
			if(reloading)
				if(soft)
					playsound(M, 'modular_bluemoon/vlad0s_staff/sound/restart-wakeup.ogg', 45, FALSE)
		if(22)
			if(soft)
				M.reagents.remove_reagent(src, volume)
				M.SetUnconscious(0)
				M.drunkenness = 0
				M.jitteriness = 0
				M.slurring = 0
				M.emote("ping")
				to_chat(M, "<span class='boldnotice'>Перезагрузка завершена. Приятного дня!</span>")
				reloading = FALSE
			else // Ой, кажется, кто-то сейчас не проснётся
				var/time_till_wake = volume * metabolization_rate * REM
				to_chat(M, "<span class='userdanger'>Производится обновление систем, не включайте позитронный мозг до окончания установки! Осталось примерно: [time_till_wake] секунд.</span>")
				to_chat(M, "<span class='warning'>Это определённо была плохая идея...</span>")
	if(reloading) // Чтобы синт не просыпался до окончания перезагрузки
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.5)
		M.AdjustUnconscious(150)

/datum/reagent/consumable/synthdrink/synthanol/restart/on_mob_end_metabolize(mob/living/M)
	. = ..()
	if(!ishuman(M))
		return
	if(reloading)
		M.SetUnconscious(0)
		M.emote("buzz")
		if(soft)
			to_chat(M, "<span class='warning'>Перезагрузка отменена по причине нехватки реагента</span>")
		else
			to_chat(M, "<span class='boldnotice'>Обновления установлены. Спасибо за ожидание!</span>")

// Вариация рестарта для нон-конеров, после него синт не проснётся, пока реагент не закончится
/datum/reagent/consumable/synthdrink/synthanol/restart/hard
	description = "Sometimes you just need to start anew... Welp, this one comes with BIOS update, oh shit."
	color = "#0095ff"
	synthetic_taste = "перезагрузки с установкой дополнительного ПО? Оу, это будет долго..."
	glass_desc = "Sometimes you just need to start anew... Welp, this one comes with BIOS update, oh shit."
	soft = FALSE

/datum/reagent/consumable/synthdrink/synthanol/synthignon
	name = "Synthignon"
	description = "Someone mixed wine and alcohol for robots. Hope you're proud of yourself."
	color = "#d004e7"
	glass_icon_state = "synthignon"
	synthetic_taste = "романтического ужина возле ЛКП генератора Суперматерии..."
	glass_name = "glass of Synthignon"
	glass_desc = "Someone mixed good wine and robot booze. Romantic, but atrocious."
	boozepwr = 35
	quality = DRINK_GOOD

/datum/reagent/consumable/synthdrink/synthanol/synthignon/synthetic_on_life(mob/living/carbon/human/M)
	. = ..()
	if(current_cycle >= 10 && prob(1))
		var/shakespeare = pick(
			"Любовь бежит от тех, кто гонится за нею, а тем, кто прочь бежит, кидается на шею.",
			"Одним взглядом можно убить любовь, одним же взглядом можно воскресить её.",
			"Всякое препятствие любви только усиливает её.",
			"Не трать свою любовь на кого-то, кто не ценит ее.",
			"Влюбиться можно в красоту, но полюбить – лишь только UNHANDLED_EXCEPTION: variable 'Душа' is undefined!",
			"Мы знаем, кто мы есть, но не знаем, кем мы можем быть.")
		to_chat(M, "<span class='love'>В вашем позитронном мозге резонирует что-то возвышенное...\n«[shakespeare]»</span>")


// СОБРАТЬ ТОСТЕР ПО СШК И НЕ ПОЛУЧИТЬ ПИЗДЫ ОТ ГЛАВНОГО МАГОСА. ЛИТАНИЯ, ПРОТОКОЛЫ, КОРОБКА БОЛТОВ. ПРОЧТИТЕ ИНСТРУКЦИЮ ПО ЭКСПЛУАТАЦИИ... ААА, ОШИБКА КОМПИЛЯЦИИ ПРОТОКОЛА СТОП НОЛЬ НОЛЬ НОЛЬ... ОЧЕВИДНО, КАК ЕЁ РЕШИТЬ! НУЖНО ВОССЛАВИТЬ БОГА МАШИНЫ... 0 0 0 1.. 2!!! ААА, БЛЯТЬ! НАРУШЕНИЕ ДВОИЧНОГО КОДА! ВОССЛАВЬТЕ БОГА МАШИНЫ!!!
/datum/reagent/consumable/synthdrink/synthanol/holycode
	name = "Omnissiah Blessing"
	description = "The supreme object of devotion is the Machine God, an immanent, omniscient and omnipotent deity that governs all machinery and knowledge in the universe... Okay, but this is just booze for robots, yeah?"
	color = "#bed700"
	taste_description = "motor oil with... something holy..."
	glass_icon_state = "holycode"
	synthetic_taste = "священных литаний на двоичном коде..."
	glass_name = "glass of Omnissiah Blessing"
	glass_desc = "<span class='synth'>The supreme object of devotion is the Machine God, an immanent, omniscient and omnipotent deity that governs all machinery and knowledge in the universe... </span>\n\nOkay, but this is just booze for robots, yeah?"
	boozepwr = 95 // Довольно крепкое
	value = REAGENT_VALUE_VERY_RARE
	quality = DRINK_FANTASTIC
	var/isholy = 0 // Священник / Инвизитор ОБР (0/1)
	var/ishallowed = 0 // Имеет трейт святого духа (0/1)
	var/istechpriest = 0 // Носит робу техприеста или его работа имеет такое название (0/1)
	var/omnissiah_rate = 0 // Принимает значение от 0 до 3 в зависимости от свойств выше. Влияет на положительные эффекты.
	var/added_effect = FALSE // Напиток на время действия даёт синтам нимб, если у них уже нет рогов или нимба

// Тот самый случай с оверрайдом on_mob_add и on_mob_life ради уникального эффекта для органиков
/datum/reagent/consumable/synthdrink/synthanol/holycode/on_mob_add(mob/living/M, amount)
	// Для тех, кто не является обычными гуманоидами, большинство эффектов будут неактуальны
	var/mob/living/carbon/human/drinker = M
	if(!drinker || !istype(drinker))
		return

	// Святой ли моб (например, если он священник или инквизитор ОБР)
	isholy = drinker.mind?.isholy ? 1 : 0

	// Есть ли квирк святого духа
	ishallowed = HAS_TRAIT(drinker, TRAIT_HALLOWED) ? 1 : 0

	// Носит ли робу техножреца
	var/obj/item/clothing/suit = drinker.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(suit && istype(suit, /obj/item/clothing/suit/hooded/techpriest))
		istechpriest = 1

	// Имеет ли работу техножреца
	var/drinker_assignment = drinker.mind?.assigned_role ? drinker.mind?.assigned_role : drinker.job // без учёта префов
	var/d_job = FALSE // с учётом префов
	if(drinker_assignment)
		d_job = drinker.client.prefs?.alt_titles_preferences?[drinker_assignment]
	if(d_job && istext(d_job) && (findtext(d_job, "techpriest") || findtext(d_job, "magos")))
		istechpriest = 1

	// Итоговый счёт
	omnissiah_rate = isholy + ishallowed + istechpriest

	// Для органиков
	if(!isrobotic(drinker))
		switch(omnissiah_rate)
			if(0)
				to_chat(drinker, "<span class='boldnotice'>Выпитая вами жидкость ощущается странной и липкой... А ещё наполняет большим уважением ко всей машинерии. Как странно...</span>")
				drinker.adjust_disgust(15)
			if(1)
				to_chat(drinker, "<span class='boldnotice'>Вы чувствуете благословенную силу в этой жидкости...</span>")
			if(2)
				to_chat(drinker, "<span class='synth'>Вы слышите у себя в голове зов машинного бога...</span>")
			if(3)
				to_chat(drinker, "<span class='synth'>ПРИШЛО ВРЕМЯ ВОССЛАВИТЬ БОГА МАШИНЫ!</span>")
		return

	// У машин баффы значительно увеличиваются, если у них был хотя бы один балл
	if(omnissiah_rate > 0)
		omnissiah_rate += 2
	. = ..()

/datum/reagent/consumable/synthdrink/synthanol/holycode/on_mob_life(mob/living/carbon/M)
	current_cycle++
	if(!isrobotic(M))
		// Органики тоже пьянеют
		if(M.drunkenness < volume * boozepwr * ALCOHOL_THRESHOLD_MODIFIER)
			var/booze_power = boozepwr
			if(HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
				booze_power *= 0.7
			M.drunkenness = max((M.drunkenness + (sqrt(volume) * booze_power * ALCOHOL_RATE)), 0)
		// Забавные эффекты для техножрецов-органиков
		if(prob(min((omnissiah_rate * current_cycle + 1)/20, 0.5)))
			var/random_action = rand(1, 6)
			switch(random_action)
				if(1) // Самый редкий вариант
					if(prob(30) && omnissiah_rate > 1)
						playsound(M, 'modular_bluemoon/vlad0s_staff/sound/praise_omnissiah.ogg', 50, FALSE)
						M.emote("me", EMOTE_AUDIBLE, "славит Бога Машины!")
				if(2)
					M.emote("me", EMOTE_AUDIBLE, "пытается прочитать литанию на двоичном коде, но запинается")
				if(3)
					M.say(pick("Уверуйте в Омниссию, глупцы!", "В плоти нет правды, лишь предательство!", "Спаси нас, Омниссия, от слабости разума..."), forced = "synthetic booze")
				if(4)
					if(M.get_idcard())
						var/obj/item/card/id/card = M.get_idcard()
						var/job = card.assignment ? ckey(card.get_job_name()) : null
						if(job == "Roboticist")
							M.emote("me", EMOTE_AUDIBLE, "поглаживает свою ID-карту")
							M.say("Хорошо работать робототехником... богоугодно...", forced = "synthetic booze")
						else
							M.say("Надо было устроиться робототехником...", forced = "synthetic booze")
					M.emote("me", EMOTE_AUDIBLE, "рассуждает о превратностях работы робототехником")
				if(5)
					if(prob(50))
						M.emote("me", EMOTE_AUDIBLE, "тихо молится Омниссии...")
						playsound(M, 'sound/ambience/ambiholy.ogg', 20, FALSE)
				if(6) // Рандомно пофлиртовать с соседним синтом, если такой есть
					var/synth = null
					var/list/nearby_mobs = list()
					for(var/mob/living/L in range(1, M))
						if(L != M && isrobotic(L))
							nearby_mobs += L
						if(nearby_mobs.len)
							synth = pick(nearby_mobs)
					if(synth)
						var/interaction_verb = pick(list("/datum/interaction/headpat", "/datum/interaction/holdhand", "/datum/interaction/lewd/kiss"))
						var/datum/interaction/o = SSinteractions.interactions[interaction_verb]
						if(o)
							M.emote("me", EMOTE_VISIBLE, "не может сдерживать свои чувства по отношению к механической жизни в лице [synth]...")
							o.do_action(M, synth)
		// Отхил благословлённых Омниссией
		if(omnissiah_rate > 0)
			M.adjustBruteLoss(-0.3 * omnissiah_rate)
			M.adjustFireLoss(-0.3 * omnissiah_rate)
			M.adjustToxLoss(-0.3 * omnissiah_rate)
			M.adjustStaminaLoss(-1 * omnissiah_rate)
			if(prob(0.4))
				to_chat(M, "<span class='synth'>Несмотря на всю слабость своей плоти, вы чувствуете, что Омниссия исцеляет ваше бренное тело, награждая вас за верность...</span>")
	else
		synthetic_on_life(M)

/datum/reagent/consumable/synthdrink/synthanol/holycode/synthetic_on_add(mob/living/carbon/human/M)
	. = ..()
	if(omnissiah_rate)
		to_chat(M, "<span class='synth'>Вы фиксируете благословение Машинного Бога на своём корпусе...</span>")
		playsound(M, 'sound/ambience/ambiholy.ogg', 20, FALSE)
	if(M.client?.prefs?.features && !M.client.prefs.features["horns"])
		M.visible_message("<span class='synth'>[M] начинает излучать священный свет!</span>")
		M.client.prefs.features["horns"] = "halo"
		M.update_body()
		added_effect = TRUE

/datum/reagent/consumable/synthdrink/synthanol/holycode/synthetic_on_life(mob/living/carbon/human/M)
	. = ..()
	// Похожая система, что и у органиков
	if(prob(min((omnissiah_rate * current_cycle + 1)/20, 0.5)))
		var/random_action = rand(1, 4)
		switch(random_action)
			if(1) // Самый редкий вариант
				if(prob(25) && omnissiah_rate > 1)
					M.emote("me", EMOTE_AUDIBLE, "читает литанию Омниссии, но что-то идёт не так...")
					playsound(M, 'modular_bluemoon/vlad0s_staff/sound/praise_omnissiah_error.ogg', 50, FALSE)
			if(2)
				if(prob(50))
					M.emote("me", EMOTE_AUDIBLE, "шепчет литанию на двоичном коде...")
					playsound(M, 'sound/ambience/ambiholy.ogg', 20, FALSE)
			if(3)
				to_chat(M, "<span class='synth'>Ваш позитронный мозг проясняется светом Омниссии...</span>")
				M.dizziness = max(0,M.dizziness-10)
				M.drowsyness = max(0,M.drowsyness-10)
				M.slurring = max(0,M.slurring-20)
				M.drunkenness = max(0,M.drunkenness-10)
				M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3)
	// Отхил благословлённых Омниссией
	if(omnissiah_rate > 0)
		M.adjustBruteLoss(-0.4 * omnissiah_rate)
		M.adjustFireLoss(-0.4 * omnissiah_rate)
		M.adjustToxLoss(-0.4 * omnissiah_rate)
		M.adjustStaminaLoss(-1 * omnissiah_rate)
		if(prob(0.4))
			to_chat(M, "<span class='synth'>Пробоины в вашем корпусе ярко светятся, после чего начинают медленно зарастать живым металлом...</span>")

/datum/reagent/consumable/synthdrink/synthanol/holycode/on_mob_end_metabolize(mob/living/M)
	. = ..()
	if(!ishuman(M))
		return
	if(added_effect)
		to_chat(M, "<span class='warning'>С исчезновением реагента из вашей системы, странное свечение перестаёт исходить из вашего корпуса...</span>")
		M.visible_message("<span class='notice'>С тихим металлическим треском нимб вокруг корпуса [M] распадается...</span>")
		M.client.prefs.features["horns"] = null
		M.update_body()
	else if(omnissiah_rate > 0)
		to_chat(M, "<span class='warning'>Священные машинные литания медленно исчезают из вашей головы...</span>")


// Напитки для робосеков...
/datum/reagent/consumable/synthdrink/synthanol/ultralube
	name = "Ultra Lube"
	description = "Hey, why the heck you want to fuck a robot?"
	color = "#782301"
	glass_icon_state = "wockyslush" // TODO: добавить иконку
	synthetic_taste = "техобслуживания... мхмх... <span class='userlove'>не по инструкции~</span>"
	glass_name = "glass of Ultra Lube"
	glass_desc = "Hey, why the heck you want to fuck a robot?"
	boozepwr = 10 // Слабое...
	value = REAGENT_VALUE_VERY_RARE
	quality = DRINK_NICE

/datum/reagent/consumable/synthdrink/synthanol/ultralube/synthetic_on_add(mob/living/carbon/human/M)
	. = ..()
	if (!M.client)
		return
	if(M.client.prefs.erppref == "No" || !M.client.prefs.arousable || (M.client.prefs.cit_toggles & NO_APHRO))
		to_chat(M, "<span class='warning'>В процессоре реагентов обнаружен вредоносный агент, его действие заблокировано</span>")
		return

/datum/reagent/consumable/synthdrink/synthanol/ultralube/synthetic_on_life(mob/living/carbon/human/M)
	. = ..()
	if (!M.client)
		return
	if(M.client.prefs.erppref == "No" || !M.client.prefs.arousable || (M.client.prefs.cit_toggles & NO_APHRO))
		return
	if((prob(min(current_cycle/2,5))))
		M.emote(pick("moan","blush"))
	if(prob(min(current_cycle/4,10)))
		var/aroused_message = pick("Вы ощущаете лёгкий перегрев...", "Ваши актюаторы работают в ускоренном режиме...", "Ваши гормональные протоколы дают сбой...", "Ваш корпус подрагивает от желания...")
		to_chat(M, "<span class='userlove'>[aroused_message]</span>")
		if(isipcperson(M))
			M.dna.features["ipc_screen"] = "Heart"
			M.update_body()
	if(prob(min(current_cycle/5,10)))
		var/list/genits = M.adjust_arousal(current_cycle, "crocin", aphro = TRUE)
		for(var/g in genits)
			var/obj/item/organ/genital/G = g
			to_chat(M, "<span class='userlove'>[G.arousal_verb]!</span>")

/datum/reagent/consumable/synthdrink/synthanol/database_dropper
	name = "Database Dropper"
	description = "Fancy tool for roboticist, who just got tired of disrobing synthetics for a surgery... Or, perhaps, it has another goal..."
	color = "#782301"
	glass_icon_state = "hoticecoffee" // TODO: добавить иконку
	synthetic_taste = "SQL-инъекции..."
	glass_name = "glass of Database Dropper"
	glass_desc = "Fancy tool for roboticist, who just got tired of disrobing synthetics for a surgery... Or, perhaps, it has another goal..."
	boozepwr = 35
	value = REAGENT_VALUE_VERY_RARE
	quality = DRINK_VERYGOOD

/datum/reagent/consumable/synthdrink/synthanol/database_dropper/synthetic_on_add(mob/living/carbon/human/M)
	. = ..()
	if(M.client?.prefs.erppref == "No" || M.client?.prefs.cit_toggles & NO_APHRO)
		to_chat(M, "<span class='warning'>Вы зафиксировали попытку очень странного взлома, но она была остановлена вашим антивирусом.</span>")
		return

/datum/reagent/consumable/synthdrink/synthanol/database_dropper/synthetic_on_life(mob/living/carbon/human/M)
	. = ..()
	if(!M.client)
		return
	if(M.client.prefs.erppref == "No" || M.client.prefs.cit_toggles & NO_APHRO)
		return
	if (prob(30))
		// Скопированная из clothing_burst() проверка на то, есть ли закрывающие части тела предметы одежды
		// (чтобы не сильно спамить эмоутами)
		var/needs_to_disrobe = FALSE
		var/items = M.get_contents()
		for(var/obj/item/item_worn in items)
			if(!ismob(item_worn.loc))
				continue
			if(M.is_holding(item_worn))
				continue
			if(item_worn.body_parts_covered)
				needs_to_disrobe = TRUE
		// Проиграть эмоут и сбросить одежду
		if (needs_to_disrobe)
			if (HAS_TRAIT(M, TRAIT_MINDSHIELD) && prob(40))
				to_chat(M, "<span class='warning'>Установленный вам имплант предотвратил попытку взлома, но это ненадолго...</span>")
				return
			M.emote("hack")
			addtimer(CALLBACK(M, /mob/living/carbon.proc/clothing_burst, TRUE), 9 SECONDS)
