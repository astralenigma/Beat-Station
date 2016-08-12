/obj/machinery/verdict_render
	name = "verdict render"
	desc = "Strike this to render a verdict in a trial."
	icon = 'icons/obj/objects.dmi'
	icon_state = "render"

	var/console_tag
	var/obj/machinery/computer/sentencing/console

/obj/machinery/verdict_render/New()
	..()

	spawn( 10 )
		if( console_tag )
			console = locate( console_tag )

/obj/machinery/verdict_render/attackby( obj/item/weapon/gavel/O as obj, user as mob)
	if( console && istype( O ))
		if( console.incident )
			console.render_verdict( user )
			playsound(get_turf( src ), 'sound/items/gavel.ogg', 50, 1)
		else
			user << "<span class='alert'>There is no active trial!</span>"
		return

	..()

/obj/machinery/verdict_render/courtroom
	console_tag = "sentencing_courtroom"
