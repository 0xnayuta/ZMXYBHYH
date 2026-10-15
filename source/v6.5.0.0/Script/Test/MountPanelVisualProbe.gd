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
		push_error("MOUNT_PANEL_VISUAL_FAIL: PlayerData 未加载")
		quit(1)
		return
	var original: Dictionary = data.player_data.duplicate(true)
	data.player_data["玩家等级"] = 126
	data.call("ensure_mount_data")
	root.size = Vector2i(960, 640)
	var bg: = ColorRect.new()
	bg.color = Color("0a101b")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var scene: = load("res://Scene/Main_menu/MountPanel.tscn") as PackedScene
	var panel: = scene.instantiate()
	root.add_child(panel)
	await process_frame
	await process_frame
	var initial_action: = panel.find_child("MountActionButton", true, false) as Button
	_check(initial_action != null and initial_action.text == "解锁", "未解锁坐骑没有显示解锁按钮")
	_check(panel.find_child("MountUnlockRequirement", true, false) != null, "未解锁坐骑没有显示材料需求")
	_check(_find_text(panel, "战神虎爪"), "西灵圣虎没有显示对应解锁材料")
	await _save("mount_panel_locked_unlock.png")
	var unlocked_mounts: = data.call("ensure_mount_data") as Array
	for mount_value in unlocked_mounts:
		if mount_value is Dictionary:
			mount_value[data.MOUNT_UNLOCKED_KEY] = true
	data.call("set_active_mount", "1002200")
	panel.call("_refresh")
	await process_frame
	_check(panel.find_child("MountSelfDrawnPanel", true, false) != null, "自绘坐骑面板未创建")
	_check(panel.find_child("MountPreview", true, false) != null, "坐骑模型未创建")
	_check(panel.find_child("MountExperience", true, false) == null, "左侧仍显示经验条")
	_check(panel.find_child("MountActionButton", true, false) != null, "出战按钮未创建")
	_check( not _has_official_texture(panel), "新页面仍引用官方坐骑页面贴图")
	_check(_page_count(panel) == 1, "属性页初始存在重复内容层")

	var mounts: = panel.call("_mounts_for_panel") as Array
	_check(mounts.size() == 6, "远古年兽没有从坐骑列表移除")
	for index in range(mounts.size()):
		panel.call("_select_mount_row", index)
		await process_frame
		_check(_page_count(panel) == 1, "切换坐骑后旧属性页没有清除")
		var mount: Dictionary = mounts[index] if mounts[index] is Dictionary else {}
		var mount_id: = str(mount.get("ID", ""))
		var preview: = panel.find_child("MountPreview", true, false) as Node2D
		var preview_host: = panel.find_child("MountPreviewViewport", true, false) as Control
		_check(preview != null and preview_host != null, "%s 预览节点缺失" % mount_id)
		if preview != null and preview_host != null:
			var expected_preview_id: = "1003100" if mount_id == "1002200" else mount_id
			_check(str(preview.get("mount_id")) == expected_preview_id, "%s 没有使用正确的预览模型 %s" % [mount_id, expected_preview_id])
			var bounds: Rect2 = preview.call("get_animation_visual_bounds")
			var displayed: = Rect2(preview.position + bounds.position * preview.scale, bounds.size * preview.scale)
			_check(displayed.position.x >= -1.0 and displayed.position.y >= -1.0, "%s 预览模型越出左上边界" % mount_id)
			_check(displayed.end.x <= preview_host.size.x + 1.0 and displayed.end.y <= preview_host.size.y + 1.0, "%s 预览模型被裁切" % mount_id)
			_check(displayed.get_center().distance_to(preview_host.size * 0.5) <= 1.0, "%s 预览模型没有居中" % mount_id)
		var skills: = MOUNT_CATALOG.get_skills(mount_id)
		var frames: = panel.find_children("MountSkillFrame_*", "PanelContainer", true, false)
		_check(frames.size() == skills.size(), "%s 技能图标边框数量不正确" % mount_id)
		for skill_value in skills:
			var skill: Dictionary = skill_value if skill_value is Dictionary else {}
			var skill_id: = str(skill.get("id", ""))
			_check(MOUNT_CATALOG.get_icon_path(skill_id) != "", "%s 技能 %s 缺少图标" % [mount_id, skill_id])
			_check(panel.find_child("MountSkillFrame_%s" % skill_id, true, false) != null, "%s 技能 %s 缺少边框" % [mount_id, skill_id])
		await _save("mount_panel_preview_%s.png" % mount_id)
	panel.call("_select_mount_row", 0)
	await process_frame
	_check(_find_text(panel, "西灵圣虎"), "坐骑名称没有显示西灵圣虎")
	_check(_find_text(panel, "等级"), "坐骑等级没有显示在右侧属性页")
	_check( not _find_text(panel, "战力"), "坐骑页面仍显示战力")
	_check( not _find_stat_percent(panel, "暴击"), "坐骑暴击属性仍然显示百分号")
	_check( not _find_stat_percent(panel, "命中"), "坐骑命中属性仍然显示百分号")
	_check( not _find_stat_percent(panel, "闪避"), "坐骑闪避属性仍然显示百分号")
	_check(_find_text(panel, "横扫千军") and _find_text(panel, "噬血虎爪"), "西灵圣虎普通技能显示不完整")
	_check(_find_text(panel, "战神之爪") and _find_text(panel, "虎啸风生") and _find_text(panel, "灵能聚变"), "西灵圣虎五个技能显示不完整")
	_check((MOUNT_CATALOG.get_skills("1002200") as Array).size() == 5, "西灵圣虎不是五个技能")
	await _save("mount_panel_self_drawn_property.png")
	panel.call("_select_tab", 1)
	await process_frame
	var equipment_page: = panel.find_child("Page_1", true, false)
	_check(equipment_page != null, "装备页未创建")
	_check(equipment_page != null and equipment_page.get_child_count() == 0, "装备页内容没有清空")
	await _save("mount_panel_self_drawn_equip.png")
	panel.call("_select_tab", 2)
	await process_frame
	var soul_page: = panel.find_child("Page_2", true, false)
	_check(soul_page != null, "兽魂页未创建")
	_check(soul_page != null and soul_page.get_child_count() == 0, "兽魂页内容没有清空")
	await _save("mount_panel_self_drawn_soul.png")
	var mount: = data.call("get_mount_by_id", "1002200") as Dictionary
	var old_life: = int(mount.get("生命", 0))
	mount["等级"] = mini(int(mount.get("等级", 1)) + 1, int(data.call("get_mount_level_limit")))
	data.call("_recalculate_mount_stats", mount)
	_check(int(mount.get("生命", 0)) >= old_life, "坐骑升级后生命属性未增加")
	var list_button: = panel.find_child("MountChangeButton", true, false) as Button
	if list_button != null:
		list_button.pressed.emit()
		await process_frame
		var list: = panel.find_child("MountChangeList", true, false) as Control
		_check(list != null and list.visible, "更换列表没有打开")
		_check(_find_text(list, "[出战]"), "更换列表没有标注当前出战坐骑")
		_check( not _find_text(list, "远古年兽"), "更换列表仍显示远古年兽")
		_check(list != null and list.z_index > 100, "更换坐骑列表层级低于坐骑部件")
		await _save("mount_panel_change_list.png")
	data.player_data = original
	if failures.is_empty():
		print("MOUNT_PANEL_VISUAL_OK")
		quit(0)
		return
	for failure in failures:
		push_error("MOUNT_PANEL_VISUAL_FAIL: %s" % failure)
	quit(1)

