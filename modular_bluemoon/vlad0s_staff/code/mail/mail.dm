/// Info block for mails examine
#define mail_info_box(str) ("<div class='mail_info_box'>" + str + "</div>")

/**
 *
 * ПОЧТОВЫЕ КОНВЕРТЫ И ОСНОВНАЯ ЛОГИКА
 *
 */

/obj/item/mail
	name = "Postal Envelope"
	gender = NEUTER
	desc = "Сертифицированный Пактом современный™ почтовый конверт из сверхпрочной бумаги с небольшим датчиком отпечатков пальцев. Всё ещё сильно дешевле блюспейс-доставки."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "mail_small"
	item_state = "paper"
	var/open_state = "mail_small_tempered"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	// drop_sound = 'sound/items/handling/paper_drop.ogg'
	// pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	// Свойства, относящиеся к самому письму

	/// Destination tagging for the mail sorter.
	var/sort_tag = 0
	/// Fingerprint of recipient
	var/recipient_fingerprint = null
	/// Whether mail is opened or not
	var/opened = FALSE
	/// Whether mail is postmarked or not
	var/postmarked = TRUE
	/// Does the letter have a stamp overlay?
	var/stamped = TRUE
	/// List of all stamp overlays on the letter.
	var/list/stamps = list()
	/// Maximum number of stamps on the letter.
	var/stamp_max = 1
	/// Physical offset of stamps on the object. X direction.
	var/stamp_offset_x = 0
	/// Physical offset of stamps on the object. Y direction.
	var/stamp_offset_y = 2
	/// Mail will have the color of the department the recipient is in.
	var/static/list/department_colors

	// Свойства, относящиеся к наполнению

	var/datum/mail_pattern/pattern

	var/obj/item/paper/included_letter

	var/sender_name = "НЕИЗВЕСТЕН"
	var/recipient_name = "???"
	var/recipient_job = "N/A"
	var/arrive_time = ""
	var/open_time = "N/A"

/obj/item/mail/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposal_handling))
	AddElement(/datum/element/item_scaling, 0.5, 1)
	if(isnull(department_colors))
		department_colors = list(
			ACCOUNT_CIV = COLOR_WHITE,
			ACCOUNT_ENG = COLOR_PALE_ORANGE,
			ACCOUNT_SCI = COLOR_PALE_PURPLE_GRAY,
			ACCOUNT_MED = COLOR_PALE_BLUE_GRAY,
			ACCOUNT_SRV = COLOR_PALE_GREEN_GRAY,
			ACCOUNT_CAR = COLOR_BEIGE,
			ACCOUNT_SEC = COLOR_PALE_RED_GRAY,
		)
	// Icons
	// Add some random stamps.
	if(stamped == TRUE)
		var/stamp_count = rand(1, stamp_max)
		for(var/i = 1, i <= stamp_count, i++)
			stamps += list("stamp_[rand(2, 6)]")
	update_icon()
	SSmail.total_mails_count++

/obj/item/mail/Destroy()
	qdel(pattern)
	pattern = null
	stamps = null
	included_letter = null
	for(var/atom/content in contents)
		contents -= content
		qdel(content)
	var/datum/component/storage/concrete/STR = GetComponent(/datum/component/storage/concrete)
	qdel(STR)
	if(!opened)
		SSmail.unregister_mail(src)
	. = ..()

/obj/item/mail/proc/disappear()
	if(opened)
		return
	say("Получатель не был обнаружен в течении тридцати минут. Самоликвидация...")
	sleep(3 SECONDS)
	do_fake_sparks(2, 2, src)
	qdel(src)

/obj/item/mail/proc/manual_destroy(mob/destroyer)
	if(QDELETED(src) || !istype(destroyer))
		return
	if(isobserver(destroyer) || !destroyer.canUseTopic(src, BE_CLOSE))
		return
	if(!opened)
		return
	say("Конверт распакован, пользователем [destroyer] запрошена ликвидация оболочки...")
	var/datum/component/storage/concrete/STR = GetComponent(/datum/component/storage/concrete)
	STR.drop_all_on_destroy = TRUE
	sleep(3 SECONDS)
	do_fake_sparks(2, 2, src)
	qdel(STR)
	qdel(src)

/obj/item/mail/update_overlays()
	. = ..()
	var/bonus_stamp_offset = 0
	for(var/stamp in stamps)
		var/image/stamp_image = image(
			icon = icon,
			icon_state = stamp,
			pixel_x = stamp_offset_x,
			pixel_y = stamp_offset_y + bonus_stamp_offset
		)
		stamp_image.appearance_flags |= RESET_COLOR
		bonus_stamp_offset -= 5
		. += stamp_image

	if(postmarked == TRUE)
		var/image/postmark_image = image(
			icon = icon,
			icon_state = "postmark",
			pixel_x = stamp_offset_x + rand(-3, 1),
			pixel_y = stamp_offset_y + rand(bonus_stamp_offset + 3, 1)
		)
		postmark_image.appearance_flags |= RESET_COLOR
		. += postmark_image

