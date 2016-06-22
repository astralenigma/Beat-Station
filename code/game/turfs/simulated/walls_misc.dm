/turf/simulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult"
	walltype = "cult"
	canSmoothWith = null

/turf/simulated/wall/cult/narsie_act()
	return

/turf/simulated/wall/rust
	name = "rusted wall"
	desc = "A rusted metal wall."
	icon = 'icons/turf/walls/rusty_wall.dmi'
	icon_state = "arust"
	walltype = "arust"

/turf/simulated/wall/r_wall/rust
	name = "rusted reinforced wall"
	desc = "A huge chunk of rusted reinforced metal."
	icon = 'icons/turf/walls/rusty_reinforced_wall.dmi'
	icon_state = "rrust"
	walltype = "rrust"
	
//Clockwork wall: Causes nearby tinkerer's caches to generate components.
/turf/closed/wall/clockwork
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall"
	canSmoothWith = list(/turf/closed/wall/clockwork)
	smooth = SMOOTH_MORE

/turf/closed/wall/clockwork/New()
	..()
	PoolOrNew(/obj/effect/overlay/temp/ratvar/wall, src)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/beam, src)
	SSobj.processing += src
	clockwork_construction_value += 5

/turf/closed/wall/clockwork/Destroy()
	SSobj.processing -= src
	clockwork_construction_value -= 5
	..()

/turf/closed/wall/clockwork/process()
	if(prob(2))
		playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', rand(1, 5), 1, -4, 1, 1)
	for(var/obj/structure/clockwork/cache/C in range(1, src))
		if(prob(5))
			clockwork_component_cache[pick("belligerent_eye", "vanguard_cogwheel", "guvax_capacitor", "replicant_alloy", "hierophant_ansible")]++
			playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', rand(15, 20), 1, -3, 1, 1)

/turf/closed/wall/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I
		if(!WT.isOn())
			return 0
		user.visible_message("<span class='notice'>[user] begins slowly breaking down [src]...</span>", "<span class='notice'>You begin painstakingly destroying [src]...</span>")
		if(!do_after(user, 120 / WT.toolspeed, target = src))
			return 0
		if(!WT.remove_fuel(1, user))
			return 0
		user.visible_message("<span class='notice'>[user] breaks apart [src]!</span>", "<span class='notice'>You break apart [src]!</span>")
		break_wall()
		return 1
	return ..()

/turf/closed/wall/clockwork/break_wall()
	new/obj/item/clockwork/component/replicant_alloy(get_turf(src))
	return(new /obj/structure/girder(src))

/turf/closed/wall/clockwork/devastate_wall()
	return break_wall()