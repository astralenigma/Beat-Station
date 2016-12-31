var/global/datum/global_init/init = new ()

/*
	Pre-map initialization stuff should go here.
*/
/datum/global_init/New()

	makeDatumRefLists()
	load_configuration()

	del(src)

/world
	mob = /mob/new_player
	turf = /turf/space
	area = /area/space
	view = "15x15"
	cache_lifespan = 0	//stops player uploaded stuff from being kept in the rsc past the current session


#define RECOMMENDED_VERSION 510

/world/New()
	//logs
	var/date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")
	href_logfile = file("data/logs/[date_string] hrefs.htm")
	diary = file("data/logs/[date_string].log")
	diaryofmeanpeople = file("data/logs/[date_string] Attack.log")
	diary << "\n\nStarting up. [time2text(world.timeofday, "hh:mm.ss")]\n---------------------"
	diaryofmeanpeople << "\n\nStarting up. [time2text(world.timeofday, "hh:mm.ss")]\n---------------------"

	if(byond_version < RECOMMENDED_VERSION)
		log_to_dd("Your server's byond version does not meet the recommended requirements for this code. Please update BYOND")

	if(config && config.log_runtimes)
		log = file("data/logs/runtime/[time2text(world.realtime,"YYYY-MM-DD-(hh-mm-ss)")]-runtime.log")

	SetupHooks() // /vg/

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	timezoneOffset = text2num(time2text(0,"hh")) * 36000

	callHook("startup")

	src.update_status()

	. = ..()

	plant_controller = new()
	// Create robolimbs for chargen.
	populate_robolimb_list()

	setup_map_transitions() //Before the MC starts up

	processScheduler = new
	master_controller = new /datum/controller/game_controller()
	spawn(1)
		processScheduler.deferSetupFor(/datum/controller/process/ticker)
		processScheduler.setup()

		master_controller.setup()
		getFormsFromWiki()
		sleep_offline = 1

	#ifdef MAP_NAME
	map_name = "[MAP_NAME]"
	#else
	map_name = "Unknown"
	#endif
/*
This is for shitty brazilian hosts that abuse their admin powers and barely enforce any rules whatsoever.
If you can read this line and understand it, you probably aren't brazilian.
If so, feel free to comment the code out.
Also: Most people don't check the source before compiling,
so if you plan on customizing the code and making it hostable only by yourself; change "Nopm" to your key.
*/
	log_to_dd("Checking host...")
	sleep(5) //To stop the logs from glitching
	if(config.hostedby != "Nopm")
		log_to_dd("The server host is probably shitty")
		log_to_dd("Rebooting...")
		Reboot(1)
	else if(config.hostedby == "Nopm" && host != "Nopm")
		log_to_dd("The server host is probably shitty.")
		log_to_dd("Rebooting...")
		Reboot(1)
	else if(system_type == UNIX && config.hostedby == "Nopm" && config.simple_password == "Imnotshitty")
		log_to_dd("The host isn't shitty.")
		log_to_dd("Continuing initialization...")



#undef RECOMMENDED_VERSION

	return

//world/Topic(href, href_list[])
//		to_chat(world, "Received a Topic() call!")
//		to_chat(world, "[href]")
//		for(var/a in href_list)
//			to_chat(world, "[a]")
//		if(href_list["hello"])
//			to_chat(world, "Hello world!")
//			return "Hello world!"
//		to_chat(world, "End of Topic() call.")
//		..()

var/world_topic_spam_protect_ip = "0.0.0.0"
var/world_topic_spam_protect_time = world.timeofday

