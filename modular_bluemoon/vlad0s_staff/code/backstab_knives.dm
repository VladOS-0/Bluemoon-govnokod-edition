// МГЕ МУЖИКИ!!!

/obj/item/kitchen/knife/backstabber
	name = "Strange Butterfly Knife"
	icon = 'modular_splurt/icons/obj/items_and_weapons.dmi'
	icon_state = "butterflyknife_open"
	item_state = "knife"
	desc = "A strange butterfly knife, impeccably sharpened and quite well-maintained. For some reason, you have an irresistible desire to strike someone in the back with it..."
	embedding = list("pain_mult" = 6, "embed_chance" = 50, "fall_chance" = 10, "ignore_throwspeed_threshold" = TRUE)
	resistance_flags = FIRE_PROOF
	custom_materials = list(/datum/material/iron=12000, /datum/material/bluespace=4000, /datum/material/titanium=2000)
	force = 5
	throwforce = 5
	wound_bonus = 4
	bare_wound_bonus = 3
	attack_verb = list("facestabbed")
	bayonet = FALSE
	var/can_transform = TRUE
	var/unique = FALSE
	var/cooldown_icon_state = "butterflyknife"
	var/start_cooldown_message = "складывается с тихим щелчком"
	var/end_cooldown_message = "внезапно сам собой раскладывается, готовый к новым убийствам"
	var/cooldown_time = 30 SECONDS
	var/is_on_cooldown = FALSE
	var/silent_backstab = FALSE
	var/peaceful = FALSE
	var/speech_after_backstab = TRUE
	var/custom_backstab_sound = ""

/obj/item/kitchen/knife/backstabber/Initialize(mapload)
	. = ..()
	update_description()

/obj/item/kitchen/knife/backstabber/proc/update_description()
	var/new_desc = initial(desc)
	if(can_transform)
		new_desc += "\n\n<span class='notice'>It seems that the quick replacement system of this knife works, and you can choose a new murder weapon <span class='boldnotice'>by using it in your hand!</span></span>"
	if(is_on_cooldown)
		new_desc += "\n\n<span class='warning'>It's unlikely that this knife can stab anyone right now... give it some time</span>"
	if(silent_backstab)
		new_desc += "\n\n<span class='notice'>Apparently, this knife is VERY good for covert killings</span>"
	if(peaceful)
		new_desc += "\n\n<span class='notice'>Don't you think this knife is uncapable of killing someone at all?</span>"
	desc = new_desc

/obj/item/kitchen/knife/backstabber/attack_self(mob/user)
	if(user.mind && istype(user, /mob/living/carbon) && can_transform)
		var/obj/item/kitchen/knife/backstabber/new_knife
		var/list/possible_knives = subtypesof(/obj/item/kitchen/knife/backstabber)
		var/list/display_names = list()
		var/list/knife_icons = list()
		for(var/k in possible_knives)
			var/obj/item/kitchen/knife/backstabber/knife_type = k
			if(!initial(knife_type.unique))
				display_names[initial(knife_type.name)] = knife_type
				knife_icons += list(initial(knife_type.name) = image(icon = initial(knife_type.icon), icon_state = initial(knife_type.icon_state)))

		knife_icons = sort_list(knife_icons)

		var/choice = show_radial_menu(user, src , knife_icons, radius = 42, require_near = TRUE)
		if(!choice || !istype(user) || QDELETED(src) || !can_transform || user.incapacitated() || !user.is_holding(src))
			return

		var/A = display_names[choice]
		new_knife = new A

		if(new_knife)
			new_knife.can_transform = FALSE
			qdel(src)
			user.put_in_active_hand(new_knife)
	else
		return ..()

/obj/item/kitchen/knife/backstabber/proc/go_on_cooldown(cooldown_multiplier = 1)
	if(item_flags & IN_INVENTORY && istype(loc, /mob/living/carbon))
		var/mob/living/carbon/user = loc
		to_chat(user, "<span class='boldnotice'>[src.name] [start_cooldown_message].</span>")
	if(cooldown_icon_state)
		icon_state = cooldown_icon_state
	is_on_cooldown = TRUE
	update_description()
	addtimer(CALLBACK(src, .proc/end_stab_cooldown), cooldown_time * cooldown_multiplier)

