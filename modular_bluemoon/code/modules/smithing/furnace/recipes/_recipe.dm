/datum/furnace_recipe
	/// Название рецепта, которое будет видно в UI
	var/name = "Cool Root Recipe (tm)"
	/// Описание рецепта, которое будет видно в UI при выборе рецепта
	var/desc = "Если вы это видите не в дебаговой печи - напишите багрепорт!"

	/// Требуемые для крафта предметы и их количество.
	var/list/required_items = list()
	/// Чёрный список предметов, которые не могут участвовать в крафте. Если предмет `А` требуется для крафта (находится в
	/// `required_items`), и у него есть подтипы `Б` и `В`, из которых `Б` находится в блеклисте, то для крафта можно
	/// будет использовать только `А` или `В`. Все подтипы `Б` также будут в блеклисте.
	var/list/blacklisted_items = list()

	/// Требуемые для крафта реагенты и их количество.
	var/list/required_reagents = list()
	/// Чёрный список реагентов, которые не могут участвовать в крафте. Если реагент `А` требуется для крафта (находится в
	/// `required_reagents`), и у него есть подтипы `Б` и `В`, из которых `Б` находится в блеклисте, то для крафта можно
	/// будет использовать только `А` или `В`. Все подтипы `Б` также будут в блеклисте.
	var/list/blacklisted_reagents = list()

	/// Случайные события, которые могут произойти при провале крафта, а также их веса.
	var/list/failure_events = list(
		/datum/furnace_event/plain_smoke = 10
	)

// /datum/furnace_recipe/proc/

// Рецепт для примера

/datum/furnace_recipe/example
	name = "Cool Example Recipe (tm)"
	desc = "Если вы это видите не в дебаговой печи - напишите багрепорт!"
	required_items = list(
		/obj/item/banhammer = 2,
		/obj/item/stack/sheet/metal = 10,
		/obj/item/reagent_containers/food/snacks/burger = 1
	)
	blacklisted_items = list(
		/obj/item/reagent_containers/food/snacks/burger/clown
	)
	required_reagents = list(
		/datum/reagent/blood = 10
	)
	blacklisted_reagents = list(
		/datum/reagent/blood/oil
	)

