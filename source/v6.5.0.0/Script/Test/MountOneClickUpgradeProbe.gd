extends SceneTree

var failures: Array[String] = []

func _initialize() -> void :
	call_deferred("_run")

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _run() -> void :
	var data: = root.get_node_or_null("PlayerData")
	if data == null:
		push_error("MOUNT_ONE_CLICK_FAIL: PlayerData 未加载")
		quit(1)
		return
	var original: Dictionary = data.player_data.duplicate(true)
	data.player_data["玩家等级"] = 5
	var mounts: = data.call("ensure_mount_data") as Array
	for mount_value in mounts:
		if mount_value is Dictionary:
			mount_value[data.MOUNT_UNLOCKED_KEY] = true
	var mount: = data.call("get_mount_by_id", "1002200") as Dictionary
	mount["等级"] = 1
	mount["经验"] = 80
	data.call("set_soul", 5000)
	var full_result: = data.call("upgrade_mount_to_level_limit", "1002200") as Dictionary
	_check(bool(full_result.get("success", false)), "灵魂足够时一键升级失败")
	_check(int(mount.get("等级", 0)) == 5, "一键升级没有升到人物当前等级")
	_check(int(full_result.get("cost", 0)) == 5000, "一键升级逐级灵魂消耗计算错误")
	_check(int(data.call("get_soul")) == 0, "一键升级没有正确扣除总灵魂")
	_check(int(mount.get("经验", -1)) == 0, "一键升级后经验没有归零")
	data.player_data["玩家等级"] = 10
	mount["等级"] = 1
	mount["经验"] = 0
	data.call("set_soul", 1600)
	var partial_result: = data.call("upgrade_mount_to_level_limit", "1002200") as Dictionary
	_check(bool(partial_result.get("success", false)), "灵魂只够部分等级时一键升级失败")
	_check(int(mount.get("等级", 0)) == 3, "一键升级没有在灵魂不足前停止")
	_check(int(partial_result.get("cost", 0)) == 1500 and int(data.call("get_soul")) == 100, "部分一键升级扣费错误")
	mount["等级"] = 1
	data.call("set_soul", 400)
	var poor_result: = data.call("upgrade_mount_to_level_limit", "1002200") as Dictionary
	_check( not bool(poor_result.get("success", false)) and str(poor_result.get("reason", "")) == "soul", "灵魂不足时没有正确阻止一键升级")
	_check(int(mount.get("等级", 0)) == 1 and int(data.call("get_soul")) == 400, "一键升级失败后仍修改了等级或灵魂")
	data.call("set_soul", 10000)
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
	var train_button: = panel.find_child("MountTrainButton", true, false) as Button
	var train_all_button: = panel.find_child("MountTrainAllButton", true, false) as Button
	_check(train_button != null, "普通升级按钮缺失")
	_check(train_all_button != null, "一键升级按钮缺失")
	if train_button != null and train_all_button != null:
		_check(train_all_button.position.x > train_button.position.x and is_equal_approx(train_all_button.position.y, train_button.position.y), "一键升级按钮没有放在升级按钮右侧")
		train_all_button.pressed.emit()
		await process_frame
		_check(int(mount.get("等级", 0)) > 1, "界面一键升级按钮没有实际升级坐骑")
		_check(_find_text(panel, "一键升级"), "界面没有显示一键升级结果")
	await _save("mount_one_click_upgrade.png")
	data.player_data = original
	if failures.is_empty():
		print("MOUNT_ONE_CLICK_OK")
		quit(0)
		return
	for failure in failures:
		push_error("MOUNT_ONE_CLICK_FAIL: %s" % failure)
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
		print("MOUNT_ONE_CLICK_SCREENSHOT_SKIPPED:%s" % file_name)
		return
	var viewport: = root.get_viewport()
	var viewport_texture: = viewport.get_texture() if viewport != null else null
	if viewport_texture == null:
		print("MOUNT_ONE_CLICK_SCREENSHOT_SKIPPED:%s" % file_name)
		return
	var image: = viewport_texture.get_image()
	if image == null or image.is_empty():
		print("MOUNT_ONE_CLICK_SCREENSHOT_SKIPPED:%s" % file_name)
		return
	var path: = OS.get_environment("TEMP").path_join(file_name)
	_check(image.save_png(path) == OK, "截图保存失败: %s" % path)
	print("MOUNT_ONE_CLICK_SCREENSHOT:%s" % path)
