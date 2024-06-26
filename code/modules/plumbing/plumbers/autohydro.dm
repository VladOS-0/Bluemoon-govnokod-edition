/obj/machinery/hydroponics/constructable/automagic
	name = "automated hydroponics system"
	desc = "The bane of botanists everywhere. Accepts chemical reagents via plumbing, automatically harvests and removes dead plants."
	icon_state = "hydrotray4"
	obj_flags = CAN_BE_HIT | UNIQUE_RENAME
	circuit = /obj/item/circuitboard/machine/hydroponics/automagic

/obj/machinery/hydroponics/constructable/automagic/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/machinery/hydroponics/constructable/automagic/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/machinery/hydroponics/constructable/automagic/process()
	if(!myseed)
		return
	if(dead)
		dead = 0
		qdel(myseed)
		myseed = null
		update_icon()
		name = initial(name)
		desc = initial(desc)
	if(harvest)
		myseed.harvest_userless()
		harvest = 0
		lastproduce = age
		if(!myseed.get_gene(/datum/plant_gene/trait/repeated_harvest))
			qdel(myseed)
			myseed = null
			dead = 0
			name = initial(name)
			desc = initial(desc)
		update_icon()
	..()
