
/// Печь для плавки сплавов для кузнечного дела
/obj/machinery/atmospherics/components/unary/blast_furnace
	name = "blast furnace"
	desc = "A furnace."
	icon = 'modular_bluemoon/icons/obj/smith/furnace.dmi'
	icon_state = "furnace"
	density = TRUE
	anchored = TRUE
	var/debug = FALSE

/obj/machinery/atmospherics/components/unary/blast_furnace/attackby(obj/item/I, mob/user)
/*
	if(istype(I, /obj/item/ingot))
		var/obj/item/ingot/notsword = I
		if(working)
			to_chat(user, "You heat the [notsword] in the [src].")
			notsword.workability = "shapeable"
		else
			to_chat(user, "The furnace isn't working!.")
	else
		..()*/

/obj/machinery/atmospherics/components/unary/blast_furnace/attackby(obj/item/W, mob/user, params)
	if(W.reagents)
		W.reagents.trans_to(src, 250)
	else
		return ..()

/obj/machinery/atmospherics/components/unary/blast_furnace/debug
	name = "Fabricator-General's Foundry"
	desc = "This furnace has a powerful machine spirit \"Modus Debugus\" inside. ALL HAIL THE OMNISSIAH!"
	debug = TRUE

/obj/item/deployer/blast_furnace
	name = "Blast Furnace Deployer"
	desc = "This thing feels kinda hot."
	icon_state = "smithing-furnace"
	deployed_type = /obj/machinery/atmospherics/components/unary/blast_furnace
