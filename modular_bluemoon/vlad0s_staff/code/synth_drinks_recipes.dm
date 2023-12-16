/datum/chemical_reaction/synthdrink
	name = "Positronic Oil"
	id = /datum/reagent/consumable/synthdrink
	results = list(/datum/reagent/consumable/synthdrink = 15)
	required_reagents = list(/datum/reagent/oil = 5, /datum/reagent/lube = 5, /datum/reagent/acetone = 5)

/datum/chemical_reaction/synthanol
	name = "Synthanol"
	id = /datum/reagent/consumable/synthdrink/synthanol
	results = list(/datum/reagent/consumable/synthdrink/synthanol = 10)
	required_reagents = list(/datum/reagent/consumable/synthdrink = 5, /datum/reagent/consumable/ethanol = 5)
