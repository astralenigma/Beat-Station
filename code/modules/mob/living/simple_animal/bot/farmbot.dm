#define FARMBOT_COLLECT 1
#define FARMBOT_WATER 2
#define FARMBOT_UPROOT 3
#define FARMBOT_NUTRIMENT 4

/mob/living/simple_animal/bot/farmbot
	name = "Farmbot"
	desc = "The botanist's best friend."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "farmbot0"
	health = 50
	maxHealth = 50
	var/action = "" // Used to update icon
	var/waters_trays = 1
	var/refills_water = 1
	var/uproots_weeds = 1
	var/replaces_nutriment = 0
	var/collects_produce = 0
	var/removes_dead = 0

	var/obj/structure/reagent_dispensers/watertank/tank

	var/attacking = 0
	var/atom/target

/mob/living/simple_animal/bot/farmbot/New()
	..()
	spawn(5)
		tank = locate() in contents
		if(!tank)
			tank = new /obj/structure/reagent_dispensers/watertank(src)

	var/datum/job/roboticist/R = new/datum/job/roboticist
	var/datum/job/hydro/H = new/datum/job/hydro
	access_card.access += R.get_access()
	access_card.access += H.get_access()
	prev_access = access_card.access

/mob/living/simple_animal/bot/farmbot/attack_hand(var/mob/user as mob)
	. = ..()
	if(.)
		return
	var/dat = ""
	dat += "<TT><B>Automatic Hyrdoponic Assisting Unit v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Water Tank: "
	if (tank)
		dat += "[tank.reagents.total_volume]/[tank.reagents.maximum_volume]"
	else
		dat += "Error: Watertank not found"
	dat += "<br>Behaviour controls are [locked ? "locked" : "unlocked"]<hr>"
	if(!locked)
		dat += "<TT>Watering controls:<br>"
		dat += "Water plants : <A href='?src=\ref[src];water=1'>[waters_trays ? "Yes" : "No"]</A><BR>"
		dat += "Refill watertank : <A href='?src=\ref[src];refill=1'>[refills_water ? "Yes" : "No"]</A><BR>"
		dat += "<br>Weeding controls:<br>"
		dat += "Weed plants: <A href='?src=\ref[src];weed=1'>[uproots_weeds ? "Yes" : "No"]</A><BR>"
		dat += "<br>Nutriment controls:<br>"
		dat += "Replace fertilizer: <A href='?src=\ref[src];replacenutri=1'>[replaces_nutriment ? "Yes" : "No"]</A><BR>"
		dat += "<br>Plant controls:<br>"
		dat += "Collect produce: <A href='?src=\ref[src];collect=1'>[collects_produce ? "Yes" : "No"]</A><BR>"
		dat += "Remove dead plants: <A href='?src=\ref[src];removedead=1'>[removes_dead ? "Yes" : "No"]</A><BR>"
		dat += "</TT>"

	user << browse("<HEAD><TITLE>Farmbot v1.0 controls</TITLE></HEAD>[dat]", "window=autofarm")
	onclose(user, "autofarm")
	return

/mob/living/simple_animal/bot/farmbot/emag_act(var/remaining_charges, var/mob/user)
	. = ..()
	if(!emagged)
		if(user)
			to_chat(user, "<span class='notice'>You short out [src]'s plant identifier circuits.</span>")
		spawn(rand(30, 50))
			visible_message("<span class='warning'>[src] buzzes oddly.</span>")
			emagged = 1
		return 1

/mob/living/simple_animal/bot/farmbot/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	add_fingerprint(usr)
	if((href_list["power"]) && (access_scanner.allowed(usr)))
		if(on)
			turn_off()
		else
			turn_on()

	if(locked)
		return

	if(href_list["water"])
		waters_trays = !waters_trays
	else if(href_list["refill"])
		refills_water = !refills_water
	else if(href_list["weed"])
		uproots_weeds = !uproots_weeds
	else if(href_list["replacenutri"])
		replaces_nutriment = !replaces_nutriment
	else if(href_list["collect"])
		collects_produce = !collects_produce
	else if(href_list["removedead"])
		removes_dead = !removes_dead

	attack_hand(usr)
	return

/mob/living/simple_animal/bot/farmbot/update_icons()
	if(on && action)
		icon_state = "farmbot_[action]"
	else
		icon_state = "farmbot[on]"