/world/Topic(T, addr, master, key)
	var/list/players = list()
	var/list/admins = list()

	for(var/client/C in clients)
		if(C.holder) // BB doesn't show up at all
			if(C.holder.big_brother)
				continue
			admins += C.ckey
		players += C.ckey

	diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]"

	var/list/input = params2list(T)
	var/key_valid = (config.comms_password && input["key"] == config.comms_password) //no password means no comms, not any password

	if("ping" in input)
		var/x = 0
		for(var/client/C)
			x++
		return x

	else if("players" in input)
		return players.len

	else if ("admins" in input)
		return admins.len

	else if ("gamemode" in input)
		return master_mode

	else if ("status" in input)
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["stationtime"] = worldtime2text()
		s["players"] = players.len
		s["admins"] = admins.len
		s["map_name"] = map_name ? map_name : "Unknown"

		if(key_valid)
			if(ticker && ticker.mode)
				s["real_mode"] = ticker.mode.name

			s["security_level"] = get_security_level()

			if(shuttle_master && shuttle_master.emergency)
				// Shuttle status, see /__DEFINES/stat.dm
				s["shuttle_mode"] = shuttle_master.emergency.mode
				// Shuttle timer, in seconds
				s["shuttle_timer"] = shuttle_master.emergency.timeLeft()

			for(var/i=1, i <= admins.len, i++)
				var/client/C = admins[i]
				s["admin[i - 1]"] = list()
				s["admin[i - 1]"]["ckey"] = C.ckey
				s["admin[i - 1]"]["rank"] = C.holder.rank
				s["admin[i - 1]"] = list2params(s["admin[i - 1]"])

		return list2params(s)

	else if("manifest" in input)
		if (!ticker)
			return "Game not started yet!"

		var/list/positions = list()
		var/list/set_names = list(
				"heads" = command_positions,
				"sec" = security_positions,
				"eng" = engineering_positions,
				"med" = medical_positions,
				"sci" = science_positions,
				"civ" = civilian_positions,
				"bot" = nonhuman_positions
			)

		for(var/datum/data/record/t in data_core.general)
			var/name = t.fields["name"]
			var/rank = t.fields["rank"]
			var/real_rank = t.fields["real_rank"]

			var/department = 0
			for(var/k in set_names)
				if(real_rank in set_names[k])
					if(!positions[k])
						positions[k] = list()
					positions[k][name] = rank
					department = 1
			if(!department)
				if(!positions["misc"])
					positions["misc"] = list()
				positions["misc"][name] = rank

		for(var/k in positions)
			positions[k] = list2params(positions[k]) // converts positions["heads"] = list("Bob"="Captain", "Bill"="CMO") into positions["heads"] = "Bob=Captain&Bill=CMO"

		return list2params(positions)

	else if("mute" in input)
		if(!key_valid)
			return keySpamProtect(addr)

		for (var/client/C in clients)
			if (C.ckey == ckey(input["mute"]))
				C.mute_discord = !C.mute_discord

				switch (C.mute_discord)
					if (1)
						to_chat(C, "<b><font color='red'>You have been muted from replying to Discord PMs by [input["admin"]]!</font></b>")
						log_and_message_admins("[C] has been muted from Discord PMs by [input["admin"]].")
						return "[C.key] is now muted from replying to Discord PMs."
					if (0)
						to_chat(C, "<b><font color='red'>You have been unmuted from replying to Discord PMs by [input["admin"]]!</font></b>")
						log_and_message_admins("[C] has been unmuted from Discord PMs by [input["admin"]].")
						return "[C.key] is now unmuted from replying to Discord PMs."

		return "couldn't find that ckey!"

	else if("adminmsg" in input)
		/*
			We got an adminmsg from IRC bot lets split the input then validate the input.
			expected output:
				1. adminmsg = ckey of person the message is to
				2. msg = contents of message, parems2list requires
				3. validatationkey = the key the bot has, it should match the gameservers commspassword in it's configuration.
				4. sender = the ircnick that send the message.
		*/
		if(!key_valid)
			return keySpamProtect(addr)

		var/client/C

		for(var/client/K in clients)
			if(K.ckey == input["adminmsg"])
				C = K
				break
		if(!C)
			return "no client with that name on server!"

		var/message =	"<font color='red'>Discord-Admin PM from <b><a href='?discord_msg=[input["sender"]]'>[C.holder ? "Discord-" + input["sender"] : "Administrator"]</a></b>: [input["msg"]]</font>"
		var/amessage =  "<font color='blue'>Discord-Admin PM from <a href='?discord_msg=[input["sender"]]'>Discord-[input["sender"]]</a> to <b>[key_name(C)]</b> : [input["msg"]]</font>"

		C.received_discord_pm = world.time
		C.discord_admin = input["sender"]

		C << 'sound/effects/adminhelp.ogg'
		to_chat(C, message)

		for(var/client/A in admins)
			if(A != C)
				to_chat(A, amessage)

		return "message successfully sent!"

	else if("notes" in input)
		/*
			We got a request for notes from the IRC Bot
			expected output:
				1. notes = ckey of person the notes lookup is for
				2. validationkey = the key the bot has, it should match the gameservers commspassword in it's configuration.
		*/
		if(!key_valid)
			return keySpamProtect(addr)

		return show_player_info_irc(input["notes"])

	else if ("announce" in input)
		if(!key_valid)
			return keySpamProtect(addr)
		var/message = replacetext(input["msg"], "\n", "<br>")
		for(var/client/C in clients)
			to_chat(C, "<span class='announce'>Announces via Discord: [message]</span>")
		return "announcement successfully sent!"

	else if ("who" in input)
		return list2params(players)

	else if ("adminwho" in input)
		return list2params(admins)

