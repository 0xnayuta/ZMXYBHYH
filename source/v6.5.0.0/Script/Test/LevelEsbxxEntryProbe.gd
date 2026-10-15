extends SceneTree

const LEVEL_SCENE_PATH: = "res://Scene/Level/Level_esbxx.tscn"
const SETTINGS_PROBE_PATH: = "user://_level_esbxx_settings_probe.json"


func _init() -> void :
	call_deferred("_run")


func _run() -> void :
	if not _verify_main_settings_failures():
		return
	if not await _verify_entry_tier_and_monster_count():
		return
	print("LEVEL_ESBXX_ENTRY_OK settings_null_guard tier_reset count=3 all_dead_gate")
	quit(0)


func _verify_main_settings_failures() -> bool:
	var memory_class: = root.get_node_or_null("MemoryClass")
	if memory_class == null:
		return _fail("MemoryClass autoload")
	_remove_settings_probe()
	memory_class.call("_load_main_settings", SETTINGS_PROBE_PATH)

	var empty_file: = FileAccess.open(SETTINGS_PROBE_PATH, FileAccess.WRITE)
	if empty_file == null:
		return _fail("create empty settings probe")
	empty_file.close()
	memory_class.call("_load_main_settings", SETTINGS_PROBE_PATH)
	_remove_settings_probe()
	return true


func _verify_entry_tier_and_monster_count() -> bool:
	var level_scene: = load(LEVEL_SCENE_PATH) as PackedScene
	if level_scene == null:
		return _fail("load level scene")
	var global: = root.get_node_or_null("Global")
	var main_set: = root.get_node_or_null("MainSet")
	if global == null or main_set == null:
		return _fail("level autoloads")

	global.set("SelectedConstellationLevel", 1)
	var best_tiers: Dictionary = global.get("ConstellationBestTier")
	best_tiers["1"] = 10
	global.set("cd_path", "")
	var settings: Dictionary = main_set.get("set_data")
	settings["CreateMonsterCount"] = 3
	var level: = level_scene.instantiate()
	root.add_child(level)
	if not await _wait_for_boss_count(level, 3):
		var actual_bosses: Array = level.get("_boss_instances")
		var monster_node: = level.get_node_or_null("Monster")
		level.queue_free()
		return _fail(
			"CreateMonsterCount=3 actual=%d multiplier=%d children=%d" % [
				actual_bosses.size(), int(level.get("_boss_count_multiplier")), 
				monster_node.get_child_count() if monster_node != null else -1, 
			]
		)
	if int(level.get("current_tier")) != 1:
		level.queue_free()
		return _fail("first entry tier")
	for index in range(3):
		var spawn_position: Vector2 = level.call("_get_boss_spawn_position", index)
		if not is_equal_approx(spawn_position.y, 438.0):
			level.queue_free()
			return _fail("boss spawn height")

	var bosses: Array = level.get("_boss_instances").duplicate()
	for index in range(bosses.size()):
		var boss: Node = bosses[index]
		boss.set("Hp", 0)
		level.call("on_constellation_boss_defeated", boss)
		if index < bosses.size() - 1 and int(level.get("current_tier")) != 1:
			level.queue_free()
			return _fail("advanced before all bosses died")
	if int(level.get("current_tier")) != 2:
		level.queue_free()
		return _fail("did not advance after all bosses died")
	level.queue_free()
	await process_frame

	settings["CreateMonsterCount"] = 1
	var retry_level: = level_scene.instantiate()
	root.add_child(retry_level)
	if not await _wait_for_boss_count(retry_level, 1):
		retry_level.queue_free()
		return _fail("CreateMonsterCount=1")
	if int(retry_level.get("current_tier")) != 1:
		retry_level.queue_free()
		return _fail("retry entry tier")
	retry_level.queue_free()
	await process_frame
	return true


func _wait_for_boss_count(level: Node, expected: int) -> bool:
	for _frame in range(300):
		if not is_instance_valid(level):
			return false
		var bosses: Array = level.get("_boss_instances")
		if bosses.size() == expected:
			for boss in bosses:
				if not is_instance_valid(boss):
					return false
			return true
		await process_frame
	return false


func _remove_settings_probe() -> void :
	if FileAccess.file_exists(SETTINGS_PROBE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS_PROBE_PATH))


func _fail(reason: String) -> bool:
	_remove_settings_probe()
	push_error("LEVEL_ESBXX_ENTRY_FAIL %s" % reason)
	quit(1)
	return false
