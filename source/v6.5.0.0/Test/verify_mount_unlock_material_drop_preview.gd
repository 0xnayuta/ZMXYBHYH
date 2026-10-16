extends Node

const LEVEL_INFO_SCENE_PATH := "res://Scene/OtherScene/LevelInfo.tscn"
const PREVIEW_CASES := [
	{"level_name": "通天教主", "stage_path": "res://Scene/Level/Level_46.tscn", "material_id": "139300016"},
	{"level_name": "未央宫", "stage_path": "res://Scene/Level/Level_49.tscn", "material_id": "139300014V1"},
	{"level_name": "神光金岭", "stage_path": "res://Scene/Level/Level_52.tscn", "material_id": "139300012"},
	{"level_name": "法华灵洞", "stage_path": "res://Scene/Level/Level_55.tscn", "material_id": "139300018"},
	{"level_name": "金顶云海", "stage_path": "res://Scene/Level/Level_58.tscn", "material_id": "139300021"},
	{"level_name": "万佛朝阁", "stage_path": "res://Scene/Level/Level_61.tscn", "material_id": "139300017"},
]

var failures: Array[String] = []


func _ready() -> void:
	var original_difficulty := int(MainSet.set_data.get("Difficult", 0))
	MainSet.set_data["Difficult"] = 0
	var level_info_scene: PackedScene = load(LEVEL_INFO_SCENE_PATH)
	_check(level_info_scene != null, "战斗信息框场景应可加载")
	if level_info_scene != null:
		for preview_case in PREVIEW_CASES:
			await _verify_preview(level_info_scene, preview_case)
	MainSet.set_data["Difficult"] = original_difficulty
	level_info_scene = null
	call_deferred("_finish")


func _verify_preview(level_info_scene: PackedScene, preview_case: Dictionary) -> void:
	var panel = level_info_scene.instantiate()
	panel.LevelName = str(preview_case["level_name"])
	panel.TargetStagePath = str(preview_case["stage_path"])
	add_child(panel)
	await get_tree().physics_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	var material_id := str(preview_case["material_id"])
	var fall_list := panel.get_node("ColorRect/TextureRect/ScrollContainer/FallList") as HBoxContainer
	var material_box: Button = null
	for child in fall_list.get_children():
		if child is Button and str(child.get_meta("fall_item_name", "")) == material_id:
			material_box = child
			break
	_check(material_box != null, "%s战斗信息框应显示材料%s" % [str(preview_case["level_name"]), material_id])
	if material_box != null:
		_check(material_box.icon != null, "%s材料图标应正常显示" % str(preview_case["level_name"]))
		var probability_text := ""
		for child in material_box.get_children():
			if child is Label and child.has_meta("prob_label"):
				probability_text = child.text
				break
		_check(probability_text == "10%", "%s普通难度应显示10%%概率" % str(preview_case["level_name"]))

	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var screenshot_path := OS.get_temp_dir().path_join("mount_drop_preview_%s.png" % material_id)
		var screenshot := get_viewport().get_texture().get_image()
		_check(
			screenshot != null and screenshot.save_png(screenshot_path) == OK,
			"%s截图应可生成" % str(preview_case["level_name"])
		)
		print("MOUNT_DROP_PREVIEW_SCREENSHOT=%s" % screenshot_path)

	panel.free()
	panel = null
	await get_tree().process_frame


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	await get_tree().process_frame
	if failures.is_empty():
		print("MOUNT_UNLOCK_MATERIAL_DROP_PREVIEW_VERIFICATION_PASSED")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	print("MOUNT_UNLOCK_MATERIAL_DROP_PREVIEW_VERIFICATION_FAILED=%d" % failures.size())
	get_tree().quit(1)
