// Pistol Magazines

/obj/item/ammo_box/magazine/e45/e45_extended
	name = "Extended Enforcer magazine"
	icon = 'modular_splurt/icons/obj/ammo.dmi'
	icon_state = "enforcer-ext"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	desc = "An extended Mk. 58 magazine."
	max_ammo = 12

/obj/item/ammo_box/magazine/e45/e45_extended/update_icon()
	..()
	icon_state = "enforcer-ext-[round(ammo_count())]"

/obj/item/ammo_box/magazine/e45/e45_extended/empty
	name = "Extended Enforcer magazine"
	desc = "An extended Mk. 58 magazine."
	start_empty = 1