/obj/item/mail/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/storage/concrete)
	var/datum/component/storage/concrete/STR = GetComponent(/datum/component/storage/concrete)
	STR.storage_flags = STORAGE_FLAGS_VOLUME_DEFAULT
	STR.max_volume = DEFAULT_VOLUME_TINY * 4
	STR.max_w_class = WEIGHT_CLASS_TINY
	STR.allow_quick_empty = TRUE
	STR.drop_all_on_deconstruct = FALSE
	STR.max_items = 3
	STR.locked = TRUE

/obj/item/mail/proc/disposal_handling(disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER
	if(!hasmob)
		disposal_holder.destinationTag = sort_tag

/obj/item/mail/examine(mob/user)
	. = ..()
	. += span_notice("<br>Вы видите красную панель с текстом на упаковке. <a href='?src=[REF(src)];check_mail_info=1'>Осмотреть</a>")
	. += span_info("<br>Используйте таггер, чтобы отправить письмо по станционной системе труб.")
	if(pattern && isobserver(user))
		. += span_info("<br>Будучи неупокоенным и очень любознательным духом, вы понимаете, что это <b>[pattern.name]</b>")
	if(opened)
		. += span_info("<br>Письмо уже открыто, и вы видите мигающую кнопку самоуничтожения конверта <a href='?src=[REF(src)];destroy=1'>Нажать</a>")

/obj/item/mail/Topic(href, list/href_list)
	. = ..()
	if(href_list["check_mail_info"])
		mail_info_display(usr)
		return
	if(href_list["destroy"])
		manual_destroy(usr)
		return

/obj/item/mail/proc/mail_info_display(mob/user)
	if(QDELETED(src) || !istype(user))
		return
	if(!isobserver(user) && !user.canUseTopic(src, BE_CLOSE))
		return
	var/mail_info = ""
	mail_info += "<center><b>ПОЧТОВОЕ АГЕНТСТВО ЦЕНТРАЛЬНОГО КОМАНДОВАНИЯ</b></center><hr>"
	mail_info += "<u>ОТПРАВИТЕЛЬ</u> - [sender_name]<br>"
	mail_info += "<u>ПУНКТ НАЗНАЧЕНИЯ</u> - [GLOB.station_name]<br>"
	mail_info += "<u>ПОЛУЧАТЕЛЬ</u> - [recipient_name]<br>"
	mail_info += "<u>ДОЛЖНОСТЬ ПОЛУЧАТЕЛЯ</u> - [recipient_job]<br>"
	mail_info += "<u>ДАТА ПРИБЫТИЯ</u> - [arrive_time]<hr>"
	mail_info += "<u>ВСКРЫТО</u> - [open_time]"
	. += mail_info_box(mail_info)
	to_chat(user, mail_info)

/obj/item/mail/attackby(obj/item/W, mob/user, params)
	// Destination tagging
	if(istype(W, /obj/item/dest_tagger))
		var/obj/item/dest_tagger/destination_tag = W

		if(sort_tag != destination_tag.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[destination_tag.currTag])
			to_chat(user, span_notice("*[tag]*"))
			sort_tag = destination_tag.currTag
			playsound(loc, 'sound/machines/twobeep_high.ogg', vol = 100, vary = TRUE)

/obj/item/mail/attack_self(mob/user)
	if(!opened)
		try_open(user)
	else
		. = ..()

/// Opening mail if user's fingerprint is identical to recipient's
/obj/item/mail/proc/try_open(mob/user)
	if(!istype(user, /mob/living/carbon/human))
		to_chat(user, span_warning("Вы не понимаете, что делать с этим свёртком..."))
		return
	var/mob/living/carbon/human/opener = user
	opener.visible_message(span_notice("[opener] вдавливает палец в сканер отпечатков на [src]"))

	if(recipient_fingerprint)
		if(!opener.dna.uni_identity)
			to_chat(opener, span_warning("Сканер свёртка не реагирует на ваш палец!"))
			return
		if(md5(opener.dna.uni_identity) != recipient_fingerprint)
			balloon_alert_to_viewers("ОТКАЗАНО В ДОСТУПЕ: отпечатки не совпадают")
			return
		if(pattern && !pattern.special_open_check(opener))
			return
	open(opener)

/obj/item/mail/proc/open(mob/living/carbon/human/opener = null)
	balloon_alert_to_viewers("ДОСТУП РАЗРЕШЕН. Приятного пользования, [opener ? opener : "аноним"]!")
	playsound(src, 'sound/machines/chime.ogg', 20)
	opened = TRUE
	if(open_state)
		icon_state = open_state
	var/datum/component/storage/concrete/STR = GetComponent(/datum/component/storage/concrete)
	STR.locked = FALSE
	open_time = "[GLOB.current_date_string] [STATION_TIME_TIMESTAMP("hh:mm:ss", world.time)]"
	SSmail.unregister_mail(src)
	on_mail_open(opener)

/// Proc that called when mail is succesfully opened with special effects
/obj/item/mail/proc/on_mail_open(mob/living/carbon/human/opener)
	if(!istype(opener))
		return
	if(istype(included_letter))
		if(!opener.get_inactive_held_item())
			opener.put_in_inactive_hand(included_letter)
			opener.swap_hand()
		included_letter.attempt_examinate(opener)
	if(istype(pattern))
		pattern.on_mail_open(opener)

/// Proc that converts mail envelope into mail package
/obj/item/mail/proc/convert_to_package()
	if(recipient_name && recipient_job)
		name = "Postal Package for for [recipient_name] ([recipient_job])"
	else
		name = "Postal Package"
	desc = "Сертифицированный Пактом современный™ почтовый контейнер из сверхпрочной бумаги с небольшим датчиком отпечатков пальцев. Всё ещё сильно дешевле блюспейс-доставки."
	icon_state = "mail_large"
	open_state = "mail_large_tampered"
	w_class = WEIGHT_CLASS_NORMAL
	var/datum/component/storage/concrete/STR = GetComponent(/datum/component/storage/concrete)
	STR.max_volume = DEFAULT_VOLUME_SMALL * 6
	STR.max_w_class = WEIGHT_CLASS_SMALL

/**
 *
 * ПРЕ-СОЗДАННЫЕ ЯЩИКИ С ПОЧТОЙ
 *
 */
/obj/structure/closet/crate/mail
	name = "mail crate"
	desc = "A certified post crate from CentCom."
	icon_state = "mail"
	base_icon_state = "mail"
	storage_capacity = 50
	///if it'll show the nt mark on the crate
	var/postmarked = TRUE
	var/arrive_time = "N/A"
	var/initial_mails_count = 0

/obj/structure/closet/crate/mail/proc/wrap()
	arrive_time = "[GLOB.current_date_string] [STATION_TIME_TIMESTAMP("hh:mm:ss", world.time)]"
	for(var/obj/item/mail/envelope_in_container in contents)
		initial_mails_count++
		SSmail.register_mail(envelope_in_container)
		envelope_in_container.arrive_time = "[GLOB.current_date_string] [STATION_TIME_TIMESTAMP("hh:mm:ss", world.time)]"
	desc = initial(desc)
	name = initial(name)
	if(resistance_flags & INDESTRUCTIBLE)
		resistance_flags &= ~INDESTRUCTIBLE

/obj/structure/closet/crate/mail/examine(mob/user)
	. = ..()
	. += span_notice("Дата прибытия - [arrive_time]")
	. += span_notice("Количество прибывших в контейнере писем и посылок - [initial_mails_count]")

/obj/structure/closet/crate/mail/update_icon_state()
	. = ..()
	if(opened)
		icon_state = "[base_icon_state]open"
		if(locate(/obj/item/mail) in src)
			icon_state = base_icon_state
	else
		icon_state = "[base_icon_state]sealed"

/obj/structure/closet/crate/mail/update_overlays()
	. = ..()
	if(postmarked)
		. += "mail_nt"

/// Opened mail crate
/obj/structure/closet/crate/mail/preopen
	opened = TRUE
	icon_state = "mailopen"

/**
 *
 * МЕШОК ДЛЯ ПИСЕМ
 *
 */
/obj/item/storage/bag/mail
	name = "mail bag"
	desc = "A bag for letters, envelopes, and other postage."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookbag"
	item_state = "bookbag"
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/mail/ComponentInitialize()
	. = ..()
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	storage.max_w_class = WEIGHT_CLASS_NORMAL
	storage.max_combined_w_class = 42
	storage.max_items = 21
	storage.display_numerical_stacking = FALSE
	storage.can_hold = typecacheof(list(
		/obj/item/mail,
		/obj/item/small_delivery,
		/obj/item/paper
	))

/**
 *
 * МЕСТО, ГДЕ БУДУТ СПАВНИТЬСЯ ПОЧТОВЫЕ ЯЩИКИ
 *
 */

/area/mail_spawner
	name = "Centcomm Mail Teleporter Chamber"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = TRUE
	area_flags = NOTELEPORT | HIDDEN_AREA | UNIQUE_AREA

/obj/structure/marker_beacon/yellow/mail_beacon
	name = "Почтовый маяк"
	desc = "Этот неразрушимый маяк генерирует энергию для своей работы, собирает письма со всей галактики, пакует их в контейнеры и телепортирует их на шаттл карго. Это блюспейс, я не обязан ничего объяснять."
	resistance_flags = INDESTRUCTIBLE

/obj/structure/marker_beacon/yellow/mail_beacon/Destroy()
	message_admins("[ADMIN_VERBOSEJMP(SSmail.main_storage_spawnpoint)] Почтовый маяк был уничтожен!")
	. = ..()
