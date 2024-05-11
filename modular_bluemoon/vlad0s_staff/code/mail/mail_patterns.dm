/// Small letter
#define MAIL_TYPE_ENVELOPE "envelope"
/// Big package
#define MAIL_TYPE_PACKAGE "package"

#define MAIL_WEIGHT_EXTREMELY_RARE 0.05
#define MAIL_WEIGHT_RARE 0.2
#define MAIL_WEIGHT_UNCOMMON 0.6
#define MAIL_WEIGHT_DEFAULT 1
#define MAIL_WEIGHT_FREQUENT 2

/**
 *
 * РАЗНОЕ
 *
 */

/*
/datum/mail_pattern/misc/
	name = ""
	description = ""

	weight = ""

	letter_title = ""
	letter_html = ""

	initial_contents = list()
*/

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

/datum/mail_pattern/syndie/anecdote/apply(mob/living/carbon/human/recipient)
	if(prob(10))
		letter_html = "<img src='https://vgorode.ua/img/article/12082/19_main-v1654070622.jpg' />"
	else
		letter_html = replacetext(letter_html, "%номер агента%", pick(GLOB.phonetic_alphabet))
		letter_html = replacetext(letter_html, "%кодовые слова%", jointext(GLOB.syndicate_code_phrase, ", "))
	. = ..()

/datum/mail_pattern/syndie/anecdote/on_mail_open(mob/living/carbon/human/recipient)
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
		recipient.dropItemToGround(parent.included_letter)
		to_chat(recipient, span_boldwarning("[parent.included_letter] внезапно загорается!"))

/**
 *
 * ДЕНЕЖКИ
 *
 */

/*
/datum/mail_pattern/money/
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
	name = "Печенья от бабули"
	description = "В названии недостаточно понятно указано?"

	envelope_type = MAIL_TYPE_PACKAGE

	weight = MAIL_WEIGHT_DEFAULT

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
	name = ""
	description = ""

	weight = ""

	letter_title = ""
	letter_html = ""

	initial_contents = list()
*/

#undef MAIL_TYPE_ENVELOPE
#undef MAIL_TYPE_PACKAGE
#undef MAIL_WEIGHT_EXTREMELY_RARE
#undef MAIL_WEIGHT_RARE
#undef MAIL_WEIGHT_UNCOMMON
#undef MAIL_WEIGHT_DEFAULT
#undef MAIL_WEIGHT_FREQUENT
