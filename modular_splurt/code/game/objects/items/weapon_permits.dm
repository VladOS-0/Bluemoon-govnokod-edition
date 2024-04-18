// BLUEMOON EDITED - реворк разрешений на оружие

//This'll be used for gun permits, such as for heads of staff, crew, and bartenders. Sec and the Captain do not require these

/obj/item/clothing/accessory/permit
	name = "Weapons permit"
	desc = "Небольшая карточка с блюспейс-электроникой для упрощения контроля за трафиком оружия на станции."
	icon = 'modular_splurt/icons/obj/permits.dmi'
	icon_state = "permit"
	mob_overlay_icon = 'icons/mob/clothing/accessories.dmi'
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FIRE_PROOF
	var/owner_name = ""
	var/owner_assignment = ""
	var/permitted_weapons = ""
	var/notes = ""
	var/locked = FALSE
	// Выдан ли роли при спавне
	var/special = FALSE

/obj/item/clothing/accessory/permit/attack_self(mob/user as mob)
    if(isliving(user))
        if(!owner)
            set_name(user.name)
            to_chat(user, "[src] registers your name.")
            access += list(ACCESS_WEAPONS)
        else
            to_chat(user, "[src] already has an owner!")

/obj/item/clothing/accessory/permit/get_examine_string(mob/user, thats)
	. = ..()
	if(!current_uniform)
		return
	. += span_notice(" <a href='?src=[REF(src)];check=1'>\[Проверить\]</a>")

/obj/item/clothing/accessory/permit/Topic(href, href_list)
	..()
	if (href_list["check"])
		var/mob/user = usr
		if(!user || !istype(user))
			return
		if(get_dist(user, loc) > 5 && !isobserver(user))
			to_chat(user, span_warning("Вы слишком далеко!"))
			return
		if(istype(user, /mob/living))
			user.visible_message("[user] осматривает [src] [current_uniform ? ", прикреплённый к [current_uniform]" : ""].", "Вы осматриваете [src]")
		examine(user)
	return

/obj/item/clothing/accessory/permit/proc/register()
	return


// База для заранее созданных пермитов
/obj/item/clothing/accessory/permit/special
	name = "Coder's special shitcoding permit"
	desc = "Если вы это видите - напишите багрепорт"
	special = TRUE

/obj/item/clothing/accessory/permit/special/New(_owner_name, _owner_assignment)
	. = ..()
	owner_name = _owner_name
	owner_assignment = _owner_assignment

/obj/item/clothing/accessory/permit/special/Initialize(mapload)
	. = ..()
	register()

// Заранее созданные пермиты, выдающиеся разным ролям при спавне.
// Было бы классно, если бы кто-то правил список оружия и примечания после правок КЗ и НРП, да?
/obj/item/clothing/accessory/permit/special/captain
	name = "Captain's weapons permit"
	icon_state = "compermit"
	desc = "Кто-то сомневается в праве КАПИТАНА носить оружие?! Скормить его космо-акулам!"
	permitted_weapons = "Любое неконтрабандное вооружение"
	notes = "Капитан имеет право использовать любое неконтрабандное вооружение, исключительно в рамках самозащиты, начиная с Синего уровня тревоги. В случаях, если применение силы не вызвано критической ситуацией подставляющую жизнь капитана под угрозу, данный пункт не снимает ответственности за ущерб причинённый в рамках самообороны."

/obj/item/clothing/accessory/permit/special/bridge_officer
	name = "Bridge Officer's weapons permit"
	desc = "Боевая горничная капитана на посту!"
	permitted_weapons = "Стандартное вооружение офицера мостика"
	notes = "Офицер мостика имеет право использовать стандартное вооружение исключительно для самозащиты."

/obj/item/clothing/accessory/permit/special/blueshield
	name = "Blueshield's weapons permit"
	desc = "ОЧЕНЬ БОЕВАЯ горничная капитана на страже!"
	permitted_weapons = "Любое неконтрабандное вооружение"
	notes = "Офицер \"Синий Щит\" имеет право использовать любое неконтрабандное вооружение для защиты своих целей и себя. Использование летальной силы разрешено лишь в случае угрозы жизни или цветового кода угрозы выше синего."

/obj/item/clothing/accessory/permit/special/head_of_sec
	name = "Head's of Security weapons permit"
	desc = "Ты не можешь вооружить станцию, не вооружив сначала себя."
	permitted_weapons = "Любое неконтрабандное вооружение"
	notes = "Будучи сотрудником службы безопасности, её глава имеет право носить любое неконтрабандное вооружение и применять его в соответствии с Боевой Политикой."

