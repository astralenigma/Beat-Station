/datum/event/fire


/datum/event/fire/setup()
	impact_area = findFireArea()

/datum/event/fire/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/flux(T.loc)

/datum/event/fire/tick()
	if(!newAnomaly)
		kill()
		return
	newAnomaly.anomalyEffect()

/datum/event/fire/end()
	if(newAnomaly)//Kill the anomaly if it still exists at the end.
		qdel(newAnomaly)

/datum/event/fire/proc/findFireArea()
	var/area/candidate

	var/list/safe_areas = list(
	/area/turret_protected/ai,
	/area/turret_protected/ai_upload,
	/area/engine,
	/area/solar,
	/area/holodeck,
	/area/shuttle/arrival,
	/area/shuttle/escape,
	/area/shuttle/escape_pod1/station,
	/area/shuttle/escape_pod2/station,
	/area/shuttle/escape_pod3/station,
	/area/shuttle/escape_pod5/station,
	/area/shuttle/specops/station,
	/area/shuttle/prison/station,
	/area/shuttle/administration/station
	)