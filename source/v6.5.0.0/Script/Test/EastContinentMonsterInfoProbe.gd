extends SceneTree

const LEVEL_INFO_SCRIPT_PATH: = "res://Scene/OtherScene/LevelInfo.gd"
const HEAD_SCENE_PATH: = "res://Scene/OtherScene/MonsterHeadInfo.tscn"
const MONSTER_SCENE_PATH: = "res://Scene/Monster/Monster_3159.tscn"
const LATE_LEVEL_MONSTERS: = {
	69: [
		{"id": 3198, "name": "吸血蝙蝠", "boss": false}, 
		{"id": 3199, "name": "雷吼兽", "boss": false}, 
		{"id": 3201, "name": "召唤小蝙蝠", "boss": false}, 
		{"id": 3200, "name": "千年蝠妖", "boss": true}, 
	], 
	70: [
		{"id": 3221, "name": "雷吼兽", "boss": false}, 
		{"id": 3222, "name": "邪魅童子", "boss": false}, 
		{"id": 3226, "name": "吸血蝙蝠", "boss": false}, 
		{"id": 3223, "name": "黄眉大王", "boss": true}, 
	], 
	71: [
		{"id": 3274, "name": "邪魅童子", "boss": false}, 
		{"id": 3275, "name": "吸血蝙蝠", "boss": false}, 
		{"id": 3276, "name": "虎妖", "boss": false}, 
		{"id": 3277, "name": "雷之祖巫", "boss": true}, 
	], 
	72: [
		{"id": 3308, "name": "小狐狸", "boss": false}, 
		{"id": 3309, "name": "琉璃鸟", "boss": false}, 
		{"id": 3310, "name": "九尾天狐", "boss": true}, 
	], 
	73: [
		{"id": 3320, "name": "金甲护卫", "boss": false}, 
		{"id": 3321, "name": "小狐狸", "boss": false}, 
		{"id": 3322, "name": "琉璃鸟", "boss": false}, 
		{"id": 3323, "name": "金翅大鹏雕", "boss": true}, 
	], 
	74: [
		{"id": 3340, "name": "金甲护卫", "boss": false}, 
		{"id": 3341, "name": "小狐狸", "boss": false}, 
		{"id": 3342, "name": "琉璃鸟", "boss": false}, 
		{"id": 3343, "name": "电之祖巫", "boss": true}, 
	], 
	75: [
		{"id": 3352, "name": "通天教主(混沌版)", "boss": true}, 
	], 
}
const LATE_LEVEL_NAMES: = {
	69: "蝙蝠窟", 70: "七星洞", 71: "万妖穴", 72: "琉璃宫", 
	73: "金玉宫", 74: "浮天台", 75: "云川", 
}

func _init() -> void :
	call_deferred("_run")

func _run() -> void :
	var level_info_script: = load(LEVEL_INFO_SCRIPT_PATH) as Script
	var head_scene: = load(HEAD_SCENE_PATH) as PackedScene
	if level_info_script == null or head_scene == null:
		_fail("资源加载失败")
		return
	if not _verify_magic_weapon_boss_drops(level_info_script):
		return
	if not _verify_aolaiguo_preview(level_info_script, head_scene):
		return
	if not _verify_late_level_previews(level_info_script, head_scene):
		return
	if not _verify_east_drop_previews(level_info_script):
		return
	var level_info: = level_info_script.new() as Node
	level_info.set("TargetStagePath", "res://Scene/Level/Level_66.tscn")
	var config: Dictionary = level_info.call(
		"_get_level_monster_config", MONSTER_SCENE_PATH, 3159, 0
	)
	if config.is_empty():
		_fail("未读取 Level_66 的 3159 配置")
		return
	config["hp"] = 123456
	config["attack"] = 7890
	config["range"] = 321
	config["damage_bonus"] = 0.17
	config["damage_reduction"] = 0.23
	var head: = head_scene.instantiate()
	head.set("MonsterName", "猴妖")
	head.set("MonsterScenePath", MONSTER_SCENE_PATH)
	head.set("LevelMonsterConfig", config)
	var data: Dictionary = head.call("_get_scene_attr_data")
	if int(data.get("生命", 0)) != 123456\
	or int(data.get("基础攻击", 0)) != 7890\
	or int(data.get("攻击范围", 0)) != 321\
	or not is_equal_approx(float(data.get("伤害", 0.0)), 0.17)\
	or not is_equal_approx(float(data.get("免伤", 0.0)), 0.23):
		_fail("信息框属性未使用关卡配置：%s" % data)
		return
	var panel: = head.call("_create_monster_attr_panel") as Control
	var panel_text: = _collect_label_text(panel)
	if not ("生命：123456" in panel_text and "攻击：7890" in panel_text\
	and "攻击范围：321" in panel_text and "伤害：17%" in panel_text\
	and "免伤：23%" in panel_text):
		_fail("信息框展示文本未使用关卡配置：%s" % panel_text)
		return
	var nightmare_damage: = float(head.call(
		"_get_difficulty_value", "伤害", 0.6, 3.0, BaseMonster.NIGHTMARE_DIFFICULTY, 
		"res://Scene/Level/Level_69.tscn"
	))
	var nightmare_reduction: = float(head.call(
		"_get_difficulty_value", "免伤", 0.6, 3.0, BaseMonster.NIGHTMARE_DIFFICULTY, 
		"res://Scene/Level/Level_69.tscn"
	))
	if not is_equal_approx(nightmare_damage, BaseMonster.NIGHTMARE_DAMAGE_BONUS)\
	or not is_equal_approx(nightmare_reduction, BaseMonster.NIGHTMARE_DAMAGE_REDUCTION):
		_fail("信息框噩梦增伤免伤与战斗不一致：%.2f / %.2f" % [nightmare_damage, nightmare_reduction])
		return
	panel.free()
	print("EAST_CONTINENT_MONSTER_INFO_OK hp=%d attack=%d range=%d damage=%.2f reduction=%.2f" % [
		int(data["生命"]), int(data["基础攻击"]), int(data["攻击范围"]), 
		float(data["伤害"]), float(data["免伤"]), 
	])
	head.free()
	level_info.free()
	quit(0)

