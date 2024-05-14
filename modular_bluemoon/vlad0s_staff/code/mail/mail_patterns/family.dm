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
		%->Дорогой внучок | Дорогая внучка%-,<br>
		Надеюсь, что это письмо найдет тебя в здравии и хорошем настроении.<br>
		Я знаю, что ты очень занят%%А%% на космической станции, но я все равно нашла время испечь для тебя твои любимые печенья. Ведь как же без них, правда?<br>
		Я помню, как ты всегда любил%%А%% мои печенья, поэтому я не могла упустить возможность порадовать тебя этим вкусным угощением. Надеюсь, что они поднимут тебе настроение и добавят тебе энергии в твоей нелегкой работе.<br>
		Не забывай, что даже на космической станции важно помнить о семье и близких. Желаю тебе успехов во всех твоих начинаниях и не забывай, что я всегда думаю о тебе.
	"}
	letter_sign = "С любовью и теплом, %подпись%"

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
