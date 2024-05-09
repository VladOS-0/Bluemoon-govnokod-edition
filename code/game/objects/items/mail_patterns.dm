/// Small letter
#define MAIL_TYPE_ENVELOPE "envelope"
/// Big package
#define MAIL_TYPE_PACKAGE "package"

/**
 *
 * РАЗНОЕ
 *
 */

/*
/datum/mail_pattern/misc/
	id = ""
	name = ""
	description = ""

	weight = ""

	letter_title = ""
	letter_html = ""

	initial_contents = list()
*/

/**
 *
 * ПРИКОЛЫ ОТ СИНДИКАТА
 *
 */

/datum/mail_pattern/syndie/anecdote
	id = "syndie_anecdote"
	name = "Привет от InteQ!"
	description = "эхехехе"

	envelope_type = MAIL_TYPE_ENVELOPE

	weight = 10

	letter_title = "Привет от InteQ!"
	letter_html = {"<center>
		%->Дорогой дружочек | Дорогая подружечка%-,
		ТЕПЕРЬ ТЫ РАБОТАЕШЬ НА НАС!!!
		</center>
	"}
	letter_icon_state = "docs_red"
	letter_desc = "Что это?!"

	initial_contents = list(
		/obj/item/clothing/under/inteq_maid
	)

/datum/mail_pattern/syndie/anecdote/apply(mob/living/carbon/human/recipient)
	sender = "хорошие парни"
	initial_contents += /obj/item/reagent_containers/food/snacks/intecookies
	. = ..()

/datum/mail_pattern/syndie/anecdote/on_mail_open(mob/living/carbon/human/recipient)
	recipient.mind?.add_antag_datum(/datum/antagonist/traitor)

/**
 *
 * ДЕНЕЖКИ
 *
 */

/*
/datum/mail_pattern/money/
	id = ""
	name = ""
	description = ""

	weight = ""

	letter_title = ""
	letter_html = ""

	initial_contents = list()
*/

/**
 *
 * СЕМЕЙНЫЕ
 *
 */

/datum/mail_pattern/family/babushka_cookies
	id = "babushka_cookies"
	name = "Печенья от бабули"
	description = "В названии недостаточно понятно указано?"

	envelope_type = MAIL_TYPE_PACKAGE

	weight = 10

	letter_title = "Записка от бабули"
	letter_html = {"
		%->Дорогой внучок | Дорогая внучка%-,
		Надеюсь, что это письмо найдет тебя в здравии и хорошем настроении.
		Я знаю, что ты очень занят%%А%% на космической станции, но я все равно нашла время испечь для тебя твои любимые печенья. Ведь как же без них, правда?
		Я помню, как ты всегда любил%%А%% мои печенья, поэтому я не могла упустить возможность порадовать тебя этим вкусным угощением. Надеюсь, что они поднимут тебе настроение и добавят тебе энергии в твоей нелегкой работе.
		Не забывай, что даже на космической станции важно помнить о семье и близких. Желаю тебе успехов во всех твоих начинаниях и не забывай, что я всегда думаю о тебе. С любовью и теплом,
		Твоя бабушка.
	"}
	initial_contents = list(
		/obj/item/reagent_containers/food/snacks/cookie
	)

/datum/mail_pattern/family/babushka_cookies/apply(mob/living/carbon/human/recipient)
	sender = "[random_unique_name(FEMALE)]"
	if(prob(10))
		initial_contents += /obj/item/reagent_containers/food/snacks/intecookies
	else
		initial_contents += /obj/item/reagent_containers/food/snacks/sugarcookie
	. = ..()


/**
 *
 * ПО РАБОТЕ
 *
 */

/*
/datum/mail_pattern/job/
	id = ""
	name = ""
	description = ""

	weight = ""

	letter_title = ""
	letter_html = ""

	initial_contents = list()
*/

/**
 *
 * МАГАЗИНЫ
 *
 */

/*
/datum/mail_pattern/shop/
	id = ""
	name = ""
	description = ""

	weight = ""

	letter_title = ""
	letter_html = ""

	initial_contents = list()
*/

/**
 *
 * СПАМ
 *
 */

/*
/datum/mail_pattern/spam/
	id = ""
	name = ""
	description = ""

	weight = ""

	letter_title = ""
	letter_html = ""

	initial_contents = list()
*/

/**
 *
 * ПОШЛОЕ
 *
 */

/*
/datum/mail_pattern/lewd/
	id = ""
	name = ""
	description = ""

	weight = ""

	letter_title = ""
	letter_html = ""

	initial_contents = list()
*/

#undef MAIL_TYPE_ENVELOPE
#undef MAIL_TYPE_PACKAGE
