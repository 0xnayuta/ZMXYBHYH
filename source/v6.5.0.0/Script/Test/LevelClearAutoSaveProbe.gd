extends Node

const TEST_ARCHIVE: = "user://MyAr_99.json"

var _failed: = false

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	_remove_test_files()
	Global.cd_path = TEST_ARCHIVE
	var victory_node: = Node2D.new()
	victory_node.set_script(load("res://Script/Level/victory.gd"))
	var saved: = bool(victory_node.call("_save_completed_level"))
	_check(saved, "胜利结算保存接口返回失败")
	_check(FileAccess.file_exists(TEST_ARCHIVE), "胜利结算没有生成存档文件")
	victory_node.free()
	_remove_test_files()
	if not _failed:
		print("LEVEL_CLEAR_AUTO_SAVE_PROBE_OK")
	get_tree().quit(1 if _failed else 0)

func _remove_test_files() -> void :
	for path in [TEST_ARCHIVE, TEST_ARCHIVE + ".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("LEVEL_CLEAR_AUTO_SAVE_PROBE_FAIL " + message)
