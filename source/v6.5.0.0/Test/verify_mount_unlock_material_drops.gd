extends Node

class DropLevelStub:
	extends Node

	var fall_it: Node2D
	var Role_ = null

	func _init() -> void :
		fall_it = Node2D.new()
		fall_it.name = "fall_items"
		add_child(fall_it)

const MATERIAL_IDS: = [
	"139300016", 
	"139300014V1", 
	"139300012", 
	"139300018", 
	"139300021", 
	"139300017", 
]

const LEVEL_DROP_CASES: = [
	{"script": "res://Script/Level/Level_49.gd", "boss_id": 3007, "material_id": "139300014V1", "name": "未央宫金之祖巫"}, 
	{"script": "res://Script/Level/Level_52.gd", "boss_id": 3021, "material_id": "139300012", "name": "神光金岭木之祖巫"}, 
	{"script": "res://Script/Level/Level_55.gd", "boss_id": 3035, "material_id": "139300018", "name": "法华灵洞水之祖巫"}, 
	{"script": "res://Script/Level/Level_58.gd", "boss_id": 3042, "material_id": "139300021", "name": "金顶云海火之祖巫"}, 
	{"script": "res://Script/Level/Level_61.gd", "boss_id": 3078, "material_id": "139300017", "name": "万佛朝阁土之祖巫最终形态"}, 
]

var failures: Array[String] = []

func _ready() -> void :
	_verify_tongtian_drop()
	for drop_case in LEVEL_DROP_CASES:
		_verify_level_drop(drop_case)
	_verify_wanfo_phase_drop_assignment()
	call_deferred("_finish")

func _verify_tongtian_drop() -> void :
	var boss_script: GDScript = load("res://Script/Monster/Monster_1460.gd")
	_check(boss_script != null, "通天教主脚本应可加载")
	if boss_script == null:
		return
	var boss = boss_script.new()
	boss.call("_configure_boss")
	_check(bool(boss.get("is_boss")), "1460应配置为通天教主Boss")
	_verify_single_material_drop(Array(boss.get("independent_fall_list")), "139300016", "碧游宫通天教主")
	boss.free()
	boss = null
	boss_script = null

func _verify_level_drop(drop_case: Dictionary) -> void :
	var level_script: GDScript = load(str(drop_case["script"]))
	_check(level_script != null, "%s关卡脚本应可加载" % str(drop_case["name"]))
	if level_script == null:
		return
	var level = level_script.new()
	var config: Dictionary = level.call("get_level_monster_config", int(drop_case["boss_id"]))
	_check(bool(config.get("is_boss", false)), "%s应为Boss配置" % str(drop_case["name"]))
	_verify_single_material_drop(Array(config.get("independent_drop_list", [])), str(drop_case["material_id"]), str(drop_case["name"]))
	level.free()
	level = null
	level_script = null

func _verify_wanfo_phase_drop_assignment() -> void :
	var level_script: GDScript = load("res://Script/Level/Level_61.gd")
	var level = level_script.new()
	for transition_form_id in [3071, 3077]:
		var transition_config: Dictionary = level.call("get_level_monster_config", transition_form_id)
		_check(
			_find_material_drop(Array(transition_config.get("independent_drop_list", [])), "139300017").is_empty(), 
			"万佛朝阁过渡形态%d不应提前结算飞鱼尾鳍" % transition_form_id
		)
	var final_scene: PackedScene = load("res://Scene/Monster/Monster_3078.tscn")
	_check(final_scene != null, "万佛朝阁最终形态场景应可加载")
	if final_scene != null:
		var final_boss = final_scene.instantiate()
		final_boss.call("_configure_form", level.call("get_level_monster_config", 3078))
		_verify_single_material_drop(Array(final_boss.get("independent_fall_list")), "139300017", "万佛朝阁最终形态运行时")
		await _verify_forced_runtime_drop(final_boss)
		final_boss.free()
		final_boss = null
	level.free()
	level = null
	level_script = null

func _verify_forced_runtime_drop(final_boss: BaseMonster) -> void :
	var original_auto_pickup: = bool(MainSet.set_data.get("AutomaticallyPickUpItems", false))
	MainSet.set_data["AutomaticallyPickUpItems"] = false
	var level_stub: = DropLevelStub.new()
	add_child(level_stub)
	final_boss.set("BaseLevel_", level_stub)
	final_boss.set("level_cache_valid", true)
	final_boss.set("fall_list", [])
	final_boss.set("independent_fall_list", [
		{"name": "139300017", "value": 1, "chance": 1.0}, 
	])
	final_boss.call("fall_items")
	await get_tree().process_frame
	var spawned_fish_fin: = false
	for dropped_item in level_stub.fall_it.get_children():
		if str(dropped_item.get("item_name")) == "139300017" and int(dropped_item.get("num_")) == 1:
			spawned_fish_fin = true
			break
	_check(spawned_fish_fin, "万佛朝阁最终形态死亡掉落管线应生成1个飞鱼尾鳍")
	level_stub.free()
	level_stub = null
	MainSet.set_data["AutomaticallyPickUpItems"] = original_auto_pickup

func _verify_single_material_drop(drop_list: Array, expected_material_id: String, source_name: String) -> void :
	var matched_drop: Dictionary = {}
	var material_drop_count: = 0
	for drop in drop_list:
		if not drop is Dictionary:
			continue
		var drop_id: = str(drop.get("name", ""))
		if drop_id in MATERIAL_IDS:
			material_drop_count += 1
		if drop_id == expected_material_id:
			matched_drop = drop
	_check(material_drop_count == 1, "%s只能配置对应的一种坐骑解锁材料" % source_name)
	_check( not matched_drop.is_empty(), "%s应掉落材料%s" % [source_name, expected_material_id])
	if matched_drop.is_empty():
		return
	_check(is_equal_approx(float(matched_drop.get("chance", 0.0)), 0.1), "%s材料基础掉落概率应为10%%" % source_name)
	var min_value: = int(matched_drop.get("min_value", matched_drop.get("value", 0)))
	var max_value: = int(matched_drop.get("max_value", matched_drop.get("value", 0)))
	_check(min_value == 1 and max_value == 1, "%s材料每次应固定掉落1个" % source_name)

func _find_material_drop(drop_list: Array, material_id: String) -> Dictionary:
	for drop in drop_list:
		if drop is Dictionary and str(drop.get("name", "")) == material_id:
			return drop
	return {}

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _finish() -> void :
	await get_tree().process_frame
	if failures.is_empty():
		print("MOUNT_UNLOCK_MATERIAL_DROPS_VERIFICATION_PASSED")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	print("MOUNT_UNLOCK_MATERIAL_DROPS_VERIFICATION_FAILED=%d" % failures.size())
	get_tree().quit(1)
