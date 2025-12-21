/*

	ОСНОВА

*/

/datum/furnace_event
	var/name = "Not very cool root event (r)"
	var/desc = "Ничего не делает. Наверное."

/datum/furnace_event/proc/fire(obj/machinery/atmospherics/components/unary/blast_furnace/furnace = null, mob/living/carbon/human/blacksmith = null, turf/location = null)
	if(istype(furnace) && !QDELETED(furnace))
		furnace_effect(furnace)
	if(istype(blacksmith) && !QDELETED(blacksmith))
		blacksmith_effect(blacksmith)
	if(isturf(location) && !QDELETED(location))
		location_effect(location)

/datum/furnace_event/proc/furnace_effect(obj/machinery/atmospherics/components/unary/blast_furnace/furnace)
	return

/datum/furnace_event/proc/blacksmith_effect(mob/living/carbon/human/blacksmith)
	return

/datum/furnace_event/proc/location_effect(turf/location)
	return


/*

	МИНОРНЫЕ

*/

/datum/furnace_event/plain_smoke
	name = "Обычный дым"
	desc = "Выпускает облако обычного дыма радиусом в три тайла"

/datum/furnace_event/plain_smoke/location_effect(turf/location)
	do_smoke(3, location)