/proc/do_topic_spam_protection(var/addr, var/key)
	if (!config.comms_password || config.comms_password == "")
		return "No comms password configured, aborting."

	if (key == config.comms_password)
		return 0
	else
		if (world_topic_spam_protect_ip == addr && abs(world_topic_spam_protect_time - world.time) < 50)

			spawn(50)
				world_topic_spam_protect_time = world.time
				return "Bad Key (Throttled)"

		world_topic_spam_protect_time = world.time
		world_topic_spam_protect_ip = addr

		return "Bad Key"

/proc/keySpamProtect(var/addr)
	if(world_topic_spam_protect_ip == addr && abs(world_topic_spam_protect_time - world.time) < 50)
		spawn(50)
			world_topic_spam_protect_time = world.time
			return "Bad Key (Throttled)"

	world_topic_spam_protect_time = world.time
	world_topic_spam_protect_ip = addr
	return "Bad Key"

/world/Reboot(var/reason, var/feedback_c, var/feedback_r, var/time)
	if (reason == 1) //special reboot, do none of the normal stuff
		if(usr)
			message_admins("[key_name_admin(usr)] has requested an immediate world restart via client side debugging tools")
			log_admin("[key_name(usr)] has requested an immediate world restart via client side debugging tools")
		spawn(0)
			to_chat(world, "<span class='boldannounce'>Rebooting world immediately due to host request</span>")
		return ..(1)
	var/delay
	if(!isnull(time))
		delay = max(0,time)
	else
		delay = ticker.restart_timeout
	if(ticker.delay_end)
		to_chat(world, "<span class='boldannounce'>An admin has delayed the round end.</span>")
		return
	to_chat(world, "<span class='boldannounce'>Rebooting world in [delay/10] [delay > 10 ? "seconds" : "second"]. [reason]</span>")
	send_to_info_discord("Rebooting world in [delay/10] [delay > 10 ? "seconds" : "second"]. [reason]")
	sleep(delay)
	if(blackbox)
		blackbox.save_all_data_to_sql()
	if(ticker.delay_end)
		to_chat(world, "<span class='boldannounce'>Reboot was cancelled by an admin.</span>")
		send_to_info_discord("Reboot was cancelled by an admin.")
		return
	feedback_set_details("[feedback_c]","[feedback_r]")
	log_game("<span class='boldannounce'>Rebooting world. [reason]</span>")
	send_to_info_discord("Rebooting world.")
	//kick_clients_in_lobby("<span class='boldannounce'>The round came to an end with you in the lobby.</span>", 1)

	spawn(0)
		world << sound(pick('sound/AI/newroundsexy.ogg','sound/misc/apcdestroyed.ogg','sound/misc/bangindonk.ogg'))// random end sounds!! - LastyBatsy


	processScheduler.stop()

	for(var/client/C in clients)
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")
	..(0)