/obj/item/kitchen/knife/backstabber/proc/end_stab_cooldown()
	if(item_flags & IN_INVENTORY && istype(loc, /mob/living/carbon))
		var/mob/living/carbon/user = loc
		to_chat(user, "<span class='boldnotice'>[src.name] [end_cooldown_message].</span>")
	if(cooldown_icon_state)
		icon_state = initial(icon_state)
	is_on_cooldown = FALSE
	update_description()

/obj/item/kitchen/knife/backstabber/proc/check_style(mob/living/carbon/murderer)
	var/style_rate = 1
	var/list/stylish_clothes = list(
		/obj/item/clothing/accessory/waistcoat,
		/obj/item/clothing/accessory/suitjacket,
		/obj/item/clothing/under/suit,
		/obj/item/clothing/gloves/color/white,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/gloves/color/latex,
		/obj/item/clothing/gloves/evening,
		/obj/item/clothing/under/misc/assistantformal,
		/obj/item/clothing/under/rank/security/officer/formal/sol/armorless,
		/obj/item/clothing/under/rank/security/head_of_security/formal,
		/obj/item/clothing/under/rank/security/officer/formal,
		/obj/item/clothing/under/rank/security/warden/formal,
		/obj/item/clothing/head/fedora,
		/obj/item/clothing/head/that,
		/obj/item/clothing/shoes/laceup
		)
	var/list/items = murderer.get_contents()
	for(var/gear in items)
		var/obj/item/gearitem = gear
		if(gearitem.blood_DNA)
			style_rate *= 1.1
		else
			for(var/stylish_gear in stylish_clothes)
				if(istype(gear, stylish_gear))
					style_rate *= 0.8
	style_rate = clamp(style_rate, 0.5, 2)
	if(style_rate < 1)
		to_chat(murderer, "<span class='notice'>\"Это было стильно! Даю этому убийству [round((1 - style_rate) * 100)] очков!\"</span>")
	if(style_rate > 1)
		to_chat(murderer, "<span class='notice'>\"Фу! Настоящие профессионалы не делают это в простой грязной одежде! Минус [round((style_rate - 1) * 100)] очков!\"</span>")
	return style_rate

/obj/item/kitchen/knife/backstabber/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(is_on_cooldown)
		to_chat(user, "<span class='warning'>Твоему [src.name] нужно немного времени...</span>")
		return
	if(!istype(user, /mob/living/carbon))
		. = ..()
		return
	if(!istype(M, /mob/living/carbon))
		. = ..()
		return
	if(user == M)
		to_chat(user, "<span class='warning'>Я слишком ПРОФЕССИОНАЛЕН, чтобы порезаться собственным кинжалом!</span>")
		return
	if(M.dir != user.dir && !M.lying)
		to_chat(user, "<span class='warning'>Какой позорный удар! Настоящие профессионалы бьют В СПИНУ!</span>")
		. = ..()
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM) && !peaceful)
		to_chat(user, "<span class='warning'>Ты не можешь заставить себя сделать это!</span>")
		if(!silent_backstab)
			user.visible_message("<span class='boldwarning'>[user] заносит [src.name] над спиной [M], но вовремя останавливается! </span>")
		return
	if(!silent_backstab)
		user.visible_message("<span class='boldwarning'>[M] не успевает и обернуться, как [user] с невероятной точностью вонзает [src.name] [M.ru_emu()] в спину! </span>")
	if((M.status_flags & GODMODE || HAS_TRAIT(M, TRAIT_NODEATH)) && !peaceful)
		if(!silent_backstab)
			M.visible_message("<span class='warning'>[src.name] необъяснимым образом рикошетит от спины жертвы...</span>")
		return
	backstab(M, user)

