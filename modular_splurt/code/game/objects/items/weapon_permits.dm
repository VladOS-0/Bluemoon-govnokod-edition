// BLUEMOON EDITED - реворк разрешений на оружие

//This'll be used for gun permits, such as for heads of staff, crew, and bartenders. Sec and the Captain do not require these

/obj/item/clothing/accessory/permit
	name = "Weapons permit"
	desc = "A permit for carrying weapons."
	icon = 'modular_splurt/icons/obj/permits.dmi'
	icon_state = "permit"
	mob_overlay_icon = 'icons/mob/clothing/accessories.dmi'
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FIRE_PROOF
	var/access = null
	var/owner = 0	//To prevent people from just renaming the thing if they steal it

/obj/item/clothing/accessory/permit/attack_self(mob/user as mob)
    if(isliving(user))
        if(!owner)
            set_name(user.name)
            to_chat(user, "[src] registers your name.")
            access += list(ACCESS_WEAPONS)
        else
            to_chat(user, "[src] already has an owner!")

/obj/item/clothing/accessory/permit/proc/set_name(new_name)
	owner = 1
	if(new_name)
		src.name += " ([new_name])"
		desc += " It belongs to [new_name]."

/obj/item/clothing/accessory/permit/head
	name = "Heads of staff weapon permit"
	desc = "A card indicating that the Head of staff is allowed to carry a weapon."
	icon_state = "compermit"

/obj/item/clothing/accessory/permit/staff
	name = "Staff weapon permit"
	desc = "A card indicating that the staff is allowed to carry a weapon."
	icon_state = "permit"

/obj/item/clothing/accessory/permit/bar
	name = "bar weapon permit"
	desc = "A card indicating that the barkeep is allowed to carry a weapon, most likely their shotgun."
	icon_state = "permit"

/obj/item/clothing/accessory/permit/guard
	name = "guard weapon permit"
	desc = "A card indicating that the department guard is allowed to carry limited list of non-lethal weapons."
	icon_state = "permit"
