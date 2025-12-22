/**
 *
 * Деплойер - предмет, который распаковывается в машинерию. Возможно, когда-нибудь тут будут новотгшные флатпаки, но
 * этот день не сегодня.
 *
 */

/obj/item/deployer
	name = "Machinery Deployer"
	desc = "This shit was either spawned by badmins or a coder made some shenanigans, Adminhelp please."
	icon = 'modular_bluemoon/icons/obj/deployer.dmi'
	icon_state = "default"
	w_class = WEIGHT_CLASS_HUGE

	var/deployed_type = /obj/machinery/nuclearbomb/beer

	var/deployment_in_progress = FALSE
	var/deployment_time = 1 SECONDS
	var/deployment_cooldown_time = 1 SECONDS
	COOLDOWN_DECLARE(deployment_cooldown)

	/// Как много тайлов должно быть свободно слева от пользователя, чтобы можно было провести развёртывание
	var/left_padding = 0
	/// Как много тайлов должно быть свободно справа от пользователя, чтобы можно было провести развёртывание
	var/right_padding = 0
	/// Как много тайлов должно быть свободно сверху от пользователя, чтобы можно было провести развёртывание
	var/upper_padding = 0
	/// Как много тайлов должно быть свободно снизу от пользователя, чтобы можно было провести развёртывание
	var/lower_padding = 0

/obj/item/deployer/examine(mob/user)
	. = ..()
	. += span_boldnotice("Вы можете развернуть [deployed_type], использовав [src] в руке!")
	. += span_notice("Для успешного развертывания нужно [left_padding] свободных тайла слева, [right_padding] справа, [upper_padding] снизу и [lower_padding] сверху")

/obj/item/deployer/attack_self(mob/user)
	if(deployment_in_progress)
		to_chat(user, span_warning("Развёртывание уже в процессе!"))
		return
	if(!COOLDOWN_FINISHED(src, deployment_cooldown))
		to_chat(user, span_warning("[src] ещё перезаряжается после предыдущей попытки развёртывания!"))
		return
	COOLDOWN_START(src, deployment_cooldown, deployment_cooldown_time)
	deployment_in_progress = TRUE

	var/turf/deployment_turf = get_turf(user)
	if(!isturf(deployment_turf))
		to_chat(user, span_warning("Вы не можете поставить это здесь!"))
		deployment_in_progress = FALSE
		return
	if(!check_paddings(deployment_turf, left_padding, right_padding, upper_padding, lower_padding))
		to_chat(user, span_warning("Вы не можете поставить его здесь!"))
		deployment_in_progress = FALSE
		return

	to_chat(user, span_notice("Вы начинаете развёртывать [src]..."))
	if(!do_after(user, deployment_time, deployment_turf))
		deployment_in_progress = FALSE
		return

	// Те же проверки, что и выше. Ситуация за семь секунд могла смениться
	if(!check_paddings(deployment_turf, left_padding, right_padding, upper_padding, lower_padding))
		to_chat(user, span_warning("Вы не можете поставить его здесь!"))
		deployment_in_progress = FALSE
		return

	visible_message(span_boldnotice("[user] развёртвывает [src]!"))
	var/obj/deployed = new deployed_type(deployment_turf)
	deployed.say("Развёртывание успешно!")
	playsound(deployed, 'sound/machines/ping.ogg', 50, TRUE)
	qdel(src)
	return

/// Проверяет, свободны ли тайлы в прямоугольнике от левого нижнего до правого верхнего
/obj/item/deployer/proc/check_paddings(turf/deployment_turf, left = 0, right = 0, upper = 0, lower = 0)
	var/turf/left_lower_corner = locate(deployment_turf.x - left, deployment_turf.y - lower, deployment_turf.z)
	if(isnull(left_lower_corner))
		return FALSE

	for(var/x = 0; x <= left + right; x++)
		for(var/y = 0; y <= upper + lower; y++)
			var/turf/turf_to_check = locate(left_lower_corner.x + x, left_lower_corner.y + y, left_lower_corner.z)
			if(!check_turf(turf_to_check))
				return FALSE

	return TRUE

/obj/item/deployer/proc/check_turf(turf/turf_to_check)
	if (!isturf(turf_to_check))
		return FALSE
	var/atom/obstacle = find_obstacle_in_turf(turf_to_check, TRUE)
	if(!isnull(obstacle))
		visible_message(span_warning("[obstacle] мешает развёртыванию!"), vision_distance = 1)
		return FALSE
	return TRUE