/obj/item/kitchen/knife/backstabber/proc/backstab(mob/living/carbon/victim, mob/living/carbon/user)
	if((victim.status_flags & GODMODE || HAS_TRAIT(victim, TRAIT_NODEATH)) && !peaceful)
		return
	if(victim == user)
		log_admin("[user] ([key_name(user)]) suicided, backstabbing himself with [src.name]")
	else
		log_admin("[user] ([key_name(user)]) backstabbed [victim] ([key_name(victim)]) with [src.name]")
	if(!silent_backstab)
		if(user != victim)
			user.do_attack_animation(victim)
		var/bs_sound = "modular_bluemoon/vlad0s_staff/sound/critical_hit.ogg"
		if(custom_backstab_sound)
			bs_sound = custom_backstab_sound
		playsound(victim, bs_sound, 100, 1)
		if(!victim.mind?.miming && !HAS_TRAIT(victim, TRAIT_MUTE) && victim.IsVocal() && prob(30))
			if(isrobotic(victim))
				victim.emote("buzz2")
			else
				if(victim.is_muzzled())
					victim.emote("moan")
				else
					victim.emote(pick("scream", "realagony"))
	var/enforced_deathcoma = FALSE
	if(!peaceful && !HAS_TRAIT(victim, TRAIT_DEATHCOMA))
		ADD_TRAIT(victim, TRAIT_DEATHCOMA, "backstab")
		enforced_deathcoma = TRUE
	apply_backstab_effect(victim, user)
	if(enforced_deathcoma)
		REMOVE_TRAIT(victim, TRAIT_DEATHCOMA, "backstab")
	if(!silent_backstab && speech_after_backstab && !user.mind?.miming)
		var/list/spy_phrases = list(
			"Вы испачкали мне костюм!",
			"О, извините!",
			"О Боже, что я тут устроил[user.ru_a()]!",
			"Спасибо, что были так любезны...",
			"Простите, что без приглашения!",
			"Обычный рабочий день...")
		var/job_on_the_card = ""
		if(victim.get_idcard())
			var/obj/item/card/id/card = victim.get_idcard()
			job_on_the_card = card.assignment ? card.assignment : ""
			job_on_the_card = lowertext(job_on_the_card)
		if(HAS_TRAIT(victim, TRAIT_BLUEMOON_HEAVY_SUPER) || HAS_TRAIT(victim, TRAIT_BLUEMOON_HEAVY))
			spy_phrases = list(
				"Это ЖИРНАЯ точка в твоей жизни!",
				"Ну, толстяк, даже не ловко как-то!")
		if(findtext(job_on_the_card, "security") || findtext(job_on_the_card, "detective"))
			spy_phrases = list(
				"Может быть, в следующий раз пришлют настоящего бойца!",
				"Тебе поставят памятник \"Зелёный Салага\"!")
		if(findtext(job_on_the_card, "medic") || findtext(job_on_the_card, "doctor") || findtext(job_on_the_card, "virolog") || findtext(job_on_the_card, "geneti"))
			spy_phrases = list(
				"Всё-таки смех - лучшее лекарство!",
				"Судя по вашей кардиограмме... вы мертвы!")
		user.say(pick(spy_phrases), forced = "backstab")
	var/style = check_style(user)
	go_on_cooldown(style)

/obj/item/kitchen/knife/backstabber/proc/apply_backstab_effect(mob/living/carbon/victim, mob/living/carbon/user)
	if(!silent_backstab)
		victim.visible_message("<span class='warning'>[victim] падает на землю и перестаёт подавать признаки жизни...</span>")
	victim.apply_damage(200, BRUTE, BODY_ZONE_CHEST, wound_bonus=CANT_WOUND)
	victim.death(FALSE)

/obj/item/kitchen/knife/backstabber/suicide_act(mob/user)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		user.visible_message("<span class='suicide'>[user] заносит над собой [src.name], но не решается нанести удар, падая на землю и начиная плакать от беспомощности!</span>")
		user.emote("cry")
		return (SHAME)
	if(peaceful || is_on_cooldown)
		if(!silent_backstab)
			user.visible_message("<span class='suicide'>[user] безнадёжно пытается ударить себя своим [src.name], но это оружие оказывается неспособно [user.ru_ego()] убить!</span>")
		return (SHAME)
	if(!silent_backstab)
		user.visible_message("<span class='suicide'>[user] заворачивает руку под, казалось бы, невозможным углом, и ударяет себя в спину своим [src.name]!</span>")
	backstab(user, user)
	return (BRUTELOSS)

/obj/item/kitchen/knife/backstabber/silent
	name = "Your Eternal Reward"
	desc  = "It seems to be a REALLY stealthy knife"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "buckknife"
	silent_backstab = TRUE
	cooldown_icon_state = null
	cooldown_time = 1.5 MINUTES
	start_cooldown_message = "потухает и становится холоднее на ощупь"
	end_cooldown_message = "вновь загорается странным светом"

