// Бутыль с систем клинером для заказов в карго и получения в вендоматах робо
/obj/item/reagent_containers/glass/bottle/system_cleaner
	name = "system cleaner bottle"
	desc = "Бутыль с реагентом, эффективно проводящим очистку системы у синтетиков. На этикетке авторучкой написано \"Используй Purge Corruption, ленивая скотина! Это для ремонта в поле!\"."
	icon = 'icons/obj/chemical.dmi'
	list_reagents = list(/datum/reagent/medicine/system_cleaner = 30)


// Реагент с гидравликой для синтетиков. Вся эта шняга с кровью работает как пиздос какой-то
/datum/reagent/blood/oil
	data = list("donor"=null,"viruses"=null,"blood_DNA"="REPLICATED", "bloodcolor" = BLOOD_COLOR_OIL, "bloodblend" = BLEND_MULTIPLY, "blood_type"="HF","resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null)
	name = "Hydraulic Liquid"
	description = "Hydraulic liquid for synthetic crewmembers."
	taste_description = "oil"
	color = BLOOD_COLOR_OIL
	value = REAGENT_VALUE_NONE


// Более эффективная кровь для синтетиков
/datum/reagent/medicine/synthblood_deluxe
	name = "Super-pressurized hydraulic liquid"
	description = "Сверхэффективная гидравлическая жидкость, способная быстро восстановить работоспособность системы охлаждения у синтетиков. \
					 Была изобретена и применяется CyberSun для ремонта своих боевых роботов на передовой. Процесс производства \
					 достаточно дорогостоящий и требует применения блюспейс-сжатия, атомизации и насыщения. \
					 Более простые варианты данной жидкости могут быть произведены с помощью лишь блюспейс-сжатия и могут \
					 превращаться в обычную гидравлическую жидкость в соотношении 1/10. Вызывает кратковременные сбои сенсоров при применении."
	reagent_state = LIQUID
	color = "#D7C9C6"
	metabolization_rate = 5 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_ROBOTIC_PROCESS

/datum/reagent/medicine/synthblood_deluxe/on_mob_add(mob/living/L, amount)
	. = ..()
	if(!isrobotic(L))
		return
	to_chat(L, span_boldnotice("В процессоре реагентов обнаружена гидравлическая жидкость под большим давлением. Производится подготовка для её интеграции. Возможны побочные эффекты.."))
	L.AdjustConfused(7)
	L.adjust_blurriness(7)

/datum/reagent/medicine/synthblood_deluxe/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(!isrobotic(M))
		return
	M.reagents.add_reagent(/datum/reagent/blood/oil, metabolization_rate * 10)


// Ёмкость с супер-кровью для синтетиков.
/obj/item/reagent_containers/glass/bottle/synthblood_deluxe
	name = "H-Liquid DELUXE"
	desc = "Сверхэффективная гидравлическая жидкость, способная быстро восстановить работоспособность системы охлаждения у синтетиков. \
					 Была изобретена и применяется CyberSun для ремонта своих боевых роботов на передовой. Процесс производства \
					 достаточно дорогостоящий и требует применения блюспейс-сжатия, атомизации и насыщения. \
					 Более простые варианты данной жидкости могут быть произведены с помощью лишь блюспейс-сжатия и могут \
					 превращаться в обычную гидравлическую жидкость в соотношении 1/10. Вызывает кратковременные сбои сенсоров при применении."
	icon = 'icons/obj/chemical.dmi'
	list_reagents = list(/datum/reagent/medicine/synthblood_deluxe = 30)
