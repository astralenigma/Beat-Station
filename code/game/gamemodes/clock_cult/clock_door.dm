#define GEAR_SECURE 1 //Construction defines for the pinion airlock
#define GEAR_UNFASTENED 2
#define GEAR_LOOSE 3

//Pinion airlocks: Clockwork doors that only let servants of Ratvar through.
/obj/machinery/door/airlock/clockwork
	name = "pinion airlock"
	desc = "A massive cogwheel set into two heavy slabs of brass."
	icon = 'icons/obj/doors/clockwork/pinion_airlock.dmi'
	var/overlays_file = 'icons/obj/doors/clockwork/overlays.dmi'
	opacity = 1
	hackProof = TRUE
	aiControlDisabled = TRUE
	use_power = FALSE
	var/construction_state = GEAR_SECURE //Pinion airlocks have custom deconstruction

/obj/machinery/door/airlock/clockwork/New()
	..()
	var/turf/T = get_turf(src)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/door, T)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/beam/door, T)

/obj/machinery/door/airlock/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(!attempt_construction(I, user))
		return ..()

/obj/machinery/door/airlock/clockwork/allowed(mob/M)
	if(is_servant_of_ratvar(M))
		return 1
	return 0

/obj/machinery/door/airlock/clockwork/proc/attempt_construction(obj/item/I, mob/living/user)
	if(!I || !user || !user.canUseTopic(src))
		return 0
	if(istype(I, /obj/item/weapon/screwdriver))
		if(construction_state == GEAR_SECURE)
			user.visible_message("<span class='notice'>[user] begins unfastening [src]'s gear...</span>", "<span class='notice'>You begin unfastening [src]'s gear...</span>")
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			if(!do_after(user, 75 / I.toolspeed, target = src))
				return 1 //Returns 1 so as not to have extra interactions with the tools used (i.e. prying open)
			user.visible_message("<span class='notice'>[user] unfastens [src]'s gear!</span>", "<span class='notice'>[src]'s gear shifts slightly with a pop.</span>")
			playsound(src, 'sound/items/Screwdriver2.ogg', 50, 1)
			construction_state = GEAR_UNFASTENED
		else if(construction_state == GEAR_UNFASTENED)
			user.visible_message("<span class='notice'>[user] begins fastening [src]'s gear...</span>", "<span class='notice'>You begin fastening [src]'s gear...</span>")
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			if(!do_after(user, 75 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] fastens [src]'s gear!</span>", "<span class='notice'>[src]'s gear shifts back into place.</span>")
			playsound(src, 'sound/items/Screwdriver2.ogg', 50, 1)
			construction_state = GEAR_SECURE
		else if(construction_state == GEAR_LOOSE)
			user << "<span class='warning'>The gear isn't secure enough to fasten!</span>"
		return 1
	else if(istype(I, /obj/item/weapon/wrench))
		if(construction_state == GEAR_SECURE)
			user << "<span class='warning'>[src] is too tightly secured! Your [I.name] can't get a solid grip!</span>"
			return 0
		else if(construction_state == GEAR_UNFASTENED)
			user.visible_message("<span class='notice'>[user] begins loosening [src]'s gear...</span>", "<span class='notice'>You begin loosening [src]'s gear...</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			if(!do_after(user, 80 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] loosens [src]'s gear!</span>", "<span class='notice'>[src]'s gear pops off and dangles loosely.</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			construction_state = GEAR_LOOSE
		else if(construction_state == GEAR_LOOSE)
			user.visible_message("<span class='notice'>[user] begins tightening [src]'s gear...</span>", "<span class='notice'>You begin tightening [src]'s gear into lace...</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			if(!do_after(user, 80 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] tightens [src]'s gear!</span>", "<span class='notice'>You firmly tighten [src]'s gear into place.</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			construction_state = GEAR_UNFASTENED
		return 1
	else if(istype(I, /obj/item/weapon/crowbar))
		if(construction_state == GEAR_SECURE || construction_state == GEAR_UNFASTENED)
			user << "<span class='warning'>[src]'s gear is too tightly secured! Your [I.name] can't reach under it!</span>"
			return 1
		else if(construction_state == GEAR_LOOSE)
			user.visible_message("<span class='notice'>[user] begins slowly lifting off [src]'s gear...</span>", "<span class='notice'>You slowly begin lifting off [src]'s gear...</span>")
			playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
			if(!do_after(user, 85 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] lifts off [src]'s gear, causing it to fall apart!</span>", "<span class='notice'>You lift off [src]'s gear, causing it to fall \
			apart!</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			new/obj/item/clockwork/component/replicant_alloy(get_turf(src))
			new/obj/item/clockwork/component/replicant_alloy/pinion_lock(get_turf(src))
			qdel(src)
		return 1
	return 0

//Pinion airlocks: Clockwork doors that only let servants of Ratvar through.
/obj/machinery/door/airlock/clockwork
	name = "pinion airlock"
	desc = "A massive cogwheel set into two heavy slabs of brass."
	icon = 'icons/obj/doors/clockwork/pinion_airlock.dmi'
	overlays_file = 'icons/obj/doors/clockwork/overlays.dmi'
	opacity = 1
	hackProof = TRUE
	aiControlDisabled = TRUE
	use_power = FALSE
	var/construction_state = GEAR_SECURE //Pinion airlocks have custom deconstruction

/obj/machinery/door/airlock/clockwork/New()
	..()
	var/turf/T = get_turf(src)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/door, T)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/beam/door, T)

/obj/machinery/door/airlock/clockwork/canAIControl(mob/user)
	return (is_servant_of_ratvar(user) && !isAllPowerCut())

/obj/machinery/door/airlock/clockwork/ratvar_act()
	return 0

/obj/machinery/door/airlock/clockwork/narsie_act()
	..()
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

/obj/machinery/door/airlock/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(!attempt_construction(I, user))
		return ..()

/obj/machinery/door/airlock/clockwork/allowed(mob/M)
	if(is_servant_of_ratvar(M))
		return 1
	return 0

/obj/machinery/door/airlock/clockwork/hasPower()
	return TRUE //yes we do have power

/obj/machinery/door/airlock/clockwork/proc/attempt_construction(obj/item/I, mob/living/user)
	if(!I || !user || !user.canUseTopic(src))
		return 0
	if(istype(I, /obj/item/weapon/screwdriver))
		if(construction_state == GEAR_SECURE)
			user.visible_message("<span class='notice'>[user] begins unfastening [src]'s gear...</span>", "<span class='notice'>You begin unfastening [src]'s gear...</span>")
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			if(!do_after(user, 75 / I.toolspeed, target = src))
				return 1 //Returns 1 so as not to have extra interactions with the tools used (i.e. prying open)
			user.visible_message("<span class='notice'>[user] unfastens [src]'s gear!</span>", "<span class='notice'>[src]'s gear shifts slightly with a pop.</span>")
			playsound(src, 'sound/items/Screwdriver2.ogg', 50, 1)
			construction_state = GEAR_UNFASTENED
		else if(construction_state == GEAR_UNFASTENED)
			user.visible_message("<span class='notice'>[user] begins fastening [src]'s gear...</span>", "<span class='notice'>You begin fastening [src]'s gear...</span>")
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			if(!do_after(user, 75 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] fastens [src]'s gear!</span>", "<span class='notice'>[src]'s gear shifts back into place.</span>")
			playsound(src, 'sound/items/Screwdriver2.ogg', 50, 1)
			construction_state = GEAR_SECURE
		else if(construction_state == GEAR_LOOSE)
			user << "<span class='warning'>The gear isn't secure enough to fasten!</span>"
		return 1
	else if(istype(I, /obj/item/weapon/wrench))
		if(construction_state == GEAR_SECURE)
			user << "<span class='warning'>[src] is too tightly secured! Your [I.name] can't get a solid grip!</span>"
			return 0
		else if(construction_state == GEAR_UNFASTENED)
			user.visible_message("<span class='notice'>[user] begins loosening [src]'s gear...</span>", "<span class='notice'>You begin loosening [src]'s gear...</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			if(!do_after(user, 80 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] loosens [src]'s gear!</span>", "<span class='notice'>[src]'s gear pops off and dangles loosely.</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			construction_state = GEAR_LOOSE
		else if(construction_state == GEAR_LOOSE)
			user.visible_message("<span class='notice'>[user] begins tightening [src]'s gear...</span>", "<span class='notice'>You begin tightening [src]'s gear into place...</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			if(!do_after(user, 80 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] tightens [src]'s gear!</span>", "<span class='notice'>You firmly tighten [src]'s gear into place.</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			construction_state = GEAR_UNFASTENED
		return 1
	else if(istype(I, /obj/item/weapon/crowbar))
		if(construction_state == GEAR_SECURE || construction_state == GEAR_UNFASTENED)
			user << "<span class='warning'>[src]'s gear is too tightly secured! Your [I.name] can't reach under it!</span>"
			return 1
		else if(construction_state == GEAR_LOOSE)
			user.visible_message("<span class='notice'>[user] begins slowly lifting off [src]'s gear...</span>", "<span class='notice'>You slowly begin lifting off [src]'s gear...</span>")
			playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
			if(!do_after(user, 85 / I.toolspeed, target = src))
				return 1
			user.visible_message("<span class='notice'>[user] lifts off [src]'s gear, causing it to fall apart!</span>", "<span class='notice'>You lift off [src]'s gear, causing it to fall \
			apart!</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			new/obj/item/clockwork/alloy_shards(get_turf(src))
			new/obj/item/clockwork/component/vanguard_cogwheel/pinion_lock(get_turf(src))
			qdel(src)
		return 1
	return 0

/obj/machinery/door/airlock/clockwork/brass
	glass = 1
	opacity = 0


#undef GEAR_SECURE
#undef GEAR_UNFASTENED
#undef GEAR_LOOSE