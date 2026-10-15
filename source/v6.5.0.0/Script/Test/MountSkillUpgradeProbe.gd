extends SceneTree

const MOUNT_CATALOG: = preload("res://Script/Mount/MountCatalog.gd")

var failures: Array[String] = []

func _initialize() -> void :
	call_deferred("_run")

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _run() -> void :
	var data: = root.get_node_or_null("PlayerData")
	if data == null:
		push_error("MOUNT_SKILL_UPGRADE_FAIL: PlayerData 未加载")
		quit(1)
		return
	var original: Dictionary = data.player_data.duplicate(true)
	data.player_data["玩家等级"] = 126
	data.player_data["coin_num"] = 1000000
	var mounts: = data.call("ensure_mount_data") as Array
	for mount_value in mounts:
		if mount_value is Dictionary:
			mount_value[data.MOUNT_UNLOCKED_KEY] = true
	var mount: = data.call("get_mount_by_id", "1002200") as Dictionary
	var skills: = MOUNT_CATALOG.get_skills("1002200")
	_check((mount.get("技能等级", {}) as Dictionary).size() == skills.size(), "旧存档没有补齐全部坐骑技能等级")
	var skill: Dictionary = skills[0]
	var skill_id: = str(skill.get("id", ""))
	_check(int(data.call("get_mount_skill_level", "1002200", skill_id)) == 1, "坐骑技能默认等级不是1")
	var combat: = MOUNT_CATALOG.get_official_combat(skill_id)
	var expected_level_1: = float(combat.get("power", 0.0)) + float(combat.get("add", 0.0))
	_check(is_equal_approx(float(data.call("get_mount_skill_damage_multiplier", "1002200", skill_id)), expected_level_1), "1级伤害倍率没有使用官方power + add × level")
	var soul_before: = int(data.call("get_soul"))
	var cost: = int(data.call("get_mount_skill_upgrade_cost", "1002200", skill_id))
	_check(bool(data.call("upgrade_mount_skill", "1002200", skill_id)), "坐骑技能无法升级")
	_check(int(data.call("get_mount_skill_level", "1002200", skill_id)) == 2, "坐骑技能升级后等级没有加1")
	_check(int(data.call("get_soul")) == soul_before - cost, "坐骑技能升级没有正确扣除灵魂")
	var levels: Dictionary = mount.get("技能等级", {})
	levels[skill_id] = 19
	mount["技能等级"] = levels
	_check(bool(data.call("upgrade_mount_skill", "1002200", skill_id)), "19级技能无法升到20级")
	_check(int(data.call("get_mount_skill_level", "1002200", skill_id)) == 20, "坐骑技能最高等级不是20级")
	_check( not bool(data.call("upgrade_mount_skill", "1002200", skill_id)), "20级技能仍可继续升级")
	var effect_script: = load("res://Script/Mount/MountSkillEffect.gd") as Script
	_check(effect_script != null, "坐骑技能战斗脚本无法加载")
	if effect_script != null:
		var effect: Node = effect_script.new()
		effect.mount_id = "1002200"
		effect.skill = skill.duplicate(true)
		_check(int(effect.call("_get_official_skill_level")) == 20, "战斗伤害没有读取独立坐骑技能等级")
		effect.free()
	levels[skill_id] = 1
	mount["技能等级"] = levels
	root.size = Vector2i(960, 640)
	var background: = ColorRect.new()
	background.color = Color("0a101b")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)
	var panel_scene: = load("res://Scene/Main_menu/MountPanel.tscn") as PackedScene
	var panel: = panel_scene.instantiate()
	root.add_child(panel)
	await process_frame
	await process_frame
	var skill_button: = panel.find_child("MountSkillButton_%s" % skill_id, true, false) as Button
	_check(skill_button != null, "坐骑技能图标没有可点击按钮")
	if skill_button != null:
		skill_button.pressed.emit()
		await process_frame
		_check(panel.find_child("MountSkillUpgradePopup", true, false) != null, "点击技能图标没有弹出升级页面")
		_check(_find_text(panel, "当前技能伤害"), "技能升级页面没有显示当前技能伤害")
		_check(_find_text(panel, "升级后技能伤害"), "技能升级页面没有显示升级后技能伤害")
		_check(_find_text(panel, "Lv.1 / 20"), "技能升级页面没有显示1到20级上限")
		var upgrade_button: = panel.find_child("MountSkillUpgradeButton", true, false) as Button
		_check(upgrade_button != null and not upgrade_button.disabled, "技能升级按钮不可用")
		if upgrade_button != null:
			upgrade_button.pressed.emit()
			await process_frame
			_check(int(data.call("get_mount_skill_level", "1002200", skill_id)) == 2, "弹窗升级按钮没有实际提升技能等级")
			_check(_find_text(panel, "Lv.2 / 20"), "升级后弹窗没有刷新等级")
		await _save("mount_skill_upgrade_popup.png")
	data.player_data = original
	if failures.is_empty():
		print("MOUNT_SKILL_UPGRADE_OK")
		quit(0)
		return
	for failure in failures:
		push_error("MOUNT_SKILL_UPGRADE_FAIL: %s" % failure)
	quit(1)

func _find_text(node: Node, value: String) -> bool:
	for child in node.get_children():
		if child is Label and str(child.text).contains(value):
			return true
		if _find_text(child, value):
			return true
	return false

func _save(file_name: String) -> void :
	RenderingServer.force_draw()
	await process_frame
	if DisplayServer.get_name() == "headless":
		print("MOUNT_SKILL_UPGRADE_SCREENSHOT_SKIPPED:%s" % file_name)
		return
	var viewport: = root.get_viewport()
	var viewport_texture: = viewport.get_texture() if viewport != null else null
	if viewport_texture == null:
		print("MOUNT_SKILL_UPGRADE_SCREENSHOT_SKIPPED:%s" % file_name)
		return
	var image: = viewport_texture.get_image()
	if image == null or image.is_empty():
		print("MOUNT_SKILL_UPGRADE_SCREENSHOT_SKIPPED:%s" % file_name)
		return
	var path: = OS.get_environment("TEMP").path_join(file_name)
	_check(image.save_png(path) == OK, "截图保存失败: %s" % path)
	print("MOUNT_SKILL_UPGRADE_SCREENSHOT:%s" % path)
