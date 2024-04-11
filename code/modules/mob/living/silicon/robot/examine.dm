/mob/living/silicon/robot/examine(mob/user)
	. = list("<span class='info'>Это [icon2html(src, user)] \a <EM>[src]</EM>, [src.module.name] юнит!")
	if(desc)
		. += "[desc]"

	var/obj/act_module = get_active_held_item()
	if(act_module)
		. += "В его манипуляторах [icon2html(act_module, user)] \a [act_module]."
	var/effects_exam = status_effect_examines()
	if(!isnull(effects_exam))
		. += effects_exam
	if (getBruteLoss())
		if (getBruteLoss() < maxHealth*0.5)
			. += "<span class='warning'>Он выглядит слегка повреждённым.</span>"
		else
			. += "<span class='warning'><B>Он сильно повреждён!</B></span>"
	if (getFireLoss() || getToxLoss())
		var/overall_fireloss = getFireLoss() + getToxLoss()
		if (overall_fireloss < maxHealth * 0.5)
			. += "<span class='warning'>Он выглядит слегка обгоревшим.</span>"
		else
			. += "<span class='warning'><B>Он сильно обгорел!</B></span>"
	if (health < -maxHealth*0.5)
		. += "<span class='warning'>Он вот-вот отключится.</span>"
	if (fire_stacks < 0)
		. += "<span class='warning'>Он вымок в воде.</span>"
	else if (fire_stacks > 0)
		. += "<span class='warning'>Он покрыт чем-то горючим.</span>"

	if(opened)
		. += "<span class='warning'>Люк техобслуживания открыт, [cell ? "вы видите [icon2html(cell, user)] [cell] внутри " : "батарея отсутствует"].</span>"
	else
		. += "Люк техобслуживания закрыт[locked ? "" : ", однако разблокирован"]."

	if(cell && cell.charge <= 0)
		. += "<span class='warning'>Индикатор батареи горит красным!</span>"

	if(is_servant_of_ratvar(src) && get_dist(user, src) <= 1 && !stat) //To counter pseudo-stealth by using headlamps
		. += "<span class='warning'>Его дисплей горит ярко-жёлтым цветом!</span>"

	switch(stat)
		if(CONSCIOUS)
			if(shell)
				. += "Видимо, это [deployed ? "активная" : "пустая"] оболочка ИИ."
			else if(!client)
				. += "Он в спящем режиме." //afk
		if(UNCONSCIOUS)
			. += "<span class='warning'>Похоже, он временно отключён.</span>"
		if(DEAD)
			. += "<span class='deadsay'>Система критически повреждена. Требуется перезагрузка.</span>"

	if(LAZYLEN(.) > 1)
		.[2] = "<hr>[.[2]]"

	. += span_boldnotice("<br>Профиль киборга: <a href='?src=\ref[src];cyborg_profile=1'>\[Осмотреть\]</a><br>")
	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, usr, .)

	if(tempflavor)
		. += span_notice(tempflavor)

	if(length(.) > 1)
		.[1] += "<br>"

	. += "</span>"

	. += ..()