/mob/living/simple_animal/bot/farmbot/Life()
	..()
	if(!on)
		return
	if(emagged && prob(1))
		flick("farmbot_broke", src)
	if(client)
		return

	if(target)
		if(Adjacent(target))
			UnarmedAttack(target)
			path = list()
			target = null
		else
			if(path.len && frustration < 5)
				if(path[1] == loc)
					path -= path[1]
				var/t = step_towards(src, path[1])
				if(t)
					path -= path[1]
				else
					++frustration
			else
				path = list()
				target = null
	else
		if(emagged)
			for(var/mob/living/carbon/human/H in view(7, src))
				target = H
				break
		else
			for(var/obj/machinery/portable_atmospherics/hydroponics/tray in view(7, src))
				if(process_tray(tray))
					target = tray
					frustration = 0
					break
			if(!target && refills_water && tank && tank.reagents.total_volume < tank.reagents.maximum_volume)
				for(var/obj/structure/sink/source in view(7, src))
					target = source
					frustration = 0
					break
		if(target)
			var/t = get_dir(target, src) // Turf with the tray is impassable, so a* can't navigate directly to it
			path = AStar(loc, get_step(target, t), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 30, id = botcard)
			if(!path)
				path = list()

/mob/living/simple_animal/bot/farmbot/UnarmedAttack(var/atom/A, var/proximity)
	if(!..())
		return
	if(attacking)
		return

	if(istype(A, /obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/T = A
		var/t = process_tray(T)
		switch(t)
			if(0)
				return
			if(FARMBOT_COLLECT)
				action = "water" // Needs a better one
				update_icons()
				visible_message("<span class='notice'>[src] starts [T.dead? "removing the plant from" : "harvesting"] \the [A].</span>")
				attacking = 1
				if(do_after(src, 30, A))
					visible_message("<span class='notice'>[src] [T.dead? "removes the plant from" : "harvests"] \the [A].</span>")
					T.attack_hand(src)
			if(FARMBOT_WATER)
				action = "water"
				update_icons()
				visible_message("<span class='notice'>[src] starts watering \the [A].</span>")
				attacking = 1
				if(do_after(src, 30, A))
					playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
					visible_message("<span class='notice'>[src] waters \the [A].</span>")
					tank.reagents.trans_to(T, 100 - T.waterlevel)
			if(FARMBOT_UPROOT)
				action = "hoe"
				update_icons()
				visible_message("<span class='notice'>[src] starts uprooting the weeds in \the [A].</span>")
				attacking = 1
				if(do_after(src, 30, A))
					visible_message("<span class='notice'>[src] uproots the weeds in \the [A].</span>")
					T.weedlevel = 0
			if(FARMBOT_NUTRIMENT)
				action = "fertile"
				update_icons()
				visible_message("<span class='notice'>[src] starts fertilizing \the [A].</span>")
				attacking = 1
				if(do_after(src, 30, A))
					visible_message("<span class='notice'>[src] fertilizes \the [A].</span>")
					T.reagents.add_reagent("ammonia", 10)
		attacking = 0
		action = ""
		update_icons()
		T.update_icon()
	else if(istype(A, /obj/structure/sink))
		if(!tank || tank.reagents.total_volume >= tank.reagents.maximum_volume)
			return
		action = "water"
		update_icons()
		visible_message("<span class='notice'>[src] starts refilling its tank from \the [A].</span>")
		attacking = 1
		while(do_after(src, 10) && tank.reagents.total_volume < tank.reagents.maximum_volume)
			tank.reagents.add_reagent("water", 10)
			if(prob(5))
				playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		attacking = 0
		action = ""
		update_icons()
		visible_message("<span class='notice'>[src] finishes refilling its tank.</span>")
	else if(emagged && ishuman(A))
		var/action = pick("weed", "water")
		attacking = 1
		spawn(50) // Some delay
			attacking = 0
		switch(action)
			if("weed")
				flick("farmbot_hoe", src)
				do_attack_animation(A)
				if(prob(50))
					visible_message("<span class='danger'>[src] swings wildly at [A] with a minihoe, missing completely!</span>")
					return
				var/t = pick("slashed", "sliced", "cut", "clawed")
				A.attack_generic(src, 5, t)
			if("water")
				flick("farmbot_water", src)
				visible_message("<span class='danger'>[src] splashes [A] with water!</span>") // That's it. RP effect.

/mob/living/simple_animal/bot/farmbot/explode()
	visible_message("<span class='danger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/minihoe(Tsec)
	new /obj/item/weapon/reagent_containers/glass/bucket(Tsec)
	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/device/analyzer/plant_analyzer(Tsec)

	if(tank)
		tank.loc = Tsec

	if(prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return

/mob/living/simple_animal/bot/farmbot/proc/process_tray(var/obj/machinery/portable_atmospherics/hydroponics/tray)
	if(!tray || !istype(tray))
		return 0

	if(tray.closed_system || !tray.seed)
		return 0

	if(tray.dead && removes_dead || tray.harvest && collects_produce)
		return FARMBOT_COLLECT

	else if(refills_water && tray.waterlevel < 40 && !tray.reagents.has_reagent("water"))
		return FARMBOT_WATER

	else if(uproots_weeds && tray.weedlevel > 3)
		return FARMBOT_UPROOT

	else if(replaces_nutriment && tray.nutrilevel < 1 && tray.reagents.total_volume < 1)
		return FARMBOT_NUTRIMENT

	return 0