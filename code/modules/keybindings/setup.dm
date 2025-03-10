/client
	/// A list of any keys held currently
	var/list/keys_held = list()
	// These next two vars are to apply movement for keypresses and releases made while move delayed.
	// Because discarding that input makes the game less responsive.
	var/next_move_dir_add // On next move, add this dir to the move that would otherwise be done
	var/next_move_dir_sub // On next move, subtract this dir from the move that would otherwise be done

// Set a client's focus to an object and override these procs on that object to let it handle keypresses

/datum/proc/key_down(key, client/user) // Called when a key is pressed down initially
	return
/datum/proc/key_up(key, client/user) // Called when a key is released
	return
/datum/proc/keyLoop(client/user) // Called once every frame
	set waitfor = FALSE
	return

// removes all the existing macros
/client/proc/erase_all_macros()
	var/list/macro_sets = params2list(winget(src, null, "macros"))
	var/erase_output = ""
	for(var/i in 1 to macro_sets.len)
		var/setname = macro_sets[i]
		if(copytext(setname, 1, 9) == "persist_") // Don't remove macro sets not handled by input. Used in input_box.dm by create_input_window
			continue
		var/list/macro_set = params2list(winget(src, "[setname].*", "command")) // The third arg doesnt matter here as we're just removing them all
		for(var/k in 1 to macro_set.len)
			var/list/split_name = splittext(macro_set[k], ".")
			var/macro_name = "[split_name[1]].[split_name[2]]" // [3] is "command"
			erase_output = "[erase_output];[macro_name].parent=null"
	winset(src, null, erase_output)

/client/proc/set_macros()
	set waitfor = FALSE

	erase_all_macros()

	var/list/macro_sets = SSinput.macro_sets
	for(var/i in 1 to macro_sets.len)
		var/setname = macro_sets[i]
		if(setname != "default")
			winclone(src, "default", setname)
		var/list/macro_set = macro_sets[setname]
		for(var/k in 1 to macro_set.len)
			var/key = macro_set[k]
			var/command = macro_set[key]
			winset(src, "[setname]-[REF(key)]", "parent=[setname];name=[key];command=[command]")

	winset(src, null, "map.focus=true input.background-color=[COLOR_INPUT_DISABLED] mainwindow.macro=old_hotkeys")
