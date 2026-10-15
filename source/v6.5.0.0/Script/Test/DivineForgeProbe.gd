extends Node

var _failed: = false

func _ready() -> void :
	call_deferred("_run")

func _check(condition: bool, message: String) -> void :
	if not condition:
		_failed = true
		push_error("DIVINE_FORGE_FAIL: " + message)

func _run() -> void :
	var original: = PlayerData.player_data.duplicate(true)
	var original_selection: Dictionary = MLdl.qh_list.duplicate(true)
	var original_path: String = Global.cd_path
	Global.cd_path = ""
	PlayerData.player_data["道具列表"] = {}
	PlayerData.player_data["装备列表"] = {}
	var data: Dictionary = AE.AllEquipment_["zxstg"].duplicate(true)
	data["宝石"] = ["sms_2", "sms_2", "sms_2", "sms_2", "sms_2", "sms_2", "sms_2", "sms_2"]
	var equipment: = {"名字": "zxstg", "强化等级": 3, "Data": data}
	PlayerData.player_data["装备列表"]["页码1"] = [equipment]
	MLdl.qh_list = {"名字": "zxstg", "强化等级": 3, "页码": 1, "位置": 0, "来源": "装备背包", "穿戴栏": "", "Data": data}
	var forge = load("res://Scene/LDL/DivineForge.tscn").instantiate()
	add_child(forge)
	await get_tree().process_frame
	_check( not forge.get_node("n_q_2").visible, "副装备材料格未隐藏")
	var preview = load("res://Scene/OtherScene/LevelInfo.gd").new()
	for mapping in [[47, 1], [50, 2], [53, 3], [56, 4], [59, 5], [63, 6], [66, 7], [69, 8], [72, 9]]:
		var level_number: int = mapping[0]
		var stone_id: String = forge._stone_id(mapping[1])
		var level_script = load("res://Script/Level/Level_%d.gd" % level_number)
		var configs: Dictionary = level_script.get_script_constant_map()["LEVEL_%d_MONSTER_DATA" % level_number]
		var found: = false
		for config in configs.values():
			for drop in config.get("independent_drop_list", []):
				if drop.get("name", "") == stone_id:
					found = true
					_check(float(drop.chance) == 0.15 and int(drop.min_value) == 2 and int(drop.max_value) == 5, "神铸石掉落数量概率错误")
		_check(found, "指定关卡没有对应神铸石掉落：%d" % level_number)
		preview.TargetStagePath = "res://Scene/Level/Level_%d.tscn" % level_number
		preview.LevelName = {47: "玄武门", 50: "九华山麓", 53: "普陀山脚", 56: "峨眉山道", 59: "五台山口"}.get(level_number, "")
		_check(preview._get_level_info().get("LevelFall", []).has(stone_id), "掉落预览缺少对应神铸石：%d" % level_number)
		_check(preview._get_level_info().get("LevelFallProbability", {}).get(stone_id, 0) == 15, "神铸石掉落预览概率错误")
	preview.free()
	for stage in range(1, 10):
		var stone_id: String = forge._stone_id(stage)
		_check(AE.AllEquipment_.has(stone_id), "对应阶数神铸石未登记")
		_check(AE.AllEquipment_[stone_id]["名字"] == ["一", "二", "三", "四", "五", "六", "七", "八", "九"][stage - 1] + "阶神铸石", "神铸石阶数未使用汉字")
		PlayerData.player_data["道具列表"] = {"页码1": [{"名字": stone_id, "数量": 9}], "页码20": [{"名字": stone_id, "数量": 10}]}
		forge._on_sz_pressed()
		_check(AE.get_divine_forge_stage(equipment.Data) == stage - 1, "19颗材料仍可升级")
		PlayerData.player_data["道具列表"]["页码20"][0]["数量"] = 12
		forge._physics_process(0)
		_check(forge.n_q_1.get_item_name == stone_id and forge.num_b1.text == "21/20", "材料预览错误")
		forge._on_sz_pressed()
		_check(AE.get_divine_forge_stage(equipment.Data) == stage, "升级失败")
		_check(forge._count_item_all_pages(stone_id) == 1, "未恰好消耗20颗")
		_check(PlayerData.player_data["装备列表"]["页码1"].size() == 1, "消耗了装备")
		_check(equipment.Data["宝石"] == data["宝石"] and equipment["强化等级"] == 3, "强化或宝石丢失")
	_check(AE.get_divine_forge_display_name("zxstg", equipment.Data).begins_with("九阶·"), "九阶名称错误")
	_check(is_equal_approx(AE.get_divine_forge_multiplier("zxstg", equipment.Data), 3.7), "九阶装备属性加成错误")
	var before: = equipment.duplicate(true)
	forge._on_sz_pressed()
	_check(equipment == before, "超过九阶")
	equipment.Data["神铸阶段"] = 5
	PlayerData.player_data["武器"] = [equipment]
	PlayerData.player_data["装备列表"]["页码1"] = []
	MLdl.qh_list["来源"] = "人物穿戴"
	MLdl.qh_list["穿戴栏"] = "武器"
	MLdl.qh_list["页码"] = 0
	PlayerData.player_data["道具列表"] = {"页码1": [{"名字": "pgs_6", "数量": 20}]}
	forge._on_sz_pressed()
	_check(AE.get_divine_forge_stage(PlayerData.player_data["武器"][0].Data) == 6, "旧五阶穿戴装备无法升级六阶")
	forge._physics_process(0)
	if DisplayServer.get_name() != "headless":
		await get_tree().create_timer(0.2).timeout
		await RenderingServer.frame_post_draw
		var path: = ProjectSettings.globalize_path("user://divine_forge_stones.png")
		_check(get_viewport().get_texture().get_image().save_png(path) == OK, "截图失败")
		print("DIVINE_FORGE_SCREENSHOT=" + path)
	forge.queue_free()
	PlayerData.player_data = original
	MLdl.qh_list = original_selection
	RoleProp.get_equ_last_pro()
	Global.cd_path = original_path
	print("DIVINE_FORGE_PROBE_OK" if not _failed else "DIVINE_FORGE_PROBE_FAILED")
	get_tree().quit(1 if _failed else 0)
