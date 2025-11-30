/datum/job/metallurgist
	title = "Metallurgist"
	flag = METALLURGIST
	department_head = list("Quartermaster")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the quartermaster"
	selection_color = "#ca8f55"
	custom_spawn_text = "вы - металлург, ваша задача - ковать будущее станции на выданном вам станке, выполняя заказы экипажа и приказы квартирмейстера."


	outfit = /datum/outfit/job/metallurgist
	plasma_outfit = /datum/outfit/plasmaman/metallurgist

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MINING,
				ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR
	bounty_types = CIV_JOB_MINE
	departments = DEPARTMENT_BITFLAG_SUPPLY

	display_order = JOB_DISPLAY_ORDER_METALLURGIST

	threat = 2

	family_heirlooms = list(
		/obj/item/banhammer,
		/obj/item/wakibokken_steelblade
	)


/datum/outfit/job/metallurgist
	name = "Metallurgist"
	jobtype = /datum/job/metallurgist

	belt = /obj/item/pda/cargo
	ears = /obj/item/radio/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/cargo/tech

	backpack_contents = list(/obj/item/storage/box/metallurgist = 1)


/datum/outfit/plasmaman/metallurgist
	name = "Smithing Plasmaman"

	head = /obj/item/clothing/head/helmet/space/plasmaman/cargo
	uniform = /obj/item/clothing/under/plasmaman/cargo

	backpack_contents = list(/obj/item/storage/box/metallurgist = 1)


/datum/outfit/job/metallurgist/syndicate
	name = "Syndicate Metallurgist"
	jobtype = /datum/job/metallurgist

	belt = /obj/item/pda/syndicate/no_deto

	ears = /obj/item/radio/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/cargo/util
	shoes = /obj/item/clothing/shoes/jackboots/tall_default

	backpack = /obj/item/storage/backpack/duffelbag/syndie/ammo
	satchel = /obj/item/storage/backpack/duffelbag/syndie/ammo
	duffelbag = /obj/item/storage/backpack/duffelbag/syndie/ammo
	box = /obj/item/storage/box/survival/syndie
	pda_slot = ITEM_SLOT_BELT
	backpack_contents = list(/obj/item/syndicate_uplink = 1, /obj/item/storage/box/metallurgist = 1)


/obj/item/storage/box/metallurgist
	name = "Metallurgist Starter Pack"
	desc = "All important stuff to start your industrial revolution. \
	Yeah, this box is bluespace-packed, deployers will not fit back inside if you take them out."

/obj/item/storage/box/metallurgist/PopulateContents()
	new /obj/item/deployer/blast_furnace(src)
	new /obj/item/deployer/smithing_table(src)


