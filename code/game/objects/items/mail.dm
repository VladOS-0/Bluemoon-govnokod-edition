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
	/// Whether main is opened or not
	var/opened = FALSE

	// Свойства, относящиеся к наполнению

	/// Name for text letter in envelope
	var/letter_title = "БЛАНК ПОЛУЧЕНИЯ"
	/// HTML for text letter in envelope
	var/letter_html = "Данный бланк подтверждает получение посылки адресатом."
	/// Created items during initialization. If items should be customised, use
	var/list/obj/item/initial_contents = list()

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
	STR.max_volume = DEFAULT_VOLUME_TINY * 3
	STR.max_w_class = WEIGHT_CLASS_TINY
	STR.allow_quick_empty = TRUE
	STR.max_items = 3
	STR.locked = TRUE

/obj/item/mail/proc/disposal_handling(disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER
	if(!hasmob)
		disposal_holder.destinationTag = sort_tag

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
	balloon_alert_to_viewers("ДОСТУП РАЗРЕШЁН. Приятного пользования, [opener]!")
	playsound(src, 'sound/machines/chime.ogg', 20)
	opened = TRUE
	if(open_state)
		icon_state = open_state
	var/datum/component/storage/concrete/STR = GetComponent(/datum/component/storage/concrete)
	STR.locked = FALSE
	on_mail_open(user)

/// Proc that called when mail is succesfully opened with special effects
/obj/item/mail/proc/on_mail_open(/mob/living/carbon/human/opener)
	return

/*
/obj/item/mail/examine_more(mob/user)
	. = ..()
	if(!postmarked)
		. += span_info("This mail has no postmarking of any sort...")
	else
		. += span_notice("<i>You notice the postmarking on the front of the mail...</i>")
	var/datum/mind/recipient = recipient_ref.resolve()
	if(recipient)
		. += span_info("[postmarked ? "Certified NT" : "Uncertified"] mail for [recipient].")
	else if(postmarked)
		. += span_info("Certified mail for [GLOB.station_name].")
	else
		. += span_info("This is a dead letter mail with no recipient.")
	. += span_info("Distribute by hand or via destination tagger using the certified NT disposal system.")
*/

/// Accepts a mind to initialize goodies for a piece of mail.
/obj/item/mail/proc/initialize_for_recipient(datum/mind/recipient)
	name = "[initial(name)] for [recipient.name] ([recipient.assigned_role])"
	recipient_ref = WEAKREF(recipient)

	var/mob/living/body = recipient.current
	var/list/goodies = generic_goodies

	var/datum/job/this_job = SSjob.name_occupations[recipient.assigned_role]
	var/is_mail_restricted = FALSE // certain roles and jobs (prisoner) do not receive generic gifts

	if(this_job)
		if(this_job.paycheck_department && department_colors[this_job.paycheck_department])
			color = department_colors[this_job.paycheck_department]

		var/list/job_goodies = this_job.get_mail_goodies()
		is_mail_restricted = this_job.exclusive_mail_goodies
		if(LAZYLEN(job_goodies))
			if(is_mail_restricted)
				goodies = job_goodies
			else
				goodies += job_goodies

	if(!is_mail_restricted)
		// the weighted list is 50 (generic items) + 50 (job items)
		// every quirk adds 5 to the final weighted list (regardless the number of items or weights in the quirk list)
		// 5% is not too high or low so that stacking multiple quirks doesn't tilt the weighted list too much
		for(var/datum/quirk/quirk as anything in body.roundstart_quirks)
			if(LAZYLEN(quirk.mail_goodies))
				var/quirk_goodie = pick(quirk.mail_goodies)
				goodies[quirk_goodie] = 5

		// A little boost for the special times!
		for(var/datum/holiday/holiday as anything in SSevents.holidays)
			if(LAZYLEN(holiday.mail_goodies))
				var/holiday_goodie = pick(holiday.mail_goodies)
				goodies[holiday_goodie] = holiday.mail_goodies[holiday_goodie]

	for(var/iterator in 1 to goodie_count)
		var/target_good = pikweight(goodies)
		var/atom/movable/target_atom = new target_good(src)
		body.log_message("received [target_atom.name] in the mail ([target_good])", LOG_GAME)

	return TRUE


/**
 *
 * ПОСЫЛКИ
 *
 */

/obj/item/mail/envelope
	name = "Postal Package"
	desc = "Сертифицированный Пактом современный™ почтовый контейнер из сверхпрочной бумаги с небольшим датчиком отпечатков пальцев. Всё ещё сильно дешевле блюспейс-доставки."
	icon_state = "mail_large"
	open_state = "mail_large_tampered"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/mail/envelope/ComponentInitialize()
	. = ..()
	var/datum/component/storage/concrete/STR = GetComponent(/datum/component/storage/concrete)
	STR.max_volume = DEFAULT_VOLUME_TINY * 3
	STR.max_w_class = WEIGHT_CLASS_TINY

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
	///if it'll show the nt mark on the crate
	var/postmarked = TRUE

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

/// Fills this mail crate with N pieces of mail, where N is the lower of the amount var passed, and the maximum capacity of this crate. If N is larger than the number of alive human players, the excess will be junkmail.
/obj/structure/closet/crate/mail/proc/populate(amount)
	var/mail_count = min(amount, storage_capacity)
	// Fills the
	var/list/mail_recipients = list()

	for(var/mob/living/carbon/human/human in GLOB.player_list)
		if(human.stat == DEAD || !human.mind)
			continue
		// Skip wizards, nuke ops, cyborgs; Centcom does not send them mail
		if(!(human.mind.assigned_role in get_all_jobs()))
			continue

		mail_recipients += human.mind

	for(var/i in 1 to mail_count)
		var/obj/item/mail/new_mail
		if(prob(FULL_CRATE_LETTER_ODDS))
			new_mail = new /obj/item/mail(src)
		else
			new_mail = new /obj/item/mail/envelope(src)

		var/datum/mind/recipient = pick_n_take(mail_recipients)
		if(recipient)
			new_mail.initialize_for_recipient(recipient)
		else
			new_mail.junk_mail()

	update_icon()

/// Crate for mail that automatically depletes the economy subsystem's pending mail counter.
/obj/structure/closet/crate/mail/economy/Initialize(mapload)
	. = ..()
	populate(SSeconomy.mail_waiting)
	SSeconomy.mail_waiting = 0

/// Crate for mail that automatically generates a lot of mail. Usually only normal mail, but on lowpop it may end up just being junk.
/obj/structure/closet/crate/mail/full
	name = "brimming mail crate"
	desc = "A certified post crate from CentCom. Looks stuffed to the gills."

/obj/structure/closet/crate/mail/full/Initialize(mapload)
	. = ..()
	populate(INFINITY)

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