func _verify_east_drop_previews(level_info_script: Script) -> bool:
	for level_number in range(64, 76):
		var level_info: = level_info_script.new() as Node
		level_info.set("TargetStagePath", "res://Scene/Level/Level_%d.tscn" % level_number)
		var info: Dictionary = level_info.call("_get_level_info")
		var drops: Array = info.get("LevelFall", [])
		var probabilities: Dictionary = info.get("LevelFallProbability", {})
		var fall_pro: = int(info.get("fall_pro", 0))
		level_info.free()
		var expected_drops: Array = ["2_jns"] if level_number == 64 else []
		var expected_probabilities: Dictionary = {"2_jns": 20} if level_number == 64 else {}
		if fall_pro != 0 or drops != expected_drops or probabilities != expected_probabilities:
			_fail("Level_%d 信息框错误继承普通掉落：rate=%d drops=%s probabilities=%s" % [
				level_number, fall_pro, drops, probabilities, 
			])
			return false
	print("EAST_CONTINENT_DROP_PREVIEW_OK levels=12")
	return true

func _verify_magic_weapon_boss_drops(level_info_script: Script) -> bool:
	var cases: = [
		{
			"level": 60, "level_name": "锦绣峰", "boss": 3070, 
			"scene": "res://Scene/Monster/Monster_3070.tscn", "item": "469000004", 
		}, 
		{
			"level": 63, "level_name": "金沙村", "boss": 3120, 
			"scene": "res://Scene/Monster/Monster_3120.tscn", "item": "469000011", 
		}, 
	]
	for drop_case: Dictionary in cases:
		var level_info: = level_info_script.new() as Node
		level_info.set("LevelName", str(drop_case["level_name"]))
		level_info.set("TargetStagePath", "res://Scene/Level/Level_%d.tscn" % int(drop_case["level"]))
		var info: Dictionary = level_info.call("_get_level_info")
		var item_id: = str(drop_case["item"])
		var preview_drops: Array = info.get("LevelFall", [])
		var probabilities: Dictionary = info.get("LevelFallProbability", {})
		var config: Dictionary = level_info.call(
			"_get_level_monster_config", str(drop_case["scene"]), int(drop_case["boss"]), 0
		)
		level_info.free()
		var runtime_drops: Array = config.get("independent_drop_list", [])
		if preview_drops != [item_id] or int(probabilities.get(item_id, 0)) != 10\
		or runtime_drops.size() != 1:
			_fail("法宝掉落配置缺失：%s / %s" % [info, config])
			return false
		var runtime_drop: Dictionary = runtime_drops[0]
		if str(runtime_drop.get("name", "")) != item_id\
		or int(runtime_drop.get("value", 0)) != 1\
		or not is_equal_approx(float(runtime_drop.get("chance", 0.0)), 0.1):
			_fail("法宝掉落概率错误：%s" % runtime_drop)
			return false
	print("MAGIC_WEAPON_BOSS_DROP_OK cases=%d chance=10%%" % cases.size())
	return true

