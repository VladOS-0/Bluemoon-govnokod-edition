
/// Печь для плавки сплавов для кузнечного дела
/obj/machinery/atmospherics/components/unary/blast_furnace
	name = "blast furnace"
	desc = "A furnace."
	icon = 'modular_bluemoon/icons/obj/smith/furnace.dmi'
	icon_state = "furnace"
	density = TRUE
	anchored = TRUE

	/// Является ли эта печь дебаговой. Дебаговые печи имеют имбовые способности для проверки механик.
	var/debug = FALSE

	/// Является ли печь активной и потребляет ли она топливо в моменте
	var/active = FALSE

	/// Выбранный рецепт, который сейчас обрабатывается печью
	var/datum/furnace_recipe/active_recipe = null

	/// Бикер для хранения реагентов для крафтов
	var/obj/item/reagent_containers/beaker = null

	/// Количество газообразного топлива. Подводимый к печке газ плазмы по необходимости превращается в это абстрактное значение,
	/// 1 моль = `FURNACE_GAS_CONVERSION_RATE` очков топлива.
	var/gas_fuel_amount = 0
	/// Количество твёрдого топлива. Вставленные в печь листы или кучки руды плазмы по необходимости превращается
	/// в это абстрактное значение, 1 лист = `FURNACE_SOLID_CONVERSION_RATE` очков топлива.
	var/solid_fuel_amount = 0
	/// **Множитель** потребления топлива печью на любые операции (в том числе на простаивание)
	var/fuel_consumption_multiplier = FURNACE_FUEL_CONSUMPTION_MULTIPLIER
	/// Количества очков топлива, сколько печь потребляет в тик простаивая
	var/idle_fuel_consumption = FURNACE_IDLE_FUEL_CONSUMPTION

	/// Максимальное количество твёрдой плазмы (в единицах, 1 лист/руда = 2 000 ед.), которое можно вставить в печь
	var/plasma_storage_capacity = FURNACE_SOLID_STORAGE_CAPACITY

/*

	ОСНОВА

*/


/obj/machinery/atmospherics/components/unary/blast_furnace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(/datum/material/plasma), plasma_storage_capacity)

/obj/machinery/atmospherics/components/unary/blast_furnace/process()
	if(machine_stat & NOPOWER)
		toggle_active(FALSE)
		return
	if(!try_consume_fuel(idle_fuel_consumption, FURNACE_FUEL_ANY))
		toggle_active(FALSE)

	toggle_active(TRUE)

/*

	ТОПЛИВО

*/

/// Переключает печь в новое состояние (горит/не горит). Если она выключается, то любой активный рецепт безопасно прекращается
/// * `new_active` - состояние, в которое нужно переключить печь
/obj/machinery/atmospherics/components/unary/blast_furnace/proc/toggle_active(new_active = TRUE)
	if(active == new_active)
		return
	if(new_active)
		visible_message(span_smallnotice("[src] вновь разгорается!"), "", span_smallnotice("Вы слышите звук потрескивания плазмы..."))
		update_appearance()
		active = TRUE
	else
		visible_message(span_smallnotice("[src] затухает!"), "", span_smallnotice("Звук потрескивание плазмы затихает..."))
		active = FALSE
		update_appearance()
		stop_recipe(TRUE)

/// Потребляет определённое количество очков топлива определённого типа. Если очки этого типа топлива закончились, то пытается
/// сжечь соответствующее количество газа/твёрдой плазмы. Если топливо было успешно потреблено, то возвращает `TRUE`.
/// * `amount` - количество потреблённых очков топлива
/// * `fuel_type` - тип потребляемого топлива. Если `FURNACE_FUEL_ANY`, то сначала рекурсивно пытается потребить газ,
/// потом - твёрдое топливо.
/obj/machinery/atmospherics/components/unary/blast_furnace/proc/try_consume_fuel(amount = FURNACE_IDLE_FUEL_CONSUMPTION, fuel_type = FURNACE_FUEL_ANY)
	. = FALSE
	switch(fuel_type)
		if(FURNACE_FUEL_ANY)
			// ура, рекурсия
			if(try_consume_fuel(amount, FURNACE_FUEL_GAS) || try_consume_fuel(amount, FURNACE_FUEL_SOLID))
				return TRUE
		if(FURNACE_FUEL_GAS)
			amount = amount * fuel_consumption_multiplier
			var/required_moles = ceil(amount / FURNACE_GAS_CONVERSION_RATE)
			if(gas_fuel_amount >= amount)
				gas_fuel_amount -= amount
				return TRUE

			if(!nodes[1] || !airs[1])
				return FALSE
			var/datum/gas_mixture/air1 = airs[1]
			if(air1.get_moles(GAS_PLASMA) < required_moles)
				return FALSE
			air1.adjust_moles(GAS_PLASMA, -required_moles)

			// required_moles был округлен в большую сторону, поэтому у нас мог получиться остаток
			gas_fuel_amount = required_moles * FURNACE_GAS_CONVERSION_RATE - amount
			return TRUE

		if(FURNACE_FUEL_SOLID)
			amount = amount * fuel_consumption_multiplier
			var/required_solid_amount = ceil(amount / FURNACE_SOLID_CONVERSION_RATE)
			if(solid_fuel_amount >= required_solid_amount)
				solid_fuel_amount -= required_solid_amount
				return TRUE
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			if(!materials.use_amount_mat(required_solid_amount, /datum/material/plasma))
				return FALSE

			// required_solid_amount был округлен в большую сторону, поэтому у нас мог получиться остаток
			solid_fuel_amount = required_solid_amount * FURNACE_SOLID_CONVERSION_RATE - amount

/*

	РЕЦЕПТЫ

*/

/// Прекращает любой активный рецепт, если таковой есть.
/// * `safe` - закончится ли рецепт безопасно, или же все ресурсы будут уничтожены, а также с определённым шансом прокнет
/// плохой ивент.
/obj/machinery/atmospherics/components/unary/blast_furnace/proc/stop_recipe(safe = TRUE)
	if(isnull(active_recipe))
		return
	// TODO

/*

	UI

*/

/obj/machinery/atmospherics/components/unary/blast_furnace/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "", name)
		ui.open()

/obj/machinery/atmospherics/components/unary/blast_furnace/ui_static_data(mob/user)
	var/list/data = list()
	// TODO
	return data

/obj/machinery/atmospherics/components/unary/blast_furnace/ui_data(mob/user)
	var/list/data = list()
	// TODO
	return data

/obj/machinery/atmospherics/components/unary/blast_furnace/ui_act(action, params)
	if(..())
		return
	//switch(action)
	// TODO

/*

	РАЗНОЕ

*/

/obj/machinery/atmospherics/components/unary/blast_furnace/debug
	name = "Fabricator-General's Foundry"
	desc = "This furnace contains a powerful machine spirit \"Modus Debugus\". ALL HAIL THE OMNISSIAH!"
	debug = TRUE

/obj/item/deployer/blast_furnace
	name = "Blast Furnace Deployer"
	desc = "This thing feels kinda hot."
	icon_state = "smithing-furnace"
	deployed_type = /obj/machinery/atmospherics/components/unary/blast_furnace
