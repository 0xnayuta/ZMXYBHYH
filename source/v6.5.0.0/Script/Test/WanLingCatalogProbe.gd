extends Node

var _failed: = false


func _ready() -> void :
	call_deferred("_run_probe")


func _run_probe() -> void :
	var page_script: = ResourceLoader.load("res://Script/Main_menu/WanLingCatalogPage.gd", "", ResourceLoader.CACHE_MODE_IGNORE)
	_check(page_script != null, "万灵图录脚本加载失败")
	var original_items: Dictionary = PlayerData.player_data["道具列表"].duplicate(true)
	var original_catalog: Variant = PlayerData.player_data.get(PlayerData.WANLING_CATALOG_LEVELS_KEY, null)
	if original_catalog is Dictionary:
		original_catalog = (original_catalog as Dictionary).duplicate(true)
	PlayerData.player_data["道具列表"] = {"页码1": []}
	PlayerData.player_data[PlayerData.WANLING_CATALOG_LEVELS_KEY] = {"地府": {"34": 7}}
	PlayerData.ensure_wanling_catalog_data()

	var monster_ids: Array = PlayerData.WANLING_HUMAN_MONSTER_IDS
	_check(monster_ids.size() == 23, "人间怪物数量应为23")
	_check( not monster_ids.has(19), "人间图录不应包含编号19")
	var expected_human_boss_ids: = [4, 5, 6, 8, 11, 12, 18, 20, 22, 23, 24]
	_check(PlayerData.WANLING_HUMAN_BOSS_IDS == expected_human_boss_ids, "人间Boss列表不完整")
	for human_id in monster_ids:
		var expected_human_limit: = 50 if expected_human_boss_ids.has(human_id) else 1000
		_check(PlayerData.get_wanling_human_consume_limit(int(human_id)) == expected_human_limit, "人间怪物吞噬上限错误：%d" % int(human_id))
	_check(PlayerData.get_wanling_human_consume_limit(1) == 1000, "小怪吞噬上限错误")
	_check(PlayerData.get_wanling_human_consume_limit(6) == 50, "Boss吞噬上限错误")
	_check(PlayerData.WANLING_UNDERWORLD_MONSTER_IDS.size() == 23, "地府图录怪物数量错误")
	_check( not PlayerData.WANLING_UNDERWORLD_MONSTER_IDS.has(34), "地府图录不应包含傀儡")
	_check( not PlayerData.player_data[PlayerData.WANLING_CATALOG_LEVELS_KEY]["地府"].has("34"), "旧存档傀儡培养数据未清理")
	var expected_underworld_boss_ids: = [29, 30, 31, 32, 33, 37, 41, 43, 48, 49, 55, 56, 57]
	_check(PlayerData.WANLING_UNDERWORLD_BOSS_IDS == expected_underworld_boss_ids, "地府Boss列表不完整")
	for underworld_id in PlayerData.WANLING_UNDERWORLD_MONSTER_IDS:
		var expected_limit: = 50 if expected_underworld_boss_ids.has(underworld_id) else 1000
		_check(PlayerData.get_wanling_underworld_consume_limit(int(underworld_id)) == expected_limit, "地府怪物吞噬上限错误：%d" % int(underworld_id))
	_check(PlayerData.get_wanling_underworld_consume_limit(30) == 50, "黑无常吞噬上限错误")
	_check(PlayerData.get_wanling_underworld_consume_limit(31) == 50, "白无常吞噬上限错误")
	_check(PlayerData.get_wanling_underworld_consume_limit(28) == 1000, "守夜人吞噬上限错误")
	_check(is_equal_approx(float(PlayerData.WANLING_UNDERWORLD_MONSTER_EFFECTS[32]["ar"]), 100.0), "白骨精破甲效果错误")
	_check(is_equal_approx(float(PlayerData.WANLING_UNDERWORLD_MONSTER_EFFECTS[32]["sp"]), 100.0), "白骨精破魔效果错误")
	_check(PlayerData.WANLING_UNDERWORLD_MONSTER_EFFECTS[49] == {"SMp": 200.0}, "孟婆魔法效果错误")
	_check(PlayerData.WANLING_UNDERWORLD_MONSTER_EFFECTS[51] == {"damage_bonus": 0.0001}, "沙华伤害效果错误")
	_check(PlayerData.WANLING_UNDERWORLD_MONSTER_EFFECTS[52] == {"damage_reduction": 0.0001}, "河童免伤效果错误")
	_check(PlayerData.WANLING_UNDERWORLD_MONSTER_EFFECTS[53] == {"SHp": 100.0}, "曼珠生命效果错误")
	_check(PlayerData.WANLING_UNDERWORLD_MONSTER_EFFECTS[43] == {"Def": 80.0}, "阎罗王物防效果错误")
	_check(PlayerData.WANLING_UNDERWORLD_MONSTER_EFFECTS[57] == {"damage_bonus": 0.002}, "转轮圣王伤害效果错误")
	_check(PlayerData.WANLING_UNDERWORLD_MONSTER_EFFECTS[37] == {"power": 100.0}, "秦广王攻击效果错误")
	_check(PlayerData.WANLING_UNDERWORLD_MONSTER_EFFECTS[41] == {"power": 100.0}, "判官攻击效果错误")
	_check(PlayerData.WANLING_UNDERWORLD_MONSTER_EFFECTS[33] == {"power": 100.0, "SHp": 100.0}, "傀儡王攻击生命效果错误")
	var human_effect_profiles: = [
		{"SHp": 50.0}, {"SHp": 50.0}, {"Mdef": 4.0}, {"power": 100.0}, 
		{"power": 100.0}, {"Crit": 20.0}, {"ar": 3.0, "sp": 3.0}, 
		{"power": 100.0}, {"SHp": 100.0}, {"power": 10.0}, 
		{"damage_bonus": 0.002}, {"damage_bonus": 0.002}, {"R_hp": 0.2, "R_mp": 0.2}, 
		{"power": 5.0}, {"power": 5.0}, {"power": 5.0}, {"Def": 4.0}, 
		{"damage_reduction": 0.002}, {"damage_reduction": 0.002}, {"SMp": 25.0}, 
		{"damage_bonus": 0.002}, {"damage_reduction": 0.002}, {"damage_reduction": 0.002}, 
		{"vampirism": 0.0001}, 
	]
	for profile in human_effect_profiles:

		if profile == {"SMp": 25.0} or profile == {"vampirism": 0.0001} or profile == {"Def": 4.0} or profile == {"power": 10.0}:
			continue
		var profile_found: = false
		for underworld_effect in PlayerData.WANLING_UNDERWORLD_MONSTER_EFFECTS.values():
			var normalized_profile: Dictionary = profile.duplicate()
			if normalized_profile == underworld_effect or (normalized_profile == {"ar": 3.0, "sp": 3.0} and underworld_effect == {"ar": 100.0, "sp": 100.0}):
				profile_found = true
				break
		_check(profile_found, "地府图录缺少人间模板属性：%s" % str(profile))
	_check(PlayerData.get_wanling_underworld_consume_limit(26) == 1000, "地府小怪吞噬上限错误")
	_check(PlayerData.get_wanling_underworld_consume_limit(37) == 50, "地府Boss吞噬上限错误")
	_check(PlayerData.WANLING_HEAVEN_MONSTER_IDS.size() == 45, "天庭图录怪物数量错误")
	var expected_heaven_boss_ids: = [
		77, 78, 79, 83, 84, 85, 89, 91, 93, 96, 
		100, 101, 102, 103, 107, 108, 110, 112, 114, 134, 136, 137, 
	]
	_check(PlayerData.WANLING_HEAVEN_BOSS_IDS == expected_heaven_boss_ids, "天庭Boss列表不完整")
	for heaven_id in PlayerData.WANLING_HEAVEN_MONSTER_IDS:
		var heaven_expected_limit: = 50 if expected_heaven_boss_ids.has(heaven_id) else 1000
		_check(PlayerData.get_wanling_heaven_consume_limit(int(heaven_id)) == heaven_expected_limit, "天庭怪物吞噬上限错误：%d" % int(heaven_id))
		_check(ResourceLoader.exists("res://Art/Monster/万灵图录/%d.png" % int(heaven_id)), "缺少天庭怪物立绘%d" % int(heaven_id))
		_check(ResourceLoader.exists("res://Art/Monster/魂晶/%d.png" % int(heaven_id)), "缺少天庭怪物魂晶%d" % int(heaven_id))
		_check(PlayerData.get_wanling_heaven_consumed_count(int(heaven_id)) == 0, "天庭怪物初始吞噬数据无效%d" % int(heaven_id))
	_check(PlayerData.get_wanling_heaven_consume_limit(74) == 1000, "天庭小怪吞噬上限错误")
	_check(PlayerData.get_wanling_heaven_consume_limit(114) == 50, "天庭Boss吞噬上限错误")
	_check(PlayerData.get_wanling_heaven_consume_limit(134) == 50, "马天君Boss吞噬上限错误")
	_check(PlayerData.get_wanling_heaven_consume_limit(135) == 1000, "天王使者吞噬上限错误")
	_check(PlayerData.get_wanling_heaven_consume_limit(136) == 50, "持国傀儡吞噬上限错误")
	PlayerData.player_data[PlayerData.WANLING_CATALOG_LEVELS_KEY]["天庭"]["136"] = 1000
	_check(PlayerData.get_wanling_heaven_consumed_count(136) == 50, "持国傀儡旧存档未限制到50")
	_check(is_equal_approx(float(PlayerData.get_wanling_attribute_totals()["SHp"]), 50000.0), "持国傀儡满级生命加成错误")
	PlayerData.player_data[PlayerData.WANLING_CATALOG_LEVELS_KEY]["天庭"]["136"] = 0
	_check(PlayerData.get_wanling_heaven_consume_limit(137) == 50, "持国天王Boss吞噬上限错误")
	_check(str(AE.AllEquipment_.get("heaven_soul_crystal_134", {}).get("名字", "")) == "马天君魂晶", "马天君魂晶物品未注册")
	_check(str(AE.AllEquipment_.get("heaven_soul_crystal_135", {}).get("名字", "")) == "天王使者魂晶", "天王使者魂晶物品未注册")
	_check(str(AE.AllEquipment_.get("heaven_soul_crystal_136", {}).get("名字", "")) == "持国傀儡魂晶", "持国傀儡魂晶物品未注册")
	_check(str(AE.AllEquipment_.get("heaven_soul_crystal_137", {}).get("名字", "")) == "持国天王魂晶", "持国天王魂晶物品未注册")
	_check(PlayerData.player_data[PlayerData.WANLING_CATALOG_LEVELS_KEY].has("天庭"), "旧存档未补充天庭图录数据")
	var heaven_max_totals: = {
		"Def": 0.0, "Mdef": 0.0, "ar": 0.0, "sp": 0.0, 
		"damage_bonus": 0.0, "damage_reduction": 0.0, 
	}
	for heaven_id in PlayerData.WANLING_HEAVEN_MONSTER_IDS:
		var consume_limit: = PlayerData.get_wanling_heaven_consume_limit(int(heaven_id))
		var effects: Dictionary = PlayerData.WANLING_HEAVEN_MONSTER_EFFECTS.get(heaven_id, {})
		for attribute_name in heaven_max_totals:
			heaven_max_totals[attribute_name] += float(effects.get(attribute_name, 0.0)) * consume_limit
	_check(is_equal_approx(float(heaven_max_totals["Def"]), 6000.0), "天庭图录满级物防总和不是6000")
	_check(is_equal_approx(float(heaven_max_totals["Mdef"]), 6000.0), "天庭图录满级魔防总和不是6000")
	_check(is_equal_approx(float(heaven_max_totals["ar"]), 6000.0), "天庭图录满级破甲总和不是6000")
	_check(is_equal_approx(float(heaven_max_totals["sp"]), 6000.0), "天庭图录满级破魔总和不是6000")
	_check(is_equal_approx(float(heaven_max_totals["damage_bonus"]), 0.4), "天庭图录满级伤害总和不是40%")
	_check(is_equal_approx(float(heaven_max_totals["damage_reduction"]), 0.4), "天庭图录满级免伤总和不是40%")
	_check( not AE.AllEquipment_.has("human_soul_crystal_19"), "编号19不应注册魂晶")
	for monster_id in monster_ids:
		_check(ResourceLoader.exists("res://Art/Monster/万灵图录/%d.png" % int(monster_id)), "缺少怪物立绘%d" % int(monster_id))
		_check(ResourceLoader.exists("res://Art/Monster/魂晶/%d.png" % int(monster_id)), "缺少怪物魂晶%d" % int(monster_id))
		_check(PlayerData.get_wanling_human_consumed_count(int(monster_id)) == 0, "怪物初始吞噬数据无效%d" % int(monster_id))

	PlayerData.add_dj("human_soul_crystal_1", 3)
	_check(PlayerData.consume_all_wanling_human_crystals(1) == 3, "小怪魂晶未一次全部吞噬")
	_check(PlayerData.get_wanling_human_consumed_count(1) == 3, "小怪吞噬数量错误")
	_check(PlayerData.get_wanling_soul_crystal_count(1) == 0, "小怪吞噬后仍残留魂晶")

	PlayerData.add_dj("human_soul_crystal_6", 60)
	_check(PlayerData.consume_all_wanling_human_crystals(6) == 50, "Boss未吞噬到50上限")
	_check(PlayerData.get_wanling_human_consumed_count(6) == 50, "Boss吞噬数量错误")
	_check(PlayerData.get_wanling_soul_crystal_count(6) == 10, "达到Boss上限后未保留多余魂晶")
	_check(PlayerData.consume_all_wanling_human_crystals(6) == 0, "Boss达到上限后仍可吞噬")

	PlayerData.add_dj("human_soul_crystal_11", 2)
	PlayerData.add_dj("human_soul_crystal_13", 5)
	PlayerData.add_dj("human_soul_crystal_3", 2)
	PlayerData.add_dj("human_soul_crystal_7", 1)
	PlayerData.add_dj("human_soul_crystal_17", 3)
	PlayerData.add_dj("human_soul_crystal_18", 3)
	PlayerData.add_dj("human_soul_crystal_24", 4)
	PlayerData.add_dj("human_soul_crystal_21", 1)
	PlayerData.add_dj("human_soul_crystal_23", 1)
	_check(PlayerData.consume_all_wanling_human_crystals(11) == 2, "伤害魂晶吞噬失败")
	_check(PlayerData.consume_all_wanling_human_crystals(13) == 5, "恢复魂晶吞噬失败")
	_check(PlayerData.consume_all_wanling_human_crystals(3) == 2, "大猩猩魂晶吞噬失败")
	_check(PlayerData.consume_all_wanling_human_crystals(7) == 1, "蝙蝠魂晶吞噬失败")
	_check(PlayerData.consume_all_wanling_human_crystals(17) == 3, "龟丞相魂晶吞噬失败")
	_check(PlayerData.consume_all_wanling_human_crystals(18) == 3, "免伤魂晶吞噬失败")
	_check(PlayerData.consume_all_wanling_human_crystals(24) == 4, "吸血魂晶吞噬失败")
	_check(PlayerData.consume_all_wanling_human_crystals(21) == 1, "牛魔斗士魂晶吞噬失败")
	_check(PlayerData.consume_all_wanling_human_crystals(23) == 1, "牛魔王人魂晶吞噬失败")
	var totals: = PlayerData.get_wanling_attribute_totals()
	_check(is_equal_approx(float(totals["SHp"]), 150.0), "生命加成汇总错误")
	_check(is_equal_approx(float(totals["SMp"]), 25.0), "魔法加成汇总错误")
	_check(is_equal_approx(float(totals["Mdef"]), 8.0), "大猩猩魔防加成汇总错误")
	_check(is_equal_approx(float(totals["Def"]), 12.0), "龟丞相物防加成汇总错误")
	_check(is_equal_approx(float(totals["Crit"]), 1000.0), "暴击加成汇总错误")
	_check(is_equal_approx(float(totals["ar"]), 3.0) and is_equal_approx(float(totals["sp"]), 3.0), "破甲破魔加成汇总错误")
	_check(is_equal_approx(float(totals["R_hp"]), 1.0) and is_equal_approx(float(totals["R_mp"]), 1.0), "回血回魔汇总错误")
	_check(is_equal_approx(float(totals["damage_bonus"]), 0.004), "伤害百分比汇总错误")
	_check(is_equal_approx(float(totals["damage_reduction"]), 0.008), "免伤百分比汇总错误")
	_check(is_equal_approx(float(totals["vampirism"]), 0.0004), "吸血百分比汇总错误")

	PlayerData.add_dj("underworld_soul_crystal_26", 3)
	_check(PlayerData.get_wanling_underworld_soul_crystal_count(26) == 3, "地府魂晶库存统计失败")
	_check(PlayerData.consume_all_wanling_underworld_crystals(26) == 3, "地府魂晶吞噬失败")
	_check(PlayerData.get_wanling_underworld_consumed_count(26) == 3, "地府吞噬数量错误")
	_check(PlayerData.get_wanling_underworld_soul_crystal_count(26) == 0, "地府魂晶吞噬后仍残留")
	totals = PlayerData.get_wanling_attribute_totals()
	_check(is_equal_approx(float(totals["SHp"]), 300.0), "地府图录属性汇总错误")

	PlayerData.add_dj("heaven_soul_crystal_74", 4)
	_check(PlayerData.get_wanling_heaven_soul_crystal_count(74) == 4, "天庭魂晶库存统计失败")
	_check(PlayerData.consume_all_wanling_heaven_crystals(74) == 4, "天庭魂晶吞噬失败")
	_check(PlayerData.get_wanling_heaven_consumed_count(74) == 4, "天庭吞噬数量错误")
	_check(PlayerData.get_wanling_heaven_soul_crystal_count(74) == 0, "天庭魂晶吞噬后仍残留")
	totals = PlayerData.get_wanling_attribute_totals()
	_check(is_equal_approx(float(totals["SHp"]), 500.0), "天庭图录属性未进入汇总")

	RoleProp.get_last_prop()
	_check(float(RoleProp.roleprop.SHp) >= 300.0, "图录生命未进入人物最终属性")
	_check(float(RoleProp.roleprop.SMp) >= 25.0, "图录魔法未进入人物最终属性")
	_check(float(RoleProp.roleprop.Crit) >= 1000.0, "图录暴击未进入人物最终属性")
	_check(float(RoleProp.roleprop.damage_bonus) >= 0.004, "图录伤害未进入人物最终属性")
	_check(float(RoleProp.roleprop.damage_reduction) >= 0.006, "图录免伤未进入人物最终属性")
	_check(float(RoleProp.roleprop.vampirism) >= 0.0004, "图录吸血未进入人物最终属性")

	var page_scene: = load("res://Scene/Main_menu/WanLingCatalogPage.tscn") as PackedScene
	var page: = page_scene.instantiate()
	add_child(page)
	await get_tree().process_frame
	await get_tree().process_frame
	var list_scroll: ScrollContainer = page.get_node("Stage/ContentPanel/MonsterScroll")
	var scroll_start: = list_scroll.scroll_vertical
	var touch_down: = InputEventScreenTouch.new()
	touch_down.position = Vector2(450, 500)
	touch_down.pressed = true
	page._input(touch_down)
	var touch_drag: = InputEventScreenDrag.new()
	touch_drag.position = Vector2(450, 420)
	touch_drag.relative = Vector2(0, -80)
	page._input(touch_drag)
	_check(list_scroll.scroll_vertical > scroll_start, "万灵图录列表中间拖动未滚动")
	var touch_up: = InputEventScreenTouch.new()
	touch_up.position = Vector2(450, 420)
	touch_up.pressed = false
	page._input(touch_up)
	page._show_category("地府")
	await get_tree().process_frame
	_check(list_scroll.visible, "地府图录列表未显示")
	_check(page.get_node("Stage/ContentPanel/MonsterScroll/MonsterGrid").get_child_count() == 23, "地府图录卡片数量错误")
	page._show_category("天庭")
	await get_tree().process_frame
	_check(list_scroll.visible, "天庭图录列表未显示")
	_check(page.get_node("Stage/ContentPanel/MonsterScroll/MonsterGrid").get_child_count() == 45, "天庭图录卡片数量错误")
	_check(page._get_monster_name(114) == "太上老君", "天庭图录怪物名称错误")
	_check(page._get_monster_name(134) == "马天君", "天庭图录怪物名称错误")
	_check(page._get_monster_name(135) == "天王使者", "天庭图录怪物名称错误")
	_check(page._get_monster_name(136) == "持国傀儡", "天庭图录怪物名称错误")
	_check(page._get_effect_text(136) == "每个+1000生命", "持国傀儡图录属性说明错误")
	_check(page._get_consume_limit(136) == 50, "持国傀儡图录上限显示错误")
	_check(page._get_monster_name(137) == "持国天王", "天庭图录怪物名称错误")
	_check(page._get_effect_text(114) == "每个+0.16%伤害、0.15%免伤", "天庭图录属性说明错误")

	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var screenshot_path: = ProjectSettings.globalize_path("user://wanling_catalog_probe.png")
		var image: = get_viewport().get_texture().get_image()
		_check(image != null and image.save_png(screenshot_path) == OK, "万灵图录截图保存失败")
		print("WANLING_CATALOG_SCREENSHOT=" + screenshot_path)
		page.queue_free()

	PlayerData.player_data["道具列表"] = original_items
	if original_catalog == null:
		PlayerData.player_data.erase(PlayerData.WANLING_CATALOG_LEVELS_KEY)
	else:
		PlayerData.player_data[PlayerData.WANLING_CATALOG_LEVELS_KEY] = original_catalog
	print("WANLING_CATALOG_PROBE_OK")
	get_tree().quit(1 if _failed else 0)


func _check(condition: bool, message: String) -> void :
	if condition:
		return
	push_error(message)
	_failed = true
