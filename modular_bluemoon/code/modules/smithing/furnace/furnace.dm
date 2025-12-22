#define FURNACE_STATE_OPENED 1
#define FURNACE_STATE_CLOSING 2
#define FURNACE_STATE_CLOSED 3
#define FURNACE_STATE_OPENING 4

/// Печь для плавки сплавов для кузнечного дела
/obj/machinery/atmospherics/components/unary/blast_furnace
	name = "blast furnace"
	desc = "A furnace."
	icon = 'modular_bluemoon/icons/obj/smith/furnace.dmi'
	icon_state = "furnace"
	density = TRUE
	anchored = TRUE

	power_channel = EQUIP
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 200

	/// Является ли эта печь дебаговой. Дебаговые печи имеют имбовые способности для проверки механик.
	var/debug = FALSE

	/// Является ли печь активной и потребляет ли она топливо в моменте
	var/active = FALSE

	var/current_state = FURNACE_STATE_OPENED

	/// Выбранный рецепт, который сейчас обрабатывается печью
	var/datum/furnace_recipe/active_recipe = null

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
	/// Бикер для хранения реагентов для крафтов
	var/obj/item/reagent_containers/beaker = null

	// Объекты для визуальных эффектов
	var/obj/effect/furnace_overlay/furnace_handle
	var/obj/effect/furnace_overlay/furnace_tigel
	var/obj/effect/furnace_overlay/furnace_plasma
	var/obj/effect/furnace_overlay/furnace_smoke

/obj/effect/furnace_overlay
	name = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE

/*

	ОСНОВА

*/

/obj/machinery/atmospherics/components/unary/blast_furnace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(/datum/material/plasma), plasma_storage_capacity)

	furnace_handle = new()
	furnace_handle.icon = icon
	furnace_handle.icon_state = "handle-off"
	furnace_handle.layer = FURNACE_HANDLE_LAYER

	furnace_tigel = new()
	furnace_tigel.icon = icon
	furnace_tigel.icon_state = "tigel-on"
	furnace_tigel.layer = FURNACE_TIGEL_LAYER

	furnace_plasma = new()
	furnace_plasma.icon = icon
	furnace_plasma.icon_state = "plasma"
	furnace_plasma.layer = FURNACE_PLASMA_LAYER
	// Начинаем с невидимого
	furnace_plasma.alpha = 0

	furnace_smoke = new()
	furnace_smoke.icon = icon
	furnace_smoke.icon_state = "smoke"
	furnace_smoke.layer = WALL_OBJ_LAYER + 0.1
	// Начинаем с невидимого
	furnace_smoke.alpha = 0

/obj/machinery/atmospherics/components/unary/blast_furnace/Destroy()
	stop_recipe(FALSE)
	if(!isnull(beaker))
		beaker.forceMove(loc)
		beaker = null

	// Удаляем объекты визуальных эффектов
	QDEL_NULL(furnace_handle)
	QDEL_NULL(furnace_tigel)
	QDEL_NULL(furnace_plasma)
	QDEL_NULL(furnace_smoke)

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()
	return ..()

/obj/machinery/atmospherics/components/unary/blast_furnace/process()
	if(machine_stat & NOPOWER || !try_consume_fuel(idle_fuel_consumption, FURNACE_FUEL_ANY))
		toggle_active(FALSE)
		return
	toggle_active(TRUE)

	if(!isnull(active_recipe))
		playsound(src, 'sound/effects/comfyfire.ogg', 40, 0, 0, 1)

/*

	ИКОНКИ

*/

/obj/machinery/atmospherics/components/unary/blast_furnace/update_icon(updates=ALL)
	. = ..()
	// Я НЕНАВИЖУ АТМОС, Я НЕНАВИЖУ АТМОС, Я НЕНАВИЖУ АТМОС
	if(updates & UPDATE_OVERLAYS)
		if(LAZYLEN(managed_vis_overlays))
			SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)

		var/list/new_overlays = update_overlays(updates)
		if(managed_overlays)
			cut_overlay(managed_overlays)
			managed_overlays = null
		if(length(new_overlays))
			if (length(new_overlays) == 1)
				managed_overlays = new_overlays[1]
			else
				managed_overlays = new_overlays
			add_overlay(new_overlays)
		. |= UPDATE_OVERLAYS

