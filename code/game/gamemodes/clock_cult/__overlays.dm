/obj/effect/overlay/temp/ratvar
	name = "ratvar's light"
	duration = 8
	randomdir = 0
	layer = ABOVE_NORMAL_TURF_LAYER

/obj/effect/overlay/temp/ratvar/door
	icon_state = "ratvardoorglow"
	layer = CLOSED_FIREDOOR_LAYER //above closed doors

/obj/effect/overlay/temp/ratvar/door/window
	icon_state = "ratvarwindoorglow"

/obj/effect/overlay/temp/ratvar/beam
	icon_state = "ratvarbeamglow"

/obj/effect/overlay/temp/ratvar/beam/door
	layer = CLOSED_FIREDOOR_LAYER //above closed doors

/obj/effect/overlay/temp/ratvar/beam/grille
	layer = LOW_ITEM_LAYER //above grilles

/obj/effect/overlay/temp/ratvar/beam/itemconsume
	layer = HIGH_OBJ_LAYER

/obj/effect/overlay/temp/ratvar/wall
	icon_state = "ratvarwallglow"

/obj/effect/overlay/temp/ratvar/floor
	icon_state = "ratvarfloorglow"

/obj/effect/overlay/temp/ratvar/window
	icon_state = "ratvarwindowglow"
	layer = ABOVE_WINDOW_LAYER //above windows

/obj/effect/overlay/temp/ratvar/grille
	icon_state = "ratvargrilleglow"
	layer = LOW_ITEM_LAYER //above grilles

/obj/effect/overlay/temp/ratvar/grille/broken
	icon_state = "ratvarbrokengrilleglow"

/obj/effect/overlay/temp/ratvar/window/single
	icon_state = "ratvarwindowglow_s"

/obj/effect/overlay/temp/ratvar/spearbreak
	icon = 'icons/effects/64x64.dmi'
	icon_state = "ratvarspearbreak"
	layer = BELOW_MOB_LAYER
	pixel_y = -16
	pixel_x = -16

/obj/effect/overlay/temp/ratvar/sigil
	name = "glowing circle"
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "sigildull"

/obj/effect/overlay/temp/ratvar/sigil/transgression
	color = "#FAE48C"
	layer = ABOVE_MOB_LAYER
	duration = 50

/obj/effect/overlay/temp/ratvar/sigil/transgression/New()
	..()
	var/oldtransform = transform
	animate(src, transform = matrix()*2, time = 5)
	animate(transform = oldtransform, alpha = 0, time = 45)

/obj/effect/overlay/temp/ratvar/sigil/vitality
	color = "#1E8CE1"
	icon_state = "sigilactivepulse"
	layer = BELOW_MOB_LAYER

/obj/effect/overlay/temp/ratvar/sigil/accession
	color = "#AF0AAF"
	layer = ABOVE_MOB_LAYER
	duration = 50
	icon_state = "sigilactiveoverlay"
	alpha = 0