/obj/item/clothing/accessory/permit/special/chief_engineer
	name = "Chief Engineer's weapons permit"
	desc = "На самом деле, главному инженеру не нужно оружие. Удар ломом по голове является самым эффективным методом самозащиты с 1998 года."
	permitted_weapons = "Стандартное вооружение командного состава"
	notes = "Главный инженер имеет право пользоваться стандартной экипировкой и вооружением, а также применять её в рамках самозащиты."

/obj/item/clothing/accessory/permit/special/research_director
	name = "Research Director's weapons permit"
	desc = "Порой лучше несколько раз пустить в ход телескопическую дубинку, чем потом плакать над взорванным отделом."
	permitted_weapons = "Стандартное вооружение командного состава и реактивная броня"
	notes = "Директор исследований имеет право пользоваться стандартной экипировкой и вооружением, а также применять её в рамках самозащиты. Помимо этого, он имеет право носить реактивную броню, а также, начиная с синего кода - активировать её."

/obj/item/clothing/accessory/permit/special/chief_medic
	name = "Chief Medical Officer's weapons permit"
	desc = "Кусок пластика, пара микросхем и щепотка блюспейса - и вот, от клятвы Гиппократа уже ничего не осталось. Это многое говорит об обществе."
	permitted_weapons = "Стандартное вооружение командного состава и шприцемёт"
	notes = "Главный врач имеет право пользоваться стандартной экипировкой и вооружением, включая шприцемёт, а также применять её в рамках самозащиты."

/obj/item/clothing/accessory/permit/special/quartermaster
	name = "Quartermaster's weapons permit"
	desc = "Да, завхоз, тебе не нужен этот ящик дробовиков, тебе хватит и телескопички. Договорились?"
	permitted_weapons = "Стандартное вооружение командного состава"
	notes = "Квартирмейстер имеет право пользоваться стандартной экипировкой и вооружением, а также применять её в рамках самозащиты."

/obj/item/clothing/accessory/permit/special/representative
	name = "Pact Representative's weapons permit"
	desc = "Нет гаранта соблюдения процедур лучше, чем энергокарабин у виска."
	permitted_weapons = "Стандартное вооружение командного состава, а также тактическую дубинку, роскошную трость и энергетический карабин"
	notes = "Представитель Пакта имеет право пользоваться своей тандартной экипировкой и вооружением, в том числе энергокарабином, роскошной тростью и тактической дубинкой, а также применять всё это в рамках самозащиты."

/obj/item/clothing/accessory/permit/special/lawyer
	name = "Lawyer's weapons permit"
	desc = "Я протестую! А это - моё вещественное доказательство!"
	permitted_weapons = "Стандартное вооружение агента внутренних дел"
	notes = "Агент внутренних дел имеет право пользоваться стандартной экипировкой и вооружением, а также применять её в рамках самозащиты."

/obj/item/clothing/accessory/permit/special/chaplain
	name = "Chaplain's weapons permit"
	desc = "Caedite eos. Novit enim Dominus qui sunt eius."
	permitted_weapons = "Нулевой жезл и его вариации"
	notes = "Священнику разрешно носить и использовать его священное оружие, сиречь вариации нулевого жезла, если это не противоречит космическому закону."

/obj/item/clothing/accessory/permit/special/bartender
	name = "Bartender's weapons permit"
	icon = "barpermit"
	desc = "Я точно не вынесу этот чертовски большой, длинный и привлекательный... дробовик за пределы отдела. Честно-честно."
	permitted_weapons = "Барменовский дробовик с нелетальными патронами"
	notes = "Бармену разрешено хранить и использовать свой дробовик с нелетальными патронами для успокоения буйных посетителей на территории бара в рамках своих норм рабочих процедур и космического закона."

/obj/item/clothing/accessory/permit/special/bouncer
	name = "Bouncer's weapons permit"
	icon = "barpermit"
	desc = "Ну надо же вышибале чем-то вышибать, да?"
	permitted_weapons = "Нелетальное энергооружие, наручники и их варианты, болы, перцовый баллончик"
	notes = "Сотрудник охраны сервиса имеет право использовать своё вооружение только в случае защиты своей жизни или жизни других. Применение вооружения также допустимо против неадекватных членов персонала, что игнорируют просьбы и предупреждения от сотрудников сервисного отдела."

/obj/item/clothing/accessory/permit/special/security
	name = "Security weapons permit"
	desc = "У охраны есть оружие? Вот это новость!"
	permitted_weapons = "Любое неконтрабандное вооружение, если иное не указано боевой политикой и НРП"
	notes = "Сотрудники службы безопасности имеют право использовать своё табельное вооружение для охраны станции в соответствии со своими процедурами и боевой политикой."
