/obj/machinery/smithing_table
	name = "bluespace smithing table"
	desc = "Contact your local dwarf for his very important opinion on all these flashy new technologies."
	icon = 'modular_bluemoon/icons/obj/smith/table.dmi'
	icon_state = "table"
	bound_width = 32 * 3
	base_pixel_x = -32
	density = TRUE
	anchored = TRUE

	var/debug = FALSE

/obj/machinery/smithing_table/debug
	name = "Fabricator-General's Workbench"
	desc = "This smithing table has a powerful machine spirit \"Modus Debugus\" inside. ALL HAIL THE OMNISSIAH!"
	debug = TRUE

/obj/item/deployer/smithing_table
	name = "Smithing Table Deployer"
	desc = "This table will be kinda large, make sure you have enough space for it!"
	icon_state = "smithing-table"
	deployed_type = /obj/machinery/smithing_table
