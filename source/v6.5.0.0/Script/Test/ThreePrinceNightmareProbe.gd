extends Node

var _failures: Array[String] = []
var _checks: = 0

func _ready() -> void :
	call_deferred("_run")

func _check(condition: bool, message: String) -> void :
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("THREE_PRINCE_NIGHTMARE_FAIL: " + message)

func _run() -> void :
	MainSet.set_data["Difficult"] = 3
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_auto_battle_enabled(false)
	RoleProp.set_physics_process(false)
	var pairs: = {"xyst": "llst", "xyzx": "llzx", "xykj": "llkj", "xytk": "lltk"}
	for blood_id in pairs:
		var blood: Dictionary = AE.AllEquipment_[blood_id]
		var old: Dictionary = AE.AllEquipment_[pairs[blood_id]]
		_check(blood["品质"] == "史诗", blood_id + " 品质错误")
		_check(blood["装备类型"] == old["装备类型"], blood_id + " 槽位不兼容")
		_check(ResourceLoader.exists(blood["图标"]), blood_id + " 图标未导入")
		for key in PlayerData.PET_EQUIPMENT_TEMPLATE_STAT_KEYS:
			_check(float(blood.get(key, 0)) == float(old.get(key, 0)) * 3.0, blood_id + " 基础属性错误: " + key)
			_check(float(blood["强化属性"].get(key, 0)) == float(old["强化属性"].get(key, 0)) * 3.0, blood_id + " 强化属性错误: " + key)
		for _roll in range(12):
			var rolls: Array = PlayerData._generate_pet_equipment_random_stats(blood)
			_check(rolls.size() == 4, blood_id + " 词条数量不是4")
			for roll in rolls:
				_check(float(roll["数值"]) == float(blood.get(roll["属性"], 0)), blood_id + " 词条未使用血焰属性")
		var backpack: = PlayerData.ensure_shared_pet_backpack()
		var before: = backpack.size()
		_check(PlayerData.add_pet_backpack_item(blood_id, 1) == 1, blood_id + " 无法进入宠物背包")
		var stored: Dictionary = backpack.back()
		_check(stored["随机属性"].size() == 4 and stored["Data"]["品质"] == "史诗", blood_id + " 拾取数据错误")
		stored["强化等级"] = 2
		var pet: = {"装备": {blood["装备类型"]: stored}}
		var stat_name: String = "攻击" if blood_id == "xyst" else "防御" if blood_id == "xyzx" else "生命"
		var key: String = "power" if blood_id == "xyst" else "Def" if blood_id == "xyzx" else "SHp"
		var expected_value: = float(blood[key]) + float(blood["强化属性"][key]) * 2.0
		for roll in stored["随机属性"]:
			if roll["属性"] == key:
				expected_value += float(roll["数值"]) + float(roll["强化属性"]) * 2.0
		_check(PlayerData.get_pet_equipment_stat(pet, stat_name) == int(expected_value), blood_id + " 穿戴/强化属性结算错误")
		backpack.resize(before)
	var legacy_rolls: Array = PlayerData._generate_pet_equipment_random_stats(AE.AllEquipment_["llst"])
	var legacy_item: = {"Data": AE.AllEquipment_["llst"].duplicate(true), "随机属性": legacy_rolls.duplicate(true)}
	PlayerData._ensure_pet_equipment_random_stats(legacy_item)
	_check(legacy_item["随机属性"] == legacy_rolls, "已有玲珑装备词条被改写")
	var head: Variant = (load("res://Scene/OtherScene/MonsterHeadInfo.gd") as GDScript).new()
	_check(head._get_difficulty_value("生命", 7500000, 3.0, 3, "res://Scene/Level/Level_stz.tscn") == 122500000, "预览生命与天庭规则不一致")
	head.free()
	var info: Variant = (load("res://Scene/OtherScene/LevelInfo.gd") as GDScript).new()
	info.LevelName = "挑战三太子"
	info.TargetStagePath = "res://Scene/Level/Level_stz.tscn"
	_check(info._get_nightmare_entry_block_message() == "", "三太子噩梦仍被拦截")
	var expected: = {4401: ["xyst"], 4402: ["xyzx"], 4403: ["xykj", "xytk"]}
	for prince_id in expected:
		Global.SelectedThreePrinceId = prince_id
		var preview: Array = info._get_level_fall_items(info.LevelInfo["挑战三太子"])
		_check(preview == ["rls"] + expected[prince_id], "噩梦掉落预览错误")
		var probabilities: Dictionary = info._get_level_fall_probabilities(info.LevelInfo["挑战三太子"])
		for blood_id in expected[prince_id]:
			_check(probabilities.get(blood_id, 0) == 20, "血焰基础掉落率错误")
		var level: = (load("res://Scene/Level/Level_stz.tscn") as PackedScene).instantiate() as BaseLevel
		level.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(level)
		await get_tree().process_frame
		var boss: = Global.Create_Monster(prince_id, level.get_node("Monster"), Vector2(900, 300)) as ThreePrinceBoss
		boss.process_mode = Node.PROCESS_MODE_ALWAYS
		await get_tree().physics_frame
		await get_tree().physics_frame
		boss.process_mode = Node.PROCESS_MODE_DISABLED
		_check(boss.level == 350 and boss.SHp in [122500000, 122500003], "三太子噩梦生命或等级错误")
		_check(boss.def == 18100 and boss.mdef == 18100, "三太子噩梦防御错误")
		_check(boss.ar == 24600 and boss.sp == 24600, "三太子噩梦穿透错误")
		_check(boss.objattackDic["hit1"]["power"] == 145000, "三太子噩梦攻击错误")
		_check(boss.damage_bonus == 1.0 and boss.damage_reduction == 1.0, "三太子噩梦伤害/免伤错误")
		_check(boss.Htarget == 2300, "三太子噩梦命中错误")
		var ids: Array = []
		for drop in boss.independent_fall_list:
			ids.append(drop["name"])
			_check(is_equal_approx(float(drop["chance"]), 0.2), "独立掉落基础概率被改写")
			drop["chance"] = 1.0
		_check(ids == expected[prince_id], "实际掉落未替换为血焰")
		boss.settle_death_drops()
		await get_tree().process_frame
		await get_tree().process_frame
		var dropped: Array = []
		for item in level.fall_it.get_children():
			if item.get("item_name") != null:
				dropped.append(item.item_name)
		for blood_id in expected[prince_id]:
			_check(dropped.has(blood_id), "死亡结算未生成血焰掉落: " + blood_id)
		var count: = level.fall_it.get_child_count()
		boss.settle_death_drops()
		await get_tree().process_frame
		_check(level.fall_it.get_child_count() == count, "死亡重复结算掉落")
		level.queue_free()
		await get_tree().process_frame
		RoleProp.SourcePlayer = null
	MainSet.set_data["Difficult"] = 0
	for prince_id in expected:
		var boss: = (load("res://Scene/Monster/Monster_%d.tscn" % prince_id) as PackedScene).instantiate() as ThreePrinceBoss
		boss._configure_monster()
		for drop in boss.independent_fall_list:
			_check(str(drop["name"]).begins_with("ll"), "普通难度玲珑掉落被替换")
		boss.free()
	info.free()
	MainSet.set_data["Difficult"] = 3
	Global.SelectedThreePrinceId = 4403
	var visual: = (load("res://Scene/OtherScene/LevelInfo.tscn") as PackedScene).instantiate()
	visual.LevelName = "挑战三太子"
	visual.TargetStagePath = "res://Scene/Level/Level_stz.tscn"
	add_child(visual)
	await get_tree().create_timer(0.4).timeout
	visual.AddLevelFallItem()
	await RenderingServer.frame_post_draw
	_check(get_viewport().get_texture().get_image().save_png("res://.codex_tmp/stz_nightmare_preview.png") == OK, "截图失败")
	print("THREE_PRINCE_NIGHTMARE_PROBE checks=%d failures=%d" % [_checks, _failures.size()])
	get_tree().quit(0 if _failures.is_empty() else 1)
