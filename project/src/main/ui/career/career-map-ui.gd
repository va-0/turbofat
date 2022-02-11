extends CanvasLayer
## UI elements for the career map's settings menu.

## Alter the player's career mode data to force a cutscene.
##
## This is triggered by a cheat code.
func _force_cutscene() -> void:
	PlayerData.career.hours_passed = CareerData.CAREER_INTERLUDE_HOURS[0]
	PlayerData.career.skipped_previous_level = false
	
	var region := CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
	var chat_key_pair := {}
	if region.cutscene_path:
		# find a region-specific cutscene
		chat_key_pair = CareerCutsceneLibrary.next_chat_key_pair([region.cutscene_path])
	if not chat_key_pair:
		# no region-specific cutscene available; find a general cutscene
		chat_key_pair = CareerCutsceneLibrary.next_chat_key_pair([CareerData.GENERAL_CHAT_KEY_ROOT])
	if not chat_key_pair:
		var chat_keys := CareerCutsceneLibrary.chat_keys([CareerData.GENERAL_CHAT_KEY_ROOT])
		var min_chat_age := ChatHistory.CHAT_AGE_NEVER
		var newest_chat_key := ""
		for chat_key in chat_keys:
			var chat_age := PlayerData.chat_history.get_chat_age(chat_key)
			if chat_age < min_chat_age:
				min_chat_age = chat_age
				newest_chat_key = chat_key
		PlayerData.chat_history.delete_history_item(newest_chat_key)


## Alter the player's career mode data to force a boss level.
##
## This is triggered by a cheat code.
func _force_boss_level() -> void:
	var region := CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
	if region.length == CareerData.MAX_DISTANCE_TRAVELLED:
		# if they're in the last region, move them to the end of the previous region
		PlayerData.career.distance_travelled = region.distance - 1
	else:
		# move them to the end of the current region
		PlayerData.career.distance_travelled = region.length + region.distance - 1
	
	# set their max_distance_travelled so that the boss level isn't skipped
	PlayerData.career.max_distance_travelled = PlayerData.career.distance_travelled
	
	# reload the CareerMap scene
	SceneTransition.change_scene()


func _on_SettingsButton_pressed() -> void:
	$SettingsMenu.show()


func _on_SettingsMenu_show() -> void:
	$Control/SettingsButton.hide()


func _on_SettingsMenu_hide() -> void:
	$Control/SettingsButton.show()


func _on_SettingsMenu_quit_pressed() -> void:
	SceneTransition.pop_trail()


func _on_SettingsMenu_other_quit_pressed() -> void:
	PlayerData.career.hours_passed = CareerData.HOURS_PER_CAREER_DAY
	PlayerData.career.push_career_trail()


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "cutsio":
		_force_cutscene()
		detector.play_cheat_sound(true)
	elif cheat == "bossio":
		_force_boss_level()
		detector.play_cheat_sound(true)
