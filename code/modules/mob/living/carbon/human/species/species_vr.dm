/datum/species
	//This is used in character setup preview generation (prefences_setup.dm) and human mob
	//rendering (update_icons.dm)
	var/color_mult = 0

	//This is for overriding tail rendering with a specific icon in icobase, for static
	//tails only, since tails would wag when dead if you used this
	var/icobase_tail = 0


	//This is used for egg TF. It decides what type of egg the person will lay when they TF.
	//Default to the normal and bland "egg" just in case a race isn't defined.
	var/egg_type = "egg"

	var/min_age = 17
	var/max_age = 70

	var/name_language = "Galactic Common"

	var/heat_discomfort_level = 315                   // Aesthetic messages about feeling warm.
	var/cold_discomfort_level = 285                   // Aesthetic messages about feeling chilly.
	var/list/heat_discomfort_strings = list(
		"You feel sweat drip down your neck.",
		"You feel uncomfortably warm.",
		"Your skin prickles in the heat."
		)
	var/list/cold_discomfort_strings = list(
		"You feel chilly.",
		"You shiver suddenly.",
		"Your chilly flesh stands out in goosebumps."
		)

	var/appearance_flags = 0      // Appearance/display related features.
	var/spawn_flags = 0 // Flags that specify who can spawn as this species
	var/tail_animation