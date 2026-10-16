extends CanvasLayer

signal background_changed(index: int)


func _on_game_1_bg_pressed() -> void:
	set_bg_image(1)


func _on_game_2_bg_pressed() -> void:
	if int(MainSet.set_data.get("CurrentLevelPage", 1)) >= 2:
		set_bg_image(2)
	else:
		Global.add_message_show(Global.windows, "到达二图解锁二图封面", 1.5, Vector2(470, 300))


func _on_game_3_bg_pressed() -> void:
	if int(MainSet.set_data.get("CurrentLevelPage", 1)) >= 3:
		set_bg_image(3)
	else:
		Global.add_message_show(Global.windows, "到达三图解锁三图封面", 1.5, Vector2(470, 300))


func _on_game_4_bg_pressed() -> void:
	set_bg_image(4)


func _on_game_5_bg_pressed() -> void:
	set_bg_image(5)


func _on_game_5_bg_2_pressed() -> void:
	set_bg_image(6)


func _on_close_pressed() -> void:
	queue_free()


func set_bg_image(index: int) -> void:
	MainSet.set_data["MainMenuBG"] = clampi(index, 1, 6)
	MemoryClass.main_bc()
	background_changed.emit(MainSet.set_data["MainMenuBG"])
