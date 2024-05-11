// BLUEMOON ADDED - переработка писем

/// How much mail the Economy SS will create per minute, regardless of firing time.
#define MAX_MAIL_PER_FIRE 50
/// Maximum of mails on station, which was not opened yet
#define MAX_SEALED_MESSAGES 120

SUBSYSTEM_DEF(mail)
	name = "Mail"
	flags = SS_BACKGROUND | SS_NO_TICK_CHECK
	priority = FIRE_PRIORITY_ACTIVITY
	runlevels = RUNLEVEL_GAME
	init_order = INIT_ORDER_MAIL
	wait = 5 MINUTES
	/// Mails on station, which was not opened yet - BLUEMOON ADD
	var/sealed_mails_count = 0
	/// Total amount of arrived letters during the round - BLUEMOON ADD
	var/total_mails_count = 0

	var/sealed_mails

	var/last_mail_created_count = 0

	var/obj/structure/closet/crate/mail/main_storage = null
	var/obj/structure/marker_beacon/yellow/mail_beacon/beacon = null

/datum/controller/subsystem/mail/Initialize(start_timeofday)

	. = ..()

/datum/controller/subsystem/mail/Recover()
	last_mail_created_count = SSmail.last_mail_created_count
	sealed_mails_count = SSmail.sealed_mails_count
	total_mails_count = SSmail.total_mails_count

/datum/controller/subsystem/mail/fire(resumed = 0)
	if(sealed_mails_count > MAX_SEALED_MESSAGES)
		return
	var/mail_gen_count = clamp(living_player_count() / rand(1, 5), 0, MAX_MAIL_PER_FIRE)
	if(mail_gen_count)
		generate_mails(mail_gen_count)

/datum/controller/subsystem/mail/proc/generate_mails(mail_gen_count)
	if(!main_storage)
		create_main_storage()

/datum/controller/subsystem/mail/proc/create_main_storage()
	main_storage = new /obj/structure/closet/crate/mail(get_turf(beacon))
	return main_storage

/datum/controller/subsystem/mail/proc/a()
/*
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
		var/datum/mind/recipient = pick_n_take(mail_recipients)
		if(!recipient)
			continue
		create_mail_for_recipient(recipient, src)
	update_icon()

/// Creates a mail for a specific mind
/obj/structure/closet/crate/mail/proc/create_mail_for_recipient(datum/mind/recipient)

	var/mob/living/carbon/human/body = recipient.current

	var/datum/job/this_job = SSjob.name_occupations[recipient.assigned_role]

	if(!this_job || !istype(body))
		return

	if(!body.dna.uni_identity)
		return

	var/obj/item/mail/new_mail = null

	new_mail.recipient_name = recipient.name
	new_mail.recipient_job = recipient.assigned_role
	new_mail.recipient_fingerprint = md5(body.dna.uni_identity)

	new_mail.name = "[initial(new_mail.name)] for [new_mail.recipient_name] ([new_mail.recipient_job])"
	if(this_job.paycheck_department && new_mail.department_colors[this_job.paycheck_department])
		new_mail.color = new_mail.department_colors[this_job.paycheck_department]

	if(!new_mail.pattern?.choose_pattern(body) || !new_mail.pattern)
		qdel(new_mail)
		return

	initial_mails_count++

	return

*/
