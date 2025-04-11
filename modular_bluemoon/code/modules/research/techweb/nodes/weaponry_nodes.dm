
/////////////////////////weaponry tech bluemoon module/////////////////////////

/datum/techweb_node/military_ammo
	id = "military_ammo"
	display_name = "Military Ammunition"
	description = "Big guns were authorized."
	prereq_ids = list("adv_weaponry", "ballistic_weapons")
	design_ids = list("mag_acr5", "mag_acr5_empty", "box_acr5_ap", "box_acr5_hp", "box_acr5_hs")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