/obj/machinery/atmospherics/components/unary/blast_furnace/update_icon_state()
	if(machine_stat & NOPOWER)
		icon_state = "furnace-off"
	else
		icon_state = "furnace"
	return ..()

/obj/machinery/atmospherics/components/unary/blast_furnace/update_overlays()
	. = ..()

	// Очищаем vis_contents
	vis_contents.Cut()

	// Добавляем объекты в визуальное содержимое в зависимости от состояния
	switch(current_state)
		if(FURNACE_STATE_OPENED)
			furnace_handle.icon_state = "handle-off"
			vis_contents += furnace_handle
			furnace_tigel.alpha = 0
		if(FURNACE_STATE_CLOSING)
			furnace_handle.icon_state = "handle-engage"
			furnace_tigel.icon_state = "tigel-engage"
			furnace_tigel.alpha = 255
			vis_contents += furnace_handle
			vis_contents += furnace_tigel
		if(FURNACE_STATE_CLOSED)
			furnace_handle.icon_state = "handle-on"
			furnace_tigel.icon_state = "tigel-on"
			furnace_tigel.alpha = 255
			vis_contents += furnace_handle
			vis_contents += furnace_tigel
		if(FURNACE_STATE_OPENING)
			furnace_handle.icon_state = "handle-disengage"
			furnace_tigel.icon_state = "tigel-disengage"
			furnace_tigel.alpha = 255
			vis_contents += furnace_handle
			vis_contents += furnace_tigel

	// Управляем плазмой
	if(active)
		furnace_plasma.alpha = 255
		vis_contents += furnace_plasma
		set_light(2.2, 0.8, LIGHT_COLOR_PURPLE)
	else
		furnace_plasma.alpha = 0
		set_light(0)

	// Управляем дымом
	if(!isnull(active_recipe))
		furnace_smoke.alpha = 255
		vis_contents += furnace_smoke
	else
		furnace_smoke.alpha = 0

/// Прок, который проигрывает анимацию и звуки закрытия печи. По факту просто враппер над
/// `set_furnace_state(FURNACE_STATE_CLOSING)`, чтобы не выделять всю эту муть с закрытием/открытием в глобальные дефайны.
/obj/machinery/atmospherics/components/unary/blast_furnace/proc/close()
	set_furnace_state(FURNACE_STATE_CLOSING)