func _find_text(node: Node, value: String) -> bool:
	for child in node.get_children():
		if child is Label and str(child.text).contains(value):
			return true
		if _find_text(child, value):
			return true
	return false

func _find_stat_percent(node: Node, stat_name: String) -> bool:
	for child in node.get_children():
		if child is Label:
			var text: = str(child.text)
			if text.begins_with(stat_name + "：") and text.ends_with("%"):
				return true
		if _find_stat_percent(child, stat_name):
			return true
	return false

func _has_official_texture(node: Node) -> bool:
	for child in node.get_children():
		if child is TextureRect and child.texture != null and str(child.texture.resource_path).contains("Art/Mount/UI"):
			return true
		if _has_official_texture(child):
			return true
	return false

func _page_count(node: Node) -> int:
	var count: = 0
	for child in node.get_children():
		if str(child.name).begins_with("Page_"):
			count += 1
		count += _page_count(child)
	return count

func _save(file_name: String) -> void :
	RenderingServer.force_draw()
	await process_frame
	if DisplayServer.get_name() == "headless":
		print("MOUNT_PANEL_VISUAL_SCREENSHOT_SKIPPED:%s" % file_name)
		return
	var viewport: = root.get_viewport()
	var viewport_texture: = viewport.get_texture() if viewport != null else null
	if viewport_texture == null:

		print("MOUNT_PANEL_VISUAL_SCREENSHOT_SKIPPED:%s" % file_name)
		return
	var image: = viewport_texture.get_image()
	if image == null or image.is_empty():
		print("MOUNT_PANEL_VISUAL_SCREENSHOT_SKIPPED:%s" % file_name)
		return
	var path: = OS.get_environment("TEMP").path_join(file_name)
	_check(image.save_png(path) == OK, "截图保存失败: %s" % path)
	print("MOUNT_PANEL_VISUAL_SCREENSHOT:%s" % path)
