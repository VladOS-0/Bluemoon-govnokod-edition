// Configuration defines
#define BLUESPACE_MINER_BONUS_MULT		CONFIG_GET(number/bluespaceminer_mult_output)
#define BLUESPACE_MINER_CRYSTAL_TIER	CONFIG_GET(number/bluespaceminer_crystal_tier)

/obj/machinery/mineral/bluespace_miner
	name = "bluespace mining machine"
	desc = "A machine that uses the magic of Bluespace to slowly generate materials and add them to a linked ore silo."
	icon = 'modular_sand/icons/obj/machines/mining_machines.dmi'
	icon_state = "bsminer"
	density = TRUE
	can_be_unanchored = TRUE
	circuit = /obj/item/circuitboard/machine/bluespace_miner
	layer = BELOW_OBJ_LAYER
	init_process = TRUE
	idle_power_usage = 5000
	active_power_usage = 10000
	var/list/ore_rates = list(
		/datum/material/iron = 0.05,
		/datum/material/glass = 0.05,
		/datum/material/silver = 0.025,
		/datum/material/titanium = 0.025,
		/datum/material/uranium = 0.025,
		/datum/material/plastic = 0.025,
		/datum/material/gold = 0.01,
		/datum/material/diamond = 0.01,
		/datum/material/plasma = 0.01
		)
	var/datum/component/remote_materials/materials
	var/multiplier = 0 //Multiplier by tier, has been made fair and everything

/obj/machinery/mineral/bluespace_miner/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "bsm", mapload)

	// Set initial multiplier based on config
	multiplier *= BLUESPACE_MINER_BONUS_MULT

/obj/machinery/mineral/bluespace_miner/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("A small screen on the machine reads, \"Efficiency at [multiplier * 100]%\"")
		if(multiplier >= BLUESPACE_MINER_CRYSTAL_TIER)
			. += span_notice("Bluespace generation is active.")
	if(!anchored)
		. += span_warning("The machine won't work while not firmly secured to the ground.")
	if(!materials?.silo)
		. += span_notice("No ore silo connected. Use a multi-tool to link an ore silo to this machine.")
	else if(materials?.on_hold())
		. += span_warning("Ore silo access is on hold, please contact the quartermaster.")

/obj/machinery/mineral/bluespace_miner/RefreshParts()
	multiplier = 0
	var/stock_amt = 0
	for(var/obj/item/stock_parts/L in component_parts)
		if(!istype(L))
			continue
		multiplier += L.rating
		stock_amt++
	multiplier /= stock_amt
	if(multiplier >= BLUESPACE_MINER_CRYSTAL_TIER)
		ore_rates[/datum/material/bluespace] = 0.005
		ore_rates[/datum/material/bananium] = 0.005
	else
		ore_rates -= /datum/material/bluespace
		ore_rates -= /datum/material/bananium

	// Apply config multiplier here to not interfere with bluespace material check
	multiplier *= BLUESPACE_MINER_BONUS_MULT

/obj/machinery/mineral/bluespace_miner/Destroy()
	materials = null
	return ..()

/obj/machinery/mineral/bluespace_miner/multitool_act(mob/living/user, obj/item/M)
	. = ..()
	if(!M.buffer || !istype(M.buffer, /obj/machinery/ore_silo))
		to_chat(user, span_warning("You need to multitool the ore silo first."))
		balloon_alert(user, "Данные отсутствуют!")
		return TRUE

/obj/machinery/mineral/bluespace_miner/process()
	for(var/obj/machinery/bluespace_miner as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/mineral/bluespace_miner))
		if(length(bluespace_miner) >= 5)
			if(prob(0.0005))
				var/datum/round_event_control/anomaly/anomaly_bluespace/bluespace_anomaly = new/datum/round_event_control/anomaly/anomaly_bluespace
				bluespace_anomaly.runEvent()
	update_icon_state()
	if(!materials?.silo || materials?.on_hold())
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container || panel_open || !powered() || !anchored)
		return
	var/datum/material/ore = pick(ore_rates)
	mat_container.bsm_insert(((ore_rates[ore] * 1000) * multiplier), ore)

/datum/component/material_container/proc/bsm_insert(amt, datum/material/mat)
	if(!istype(mat))
		mat = SSmaterials.GetMaterialRef(mat)
	if(amt > 0 && has_space(amt))
		var/total_amount_saved = total_amount
		if(mat)
			materials[mat] += amt
			total_amount += amt
		else
			for(var/i in materials)
				materials[i] += amt
				total_amount += amt
		return (total_amount - total_amount_saved)
	return FALSE

/obj/machinery/mineral/bluespace_miner/update_icon_state()
	if(!powered() || !anchored || !materials?.silo || materials?.on_hold())
		if(!panel_open)
			icon_state = "bsminer-unpowered"
		else
			icon_state = "bsminer-unpowered-maintenance"
	else
		if(!panel_open)
			icon_state = "bsminer"
		else
			icon_state = "bsminer-maintenance"

/obj/machinery/mineral/bluespace_miner/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_deconstruction_crowbar(I, FALSE))
		return TRUE

/obj/machinery/mineral/bluespace_miner/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	var/powered = powered()
	if(default_deconstruction_screwdriver(user, "bsminer-[!powered ? "unpowered-" : null]maintenance", "bsminer[!powered ? "unpowered" : null]", I))
		return TRUE
	return FALSE

/obj/machinery/mineral/bluespace_miner/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_unfasten_wrench(user, I))
		return TRUE
	return FALSE

#undef BLUESPACE_MINER_BONUS_MULT
#undef BLUESPACE_MINER_CRYSTAL_TIER