/// Ужас за пределами восприятия. Изменяет состояние печи, что влияет на звуки и оверлеи. Схема такая: `FURNACE_LEVEL_OPENED` ->
/// `FURNACE_LEVEL_CLOSING` -> `FURNACE_LEVEL_CLOSED` -> `FURNACE_LEVEL_OPENING` -> `FURNACE_LEVEL_OPENED`. По факту, у этой
/// системы одна точка входа - при начале крафта печь закрывается и дальше всё работает через муть с коллбеками, пока она не
/// откроется снова. Если вы не добавляли новых точек входа, то НЕ ИСПОЛЬЗУЙТЕ этот прок, а просто вызывайте `close()`.
/obj/machinery/atmospherics/components/unary/blast_furnace/proc/set_furnace_state(new_state)
	switch(new_state)
		if(FURNACE_STATE_OPENED)
			// Открытие -> Открыто
			if(current_state == FURNACE_STATE_OPENING)
				current_state = FURNACE_STATE_OPENED
				update_appearance()

		if(FURNACE_STATE_CLOSING)
			switch(current_state)
				// Открыто -> Закрытие
				if(FURNACE_STATE_OPENED)
					current_state = FURNACE_STATE_CLOSING
					playsound(src, 'modular_bluemoon/sound/effects/opening-gears.ogg', 70)
					playsound(src, 'modular_bluemoon/sound/smith/hydraulic.ogg', 40)
					update_appearance()
					// Завершим анимацию закрытия через пару секунд
					addtimer(CALLBACK(src, PROC_REF(set_furnace_state), FURNACE_STATE_CLOSED), 5 SECONDS)
				// Открытие -> Закрытие
				if(FURNACE_STATE_OPENING)
					// Печь открывается, пускай снова попробует закрыться через 10 секунд
					addtimer(CALLBACK(src, PROC_REF(set_furnace_state), FURNACE_STATE_CLOSING), 10 SECONDS)
					return

		if(FURNACE_STATE_CLOSED)
			// Закрытие -> Закрыто
			if(current_state == FURNACE_STATE_CLOSING)
				current_state = FURNACE_STATE_CLOSED
				update_appearance()
				// Мы успешно закрылись, откроемся через 15 секунд, если не будет активных крафтов
				addtimer(CALLBACK(src, PROC_REF(set_furnace_state), FURNACE_STATE_OPENING), 15 SECONDS)

		if(FURNACE_STATE_OPENING)
			switch(current_state)
				// Закрыто -> Открытие
				if(FURNACE_STATE_CLOSED)
					// Если есть рецепт в процессе - откладываем открытие на 10 секунд
					if(!isnull(active_recipe))
						addtimer(CALLBACK(src, PROC_REF(set_furnace_state), FURNACE_STATE_OPENING), 10 SECONDS)
						return
					current_state = FURNACE_STATE_OPENING
					playsound(src, 'modular_bluemoon/sound/effects/opening-gears.ogg', 70)
					playsound(src, 'modular_bluemoon/sound/smith/hydraulic.ogg', 40)
					update_appearance()
					// Завершим анимацию открытия через пару секунд
					addtimer(CALLBACK(src, PROC_REF(set_furnace_state), FURNACE_STATE_OPENED), 5 SECONDS)
				// Закрытие -> Открытие
				if(FURNACE_STATE_CLOSING)
					// Печь закрывается, пускай снова попробует открыться через 10 секунд
					addtimer(CALLBACK(src, PROC_REF(set_furnace_state), FURNACE_STATE_OPENING), 10 SECONDS)
					return

/*

	ТОПЛИВО

*/

/// Переключает печь в новое состояние (горит/не горит). Если она выключается, то любой активный рецепт безопасно прекращается
/// * `new_active` - состояние, в которое нужно переключить печь
/obj/machinery/atmospherics/components/unary/blast_furnace/proc/toggle_active(new_active = TRUE)
	if(active == new_active)
		return
	if(new_active)
		visible_message(span_smallnotice("[src] разгорается!"), "", span_smallnotice("Вы слышите звук потрескивания плазмы..."))
		playsound(src, 'sound/effects/comfyfire.ogg', 60, 0, 0, 1)
		active = TRUE
		update_appearance()
	else
		visible_message(span_smallnotice("[src] затухает!"), "", span_smallnotice("Звук потрескивание плазмы затихает..."))
		playsound(loc, 'sound/machines/synth_no.ogg', 40)
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
			return TRUE

/*

	РЕЦЕПТЫ

*/

/// Прекращает любой активный рецепт, если таковой есть.
/// * `safe` - закончится ли рецепт безопасно, или же все ресурсы будут уничтожены, а также с определённым шансом прокнет
/// плохой ивент.
/obj/machinery/atmospherics/components/unary/blast_furnace/proc/stop_recipe(safe = TRUE)
	if(isnull(active_recipe))
		return
	use_power = IDLE_POWER_USE
	active_recipe = null
	update_appearance()
	// TODO

/obj/machinery/atmospherics/components/unary/blast_furnace/proc/start_recipe()
	// TODO: нормальная логика рецептов, а не этот мок
	use_power = ACTIVE_POWER_USE
	active_recipe = 1
	close()
	addtimer(CALLBACK(src, PROC_REF(stop_recipe)), 15 SECONDS)

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

#undef FURNACE_STATE_OPENED
#undef FURNACE_STATE_OPENING
#undef FURNACE_STATE_CLOSED
#undef FURNACE_STATE_CLOSING
