/**
 * Механика, введённая для того, чтобы краши сервера не вызывали бесконечные форсы одного и того же режима и карты.
 * Теперь если раунд продлился более двух часов, карта и режим будут записаны в SSPersistance.
 */

GLOBAL_VAR_INIT(midround_recorded, FALSE)

#define MIDROUND_RECORD_TIMEOUT 72000 // Два часа

/datum/controller/subsystem/ticker/proc/midround_record_check()
	if(GLOB.midround_recorded)
		return
	if(world.time < (SSautotransfer.starttime + MIDROUND_RECORD_TIMEOUT))
		return
	SSpersistence.RecordDynamicType()
	SSpersistence.RecordMaps()
	SSpersistence.CollectRoundtype(FALSE)
	GLOB.midround_recorded = TRUE
	var/message = "Часы пробили дважды."
	message += " [SSmapping.config.map_name] отжила своё."
	var/combo = SSvote.check_combo()
	if(combo == "dynamic")
		message += " Экста грядёт..."
	else if (combo == "Extended")
		message += " Динамик грядёт..."
	to_chat(world, span_boldwarning(message))
	message_admins("Мидраундовая запись режима и карты произведена.")
