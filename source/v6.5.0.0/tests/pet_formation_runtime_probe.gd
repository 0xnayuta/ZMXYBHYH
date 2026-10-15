extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _pet_data(pet_type: String) -> Dictionary:
	return {
		"类型": pet_type, 
		"名称": pet_type, 
		"名字": pet_type, 
		"阶段": 1, 
		"等级": 1, 
		"生命": 100, 
		"生命上限": 100, 
		"魔法": 100, 
		"魔法上限": 100, 
		"攻击": 10, 
		"防御": 10, 
		"物防": 10, 
		"魔防": 10, 
		"魔抗": 10, 
		"暴击": 0, 
		"闪避": 0, 
		"幸运": 0, 
		"回血": 0, 
		"回魔": 0, 
		"悟性": 0, 
		"根骨": 0, 
		"灵力": 0, 
		"技能": [], 
		"装备": {}, 
		"出战": true, 
	}

func _init() -> void :
	call_deferred("_run")

func _run() -> void :
	var player_data: = root.get_node_or_null("PlayerData")
	_check(player_data != null, "PlayerData 未加载")
	if player_data == null:
		_finish()
		return
	var levels: Dictionary = player_data.call("get_pet_formation_levels")
	for stat_name in levels:
		levels[stat_name] = 1
	var expected: = {"攻击": 50, "生命": 400, "防御": 25, "魔防": 25}
	var scenes: = {
		"PetTiger": "res://Scene/Pet/PetTigerSummon_1.tscn", 
		"PetDragon": "res://Scene/Pet/PetDragonSummon_1.tscn", 
		"PetPhoenix": "res://Scene/Pet/PetPhoenixSummon_1.tscn", 
		"PetTurtle": "res://Scene/Pet/PetTurtleSummon_1.tscn", 
		"PetRabbit": "res://Scene/Pet/PetRabbitSummon_1.tscn", 
		"PetMouse": "res://Scene/Pet/PetMouseSummon_1.tscn", 
		"PetNeat": "res://Scene/Pet/PetNeatSummon_1.tscn", 
		"PetYinTiger": "res://Scene/Pet/PetYinTigerSummon_1.tscn", 
	}
	for pet_type in scenes:
		var scene: = load(str(scenes[pet_type])) as PackedScene
		_check(scene != null, "%s 场景无法加载" % pet_type)
		if scene == null:
			continue
		var unit: = scene.instantiate()
		root.add_child(unit)
		await process_frame
		if unit.has_method("apply_pet_data"):
			unit.call("apply_pet_data", _pet_data(pet_type))
			await process_frame
		_check(int(unit.get("attack_in")) == 60, "%s 战斗攻击未包含阵法: %s" % [pet_type, unit.get("attack_in")])
		_check(int(unit.get("SHp")) >= 500, "%s 战斗生命未包含阵法: %s" % [pet_type, unit.get("SHp")])
		_check(int(unit.get("def")) >= 35, "%s 战斗物防未包含阵法: %s" % [pet_type, unit.get("def")])
		_check(int(unit.get("mdef")) >= 35, "%s 战斗魔防未包含阵法: %s" % [pet_type, unit.get("mdef")])
		unit.queue_free()
		await process_frame
	_finish()

func _finish() -> void :
	if failures.is_empty():
		print("PET_FORMATION_RUNTIME_PROBE_OK")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)
