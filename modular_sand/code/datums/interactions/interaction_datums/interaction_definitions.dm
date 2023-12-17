/datum/interaction/handshake
	description = "Пожать руку."
	simple_message = "USER пожимает руку TARGET."
	interaction_sound = 'sound/weapons/thudswoosh.ogg'
	required_from_user = INTERACTION_REQUIRE_HANDS
	required_from_target = INTERACTION_REQUIRE_HANDS

/datum/interaction/pat
	description = "Похлопать по плечу."
	simple_message = "USER хлопает по плечу TARGET."
	interaction_sound = 'sound/weapons/thudswoosh.ogg'
	required_from_user = INTERACTION_REQUIRE_HANDS

/datum/interaction/headpat
	description = "Погладить по голове."
	simple_message = "USER гладит TARGET по макушке головы!"
	interaction_sound = 'sound/weapons/thudswoosh.ogg'
	required_from_user = INTERACTION_REQUIRE_HANDS

/datum/interaction/cheer
	description = "Подбодрить."
	simple_message = "USER подбадривает TARGET!"
	interaction_sound = 'sound/weapons/thudswoosh.ogg'
	required_from_user = INTERACTION_REQUIRE_MOUTH
	interaction_flags = NONE

/datum/interaction/highfive
	description = "Дать пять!"
	simple_message = "USER даёт пять TARGET!"
	interaction_sound = 'modular_sand/sound/interactions/slap.ogg'
	required_from_user = INTERACTION_REQUIRE_HANDS
	required_from_target = INTERACTION_REQUIRE_HANDS

/datum/interaction/salute
	description = "Исполнить Воинское Приветствие!"
	simple_message = "USER исполняет воинское приветствие при виде TARGET!"
	interaction_sound = 'sound/voice/salute.ogg'
	required_from_user = INTERACTION_REQUIRE_HANDS
	interaction_flags = NONE
	max_distance = 25

/datum/interaction/fistbump
	description = "Удариться кулачками!"
	simple_message = "USER бьётся кулачком о кулачок TARGET! О да!"
	interaction_sound = 'sound/weapons/thudswoosh.ogg'
	required_from_user = INTERACTION_REQUIRE_HANDS
	required_from_target = INTERACTION_REQUIRE_HANDS

/datum/interaction/pinkypromise
	description = "Пообещать что-то на мизинчиках."
	simple_message = "USER хватается своим мизинчиком за мизинчик TARGET! Клятва Мизинчиками! Давно пора!"
	interaction_sound = 'sound/weapons/thudswoosh.ogg'
	required_from_user = INTERACTION_REQUIRE_HANDS
	required_from_target = INTERACTION_REQUIRE_HANDS

/datum/interaction/bird
	description = "Показать Средний Палец"
	simple_message = "USER демонстрирует TARGET средний палец! Туда его!!"
	interaction_sound = 'sound/weapons/thudswoosh.ogg'
	required_from_user = INTERACTION_REQUIRE_HANDS
	max_distance = 25
	interaction_flags = NONE

/datum/interaction/holdhand
	description = "Взяться за руку."
	simple_message = "USER хватается за руку TARGET."
	interaction_sound = 'sound/weapons/thudswoosh.ogg'
	required_from_user = INTERACTION_REQUIRE_HANDS
	required_from_target = INTERACTION_REQUIRE_HANDS
