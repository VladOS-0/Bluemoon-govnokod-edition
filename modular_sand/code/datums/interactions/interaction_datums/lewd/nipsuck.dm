/datum/interaction/lewd/nipsuck
	description = "Грудь. Пососать соски."
	required_from_user = INTERACTION_REQUIRE_MOUTH
	required_from_target_exposed = INTERACTION_REQUIRE_BREASTS
	write_log_user = "sucked nipples"
	write_log_target = "had their nipples sucked by"
	interaction_sound = null

/datum/interaction/lewd/nipsuck/display_interaction(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/organ/genital/breasts/B = target.getorganslot(ORGAN_SLOT_BREASTS)
	var/milktype = B?.fluid_id
	var/modifier = 1 //Optimized variables. - Gardelin0
	if((user.a_intent == INTENT_HELP) || (user.a_intent == INTENT_DISARM))
		if(target.has_breasts(REQUIRE_EXPOSED))
			if(B.climaxable(target, TRUE))
				var/datum/reagent/milk = find_reagent_object_from_type(milktype)
				var/milktext = milk.name //So you know what are you drinking. - Gardelin0
				user.visible_message(
					pick("<span class='lewd'>\The <b>[user]</b> аккуратно хватается за грудь партнёра и нежно обсасывает [pick("сосок", "соски")] \the <b>[target]</b>, выпивая тёплое <b>'[lowertext(milktext)]'</b>.</span>",
						"<span class='lewd'>\The <b>[user]</b> поглаживает грудь партнёра, аккуратно хватаясь своими губами за [pick("сосок", "соски")] \the <b>[target]</b>, пробуя сладкое на первовкусие <b>'[lowertext(milktext)]'</b>.</span>",
						"<span class='lewd'>\The <b>[user]</b> в улыбке облизывает [pick("сосок", "соски")] \the <b>[target]</b>, чувствуя вкус <b>'[lowertext(milktext)]'</b> и усмехается.</span>"))
				switch(B.size)
					if("c", "d", "e")
						modifier = 2
					if("f", "g", "h")
						modifier = 3
					else
						if(B.size in GLOB.breast_values)
							modifier = clamp(GLOB.breast_values[B.size] - 5, 0, INFINITY)
						else
							modifier = 1
				if(milktype)
					user.reagents.add_reagent(milktype, rand(1,2 * modifier) * user.get_fluid_mod(B)) //SPLURT edit
			else
				user.visible_message(
					pick("<span class='lewd'>\The <b>[user]</b> аккуратно хватается за грудь партнёра и нежно обсасывает [pick("сосок", "соски")] \the <b>[target]</b>.</span>",
						"<span class='lewd'>\The <b>[user]</b> поглаживает грудь партнёра, аккуратно хватаясь своими губами за [pick("сосок", "соски")] \the <b>[target]</b>.</span>",
						"<span class='lewd'>\The <b>[user]</b> в улыбке облизывает [pick("сосок", "соски")] \the <b>[target]</b> и усмехается.</span>"))

	if(user.a_intent == INTENT_HARM)
		if(target.has_breasts(REQUIRE_EXPOSED))
			if(B.climaxable(target, TRUE))
				var/datum/reagent/milk = find_reagent_object_from_type(milktype)
				var/milktext = milk.name //So you know what are you drinking. - Gardelin0
				user.visible_message(
					pick("<span class='lewd'>\The <b>[user]</b> с силой обхватывает грудь партнёра и грубо посасывает [pick("сосок", "соски")] \the <b>[target]</b>, орошая своё горло большим количеством большому количеству <b>'[lowertext(milktext)]'</b>.</span>",
						"<span class='lewd'>\The <b>[user]</b> хватается губами за [pick("сосок", "соски")], касается зубками \the <b>[target]</b>'s и начинает грубо посасывать, выпивая тёплое <b>'[lowertext(milktext)]'</b>.</span>"))
				switch(B.size)
					if("c", "d", "e")
						modifier = 2
					if("f", "g", "h")
						modifier = 3
					else
						if(B.size in GLOB.breast_values)
							modifier = clamp(GLOB.breast_values[B.size] - 5, 0, INFINITY)
						else
							modifier = 1
				if(milktype)
					user.reagents.add_reagent(milktype, rand(1,3 * modifier)) //aggressive sucking leads to high rewards
			else
				user.visible_message(
					pick("<span class='lewd'>\The <b>[user]</b> с силой обхватывает грудь партнёра и грубо посасывает [pick("сосок", "соски")] \the <b>[target]</b>.</span>",
						"<span class='lewd'>\The <b>[user]</b> хватается губами за [pick("сосок", "соски")], касается зубками \the <b>[target]</b>'s и начинает грубо посасывать.</span>"))

	if(user.a_intent == INTENT_GRAB)
		if(target.has_breasts(REQUIRE_EXPOSED))
			if(B.climaxable(target, TRUE))
				var/datum/reagent/milk = find_reagent_object_from_type(milktype)
				var/milktext = milk.name //So you know what are you drinking. - Gardelin0
				user.visible_message(
					pick("<span class='lewd'>\The <b>[user]</b> крепко обхватывает грудь партнёра и активно обсасывает [pick("сосок", "соски")] \the <b>[target]</b>, чувствуя вкус <b>'[lowertext(milktext)]'</b>.</span>",
						"<span class='lewd'>\The <b>[user]</b> игриво облизывает [pick("сосок", "соски")] \the <b>[target]</b>, слизывая <b>'[lowertext(milktext)]'</b> и ехидно ухмыляется.</span>"))
				switch(B.size)
					if("c", "d", "e")
						modifier = 2
					if("f", "g", "h")
						modifier = 3
					else
						if(B.size in GLOB.breast_values)
							modifier = clamp(GLOB.breast_values[B.size] - 5, 0, INFINITY)
						else
							modifier = 1
				if(milktype)
					user.reagents.add_reagent(milktype, rand(1,3 * modifier)) //aggressive sucking leads to high rewards
			else
				user.visible_message(
					pick("<span class='lewd'>\The <b>[user]</b> крепко обхватывает грудь партнёра и активно обсасывает [pick("сосок", "соски")] \the <b>[target]</b>.</span>",
						"<span class='lewd'>\The <b>[user]</b> поглаживает грудь партнёра и крепко хватается своими губами за [pick("сосок", "соски")] \the <b>[target]</b>.</span>",
						"<span class='lewd'>\The <b>[user]</b> игриво облизывает [pick("сосок", "соски")] \the <b>[target]</b> и ехидно ухмыляется.</span>"))

	if(prob(50 + target.get_lust()))
		target.handle_post_sex(NORMAL_LUST, null, user, ORGAN_SLOT_BREASTS)
		if(target.a_intent == INTENT_HELP)
			user.visible_message(
				pick("<span class='lewd'>\The <b>[target]</b> дрожит от возбуждения.</span>",
					"<span class='lewd'>\The <b>[target]</b> тихо стонет.</span>",
					"<span class='lewd'>\The <b>[target]</b> выдыхает тихий довольный стон.</span>",
					"<span class='lewd'>\The <b>[target]</b> мурлычет и звучно вздыхает.</span>",
					"<span class='lewd'>\The <b>[target]</b> тихонько вздрагивает.</span>",
					"<span class='lewd'>\The <b>[target]</b> возбуждённо проводит пальцем вдоль своей груди.</span>",
					"<span class='lewd'>\The <b>[target]</b> дрожит от возбуждения и довольно выдыхает, когда \the <b>[user]</b> наслаждается содержимым грудей.</span>"))
		if(target.a_intent == INTENT_DISARM)
			if (target.restrained())
				if(!target.has_breasts())
					user.visible_message(
						pick("<span class='lewd'>\The <b>[target]</b> игриво извивается в попытке снять физические ограничения.</span>",
							"<span class='lewd'>\The <b>[target]</b> хихикает, вырываясь из рук <b>[user]</b>.</span>",
							"<span class='lewd'>\The <b>[target]</b> скользит в сторону от приближающегося <b>[user]</b>.</span>",
							"<span class='lewd'>\The <b>[target]</b> с отсутствующим сопротивлением толкает обнажённую грудь вперёд в руки <b>[user]</b>.</span>.</span>"))
				else
					user.visible_message(
						pick("<span class='lewd'>\The <b>[target]</b> игриво бьёт <b>[user]</b> по руке.</span>",
							"<span class='lewd'>\The <b>[target]</b> хихикает, вырываясь из рук <b>[user]</b>.</span>",
							"<span class='lewd'>\The <b>[target]</b> нежно проводит рукой <b>[user]</b>'s вдоль обнажённых грудей.</span>",
							"<span class='lewd'>\The <b>[target]</b> толкает обнажённую грудь вперёд и дразняще проводит несколькими пальцами <b>[user]</b> по своему соску.</span>"))
			else
				if(!target.has_breasts())
					user.visible_message(
						pick("<span class='lewd'>\The <b>[target]</b> игриво извивается в попытке снять физические ограничения.</span>",
							"<span class='lewd'>\The <b>[target]</b> хихикает, вырываясь из рук <b>[user]</b>.</span>",
							"<span class='lewd'>\The <b>[target]</b> скользит в сторону от приближающегося <b>[user]</b>.</span>",
							"<span class='lewd'>\The <b>[target]</b> с отсутствующим сопротивлением толкает обнажённую грудь вперёд в руки <b>[user]</b>.</span>.</span>"))
				else
					user.visible_message(
						pick("<span class='lewd'>\The <b>[target]</b> игриво бьёт <b>[user]</b> по руке.</span>",
							"<span class='lewd'>\The <b>[target]</b> хихикает, вырываясь из рук <b>[user]</b>.</span>",
							"<span class='lewd'>\The <b>[target]</b> нежно проводит рукой <b>[user]</b>'s вдоль обнажённых грудей.</span>",
							"<span class='lewd'>\The <b>[target]</b> толкает обнажённую грудь вперёд и дразняще проводит несколькими пальцами <b>[user]</b> по своему соску.</span>"))
	if(target.a_intent == INTENT_GRAB)
		user.visible_message(
				pick("<span class='lewd'>\The <b>[target]</b> крепко сжимает запястье <b>[user]</b>.</span>",
				"<span class='lewd'>\The <b>[target]</b> впивается ногтями в руку <b>[user]</b>.</span>",
				"<span class='lewd'>\The <b>[target]</b> хватает <b>[user]</b> за запястье буквально на секунду.</span>"))
	if(target.a_intent == INTENT_HARM)
		if (target.restrained())
			user.adjustBruteLoss(5)
			user.visible_message(
				pick("<span class='lewd'>\The <b>[target]</b> грубо отталкивает <b>[user]</b> в попытке снять физические огранения.</span>",
					"<span class='lewd'>\The <b>[target]</b> сердито впивается в руку <b>[user]</b>.</span>",
					"<span class='lewd'>\The <b>[target]</b> яростно борется с <b>[user]</b> и щёлкает своей челюсть в попытке укусить.</span>",
					"<span class='lewd'>\The <b>[target]</b> впивается в предплечье <b>[user]</b> роговыми пластинками.</span>",
					"<span class='lewd'>\The <b>[target]</b> шлёпает <b>[user]</b> по руке.</span>"))
		else
			user.adjustBruteLoss(5)
			user.visible_message(
				pick("<span class='lewd'>\The <b>[target]</b> грубо отталкивает <b>[user]</b>.</span>",
				"<span class='lewd'>\The <b>[target]</b> сердито впивается в руку <b>[user]</b>.</span>",
				"<span class='lewd'>\The <b>[target]</b> яростно борется с <b>[user]</b> и щёлкает своей челюсть в попытке укусить.</span>",
				"<span class='lewd'>\The <b>[target]</b> впивается в предплечье <b>[user]</b> роговыми пластинками.</span>",
				"<span class='lewd'>\The <b>[target]</b> шлёпает <b>[user]</b> по руке.</span>"))

	target.dir = get_dir(target, user)
	user.dir = get_dir(user, target)
	playlewdinteractionsound(get_turf(user), pick('modular_sand/sound/interactions/oral1.ogg',
						'modular_sand/sound/interactions/oral2.ogg'), 70, 1, -1)
	return
