/turf/simulated/floor/vault
	icon = 'icons/turf/floors.dmi'
	icon_state = "rockvault"
	smooth = SMOOTH_FALSE

/turf/simulated/floor/vault/New(location, vtype)
	..()
	icon_state = "[vtype]vault"

/turf/simulated/wall/vault
	icon = 'icons/turf/walls.dmi'
	icon_state = "rockvault"
	smooth = SMOOTH_FALSE

/turf/simulated/wall/vault/New(location, vtype)
	..()
	icon_state = "[vtype]vault"

/turf/simulated/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/simulated/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"

/turf/simulated/floor/greengrid/airless
	icon_state = "gcircuit"
	name = "airless floor"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/greengrid/airless/New()
	..()
	name = "floor"

/turf/simulated/floor/beach
	name = "beach"
	icon = 'icons/misc/beach.dmi'

/turf/simulated/floor/beach/sand
	name = "sand"
	icon_state = "sand"

/turf/simulated/floor/beach/coastline
	name = "coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/simulated/floor/beach/water
	name = "water"
	icon_state = "water"

/turf/simulated/floor/beach/water/New()
	..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=MOB_LAYER+0.1)

/turf/simulated/floor/noslip
	name = "high-traction floor"
	icon_state = "noslip"
	floor_tile = /obj/item/stack/tile/noslip
	broken_states = list("noslip-damaged1","noslip-damaged2","noslip-damaged3")
	burnt_states = list("noslip-scorched1","noslip-scorched2")
	slowdown = -0.3

/turf/simulated/floor/noslip/MakeSlippery()
	return

/turf/simulated/floor/silent
	name = "silent floor"
	icon_state = "silent"
	floor_tile = /obj/item/stack/tile/silent
	shoe_running_volume = 0
	shoe_walking_volume = 0
	
//Clockwork floor: Slowly heals conventional damage on nearby servants.
/turf/open/floor/clockwork
	name = "clockwork floor"
	desc = "Tightly-pressed brass tiles. They emit minute vibration."
	icon = 'icons/turf/floors.dmi'
	icon_state = "clockwork_floor"

/turf/open/floor/clockwork/New()
	..()
	PoolOrNew(/obj/effect/overlay/temp/ratvar/floor, src)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/beam, src)
	SSobj.processing += src
	clockwork_construction_value++

/turf/open/floor/clockwork/Destroy()
	SSobj.processing -= src
	clockwork_construction_value--
	..()

/turf/open/floor/clockwork/process()
	for(var/mob/living/L in src)
		if(L.stat == DEAD || !is_servant_of_ratvar(L))
			continue
		L.adjustBruteLoss(-1)
		L.adjustFireLoss(-1)

/turf/open/floor/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/crowbar))
		user.visible_message("<span class='notice'>[user] begins slowly prying up [src]...</span>", "<span class='notice'>You begin painstakingly prying up [src]...</span>")
		if(!do_after(user, 70 / I.toolspeed, target = src))
			return 0
		user.visible_message("<span class='notice'>[user] pries up [src]!</span>", "<span class='notice'>You pry up [src], destroying it!</span>")
		make_plating()
		return 1
	return ..()