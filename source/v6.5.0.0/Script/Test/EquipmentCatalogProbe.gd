extends Node

var _failed: = false

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	var original_data: Dictionary = PlayerData.player_data.duplicate(true)
	var original_path: String = Global.cd_path
	Global.cd_path = ""
	var map = load("res://Scene/Main_menu/Map_0.tscn").instantiate()
	add_child(map)
	await get_tree().process_frame
	var entry: = map.get_node("EquipmentCatalog") as Button
	_check(entry.text == "装备图鉴", "地图图鉴入口缺失")
	entry.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	var page = map.equipment_catalog_page
	_check(is_instance_valid(page), "图鉴入口未打开页面")
	if not is_instance_valid(page):
		get_tree().quit(1)
		return
	_check(page.theme.default_font == entry.get_theme_font("font"), "图鉴字体与入口按钮不一致")
	for category_name in page.CATEGORIES:
		page.select_category(category_name)
		await get_tree().process_frame
		_check( not page.displayed_ids.is_empty(), "分类为空：" + category_name)
		var previous_quality: = -1
		for item_id in page.displayed_ids:
			_check(item_id not in ["fgwxg", "fgwxj", "sbhf", "xczg", "zxttq", "zxttp"], "已移除的条目仍在图鉴中")
			var data: Dictionary = AE.AllEquipment_[item_id]
			var quality: int = page.QUALITY_ORDER.find(str(data.get("品质", "")))
			_check(quality >= 0 and quality >= previous_quality, "装备未按品质升序排列：" + category_name)
			previous_quality = quality
			if category_name == "法宝":
				_check(data["类型"] == "法宝", "法宝分类混入其他物品")
			else:
				_check(data["所属"] == category_name, "角色装备分类错误")
			var sources: String = page.catalog.get_sources(item_id)
			var code_pattern: = RegEx.new()
			code_pattern.compile("(?<![A-Za-z0-9_])[A-Za-z][A-Za-z0-9_]{2,}(?![A-Za-z0-9_])")
			_check(code_pattern.search(sources) == null, "图鉴获取方式含有物品代码：" + page.catalog.item_name(item_id))
		for index in range(page._item_list.item_count):
			var icon: Texture2D = page._item_list.get_item_icon(index)
			_check(icon is ImageTexture and icon.get_size() == Vector2(64, 64), "列表图标未使用格子底片")
	page.select_category("悟空")
	await get_tree().process_frame
	await get_tree().process_frame
	var list_bar: VScrollBar = page._item_list.get_v_scroll_bar()
	list_bar.value = 0
	var start: Vector2 = page._item_list.get_global_rect().get_center()
	var touch: = InputEventScreenTouch.new()
	touch.index = 0
	touch.position = start
	touch.pressed = true
	get_viewport().push_input(touch)
	var drag: = InputEventScreenDrag.new()
	drag.index = 0
	drag.position = start - Vector2(0, 100)
	drag.relative = Vector2(0, -100)
	get_viewport().push_input(drag)
	touch.pressed = false
	touch.position = drag.position
	get_viewport().push_input(touch)
	_check(list_bar.value > 0, "装备列表无法通过触摸滑动")
	list_bar.value = 0
	var mouse: = InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.position = start
	mouse.pressed = true
	get_viewport().push_input(mouse)
	var motion: = InputEventMouseMotion.new()
	motion.position = start - Vector2(0, 100)
	motion.relative = Vector2(0, -100)
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	get_viewport().push_input(motion)
	mouse.pressed = false
	mouse.position = motion.position
	get_viewport().push_input(mouse)
	_check(list_bar.value > 0, "装备列表无法通过鼠标拖动")
	await _screenshot("equipment_catalog_drag.png")
	page.select_category("八戒")
	_check(page.displayed_ids.has("sllyp") and page.displayed_ids.has("slfk"), "释罗装备未收录")
	page._search.text = "释罗凛月"
	page.refresh_items()
	_check(page.displayed_ids == ["sllyp"], "图鉴搜索结果错误")
	page.select_item("sllyp")
	_check(page._detail.find_child("AttributeCards", true, false) != null, "属性卡片缺失")
	_check(page.catalog.get_attributes("sllyp").has("攻击  650"), "装备属性错误")
	_check(page.catalog.get_sources("sllyp").contains("尾妖林"), "释罗武器制作书掉落位置错误")
	_check(page.catalog.get_sources("slfk").contains("龙脊山"), "释罗防具制作书掉落位置错误")
	_check(page.catalog.get_sources("ptxzg").contains("花果山"), "普通武器掉落位置错误")
	_check(page.catalog.get_sources("lgdwc").contains("商城"), "商城装备来源缺失")
	await _screenshot("equipment_catalog_bajie.png")
	page._search.text = ""
	page.select_category("法宝")
	for immortal_item in ["yyzlj", "ywhl", "zhyx", "bjs", "sxyg", "dkhl", "yyb", "hehua"]:
		_check(page.catalog.get_sources(immortal_item).contains("八仙过海副本"), "八仙法宝掉落位置缺失")
	_check( not page.catalog.get_sources("zjhl").contains("zjhlzzs"), "制作书代码仍出现在图鉴")
	page.select_item("zjhl")
	await _screenshot("equipment_catalog_slots.png")
	page.select_item("yyzlj")
	await get_tree().process_frame
	page._detail_scroll.scroll_vertical = 9999
	await _screenshot("equipment_catalog_immortals.png")
	page.select_item("469000011")
	_check(page.catalog.get_description("469000011").contains("御魔领域"), "法宝技能说明缺失")
	_check(page.catalog.get_sources("469000011").contains("东胜神洲·金沙村"), "东胜神洲法宝来源缺失")
	await get_tree().process_frame
	page._detail_scroll.scroll_vertical = 9999
	await get_tree().process_frame
	_check(page._detail_scroll.scroll_vertical > 0, "长详情无法滚动")
	await _screenshot("equipment_catalog_magic.png")
	page._panel.find_child("CloseButton", true, false).pressed.emit()
	await get_tree().process_frame
	entry.pressed.emit()
	await get_tree().process_frame
	_check(is_instance_valid(map.equipment_catalog_page), "关闭后无法重新打开图鉴")
	map.equipment_catalog_page.queue_free()
	await get_tree().process_frame
	await _screenshot("equipment_catalog_map0.png")
	map.queue_free()
	await get_tree().process_frame
	_check(PlayerData.player_data == original_data, "浏览图鉴修改了角色数据")
	Global.cd_path = original_path
	print("EQUIPMENT_CATALOG_PROBE_OK" if not _failed else "EQUIPMENT_CATALOG_PROBE_FAILED")
	get_tree().quit(1 if _failed else 0)

func _screenshot(filename: String) -> void :
	if DisplayServer.get_name() == "headless":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path: = ProjectSettings.globalize_path("user://" + filename)
	_check(get_viewport().get_texture().get_image().save_png(path) == OK, "截图保存失败")
	print("EQUIPMENT_CATALOG_SCREENSHOT=" + path)

func _check(condition: bool, message: String) -> void :
	if not condition:
		push_error(message)
		_failed = true