func _verify_aolaiguo_preview(level_info_script: Script, head_scene: PackedScene) -> bool:
	var expected: = [
		{"id": 3144, "name": "银甲守卫", "boss": false}, 
		{"id": 3145, "name": "花骨朵", "boss": false}, 
		{"id": 3146, "name": "毒毛虫", "boss": false}, 
		{"id": 3136, "name": "风之祖巫", "boss": true}, 
	]
	var level_info: = level_info_script.new() as Node
	level_info.set("LevelName", "傲来国")
	level_info.set("TargetStagePath", "res://Scene/Level/Level_65.tscn")
	var info: Dictionary = level_info.call("_get_level_info")
	var monsters: Array = info.get("MonsterList", [])
	if monsters.size() != expected.size():
		level_info.free()
		_fail("傲来国信息框怪物数量错误：%s" % monsters)
		return false
	for index in expected.size():
		var item: Dictionary = monsters[index]
		var wanted: Dictionary = expected[index]
		var source_id: = int(wanted["id"])
		var scene_path: = str(item.get("ScenePath", ""))
		var config: Dictionary = level_info.call(
			"_get_level_monster_config", scene_path, source_id, 0
		)
		if str(item.get("Name", "")) != str(source_id)\
		or bool(item.get("IsBoss", false)) != bool(wanted["boss"])\
		or str(config.get("name", "")) != str(wanted["name"]):
			level_info.free()
			_fail("傲来国第%d个怪物配置错误：%s / %s" % [index, item, config])
			return false
		var head: = head_scene.instantiate()
		head.set("MonsterName", str(source_id))
		head.set("LevelMonsterConfig", config)
		var texture: = head.call("load_", str(source_id)) as Texture2D
		if str(head.call("get_display_name")) != str(wanted["name"]) or texture == null:
			head.free()
			level_info.free()
			_fail("傲来国怪物%d名称或头像缺失" % source_id)
			return false
		head.free()
	level_info.free()
	print("AOLAIGUO_MONSTER_PREVIEW_OK heads=%d" % expected.size())
	return true

func _verify_late_level_previews(level_info_script: Script, head_scene: PackedScene) -> bool:
	var total_heads: = 0
	for stage: int in LATE_LEVEL_MONSTERS:
		var level_info: = level_info_script.new() as Node
		level_info.set("LevelName", str(LATE_LEVEL_NAMES[stage]))
		level_info.set("TargetStagePath", "res://Scene/Level/Level_%d.tscn" % stage)
		var level_scene: = load("res://Scene/Level/Level_%d.tscn" % stage) as PackedScene
		var battle_level: = level_scene.instantiate() as Game4EastLateLevel
		var info: Dictionary = level_info.call("_get_level_info")
		var monsters: Array = info.get("MonsterList", [])
		var expected: Array = LATE_LEVEL_MONSTERS[stage]
		if str(info.get("LevelName", "")) != str(LATE_LEVEL_NAMES[stage])\
		or monsters.size() != expected.size():
			level_info.free()
			_fail("Level_%d 信息框怪物数量或关卡名错误：%s" % [stage, info])
			return false
		for index in expected.size():
			var item: Dictionary = monsters[index]
			var wanted: Dictionary = expected[index]
			var source_id: = int(wanted["id"])
			if str(item.get("Name", "")) != str(source_id)\
			or bool(item.get("IsBoss", false)) != bool(wanted["boss"])\
			or int(item.get("ConfigId", 0)) != source_id:
				level_info.free()
				_fail("Level_%d 第%d个怪物配置错误：%s" % [stage, index, item])
				return false
			var scene_path: = str(item.get("ScenePath", ""))
			if not ResourceLoader.exists(scene_path):
				level_info.free()
				_fail("Level_%d 怪物场景缺失：%s" % [stage, scene_path])
				return false
			var config: Dictionary = level_info.call(
				"_get_level_monster_config", scene_path, source_id, 0
			)
			var battle_config: = battle_level.get_level_monster_config(source_id)
			if str(config.get("name", "")) != str(wanted["name"]):
				battle_level.free()
				level_info.free()
				_fail("Level_%d 怪物%d名称错误：%s" % [stage, source_id, config])
				return false
			for stat_key: String in ["hp", "attack", "def", "mdef", "armor_break", "magic_break", "damage_bonus", "damage_reduction", "is_boss"]:
				if config.get(stat_key) != battle_config.get(stat_key):
					battle_level.free()
					level_info.free()
					_fail("Level_%d 怪物%d信息框与战斗属性不一致：%s / %s" % [stage, source_id, config, battle_config])
					return false
			var head: = head_scene.instantiate()
			head.set("MonsterName", str(source_id))
			head.set("IsBoss", bool(item.get("IsBoss", false)))
			head.set("MonsterScenePath", scene_path)
			head.set("LevelMonsterConfig", config)
			if str(head.call("get_display_name")) != str(wanted["name"]):
				head.free()
				level_info.free()
				_fail("Level_%d 怪物%d显示名错误" % [stage, source_id])
				return false
			var texture: = head.call("load_", str(source_id)) as Texture2D
			if texture == null or texture.get_width() <= 0 or texture.get_height() <= 0:
				head.free()
				level_info.free()
				_fail("Level_%d 怪物%d头像缺失" % [stage, source_id])
				return false
			head.free()
			total_heads += 1
		battle_level.free()
		level_info.free()
	print("EAST_LATE_MONSTER_PREVIEW_OK levels=%d heads=%d" % [LATE_LEVEL_MONSTERS.size(), total_heads])
	return true

func _collect_label_text(node: Node) -> String:
	var result: = ""
	if node is Label:
		result += (node as Label).text + "\n"
	for child in node.get_children():
		result += _collect_label_text(child)
	return result

func _fail(message: String) -> void :
	push_error(message)
	quit(1)