/obj/item/kitchen/knife/backstabber/silent/apply_backstab_effect(mob/living/carbon/victim, mob/living/carbon/user)
	to_chat(victim, "<span class='userdanger'>Стоп, что это б...</span>")
	if(victim != user)
		to_chat(user, "<span class='boldwarning'>Ты с невероятной точностью вонзаешь [src.name] в спину [victim], после чего [victim.ru_ego()] тело оседает на землю в беззвучном крике и становится невидимым!</span>")
	var/initial_alpha = victim.alpha
	animate(victim, alpha = 0, time = 1 SECONDS)
	victim.apply_damage(75, BRUTE, BODY_ZONE_CHEST, wound_bonus=CANT_WOUND)
	victim.death(FALSE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(victim_fade_in), victim, initial_alpha, 0.3 SECONDS), 10 SECONDS)

proc/victim_fade_in(mob/target, required_alpha, fade_time)
	animate(target, alpha = required_alpha, time = fade_time)
	target.visible_message("<span class='warning'>Тело [target] внезапно появляется...</span>")

/obj/item/kitchen/knife/backstabber/icicle
	name = "Strange Icicle"
	desc = "A very sharp piece of ice. Why this thing looks like you can stab someone in back with it?"
	cooldown_icon_state = null
	cooldown_time = 40 SECONDS
	icon = 'icons/obj/lollipop.dmi'
	icon_state = "lollipop_stick"
	item_state = "lollipop_stick"
	start_cooldown_message = "будто бы слегка плавится, становясь менее острой"
	end_cooldown_message = "вновь начинает казаться самым острым куском льда из тех, которые вы видели"

/obj/item/kitchen/knife/backstabber/icicle/apply_backstab_effect(mob/living/carbon/victim, mob/living/carbon/user)
	victim.visible_message("<span class='warning'>[victim] внезапно застывает и превращается в ледяную статую!</span>")
	var/obj/structure/statue/custom/icicle_knife_statue/new_statue = new(get_turf(victim))
	new_statue.alpha = 40
	new_statue.set_visuals(victim)
	new_statue.set_custom_materials(list(/datum/material/snow=MINERAL_MATERIAL_AMOUNT*5))
	var/mutable_appearance/ma = victim
	new_statue.dir = ma.dir
	new_statue.name = "ice statue of [ma.name]"
	new_statue.desc = "A statue depicting [ma.name], made from ice... This thing feels strange..."
	new_statue.victim = victim
	victim.forceMove(new_statue)
	victim.death(FALSE)
	animate(new_statue, alpha = 160, time = 1 SECONDS)

/obj/structure/statue/custom/icicle_knife_statue
	name = "ice statue"
	var/mob/living/carbon/victim = null

/obj/structure/statue/custom/icicle_knife_statue/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, .proc/eject_victim), 1 MINUTES)

/obj/structure/statue/custom/icicle_knife_statue/proc/eject_victim(delete_statue = TRUE)
	if(victim && !QDELETED(victim))
		victim.forceMove(get_turf(src))
		victim.visible_message("<span class='boldwarning'>[victim.name] выпадает из [name]!</span>")
	if(delete_statue)
		qdel(src)

/obj/structure/statue/custom/icicle_knife_statue/Destroy()
	eject_victim(FALSE)
	return ..()

/obj/structure/statue/custom/icicle_knife_statue/attackby(obj/item/W, mob/living/user, params)
	add_fingerprint(user)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(default_unfasten_wrench(user, W))
			return
		if(W.tool_behaviour == TOOL_WELDER)
			if(!W.tool_start_check(user, amount=0))
				return FALSE

			user.visible_message("<span class='notice'>[user] начинает плавить [src.name].</span>", "<span class='notice'>Вы плавите [src.name]...</span>")
			if(W.use_tool(src, user, 70, volume=50))
				user.visible_message("<span class='notice'>[user] расплавляет [src.name].</span>", "<span class='notice'>Вы успешно расплавили [src.name]...</span>")
				eject_victim(TRUE)
			return
	return ..()

/obj/item/kitchen/knife/backstabber/kunai
	name = "Kunai"
	desc = "A very sharp kunai, suitable for the finest of ninjas"
	cooldown_icon_state = null
	cooldown_time = 1 MINUTES
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "survivalknife"
	start_cooldown_message = "похоже, пока что может быть использован лишь как садовый инструмент"
	end_cooldown_message = "снова удобно сидит в руке предприимчивого ниндзя"

/obj/item/kitchen/knife/backstabber/kunai/apply_backstab_effect(mob/living/carbon/victim, mob/living/carbon/user)
	if(victim != user && victim.health > 0)
		var/healing_amount = victim.health / 3
		user.heal_overall_damage(healing_amount, healing_amount, healing_amount, FALSE, FALSE, TRUE)
		to_chat(user, "<span class='nicegreen'>Кажется, [src.name] направляет в ваше тело часть жизненной энергии жертвы!</span>")
	victim.apply_damage(100, BRUTE, BODY_ZONE_CHEST, wound_bonus=CANT_WOUND)
	victim.death(FALSE)

