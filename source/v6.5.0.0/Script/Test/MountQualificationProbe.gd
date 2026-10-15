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
		push_error("MOUNT_QUALIFICATION_FAIL: PlayerData 未加载")
		quit(1)
		return
	var original: Dictionary = data.player_data.duplicate(true)
	data.player_data["玩家等级"] = 126
	var mounts: = data.call("ensure_mount_data") as Array
	for mount_value in mounts:
		if mount_value is Dictionary:
			mount_value[data.MOUNT_UNLOCKED_KEY] = true
			for key in data.MOUNT_QUALIFICATION_KEYS:
				_check(int(mount_value.get("%s上限" % key, 0)) == data.MOUNT_QUALIFICATION_MAX, "%s 的%s上限不是2050" % [str(mount_value.get("名称", "坐骑")), key])
	for skill_id_value in MOUNT_CATALOG.OFFICIAL_COMBAT.keys():
		var skill_id: = str(skill_id_value)
		var raw_value: Variant = MOUNT_CATALOG.OFFICIAL_COMBAT.get(skill_id, {})
		var raw: Dictionary = raw_value if raw_value is Dictionary else {}
		var scaled: = MOUNT_CATALOG.get_official_combat(skill_id)
		if bool(raw.get("buff", false)):
			continue
		_check(is_equal_approx(float(scaled.get("power", 0.0)), float(raw.get("power", 0.0)) * 2.0), "%s 基础伤害率没有翻倍" % skill_id)
		_check(is_equal_approx(float(scaled.get("add", 0.0)), float(raw.get("add", 0.0)) * 2.0), "%s 升级成长率没有翻倍" % skill_id)
	var mount: = data.call("get_mount_by_id", "1002200") as Dictionary
	for key in data.MOUNT_QUALIFICATION_KEYS:
		mount[key] = 1000
		mount["%s上限" % key] = 999
	data.call("ensure_mount_data")
	for key in data.MOUNT_QUALIFICATION_KEYS:
		_check(int(mount.get("%s上限" % key, 0)) == 2050, "旧存档%s上限没有迁移到2050" % key)
	data.call("add_dj", "139300016", 4)
	var material_before: = int(data.call("get_inventory_item_count", "139300016"))
	var before_values: Dictionary = {}
	for key in data.MOUNT_QUALIFICATION_KEYS:
		before_values[key] = int(mount.get(key, 0))
	var result: = data.call("upgrade_mount_random_qualification", "1002200") as Dictionary
	_check(bool(result.get("success", false)), "有材料时无法提升坐骑资质")
	_check(int(data.call("get_inventory_item_count", "139300016")) == material_before - 1, "资质提升没有消耗1个对应解锁材料")
	var changed_count: = 0
	for key in data.MOUNT_QUALIFICATION_KEYS:
		var gain: = int(mount.get(key, 0)) - int(before_values.get(key, 0))
		if gain != 0:
			changed_count += 1
			_check(gain >= 100 and gain <= 150, "%s 单次提升不在100-150范围" % key)
	_check(changed_count == 1, "单次培养没有只随机提升一项资质")
	for key in data.MOUNT_QUALIFICATION_KEYS:
		mount[key] = 2050
	var full_material_before: = int(data.call("get_inventory_item_count", "139300016"))
	var full_result: = data.call("upgrade_mount_random_qualification", "1002200") as Dictionary
	_check( not bool(full_result.get("success", false)) and str(full_result.get("reason", "")) == "max", "资质满2050后仍可继续培养")
	_check(int(data.call("get_inventory_item_count", "139300016")) == full_material_before, "资质满级失败时仍消耗了材料")
	mount["生命资质"] = 1900
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
	var qualification_button: = panel.find_child("MountQualificationButton", true, false) as Button
	_check(qualification_button != null, "坐骑属性页没有资质提升按钮")
	_check(_find_text(panel, "/2050"), "坐骑属性页没有显示2050资质上限")
	_check(_find_text(panel, "战神虎爪"), "资质培养没有显示对应坐骑解锁材料")
	if qualification_button != null:
		qualification_button.pressed.emit()
		await process_frame
		_check(int(data.call("get_inventory_item_count", "139300016")) == full_material_before - 1, "界面资质提升按钮没有消耗材料")
	await _save("mount_qualification_upgrade.png")
	data.player_data = original
	if failures.is_empty():
		print("MOUNT_QUALIFICATION_OK")
		quit(0)
		return
	for failure in failures:
		push_error("MOUNT_QUALIFICATION_FAIL: %s" % failure)
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
		print("MOUNT_QUALIFICATION_SCREENSHOT_SKIPPED:%s" % file_name)
		return
	var viewport: = root.get_viewport()
	var viewport_texture: = viewport.get_texture() if viewport != null else null
	if viewport_texture == null:
		print("MOUNT_QUALIFICATION_SCREENSHOT_SKIPPED:%s" % file_name)
		return
	var image: = viewport_texture.get_image()
	if image == null or image.is_empty():
		print("MOUNT_QUALIFICATION_SCREENSHOT_SKIPPED:%s" % file_name)
		return
	var path: = OS.get_environment("TEMP").path_join(file_name)
	_check(image.save_png(path) == OK, "截图保存失败: %s" % path)
	print("MOUNT_QUALIFICATION_SCREENSHOT:%s" % path)
