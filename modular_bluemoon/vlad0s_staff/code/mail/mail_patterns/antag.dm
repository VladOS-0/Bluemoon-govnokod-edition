/**
 *
 * ПИСЬМА, СВЯЗАННЫЕ С РАЗНЫМИ АНТАГОНИСТАМИ
 * Могут как действительно вербовать в антагов, так и просто подшучивать.
 *
 */

/datum/mail_pattern/antag/anecdote
	name = "Мобилизация в InteQ"
	description = "Делает персонажа предателем, если он уже не антагонист / имплантированный майндшилдом."

	envelope_type = MAIL_TYPE_ENVELOPE

	sender = "НЕИЗВЕСТЕН"

	bad_feeling = "От этого письма исходит зловещая аура."

	weight = MAIL_WEIGHT_RARE

	whitelisted_roundtypes = list(ROUNDTYPE_DYNAMIC_MEDIUM, ROUNDTYPE_DYNAMIC_HARD)
	mindshield_prohibited = TRUE

	letter_title = "???"
	letter_html = {"<center>
		Агент %номер агента%, начинайте действовать. <i>Устройство</i> отправлено вам.
		Кодовые слова - %кодовые слова%.
		Смерть корпоратам!
		</center>
	"}
	letter_icon_state = "docs_red"
	letter_desc = "Жутковатая бумажка с печатью в форме щита внизу..."
	letter_sign = null

/datum/mail_pattern/antag/anecdote/apply(mob/living/carbon/human/recipient)
	if(prob(10))
		letter_html = "<img src='https://vgorode.ua/img/article/12082/19_main-v1654070622.jpg'></img>"
	else
		letter_html = replacetext(letter_html, "%номер агента%", pick(GLOB.phonetic_alphabet))
		letter_html = replacetext(letter_html, "%кодовые слова%", jointext(GLOB.syndicate_code_phrase, ", "))
	. = ..()

/datum/mail_pattern/antag/anecdote/on_mail_open(mob/living/carbon/human/recipient)
	. = ..()
	sleep(70)
	// То, что письмо было отфильтровано при первоначальном выпадении, не означает, что получателя не
	// проимплантируют / завербуют в антажку позже
	if(!recipient.mind.has_antag_datum(/datum/antagonist, TRUE) && !HAS_TRAIT(recipient, TRAIT_MINDSHIELD))
		recipient.mind?.add_antag_datum(/datum/antagonist/traitor)
	else
		to_chat(recipient, span_warning("Вы вспоминаете о своих клятвах, данных до начала смены... Но теперь у вас другая цель. Обстоятельства изменились."))
	sleep(20)
	if(istype(parent) && istype(parent.included_letter))
		parent.included_letter.fire_act(1000)
		if(recipient.get_active_held_item() == parent.included_letter || recipient.get_inactive_held_item() == parent.included_letter)
			recipient.dropItemToGround(parent.included_letter)
			to_chat(recipient, span_boldwarning("[parent.included_letter] внезапно загорается!"))

