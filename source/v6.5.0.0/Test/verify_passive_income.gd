extends Node
const DataKeys := preload("res://Script/Base/DataKeys.gd")

var failures: Array[String] = []


func _ready() -> void:
	var player_data_node = get_node("/root/PlayerData")
	var passive_skill_node = get_node("/root/PaSkill")
	var global_node = get_node("/root/Global")
	var original_player_data: Dictionary = player_data_node.player_data
	player_data_node.player_data = original_player_data.duplicate(true)
	player_data_node.player_data[DataKeys.PLAYER_LEVEL] = 9
	player_data_node.player_data["coin_num"] = 100000
	player_data_node.player_data["被动技能"] = {
		"热血": 0,
		"魔泉": 0,
		"狂暴": 0,
		"永恒": 0,
		"辉煌": 0,
		"敏锐": 0,
	}

	player_data_node.ensure_player_passive_skills()
	_check(player_data_node.player_data["被动技能"].has("收益"), "旧存档应自动补充收益被动")
	_check(int(player_data_node.player_data["被动技能"]["收益"]) == 0, "旧存档的收益被动应从0级开始")
	_check(passive_skill_node.get_value("收益", 1) == 5 and passive_skill_node.get_value("收益", 3) == 15, "收益每级应增加5%杀怪灵魂")
	_check(passive_skill_node.apply_soul_gain_bonus(101) == 101, "0级收益不应改变杀怪灵魂")

	var passive_scene: PackedScene = load("res://Scene/Skill/bd_skill.tscn")
	_check(passive_scene != null, "人物被动技能场景应可加载")
	var passive_table: Node = passive_scene.instantiate()
	add_child(passive_table)
	_check(passive_table.has_node("HBoxContainer/Skill_Name/name_7"), "被动技能表应显示收益技能")
	_check(passive_table.has_node("HBoxContainer/Current_e/name_7"), "收益技能应显示当前效果")
	_check(passive_table.has_node("HBoxContainer/Next_e/name_7"), "收益技能应显示下一级效果")
	_check(passive_table.has_node("HBoxContainer/NeedLh/name_7"), "收益技能应显示升级灵魂消耗")
	var upgrade_button := passive_table.get_node("HBoxContainer/Up_level/up_7") as TextureButton
	_check(upgrade_button.pressed.is_connected(Callable(passive_table, "_on_up_7_pressed")), "收益升级按钮应连接升级处理")
	_check((passive_table.get_node("HBoxContainer/Next_e/name_7") as Label).text == "杀怪灵魂获取 +5%", "0级时应预览下一级增加5%")

	passive_table.call("up_level", "收益")
	_check(int(player_data_node.player_data["被动技能"]["收益"]) == 1, "收益技能应能正常升到1级")
	_check(int(player_data_node.player_data["coin_num"]) == 95000, "收益技能1级应沿用5000灵魂升级费用")
	_check(passive_skill_node.apply_soul_gain_bonus(100) == 105, "收益1级应让100点杀怪灵魂变为105点")

	player_data_node.player_data["被动技能"]["收益"] = 3
	_check(passive_skill_node.apply_soul_gain_bonus(101) == 116, "收益3级应增加15%并按现有整数规则取整")
	var aura_parent := Node2D.new()
	add_child(aura_parent)
	var aura: Node = global_node.AddAura(aura_parent, Vector2.ZERO, 100)
	_check(aura != null and int(aura.Value) == 115, "怪物灵魂掉落入口应应用收益倍率")

	player_data_node.player_data["被动技能"]["收益"] = 1
	passive_table.call("set_infor")
	await get_tree().process_frame
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		var screenshot_path := OS.get_temp_dir().path_join("passive_income_verification.png")
		var screenshot := get_viewport().get_texture().get_image()
		_check(screenshot != null and screenshot.save_png(screenshot_path) == OK, "人物被动技能页截图应可生成")
		print("PASSIVE_INCOME_SCREENSHOT=" + screenshot_path)

	passive_table.free()
	aura_parent.free()
	passive_table = null
	aura = null
	passive_scene = null
	global_node.Aura_ = null
	player_data_node.player_data = original_player_data
	call_deferred("_finish")


func _finish() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if failures.is_empty():
		print("PASSIVE_INCOME_VERIFICATION_PASSED")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	print("PASSIVE_INCOME_VERIFICATION_FAILED=%d" % failures.size())
	get_tree().quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
