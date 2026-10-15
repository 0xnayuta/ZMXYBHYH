extends Node

const PLAYER_PASSIVE_SCENE: = preload("res://Scene/Skill/bd_skill.tscn")
const PET_INTERFACE_SCENE: = preload("res://Scene/Pet/PetInterface.tscn")
const PASSIVE_NAMES: = ["热血", "魔泉", "狂暴", "永恒", "辉煌", "敏锐", "收益"]

var failed: = false


func _ready() -> void :
	call_deferred("_run")


func _run() -> void :
	var original_player_data: = PlayerData.player_data.duplicate(true)
	var original_save_path: Variant = Global.cd_path
	Global.cd_path = ""
	get_window().size = Vector2i(1200, 400)

	PlayerData.player_data["玩家等级"] = 6
	PlayerData.player_data["被动技能"] = _zero_levels(PASSIVE_NAMES)
	PlayerData.set_soul(105000)
	var player_panel: = PLAYER_PASSIVE_SCENE.instantiate()
	add_child(player_panel)
	await get_tree().process_frame
	await get_tree().process_frame
	var player_button: = player_panel.get_node_or_null("HBoxContainer/Up_level/OneKeyUpgradeButton") as Button
	_check(player_button != null and player_button.visible, "人物一键升级按钮不可见")
	if player_button != null:
		var last_upgrade: = player_panel.get_node("HBoxContainer/Up_level/up_7") as Control
		_check( not player_button.get_global_rect().intersects(last_upgrade.get_global_rect()), "人物一键升级按钮与单项升级按钮重叠")
	await _save_viewport_image("passive_player_one_key.png", "PLAYER_PASSIVE_UI_IMAGE")
	if player_button != null:
		player_button.pressed.emit()
		_check(_all_levels_equal(PlayerData.player_data["被动技能"], PASSIVE_NAMES, 2), "人物界面按钮未触发一键升级")
	await get_tree().process_frame
	player_panel.queue_free()
	for child in get_children():
		if child != player_panel:
			child.queue_free()
	await get_tree().process_frame

	var pet: = PlayerData.PET_TIGER_PET.duplicate(true)
	pet["等级"] = 6
	pet["被动技能"] = _zero_levels(PASSIVE_NAMES.slice(0, 6))
	PlayerData.player_data[PlayerData.PET_LIST_KEY] = [pet]
	PlayerData.set_soul(90000)
	var pet_panel: = PET_INTERFACE_SCENE.instantiate()
	add_child(pet_panel)
	await get_tree().process_frame
	pet_panel.current_pet_index = 0
	pet_panel.groomClick()
	await get_tree().process_frame
	await get_tree().process_frame
	var pet_button: = pet_panel.pet_passive_one_key_button as Button
	_check(pet_button != null and pet_button.is_visible_in_tree(), "宠物一键升级按钮不可见")
	var pet_limit_label: = pet_panel.pet_passive_limit_label as Label
	_check(pet_limit_label != null and pet_limit_label.text == "上限：2", "宠物被动标题栏等级上限显示异常")
	_check(pet_limit_label == null or not pet_limit_label.text.contains("灵魂"), "宠物被动标题栏仍显示灵魂")
	if pet_button != null:
		var title_row: = pet_button.get_parent() as HBoxContainer
		for sibling in title_row.get_children():
			if sibling != pet_button and sibling is Control:
				_check( not pet_button.get_global_rect().intersects((sibling as Control).get_global_rect()), "宠物一键升级按钮与标题信息重叠")
	await _save_viewport_image("passive_pet_one_key.png", "PET_PASSIVE_UI_IMAGE")
	if pet_button != null:
		pet_button.pressed.emit()
		_check(_all_levels_equal(pet["被动技能"], PASSIVE_NAMES.slice(0, 6), 2), "宠物界面按钮未触发一键升级")

	pet_panel.queue_free()
	PlayerData.player_data = original_player_data
	Global.cd_path = original_save_path
	if failed:
		get_tree().quit(1)
		return
	print("PASSIVE_ONE_KEY_UPGRADE_UI_PROBE_OK")
	get_tree().quit(0)


func _zero_levels(skill_names: Array) -> Dictionary:
	var levels: = {}
	for skill_name in skill_names:
		levels[skill_name] = 0
	return levels


func _all_levels_equal(levels: Dictionary, skill_names: Array, expected: int) -> bool:
	for skill_name in skill_names:
		if int(levels.get(skill_name, -1)) != expected:
			return false
	return true


func _save_viewport_image(file_name: String, output_label: String) -> void :
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var image: = get_viewport().get_texture().get_image()
	if image == null:
		return
	var image_path: = OS.get_temp_dir().path_join(file_name)
	image.save_png(image_path)
	print("%s=%s" % [output_label, image_path])


func _check(condition: bool, message: String) -> void :
	if condition:
		return
	failed = true
	push_error("PASSIVE_ONE_KEY_UPGRADE_UI_PROBE_FAIL: %s" % message)
