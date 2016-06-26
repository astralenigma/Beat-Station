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

/obj/effect/overlay/temp/heal //color is white by default, set to whatever is needed
	name = "healing glow"
	icon_state = "heal"
	duration = 15

/obj/effect/overlay/temp/heal/New(loc, colour)
	..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-9, 0)
	if(colour)
		color = colour

/obj/effect/overlay/temp/bloodsplatter
	icon = 'icons/effects/blood.dmi'
	duration = 5
	randomdir = FALSE
	layer = BELOW_MOB_LAYER

/obj/effect/overlay/temp/bloodsplatter/New(loc, set_dir)
	if(set_dir in diagonals)
		icon_state = "splatter[pick(1, 2, 6)]"
	else
		icon_state = "splatter[pick(3, 4, 5)]"
	..()
	var/target_pixel_x = 0
	var/target_pixel_y = 0
	switch(set_dir)
		if(NORTH)
			target_pixel_y = 16
		if(SOUTH)
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(EAST)
			target_pixel_x = 16
		if(WEST)
			target_pixel_x = -16
		if(NORTHEAST)
			target_pixel_x = 16
			target_pixel_y = 16
		if(NORTHWEST)
			target_pixel_x = -16
			target_pixel_y = 16
		if(SOUTHEAST)
			target_pixel_x = 16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(SOUTHWEST)
			target_pixel_x = -16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
	setDir(set_dir)
	animate(src, pixel_x = target_pixel_x, pixel_y = target_pixel_y, alpha = 0, time = duration)

