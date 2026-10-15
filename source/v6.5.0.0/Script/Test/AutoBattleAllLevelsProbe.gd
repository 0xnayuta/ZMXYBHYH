extends Node

var _failed: = false

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	var level_files: = DirAccess.get_files_at("res://Scene/Level")
	level_files.sort()
	var checked: = 0
	for file_name_value in level_files:
		var file_name: = str(file_name_value)
		if not file_name.begins_with("Level_") or file_name.get_extension().to_lower() != "tscn":
			continue
		var level_path: = "res://Scene/Level/" + file_name
		var resource: = ResourceLoader.load(level_path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
		_check(resource != null, "关卡无法加载：%s" % level_path)
		if resource == null:
			continue
		var instance: = resource.instantiate()
		_check(instance != null, "关卡无法实例化：%s" % level_path)
		if instance != null:
			instance.free()
		checked += 1
		if checked % 10 == 0:
			await get_tree().process_frame
	_check(checked == 114, "关卡数量异常：期望114，实际%d" % checked)
	Global.clear_level_resource_cache()
	if not _failed:
		print("AUTO_BATTLE_ALL_LEVELS_PROBE_OK levels=%d" % checked)
	get_tree().quit(1 if _failed else 0)

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("AUTO_BATTLE_ALL_LEVELS_PROBE_FAIL " + message)
