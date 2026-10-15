extends Node

var _failed: = false

func _ready() -> void :
	call_deferred("_run")

func _check(condition: bool, message: String) -> void :
	if not condition:
		_failed = true
		push_error("BACKPACK_ORGANIZE_FAIL: " + message)

func _flatten(key: String) -> Array:
	var result: Array = []
	for page in range(1, 21):
		result.append_array(PlayerData.player_data[key].get("页码%d" % page, []))
	return result

func _run() -> void :
	var original: = PlayerData.player_data.duplicate(true)
	var original_path: String = Global.cd_path
	var original_ldl: Variant = Global.is_in_ldl
	Global.cd_path = ""
	Global.is_in_ldl = false
	for key in ["装备列表", "道具列表", "消耗品列表"]:
		PlayerData.player_data[key] = {}
		for page in range(1, 21):
			PlayerData.player_data[key]["页码%d" % page] = []
	var equipment: Array = []
	for index in range(28):
		var item_id: = "zxstg" if index % 2 == 0 else "ptxzg"
		var data: Dictionary = AE.AllEquipment_[item_id].duplicate(true)
		data["锁定"] = index % 3 == 0
		data["神铸阶段"] = 5 if index % 2 == 0 else 0
		data["宝石"] = ["sms_2"]
		equipment.append({"名字": item_id, "强化等级": index, "Data": data, "测试标识": index})
	PlayerData.player_data["装备列表"]["页码2"] = equipment.slice(0, 14)
	PlayerData.player_data["装备列表"]["页码20"] = equipment.slice(14)
	PlayerData.player_data["道具列表"]["页码20"] = [{"名字": "pgs_9", "数量": 7, "锁定": true}, {"名字": "sms_1", "数量": 13}]
	for item_id in ["pgs_2", "sms_3", "qhs_4", "gjs_2", "pgs", "qhs_1", "sms_2", "gjs_1", "pgs_3", "sms_1", "qhs_2"]:
		PlayerData.player_data["道具列表"]["页码20"].append({"名字": item_id, "数量": 2, "锁定": false})
	PlayerData.player_data["消耗品列表"]["页码10"] = [{"名字": "qhsbx", "数量": 4, "锁定": true}]
	var snapshots: Dictionary = {}
	for key in ["装备列表", "道具列表", "消耗品列表"]:
		snapshots[key] = _flatten(key).duplicate(true)
	var backpack = load("res://Scene/BackPack/BackPack.tscn").instantiate()
	backpack.position = get_viewport().get_visible_rect().size * 0.5
	add_child(backpack)
	await get_tree().create_timer(0.3).timeout
	var main = backpack.get_node("Main_Backpack")
	var transmog: Button = backpack.get_node("Button")
	_check(transmog.theme == main.sort_button.theme, "幻化与整理按钮样式不一致")
	_check(transmog.get_theme_stylebox("normal") is StyleBoxFlat, "幻化按钮未使用宠物阵法样式")
	main.current_page = 20
	main.current_fl = 1
	main.sort_button.pressed.emit()
	_check(main.current_page == 1, "整理未返回第一页")
	_check(main.current_fl == 1 and main.title.text == "道具背包", "道具页面整理后未留在道具页")
	for key in snapshots:
		var sorted: = _flatten(key)
		var remaining: Array = snapshots[key].duplicate(true)
		_check(sorted.size() == remaining.size(), "整理后物品数变化：" + key)
		for index in range(sorted.size()):
			var matching: = remaining.find(sorted[index])
			_check(matching >= 0, "整理损坏物品数据：" + key)
			if matching >= 0:
				remaining.remove_at(matching)
			if index > 0:
				var before: bool = PlayerData._backpack_item_before(sorted[index], sorted[index - 1]) if key == "装备列表" else PlayerData._backpack_material_before(sorted[index], sorted[index - 1])
				_check( not before, "排序错误：" + key)
		_check(remaining.is_empty(), "整理丢失物品：" + key)
	_check(PlayerData.player_data["装备列表"]["页码1"].size() == 25 and PlayerData.player_data["装备列表"]["页码2"].size() == 3, "跨页整理错误")
	_check(PlayerData.player_data["装备列表"]["页码20"].is_empty(), "整理未填补空页")
	_check(PlayerData.player_data["武器"] == original["武器"], "整理修改了穿戴装备")
	var item_ids: Array = []
	for item in _flatten("道具列表"):
		item_ids.append(item["名字"])
	for family in [["pgs", "pgs_2", "pgs_3", "pgs_9"], ["qhs_1", "qhs_2", "qhs_4"], ["gjs_1", "gjs_2"], ["sms_1", "sms_1", "sms_2", "sms_3"]]:
		var first: = item_ids.find(family[0])
		_check(first >= 0 and item_ids.slice(first, first + family.size()) == family, "关联道具未相邻且按等级排序：" + str(family))
	var sorted_snapshot: = PlayerData.player_data.duplicate(true)
	main.sort_button.pressed.emit()
	_check(PlayerData.player_data == sorted_snapshot, "重复整理结果不稳定")
	Global.is_in_ldl = true
	main._on_sort_pressed()
	_check(PlayerData.player_data == sorted_snapshot, "炼丹炉中整理改变材料位置")
	Global.is_in_ldl = false
	await get_tree().create_timer(0.2).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var path: = ProjectSettings.globalize_path("user://backpack_organize.png")
		_check(get_viewport().get_texture().get_image().save_png(path) == OK, "截图失败")
		print("BACKPACK_ORGANIZE_SCREENSHOT=" + path)
	backpack.queue_free()
	await get_tree().process_frame
	PlayerData.player_data = original
	Global.cd_path = original_path
	Global.is_in_ldl = original_ldl
	print("BACKPACK_ORGANIZE_PROBE_OK" if not _failed else "BACKPACK_ORGANIZE_PROBE_FAILED")
	get_tree().quit(1 if _failed else 0)
