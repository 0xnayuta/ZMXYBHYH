extends Node

const TEST_ITEM_ID := "pet_mosaic_test"
const TEST_GEM_ID := "gjs_1"
var failures: Array[String] = []


class LivePetProbe:
	extends Node
	var apply_data_calls := 0
	var apply_develop_calls := 0
	var last_pet_data: Dictionary = {}

	func apply_pet_data(pet: Dictionary) -> void:
		apply_data_calls += 1
		last_pet_data = pet

	func apply_pet_develop_effects(pet: Dictionary) -> void:
		apply_develop_calls += 1
		last_pet_data = pet


func _ready() -> void:
	AE.ensure_loaded()
	var original_player_data: Dictionary = PlayerData.player_data
	var original_ldl_location: String = str(MLdl.loc_)
	var original_in_ldl: bool = Global.is_in_ldl == true
	PlayerData.player_data = _test_player_data(original_player_data)

	PlayerData.player_data["宠物背包"].append({"名字": "宠物护符", "强化等级": 8, "类型": "zbjn", "Data": {"宝石": [TEST_GEM_ID]}})
	PlayerData.player_data["宠物列表"] = [
		{
			"背包": [{"名字": "宠物护符", "强化等级": 0, "类型": "zbjn"}],
			"装备": {"zbjn": {"Data": {"名称": "宠物护符", "宝石": []}}},
		}
	]
	PlayerData.ensure_shared_pet_backpack()
	_check(PlayerData.player_data["宠物背包"].size() == 2, "旧存档共享宠物背包中的宠物护符应被删除")
	_check(not PlayerData.player_data["宠物列表"][0].has("背包"), "旧宠物背包迁移后不应保留宠物护符")
	_check(PlayerData.player_data["宠物列表"][0]["装备"]["zbjn"].is_empty(), "宠物身上装备的宠物护符应被删除")

	var pet_item: Dictionary = PlayerData.player_data["宠物背包"][0]
	var role_equipment_before: String = JSON.stringify(PlayerData.player_data["装备列表"])
	_check(PlayerData.take_pet_equipment_for_mosaic(0, pet_item, TEST_ITEM_ID), "宠物装备应能从共享背包取出")
	_check(PlayerData.player_data["宠物背包"].size() == 1, "取出后宠物背包应减少一件")
	_check(JSON.stringify(PlayerData.player_data["装备列表"]) == role_equipment_before, "取出宠物装备不应修改角色装备背包")
	_check(PlayerData.player_data["镶嵌列表"][0]["来源"] == "宠物背包", "镶嵌槽应记录宠物背包来源")
	PlayerData.player_data["镶嵌列表"][0]["Data"]["宝石"].append(TEST_GEM_ID)

	var selected_item: Dictionary = PlayerData.player_data["镶嵌列表"][0]["宠物装备"]
	var pet := {"装备": {"zbjn": selected_item}}
	_check(PlayerData.get_pet_equipment_stat(pet, "攻击") == 15, "1级攻击石应给宠物装备增加5点攻击")
	_check(PlayerData.restore_mosaic_equipment(), "宠物装备应能从镶嵌槽恢复")
	_check(PlayerData.player_data["宠物背包"].size() == 2, "恢复后宠物背包数量应还原")
	_check(is_same(PlayerData.player_data["宠物背包"][0], pet_item), "宠物装备应恢复到原索引")
	_check(PlayerData.player_data["宠物背包"][0]["Data"]["宝石"] == [TEST_GEM_ID], "恢复后的宠物装备应保留宝石")
	_check(JSON.stringify(PlayerData.player_data["装备列表"]) == role_equipment_before, "恢复宠物装备不应修改角色装备背包")

	_check(PlayerData.get_equipment_strength_max_level({"Data": {"品质": "神器"}}) == 30, "神器宠物装备最高应强化30级")
	_check(PlayerData.get_equipment_strength_max_level({"Data": {"品质": "玄冥"}}) == 50, "玄冥宠物装备最高应强化50级")
	_check(PlayerData.get_equipment_strength_max_level({"Data": {"品质": "黑神话"}}) == 50, "黑神话宠物装备最高应强化50级")

	MLdl.loc_ = "镶嵌"
	Global.is_in_ldl = true
	var backpack_scene: PackedScene = load("res://Scene/BackPack/Main_Backpack.tscn")
	var backpack: Control = backpack_scene.instantiate()
	add_child(backpack)
	backpack.call("_physics_process", 0.0)
	var pet_button: TextureButton = backpack.get_node("MarginContainer/VBoxContainer/HBoxContainer/pet_backpack")
	_check(pet_button.visible, "镶嵌页应显示宠物背包按钮")
	backpack.call("_on_pet_backpack_pressed")
	_check(int(backpack.get("current_fl")) == 3, "镶嵌页应能切换到宠物背包")
	backpack.queue_free()

	var pet_interface_scene: PackedScene = load("res://Test/PetInterfaceEquipmentProbe.tscn")
	var pet_interface: Control = pet_interface_scene.instantiate()
	add_child(pet_interface)
	pet_interface.position = get_viewport().get_visible_rect().size * 0.5 - Vector2(326.5, 256.5)
	_check(pet_interface.has_node("PetAttributePages/StatRow1/Name"), "宠物属性格应作为场景节点存在，供2D视图编辑")
	_check(pet_interface.has_node("PetAttributePages/StatRow10/Value"), "全部宠物属性格应作为场景节点存在")
	_check(pet_interface.has_node("PetStatPage1") and pet_interface.has_node("PetStatPage2"), "宠物属性页签应作为场景节点存在")
	var attribute_container := pet_interface.get_node("PetAttributeShow") as Control
	var page_two_button := pet_interface.get_node("PetStatPage2") as Button
	var learn_skill_button := pet_interface.get_node("PetAttributeShow/LearnSkillButton") as Button
	var upgrade_skill_button := pet_interface.get_node("PetAttributeShow/UpgradeSkillButton") as Button
	var skill_panel := pet_interface.get_node("PetAttributeShow/shape44_id43") as Control
	_check(attribute_container.mouse_filter == Control.MOUSE_FILTER_IGNORE, "宠物属性容器不应拦截重叠页签的鼠标输入")
	_check(page_two_button.z_index > attribute_container.z_index, "宠物属性第二页页签应绘制在属性容器上方")
	_check(learn_skill_button.text == "学习技能", "宠物技能框上方应提供学习技能按钮")
	_check(learn_skill_button.position.y + learn_skill_button.size.y <= skill_panel.position.y, "学习技能按钮应位于宠物技能框上方")
	_check(
		learn_skill_button.get_theme_stylebox("normal") == page_two_button.get_theme_stylebox("normal"),
		"学习技能按钮应复用宠物属性第二页按钮风格"
	)
	_check(not learn_skill_button.pressed.get_connections().is_empty(), "学习技能按钮应可以点击")
	_check(upgrade_skill_button.text == "升级技能", "学习技能旁边应提供升级技能按钮")
	_check(upgrade_skill_button.position.x > learn_skill_button.position.x, "升级技能按钮应位于学习技能按钮右侧")
	_check(
		upgrade_skill_button.get_theme_stylebox("normal") == page_two_button.get_theme_stylebox("normal"),
		"升级技能按钮应复用宠物属性第二页按钮风格"
	)
	_check(not upgrade_skill_button.pressed.get_connections().is_empty(), "升级技能按钮应可以点击")
	_check(
		pet_interface.has_node("PetSkillUpgradePopup/Window/SkillScroll/SkillList/SkillRowTemplate"),
		"宠物技能升级页和技能行模板应作为场景节点存在"
	)
	_check(not pet_interface.has_node("PetSkillUpgradePopup/Dim"), "宠物技能升级页不应显示黑色半透明遮罩")
	var skill_upgrade_window := pet_interface.get_node("PetSkillUpgradePopup/Window") as Panel
	var skill_upgrade_window_style := (
		skill_upgrade_window.get_theme_stylebox("panel") as StyleBoxFlat if skill_upgrade_window != null else null
	)
	_check(
		skill_upgrade_window_style != null and is_equal_approx(skill_upgrade_window_style.bg_color.a, 1.0),
		"宠物技能升级页应显示不透明面板边框"
	)
	var tiger_skill_probe := {
		"类型": "PetTiger",
		"阶段": 4,
		"技能": ["猛扑", "虎啸", "嗜血虎爪", "横扫千军", "奥义"],
	}
	var tiger_visible_skills: Array = pet_interface.call("_pet_skills", tiger_skill_probe)
	_check(tiger_visible_skills == ["虎啸", "嗜血虎爪", "横扫千军", "奥义"], "白虎普通攻击猛扑不应出现在技能图标和升级列表")
	pet_interface.call("_refresh_pet_skill_icons", tiger_skill_probe)
	var tiger_first_skill_slot := (
		(pet_interface.get("_pet_skill_grid") as Control).get_node("PetSkillSlot_0") as Control
	)
	_check((tiger_first_skill_slot.get_node("ManaLabel") as Label).text == "25", "白虎技能图标第一格应从虎啸开始")
	var live_pet_probe := LivePetProbe.new()
	live_pet_probe.set_meta("pet_mouse_unit", true)
	add_child(live_pet_probe)
	var active_mouse := {"类型": "PetMouse", "名称": "子鼠", "出战": true, "攻击": 111}
	var inactive_tiger := {"类型": "PetTiger", "名称": "虎丸", "出战": false, "攻击": 999}
	var previous_active_pet: Variant = PlayerData.player_data.get("出战宠物", "")
	PlayerData.player_data["出战宠物"] = "PetMouse"
	pet_interface.call("_refresh_live_pet_passives", active_mouse)
	_check(
		live_pet_probe.apply_data_calls == 1 and is_same(live_pet_probe.last_pet_data, active_mouse), "出战子鼠应正常刷新到子鼠战斗实例"
	)
	pet_interface.call("_refresh_live_pet_passives", inactive_tiger)
	pet_interface.call("_refresh_live_pet_develop_effects", inactive_tiger)
	_check(live_pet_probe.apply_data_calls == 1 and live_pet_probe.apply_develop_calls == 0, "培养非出战宠物不应刷新出战子鼠")
	_check(is_same(live_pet_probe.last_pet_data, active_mouse), "培养非出战宠物后子鼠战斗实例应继续保留子鼠数据")
	pet_interface.call("_refresh_live_pet_develop_effects", active_mouse)
	_check(live_pet_probe.apply_data_calls == 2 and live_pet_probe.apply_develop_calls == 1, "培养出战子鼠仍应立即刷新战斗属性")
	PlayerData.player_data["出战宠物"] = previous_active_pet
	remove_child(live_pet_probe)
	live_pet_probe.free()
	var sale_pet := {
		"名字": "出售测试宠物",
		"等级": 1,
		"经验": 0,
		"经验上限": 100,
		"生命": 100,
		"生命上限": 100,
		"魔法": 50,
		"魔法上限": 50,
		"攻击": 10,
		"防御": 5,
		"魔防": 4,
		"暴击": 1,
		"闪避": 1,
		"幸运": 1,
		"回血": 0,
		"回魔": 0,
		"被动技能": {},
		"技能": ["水疗盾", "同心链接"],
		"攻击资质": 100,
		"攻击资质上限": 1000,
		"装备": {"zbst": {}, "zbmz": {}, "zbxz": {}, "zbyf": {}, "zbjn": {}},
		"出战": false,
	}
	var gemmed_item := {"名字": "镶嵌宠物装备", "强化等级": 0, "类型": "zbjn", "售价": 20, "Data": {"品质": "神器", "宝石": [TEST_GEM_ID]}}
	var strengthened_item := {"名字": "强化宠物装备", "强化等级": 1, "类型": "zbjn", "售价": 20, "Data": {"品质": "神器", "宝石": []}}
	var equipped_item := {
		"名字": "属性汇总测试装备",
		"强化等级": 2,
		"类型": "zbst",
		"随机属性":
		[
			{"属性": "power", "数值": 1.5, "强化属性": 0.25},
			{"属性": "power", "数值": 2.0, "强化属性": 0.5},
		],
		"Data": {"品质": "神器", "power": 10.25, "强化属性": {"power": 2.5}, "宝石": [TEST_GEM_ID]},
	}
	sale_pet["装备"]["zbst"] = equipped_item
	PlayerData.player_data["宠物列表"] = [sale_pet]
	PlayerData.player_data["宠物背包"] = [gemmed_item, strengthened_item]
	PlayerData.player_data["coin_num"] = 5000
	PlayerData.player_data["消耗品列表"]["页码1"].append({"名字": "zizhiguo", "数量": 1})
	var equipment_bonuses := PlayerData.get_pet_equipment_bonuses(sale_pet)
	for canonical in PlayerData.PET_EQUIPMENT_STAT_KEYS:
		_check(
			int(equipment_bonuses.get(canonical, 0)) == PlayerData.get_pet_equipment_stat(sale_pet, str(canonical)),
			"宠物装备汇总优化后%s属性必须保持一致" % canonical
		)
	pet_interface.set("current_pet_index", 0)
	pet_interface.call("_refresh_all")
	_check(sale_pet.get("技能等级", {}) == {"水疗盾": 1, "同心链接": 1}, "旧存档宠物的已有技能应自动补为Lv.1")
	var skill_grid := pet_interface.get("_pet_skill_grid") as Control
	var first_skill_slot := skill_grid.get_node("PetSkillSlot_0") as Control
	_check((first_skill_slot.get_node("ManaLabel") as Label).text == "50", "宠物技能图标左上角应显示当前蓝耗")
	_check((first_skill_slot.get_node("LevelLabel") as Label).text == "Lv.1", "宠物技能图标右上角应显示当前等级")
	pet_interface.call("_on_upgrade_skill_pressed")
	var skill_upgrade_popup := pet_interface.get_node("PetSkillUpgradePopup") as Control
	var skill_upgrade_list := (
		pet_interface.get_node("PetSkillUpgradePopup/Window/SkillScroll/SkillList") as VBoxContainer
	)
	var visible_skill_rows := 0
	for row in skill_upgrade_list.get_children():
		if (row as Control).visible:
			visible_skill_rows += 1
	_check(skill_upgrade_popup.visible and visible_skill_rows == 2, "升级技能页应枚举当前宠物的全部技能")
	if DisplayServer.get_name() != "headless":
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		var skill_screenshot_path := OS.get_temp_dir().path_join("pet_skill_upgrade_verification.png")
		var skill_screenshot := get_viewport().get_texture().get_image()
		_check(skill_screenshot != null and skill_screenshot.save_png(skill_screenshot_path) == OK, "宠物技能升级页截图应可生成")
		print("PET_SKILL_UPGRADE_SCREENSHOT=" + skill_screenshot_path)
	pet_interface.call("_on_pet_skill_upgrade_requested", "水疗盾")
	var upgrade_confirm_popup := pet_interface.get("pet_skill_upgrade_confirm") as CanvasItem
	_check(
		upgrade_confirm_popup != null and upgrade_confirm_popup.z_index > skill_upgrade_popup.z_index,
		"技能升级确认框应显示在升级页面上方"
	)
	var upgrade_confirm_overlay := upgrade_confirm_popup.get_node_or_null("TextureRect") as ColorRect
	var upgrade_confirm_dialog := upgrade_confirm_popup.get_node_or_null("TextureRect/bg") as Control
	_check(upgrade_confirm_overlay != null and is_zero_approx(upgrade_confirm_overlay.color.a), "技能升级确认框不应显示黑色半透明遮罩")
	var skill_upgrade_center := (
		skill_upgrade_popup.position + skill_upgrade_window.position + skill_upgrade_window.size * 0.5
	)
	var confirm_dialog_center := upgrade_confirm_dialog.position + upgrade_confirm_dialog.size * 0.5
	_check(confirm_dialog_center.distance_to(skill_upgrade_center) < 1.0, "技能升级确认框应以同父级局部坐标对齐宠物升级窗口")
	var upgrade_confirm_button := upgrade_confirm_dialog.get_node_or_null("qd") as Control
	var upgrade_cancel_button := upgrade_confirm_dialog.get_node_or_null("qx") as Control
	var confirm_buttons_left := minf(upgrade_confirm_button.position.x, upgrade_cancel_button.position.x)
	var confirm_buttons_right := maxf(
		upgrade_confirm_button.position.x + upgrade_confirm_button.size.x * upgrade_confirm_button.scale.x,
		upgrade_cancel_button.position.x + upgrade_cancel_button.size.x * upgrade_cancel_button.scale.x
	)
	_check(
		absf((confirm_buttons_left + confirm_buttons_right) * 0.5 - upgrade_confirm_dialog.size.x * 0.5) < 1.0,
		"技能升级确定和取消按钮应作为一组居中"
	)
	if DisplayServer.get_name() != "headless":
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		var confirm_screenshot_path := OS.get_temp_dir().path_join("pet_skill_confirm_layer_verification.png")
		var confirm_screenshot := get_viewport().get_texture().get_image()
		_check(
			confirm_screenshot != null and confirm_screenshot.save_png(confirm_screenshot_path) == OK, "技能升级确认框层级截图应可生成"
		)
		print("PET_SKILL_CONFIRM_SCREENSHOT=" + confirm_screenshot_path)
	pet_interface.call("_confirm_pet_skill_upgrade")
	_check(int(sale_pet["技能等级"]["水疗盾"]) == 2, "确认升级后宠物技能等级应增加1")
	_check(int(PlayerData.player_data["coin_num"]) == 4400, "Lv.1第一技能升级应按人物规则扣除600灵魂")
	_check((first_skill_slot.get_node("ManaLabel") as Label).text == "55", "升级后技能图标蓝耗应刷新为当前等级消耗")
	_check((first_skill_slot.get_node("LevelLabel") as Label).text == "Lv.2", "升级后技能图标等级应立即刷新")
	var upgrade_success_tip := pet_interface.get("pet_skill_upgrade_success_tip") as CanvasItem
	_check(
		upgrade_success_tip != null and upgrade_success_tip.z_index > upgrade_confirm_popup.z_index,
		"技能升级成功提示应置于确认框和升级页面上方"
	)
	if DisplayServer.get_name() != "headless":
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		var success_screenshot_path := OS.get_temp_dir().path_join("pet_skill_success_layer_verification.png")
		var success_screenshot := get_viewport().get_texture().get_image()
		_check(
			success_screenshot != null and success_screenshot.save_png(success_screenshot_path) == OK,
			"技能升级成功提示层级截图应可生成"
		)
		print("PET_SKILL_SUCCESS_SCREENSHOT=" + success_screenshot_path)
	for popup in pet_interface.get_children():
		if popup.scene_file_path == "res://Scene/show_text/choose_scene.tscn":
			popup.queue_free()
	pet_interface.call("_close_pet_skill_upgrade_popup")
	var first_page_values: Array = pet_interface.get("pet_attribute_stat_values")
	_check((first_page_values[3] as Label).text == "5 (1.96%)", "宠物物防应和人物一样显示减伤百分比")
	_check((first_page_values[4] as Label).text == "1 (1.96%)", "宠物幸运括号前应显示整数")
	_check((first_page_values[5] as Label).text == "4 (1.57%)", "宠物魔防应和人物一样显示减伤百分比")
	_check((first_page_values[6] as Label).text == "1 (0.99%)", "宠物暴击括号前应显示整数")
	_check((first_page_values[7] as Label).text == "1 (0.99%)", "宠物闪避括号前应显示整数")
	pet_interface.call("_on_pet_attribute_page_pressed", 1)
	var stat_rows: Array = pet_interface.get("pet_attribute_stat_rows")
	var stat_names: Array = pet_interface.get("pet_attribute_stat_names")
	var second_page_names: Array[String] = []
	for index in stat_names.size():
		if index < stat_rows.size() and (stat_rows[index] as Control).visible:
			second_page_names.append((stat_names[index] as Label).text)
	for required_name in ["命中", "韧性", "吸血", "暴免", "破甲", "破魔"]:
		_check(required_name in second_page_names, "宠物属性第二页应显示%s" % required_name)
	for forbidden_name in ["悟性", "根骨", "灵力", "潜力"]:
		_check(forbidden_name not in second_page_names, "宠物属性第二页不应显示培养属性%s" % forbidden_name)
	_check(second_page_names == ["命中", "韧性", "吸血", "暴免", "破甲", "破魔"], "宠物属性第二页字段和顺序应与人物一致")
	_check(
		(
			(stat_rows[2] as Control).visible
			and (pet_interface.get("pet_attribute_stat_values") as Array)[2].text == "0.00%"
		),
		"宠物吸血应和人物一样显示百分比"
	)
	_check((pet_interface.get("pet_attribute_page_buttons") as Array).size() == 2, "宠物属性页应提供1/2两个页签")
	pet_interface.call("eipClick")
	_check(
		(pet_interface.get("pet_attribute_pages") as CanvasItem).visible and page_two_button.visible,
		"切换装备页时宠物属性与页签应保持显示"
	)
	_check(int(pet_interface.get("pet_attribute_page")) == 1, "切换装备页时应保留当前属性页码")
	(pet_interface.get_node("PetStatPage1") as Button).emit_signal("pressed")
	_check(int(pet_interface.get("pet_attribute_page")) == 0, "装备页中应能切换宠物属性页")
	pet_interface.call("groomClick")
	_check(
		(pet_interface.get("pet_attribute_pages") as CanvasItem).visible and page_two_button.visible,
		"切换培养页时宠物属性与页签应保持显示"
	)
	page_two_button.emit_signal("pressed")
	_check(int(pet_interface.get("pet_attribute_page")) == 1, "培养页中应能切换宠物属性页")
	pet_interface.call("ateClick")
	_check(
		int(pet_interface.get("pet_attribute_page")) == 1 and page_two_button.visible and not page_two_button.disabled,
		"返回属性页后应保留当前属性页且第二页可点击"
	)
	var attack_quality_before := int(sale_pet["攻击资质"])
	pet_interface.call("reset_equipment_bonus_call_count")
	pet_interface.call("_on_quality_fruit_pressed", "攻击资质", "攻击资质上限", "zizhiguo")
	var attack_quality_added := int(sale_pet["攻击资质"]) - attack_quality_before
	_check(attack_quality_added >= 10 and attack_quality_added <= 30, "资质果必须正常增加10至30点攻击资质")
	_check(int(pet_interface.call("_item_count", "zizhiguo")) == 0, "使用资质果后必须扣除一个道具")
	_check(int(pet_interface.get("equipment_bonus_call_count")) == 1, "使用资质果刷新界面时装备属性只能完整汇总一次")
	var expected_attack := int(sale_pet.get("攻击", 0)) + int(PlayerData.get_pet_equipment_bonuses(sale_pet).get("攻击", 0))
	var attack_label := pet_interface.get("atktxt") as Label
	_check(attack_label != null and attack_label.text == str(expected_attack), "资质果刷新后攻击显示必须继续包含装备加成")
	await get_tree().process_frame
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		var screenshot_path := OS.get_temp_dir().path_join("pet_attribute_page_2_verification.png")
		var screenshot := get_viewport().get_texture().get_image()
		_check(screenshot != null and screenshot.save_png(screenshot_path) == OK, "宠物属性第二页截图应可生成")
		print("PET_ATTRIBUTE_SCREENSHOT=" + screenshot_path)
	var coin_before := int(PlayerData.player_data["coin_num"])
	_check(not pet_interface.call("pet_sell_from_popup", gemmed_item, 0, "", ""), "镶嵌宝石的宠物装备应禁止出售")
	_check(
		PlayerData.player_data["宠物背包"].size() == 2 and int(PlayerData.player_data["coin_num"]) == coin_before,
		"禁止出售时装备和灵魂应保持不变"
	)
	_check(pet_interface.call("pet_sell_from_popup", strengthened_item, 1, "", ""), "强化宠物装备应打开出售确认")
	_check(PlayerData.player_data["宠物背包"].size() == 2, "强化宠物装备确认前不能立即出售")
	_check(not (pet_interface.get("pending_pet_sale") as Dictionary).is_empty(), "强化宠物装备应记录待确认出售")
	pet_interface.call("_confirm_pet_sale")
	_check(
		PlayerData.player_data["宠物背包"].size() == 1 and int(PlayerData.player_data["coin_num"]) == coin_before + 20,
		"确认后应出售强化宠物装备并增加灵魂"
	)
	for popup in pet_interface.get_children():
		if popup.scene_file_path == "res://Scene/show_text/choose_scene.tscn":
			popup.queue_free()
	pet_interface.queue_free()

	var turtle_skill_probe := PetTurtleSummonBase.new()
	turtle_skill_probe.pet_data = {"技能": ["水疗盾"], "技能等级": {"水疗盾": 2}, "根骨": 0}
	turtle_skill_probe.attack_in = 100
	turtle_skill_probe.call("_rebuild_pet_turtle_attack_data")
	_check(int(turtle_skill_probe.objattackDic["hit2"]["power"]) == 660, "宠物技能升级应实际提高战斗伤害")
	_check(int(turtle_skill_probe.call("_skill_cost", "sld")) == 55, "宠物战斗扣蓝应使用升级后的蓝耗")
	turtle_skill_probe.free()

	var role_scene: PackedScene = load("res://Scene/BackPack/BackPack.tscn")
	var role_page := role_scene.instantiate()
	add_child(role_page)
	await get_tree().physics_frame
	await get_tree().process_frame
	var role_information := role_page.get_node("background/infomation")
	for role_stat_name in ["lucky", "crit", "miss"]:
		var role_stat := role_information.get_node(role_stat_name) as Label
		var bracket_index := role_stat.text.find(" (")
		_check(
			bracket_index > 0 and not role_stat.text.substr(0, bracket_index).contains("."),
			"人物属性%s括号前应显示整数" % role_stat_name
		)
		_check(role_stat.text.ends_with("%)"), "人物属性%s括号内应保留百分比" % role_stat_name)
	role_page.queue_free()

	var crit_target := BaseMonster.new()
	var crit_attacker := SummonBaseMonster.new()
	crit_target.def = 0
	crit_target.mdef = 0
	crit_target.miss = 0
	crit_target.Critreduce = 0
	crit_target.Toughness = 0
	crit_target.llrdzs = 1.0
	crit_attacker.crit = 9223372036854775807
	crit_attacker.lucky = 100
	var crit_count_before := Global.TotalCritCount
	_check(crit_target.resolve_friendly_damage(100, "physics", crit_attacker) == 250, "宠物高暴击应触发并按幸运提高暴击伤害")
	_check(crit_target.is_crit and Global.TotalCritCount == crit_count_before + 1, "宠物暴击应写入暴击状态和统计")
	crit_target.Critreduce = crit_attacker.crit
	_check(
		crit_target.resolve_friendly_damage(100, "physics", crit_attacker) == 100 and not crit_target.is_crit,
		"怪物暴免应抵消宠物暴击"
	)
	crit_target.free()
	crit_attacker.free()

	_check(load("res://Script/BackPack/Box_1.gd") != null, "背包格脚本应可解析")
	_check(load("res://Script/LDL/strength.gd") != null, "强化脚本应可解析")
	_check(load("res://Script/BackPack/sell_or_equ.gd") != null, "装备操作菜单脚本应可解析")
	_check(load("res://Script/LDL/Mosaic.gd") != null, "镶嵌脚本应可解析")
	_check(load("res://Script/BackPack/equipment_properies.gd") != null, "装备属性脚本应可解析")
	_check(load("res://Scene/LDL/Mosaic.tscn") != null, "镶嵌场景应可加载")
	for pet_combat_script in [
		"res://Script/Pet/PetTigerSummonBase.gd",
		"res://Script/Pet/PetDragonSummonBase.gd",
		"res://Script/Pet/PetPhoenixSummonBase.gd",
		"res://Script/Pet/PetTurtleSummonBase.gd",
		"res://Script/Pet/PetRabbitSummonBase.gd",
		"res://Script/Pet/PetMouseSummonBase.gd",
	]:
		_check(load(pet_combat_script) != null, "宠物技能等级接入后战斗脚本应可解析：%s" % pet_combat_script)

	PlayerData.player_data = original_player_data
	MLdl.loc_ = original_ldl_location
	Global.is_in_ldl = original_in_ldl
	if failures.is_empty():
		print("PET_MOSAIC_VERIFICATION_PASSED")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	print("PET_MOSAIC_VERIFICATION_FAILED=%d" % failures.size())
	get_tree().quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _test_player_data(original: Dictionary) -> Dictionary:
	var result: Dictionary = original.duplicate(true)
	var equipment_pages := {}
	var item_pages := {}
	var consumable_pages := {}
	for page in range(1, 21):
		equipment_pages["页码%d" % page] = []
		item_pages["页码%d" % page] = []
		consumable_pages["页码%d" % page] = []
	item_pages["页码1"].append({"名字": TEST_GEM_ID, "数量": 1, "Data": AE.AllEquipment_[TEST_GEM_ID]})
	var test_item := {
		"名字": "测试宠物装备",
		"强化等级": 0,
		"类型": "zbjn",
		"随机属性":
		[
			{"属性": "SHp", "数值": 0, "强化属性": 0},
			{"属性": "SHp", "数值": 0, "强化属性": 0},
			{"属性": "SHp", "数值": 0, "强化属性": 0},
			{"属性": "SHp", "数值": 0, "强化属性": 0},
		],
		"Data": {"所属": "宠物装备", "类型": "宠物装备", "power": 10, "强化属性": {}, "宝石": []},
	}
	result["宠物背包"] = [
		test_item,
		{"名字": "末尾装备", "强化等级": 0, "类型": "zbjn", "Data": {"宝石": []}},
	]
	result["宠物列表"] = []
	result["镶嵌列表"] = []
	result["装备列表"] = equipment_pages
	result["道具列表"] = item_pages
	result["消耗品列表"] = consumable_pages
	result["ieho"] = true
	result["coin_num"] = 0
	return result