#define INACTIVITY_KICK	6000	//10 minutes in ticks (approx.)
/world/proc/KickInactiveClients()
	var/tmp/sleep_check = 0 // buffer for checking elapsed ticks
	var/tmp/work_length = 2 // number of ticks to run before yielding cpu
	var/tmp/sleep_length = 5 // number of ticks to yield
	var/waiting=1

	sleep_check = world.timeofday

	while(waiting)
		waiting = 0
		sleep(INACTIVITY_KICK)
		for(var/client/C in clients)
			if(C.holder) return
			if(C.is_afk(INACTIVITY_KICK))
				if(!istype(C.mob, /mob/dead))
					log_access("AFK: [key_name(C)]")
					to_chat(C, "\red You have been inactive for more than 10 minutes and have been disconnected.")
					del(C)
		if ( ((world.timeofday - sleep_check) > work_length) || ((world.timeofday - sleep_check) < 0) )
			sleep(sleep_length)
			sleep_check = world.timeofday
		waiting++
//#undef INACTIVITY_KICK
/*
#define DISCONNECTED_DELETE	6000	//10 minutes in ticks (approx)
/world/proc/KickDisconnectedClients()
	spawn(-1)
		//set background = 1
		while(1)
			sleep(DISCONNECTED_DELETE)
			for(var/mob/living/carbon/human/C in living_mob_list)
				if (dd_hasprefix(C.key,@)) return
				if(!C.client && C.brain_op_stage!=4.0 && C.lastKnownIP)
					sleep(600)
					if(!C.client && C.stat != DEAD && C.brain_op_stage!=4.0)
						job_master.FreeRole(C.job)
						message_admins("[key_name_admin(C)], the [C.job] has been freed due to (<font color='#ffcc00'><b>Client disconnect for 10 minutes</b></font>)\n")
						for(var/obj/item/W in C)
							C.unEquip(W)
						del(C)
					else if(!C.key && C.stat != DEAD && C.brain_op_stage!=4.0)
						job_master.FreeRole(C.job)
						message_admins("[key_name_admin(C)], the [C.job] has been freed due to (<font color='#ffcc00'><b>Client quit BYOND</b></font>)\n")
						for(var/obj/item/W in C)
							C.unEquip(W)
						del(C)
#undef INACTIVITY_KICK
*/

/hook/startup/proc/loadMode()
	world.load_mode()
	return 1

/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_mode = Lines[1]
			diary << "Saved mode is '[master_mode]'"

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/hook/startup/proc/loadMusic()
	for(var/obj/machinery/media/jukebox/J in machines)
		J.process()
	return 1

/hook/startup/proc/loadMOTD()
	world.load_motd()
	return 1

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")


/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
	config.loadoverflowwhitelist("config/ofwhitelist.txt")
	// apply some settings from config..

/world/proc/update_status()
	var/s = ""

	if (config && config.server_name)
		s += "<b>[config.server_name]</b> &#8212; "

	s += "<b>[station_name()]</b>";
	s += " ("
	s += "<a href=\"https://github.com/nopm/Beat-Station\">" //Change this to wherever you want the hub to link to.
	s += "Beat!Code"
	s += "</a>"
	s += ")"
	s += "<br>Brazilian medium roleplaying<br>"




	var/list/features = list()

	if(ticker)
		if(master_mode)
			features += master_mode
	else
		features += "<b>STARTING</b>"

	if (!enter_allowed)
		features += "closed"

	features += abandon_allowed ? "respawn" : "no respawn"

	if (config && config.allow_vote_mode)
		features += "vote"

	if (config && config.allow_ai)
		features += "AI allowed"

	var/n = 0
	for (var/mob/M in player_list)
		if (M.client)
			n++

	if (n > 1)
		features += "~[n] players"
	else if (n > 0)
		features += "~[n] player"

	/*
	is there a reason for this? the byond site shows 'hosted by X' when there is a proper host already.
	if (host)
		features += "hosted by <b>[host]</b>"
	*/

	if (!host && config && config.hostedby)
		features += "hosted by <b>[config.hostedby]</b>"

	if (features)
		s += ": [jointext(features, ", ")]"

	/* does this help? I do not know */
	if (src.status != s)
		src.status = s


#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0
var/failed_old_db_connections = 0

/hook/startup/proc/connectDB()
	if(!setup_database_connection())
		log_to_dd("Your server failed to establish a connection with the feedback database.")
	else
		log_to_dd("Feedback database connection established.")
	return 1

proc/setup_database_connection()

	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!dbcon)
		dbcon = new()

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon.IsConnected()
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		log_to_dd(dbcon.ErrorMsg())

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return 1

#undef FAILED_DB_CONNECTION_CUTOFF
