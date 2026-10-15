extends Node

const LEVEL_PATH: = "res://Scene/Level/Level_esbxx.tscn"

var failures: Array[String] = []
var _original_level_info_setting: Variant
var _original_selected_level: = 1
var _original_current_level: = ""

func _ready() -> void :
	_original_level_info_setting = MainSet.set_data.get("LevelInfo", false)
	_original_selected_level = int(Global.SelectedConstellationLevel)
	_original_current_level = str(Global.CurrentLevel)
	MainSet.set_data["LevelInfo"] = false
	Global.SelectedConstellationLevel = 0

	var popup = Global.AddLevelInfo(self, "挑战28星宿", Vector2.ZERO, LEVEL_PATH)
	_check(popup != null, "星宿入口应强制打开关卡信息选择页")
	if popup == null:
		_finish()
		return

	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().process_frame

	var title: = popup.get_node_or_null("ColorRect/TextureRect/Title") as Label
	var monster_list: = popup.get_node_or_null("ColorRect/TextureRect/ScrollContainer2/MonsterList") as HBoxContainer
	_check(title != null and monster_list != null, "星宿选择页应复用 Level_stz 的头像选择布局")
	if title == null or monster_list == null:
		popup.queue_free()
		_finish()
		return

	var selectable_heads: Array[Node] = []
	for child in monster_list.get_children():
		if child.has_meta("constellation_level"):
			selectable_heads.append(child)
			var icon: = child.get_node_or_null("pic") as Sprite2D
			_check(icon != null and icon.texture != null, "每个星宿选择项都应显示Boss头像")
	_check(selectable_heads.size() == 14, "星宿选择页应生成14个可点击Boss头像")

	if selectable_heads.size() == 14:
		var selected_head: = selectable_heads[7]
		selected_head.emit_signal("selection_requested", selected_head)
		await get_tree().process_frame
		_check(Global.SelectedConstellationLevel == 8, "点击Boss头像应保存对应星宿编号")
		_check(bool(selected_head.get("IsSelected")), "点击的Boss头像应显示选中状态")
		_check(title.text == "挑战28星宿 · 壁宿", "选择Boss后标题应显示当前星宿")

	if DisplayServer.get_name() != "headless":
		await get_tree().process_frame
		var screenshot: = get_viewport().get_texture().get_image()
		var screenshot_path: = OS.get_temp_dir().path_join("esbxx_popup_verification.png")
		_check(screenshot != null and screenshot.save_png(screenshot_path) == OK, "星宿头像选择页截图应可生成")
		print("ESBXX_POPUP_SCREENSHOT=" + screenshot_path)

	popup.queue_free()
	_finish()

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _restore_state() -> void :
	MainSet.set_data["LevelInfo"] = _original_level_info_setting
	Global.SelectedConstellationLevel = _original_selected_level
	Global.CurrentLevel = _original_current_level

func _finish() -> void :
	_restore_state()
	if failures.is_empty():
		print("ESBXX_POPUP_VERIFICATION_PASSED")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	print("ESBXX_POPUP_VERIFICATION_FAILED=%d" % failures.size())
	get_tree().quit(1)