/obj/item/storage/box/backstabber_kit
	name = "assasination kit"
	desc = "Suspicious as fuck..."
	icon_state = "syndiebox"
	illustration = null

/obj/item/storage/box/backstabber_kit/PopulateContents()
	new /obj/item/kitchen/knife/backstabber(src)
	new /obj/item/paper/guides/backstabber(src)
	new /obj/item/lighter/black(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_robustgold(src)
	new /obj/item/soap/inteq(src)
	new /obj/item/clothing/head/fedora(src)
	new /obj/item/clothing/under/suit/black_really(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/shoes/laceup(src)

/obj/item/paper/guides/backstabber
	name = "Мануал искусства ударов в спину"
	desc = "Довольно подозрительно, не так ли?"
	default_raw_text = {"<h1>Пояснительная записка к устройству RSCW "Нож"</h1>© InteQ, все права защищены
	<p>Поздравляю с новой работой, ассасин! У тебя в руках оружие невероятной силы, однако любым оружием нужно уметь
	пользоваться! Нож, который ты можешь найти в этой коробке, не такой простой, каким кажется на первый взгляд. Один удар
	в спину или в лежачего противника - и обидчик, скорее всего отправится к праотцам (если, конечно, такие у него имеются). Удары же во все остальные
	места - довольно позорная для доблестного агента ошибка и особого успеха не принесут. Также у всех ножей есть время перезарядки,
	необходимое для восстановления блюспейс-механизмов, позволяющих ножу игнорировать любую броню и мгновенно убивать.
	Большинство ножей при ударе издают довольно громкий звук, благодаря которому все вокруг узнают, что произошло, так что стоит быть осторожным!</p>
	<br>
	<p>Помни, что у настоящего шпиона есть СТИЛЬ! В связи с многочисленными жалобами на наших агентов, устраивающих мерзкую
	резню в окровавленных скафандрах, Ассоциация Ассасинов InteQ ввела требования к дресскоду для своих скрытных сотрудников:
	отныне хождение в окровавленных обмотках будет повышать время перезарядки, а красивый костюм - понижать! В комплекте идёт
	несколько стильных вещей для максимально красивых убийств! Для того, чтобы его носитель и звучал как джентльмен, нож будет
	выдавать реплику от имени агента после каждого удара в спину... по крайней мере, большинство ножей.</p>
	<br>
	<h3>Разновидности</h3>
	<p>Использовав нож в руке, ты можешь выбрать желаемый его образ. У всех их есть свои особенности!</p><ol>
	<li><b>Классика</b> - обычный нож-бабочка, который у тебя в руках. Наносит 200 единиц физического урона и мгновенно убивает цель
	Перезарядка: <b>30 секунд</b></li>
	<li><b>Вечный покой</b> - орудия для поистине скрытных убийств. Работает беззвучно, окружающие лишь услышат стук
	трупа о плитку станции. Тело менее чем за секунду растворится в воздухе и станет невидимым, возвратив себе непрозрачность
	лишь через 10 секунд. Наносит 75 единиц физического урона и мгновенно убивает цель.
	Перезарядка: <b>1.5 минуты</b></li>
	<li><b>Сосулька</b> - грозное оружие, несмотря на своё название. Не наносит урона, но мгновенно убивает цель, тело которой
	превращается в ледяную статую. Статуя сама собой растает через минуту, но также может быть расплавлена сваркой или просто
	разбита, после чего тело жертвы выпадет из неё.
	Перезарядка: <b>40 секунд</b></li>
	<li><b>Кунай</b> - орудие настоящих ниндзя. При ударе наносит 100 единиц физического урона и мгновенно убивает жертву, а
	также крадёт часть её здоровья, которое у неё было до удара, излечивая носителя.
	Перезарядка: <b>1 минута</b></li></ol>
	<br>
	<p>Помимо своего замечательного ножа вы также можете найти в наборе комплект одежды, этот мануал, зажигалку для уничтожения
	документов, пачку сигарет и мыло™ для очистки следов и своей одежды от крови! Не забудь уничтожить коробку и эту бумагу!</p>
	<br>
	<b>Удачи, агент!</b>"}
