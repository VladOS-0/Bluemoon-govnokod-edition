/datum/action/changeling/sting/sleepy
	name = "Sleepy Sting"
	desc = "We silently sting our victim with a cocktail of chemicals that put them to sleep. Costs 15 chemicals."
	helptext = "We silently sting our victim with a cocktail of chemicals that put them to sleep. Costs 15 chemicals."
	button_icon_state = "sting_cryo"
	sting_icon = "sting_cryo"
	chemical_cost = 15
	dna_cost = 2
	loudness = 1
	gamemode_restriction_type = ANTAG_EXTENDED

/datum/action/changeling/sting/sleepy/sting_action(mob/user, mob/target)
	log_combat(user, target, "sting", "sleepy sting")
	if(target.reagents)
		target.reagents..add_reagent(/datum/reagent/toxin/chloralhydrate, 20)
		target.reagents..add_reagent(/datum/reagent/toxin/staminatoxin, 10)
	return TRUE
