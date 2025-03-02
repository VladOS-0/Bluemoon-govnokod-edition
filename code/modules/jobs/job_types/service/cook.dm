/datum/job/cook
	title = "Cook"
	flag = COOK
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	var/cooks = 0 //Counts cooks amount

	outfit = /datum/outfit/job/cook
	plasma_outfit = /datum/outfit/plasmaman/chef

	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	bounty_types = CIV_JOB_CHEF
	departments = DEPARTMENT_BITFLAG_SERVICE

	display_order = JOB_DISPLAY_ORDER_COOK
	threat = 0.2

	family_heirlooms = list(
		/obj/item/reagent_containers/food/condiment/saltshaker,
		/obj/item/kitchen/rollingpin,
		/obj/item/clothing/head/chefhat
	)

	mail_goodies = list(
		/obj/item/storage/box/ingredients/wildcard = 80,
		/datum/reagent/consumable/caramel =  20,
		/obj/item/reagent_containers/food/condiment/flour = 20,
		/obj/item/reagent_containers/food/condiment/rice = 20,
		/obj/item/reagent_containers/food/condiment/enzyme = 15,
		/obj/item/reagent_containers/food/condiment/soymilk = 15,
		/obj/item/kitchen/knife = 4,
		/obj/item/kitchen/knife/butcher = 2
	)

/datum/outfit/job/cook
	name = "Cook"
	jobtype = /datum/job/cook

	belt = /obj/item/pda/cook
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/chef
	suit = /obj/item/clothing/suit/toggle/chef
	head = /obj/item/clothing/head/chefhat
	mask = /obj/item/clothing/mask/fakemoustache/italian
	backpack_contents = list(/obj/item/sharpener = 1, /obj/item/choice_beacon/ingredients = 1)

/datum/outfit/job/cook/syndicate
	name = "Syndicate Cook"
	jobtype = /datum/job/cook

	//belt = /obj/item/pda/syndicate/no_deto

	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/util
	suit = /obj/item/clothing/suit/toggle/chef
	head = /obj/item/clothing/head/chefhat
	mask = /obj/item/clothing/mask/fakemoustache/italian
	shoes = /obj/item/clothing/shoes/jackboots/tall_default

	backpack = /obj/item/storage/backpack/duffelbag/syndie
	satchel = /obj/item/storage/backpack/duffelbag/syndie
	duffelbag = /obj/item/storage/backpack/duffelbag/syndie
	box = /obj/item/storage/box/survival/syndie
	pda_slot = ITEM_SLOT_BELT
	backpack_contents = list(/obj/item/sharpener = 1, /obj/item/choice_beacon/ingredients = 1, /obj/item/syndicate_uplink=1)

/datum/outfit/job/cook/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE, client/preference_source)
	..()
	var/datum/job/cook/J = SSjob.GetJobType(jobtype)
	if(J) // Fix for runtime caused by invalid job being passed
		if(J.cooks>0)//Cooks
			suit = /obj/item/clothing/suit/apron/chef
			head = /obj/item/clothing/head/soft/mime
		if(!visualsOnly)
			J.cooks++

/datum/outfit/job/cook/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE, client/preference_source)
	..()
	if(visualsOnly)
		return
	var/datum/martial_art/cqc/restricted/under_siege/justacook = new //BLUEMOON CHANGE
	justacook.teach(H)

