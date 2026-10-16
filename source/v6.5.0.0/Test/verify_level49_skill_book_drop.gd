extends Node
const DataKeys := preload("res://Script/Base/DataKeys.gd")

const LEVEL_SCRIPT_PATH := "res://Script/Level/Level_49.gd"
const BOSS_SCENE_PATH := "res://Scene/Monster/Monster_3007.tscn"
const LEVEL_INFO_SCENE_PATH := "res://Scene/other_scene/LevelInfo.tscn"

var failures: Array[String] = []


func _ready() -> void:
	var original_difficulty := int(MainSet.set_data.get("Difficult", 0))
	var original_monster_blood_show := bool(MainSet.set_data.get("MonsterBloodSHow", false))
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["MonsterBloodSHow"] = false
	AE.ensure_loaded()
	_check(AE.AllEquipment_.get("1_jns", {}).get(DataKeys.NAME, "") == "一阶技能书", "掉落物ID应对应一阶技能书")

	var level_script: GDScript = load(LEVEL_SCRIPT_PATH)
	var level = level_script.new()
	var config: Dictionary = level.get_level_monster_config(3007)
	_check(config.get("name", "") == "金之祖巫", "3007应为未央宫金之祖巫")

	var skill_book_drop := _find_skill_book_drop(config)
	_check(not skill_book_drop.is_empty(), "金之祖巫应配置一阶技能书独立掉落")
	_check(is_equal_approx(float(skill_book_drop.get("chance", 0.0)), 0.2), "一阶技能书基础掉落概率应为20%")
	_check(int(skill_book_drop.get("min_value", 0)) == 1, "一阶技能书最少应掉落1本")
	_check(int(skill_book_drop.get("max_value", 0)) == 1, "一阶技能书最多应掉落1本")

	for monster_id in [3001, 3002, 3004]:
		_check(_find_skill_book_drop(level.get_level_monster_config(monster_id)).is_empty(), "一阶技能书不应添加给未央宫普通怪物")

	var boss_scene: PackedScene = load(BOSS_SCENE_PATH)
	_check(boss_scene != null, "金之祖巫真实场景应可加载")
	if boss_scene != null:
		var boss = boss_scene.instantiate()
		boss.set("BaseLevel_", level)
		boss.set("level_cache_valid", true)
		boss.call("_configure_monster")
		var runtime_drop := _find_drop(Array(boss.get("independent_fall_list")))
		_check(not runtime_drop.is_empty(), "金之祖巫运行时应接收到一阶技能书掉落配置")
		_check(is_equal_approx(float(runtime_drop.get("chance", 0.0)), 0.2), "运行时一阶技能书基础概率应保持20%")
		add_child(boss)
		boss.set("independent_fall_list", [])
		boss.set("is_fall_medi", true)
		boss.set_physics_process(false)
		await get_tree().process_frame
		boss.set("Hp", 0)
		_check(bool(level.call("_is_stage_monster_node", boss)), "金之祖巫死亡动画期间仍应阻止结算出口出现")
		var boss_reference: WeakRef = weakref(boss)
		boss.call("state_death")
		await get_tree().create_timer(2.3).timeout
		await get_tree().process_frame
		_check(boss_reference.get_ref() == null, "金之祖巫死亡动画结束后应完成结算并释放")

	var level_info_scene: PackedScene = load(LEVEL_INFO_SCENE_PATH)
	_check(level_info_scene != null, "战斗信息框场景应可加载")
	if level_info_scene != null:
		var level_info_panel = level_info_scene.instantiate()
		level_info_panel.LevelName = "未央宫"
		level_info_panel.TargetStagePath = "res://Scene/Level/Level_49.tscn"
		add_child(level_info_panel)
		await get_tree().physics_frame
		await get_tree().process_frame
		await get_tree().process_frame
		var preview_list := level_info_panel.get_node("ColorRect/TextureRect/ScrollContainer/FallList") as HBoxContainer
		var preview_box: Button = null
		for child in preview_list.get_children():
			if child is Button and str(child.get_meta("fall_item_name", "")) == "1_jns":
				preview_box = child
				break
		_check(preview_box != null, "未央宫战斗信息框应预览一阶技能书")
		if preview_box != null:
			_check(preview_box.icon != null, "战斗信息框中的一阶技能书应显示图标")
			var probability_text := ""
			for child in preview_box.get_children():
				if child is Label and child.has_meta("prob_label"):
					probability_text = child.text
					break
			_check(probability_text == "20%", "普通难度战斗信息框应显示20%概率")
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			var screenshot_path := OS.get_temp_dir().path_join("level49_skill_book_drop_preview.png")
			var screenshot := get_viewport().get_texture().get_image()
			_check(screenshot != null and _image_has_visible_pixels(screenshot), "未央宫战斗信息框截图不应为空白")
			_check(screenshot != null and screenshot.save_png(screenshot_path) == OK, "未央宫战斗信息框截图应可生成")
			print("LEVEL49_SKILL_BOOK_DROP_SCREENSHOT=" + screenshot_path)
		level_info_panel.free()

	MainSet.set_data["Difficult"] = original_difficulty
	MainSet.set_data["MonsterBloodSHow"] = original_monster_blood_show
	level.free()
	boss_scene = null
	level_info_scene = null
	level_script = null
	call_deferred("_finish")


func _find_skill_book_drop(config: Dictionary) -> Dictionary:
	return _find_drop(Array(config.get("independent_drop_list", [])))


func _find_drop(drop_list: Array) -> Dictionary:
	for drop in drop_list:
		if drop is Dictionary and drop.get("name", "") == "1_jns":
			return drop
	return {}


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _image_has_visible_pixels(image: Image) -> bool:
	for y in range(0, image.get_height(), 16):
		for x in range(0, image.get_width(), 16):
			var color := image.get_pixel(x, y)
			if color.r + color.g + color.b > 0.12:
				return true
	return false


func _finish() -> void:
	await get_tree().process_frame
	if failures.is_empty():
		print("LEVEL49_SKILL_BOOK_DROP_VERIFICATION_PASSED")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	print("LEVEL49_SKILL_BOOK_DROP_VERIFICATION_FAILED=%d" % failures.size())
	get_tree().quit(1)
