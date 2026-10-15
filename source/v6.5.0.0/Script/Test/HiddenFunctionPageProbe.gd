extends SceneTree

const ANNOUNCEMENT_SCENE_PATH: = "res://Scene/Main_menu/GameAnnouncement.tscn"
const SHOP_SCENE_PATH: = "res://Scene/Shop/SHOP.tscn"
const OUTPUT_PATH: = "res://.tmp/hidden_function_page.png"


func _init() -> void :
	call_deferred("_run")


func _run():
	var announcement_scene: = load(ANNOUNCEMENT_SCENE_PATH) as PackedScene
	if announcement_scene == null:
		return _fail("announcement scene load")
	var announcement: = announcement_scene.instantiate()
	root.add_child(announcement)
	await process_frame
	await process_frame

	var password_overlay: = announcement.get_node_or_null("SecretPasswordOverlay") as Control
	var function_overlay: = announcement.get_node_or_null("SecretFunctionOverlay") as Control
	if password_overlay == null or function_overlay == null:
		return _fail("secret overlays")

	for click_index in range(9):
		if bool(announcement.call("register_secret_title_click", click_index * 250)):
			return _fail("opened before tenth click")
	if password_overlay.visible:
		return _fail("password visible before tenth click")
	if not bool(announcement.call("register_secret_title_click", 2250)) or not password_overlay.visible:
		return _fail("ten clicks inside three seconds")

	announcement.call("_close_secret_password")
	announcement.set("_secret_click_times", [])
	for click_index in range(10):
		if bool(announcement.call("register_secret_title_click", 5000 + click_index * 400)):
			return _fail("accepted clicks outside three seconds")
	if password_overlay.visible:
		return _fail("outside-window password visibility")

	announcement.set("_secret_click_times", [])
	for click_index in range(10):
		announcement.call("register_secret_title_click", 10000 + click_index * 300)
	var password_input: = announcement.get_node("SecretPasswordOverlay/PasswordPanel/PasswordMargin/PasswordContent/PasswordInput") as LineEdit
	password_input.text = "QQ63334739"
	announcement.call("_submit_secret_password")
	if not password_overlay.visible or function_overlay.visible:
		return _fail("wrong password accepted")
	password_input.text = "qq63334739"
	announcement.call("_submit_secret_password")
	await process_frame
	if password_overlay.visible or not function_overlay.visible:
		return _fail("correct password rejected")

	var required_controls: = [
		"FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/LeftColumn/Invincible", 
		"FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/LeftColumn/InstantKill", 
		"FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/LeftColumn/AllMaps", 
		"FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/LeftColumn/AddSouls", 
		"FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/LeftColumn/OneClickDivineSet", 
		"FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/RightColumn/FreeShop", 
		"FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/RightColumn/AllShopItems", 
		"FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/RightColumn/PlayerMaxLevel", 
		"FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/RightColumn/PetsMaxLevel", 
		"FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/RightColumn/PetGrowthMax", 
		"FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/RightColumn/WanLingMax", 
		"FunctionPanel/FunctionMargin/FunctionContent/MapProgressRow/MapSelector", 
		"FunctionPanel/FunctionMargin/FunctionContent/MapProgressRow/ClearProgress", 
	]
	for control_path in required_controls:
		if function_overlay.get_node_or_null(control_path) == null:
			return _fail("missing control %s" % control_path)

	var panel: = function_overlay.get_node("FunctionPanel") as Control
	var viewport_center: = root.get_viewport().get_visible_rect().size * 0.5
	if panel.get_global_rect().get_center().distance_to(viewport_center) > 1.0:
		return _fail("function panel center %s viewport %s" % [panel.get_global_rect().get_center(), viewport_center])

	if not _verify_secret_rewards(announcement):
		return
	if not _verify_wanling_max(announcement):
		return
	if not _verify_map_progress_clear(announcement):
		return

	var shop_verified: = false
	if not OS.get_cmdline_user_args().has("--skip-shop"):
		if not await _verify_shop_features():
			return
		shop_verified = true

	var screenshot_output: = "headless-skipped"
	if DisplayServer.get_name() != "headless":
		await process_frame
		await process_frame
		var output_dir: = ProjectSettings.globalize_path("res://.tmp")
		DirAccess.make_dir_recursive_absolute(output_dir)
		var image: = root.get_viewport().get_texture().get_image()
		if image == null:
			return _fail("viewport image unavailable")
		if image.save_png(ProjectSettings.globalize_path(OUTPUT_PATH)) != OK:
			return _fail("screenshot")
		screenshot_output = OUTPUT_PATH
	print("HIDDEN_FUNCTION_PAGE_OK clicks password controls=10 centered soul divine_set shop=%s output=%s" % [shop_verified, screenshot_output])
	quit(0)


func _verify_secret_rewards(announcement: Node) -> bool:
	var expected_weapons: = {
		1: "cswkxyhb", 
		2: "cstsxyhb", 
		3: "csbjxyhb", 
		4: "csssxyhb", 
		5: "csblxyhb", 
	}
	var expected_armors: = {
		1: "xyfjwk", 
		2: "xyfjts", 
		3: "xyfjbj", 
		4: "xyfjss", 
		5: "xyfjbl", 
	}
	for role_id in expected_weapons:
		var weapon_id: = str(expected_weapons[role_id])
		if str(announcement.call("_get_secret_weapon_id", int(role_id))) != weapon_id:
			return _fail("role weapon mapping %s" % role_id)
		var generated: Dictionary = announcement.call("_build_secret_equipment", weapon_id, true)
		if not _is_max_secret_equipment(generated, weapon_id, true):
			return _fail("generated weapon %s" % weapon_id)
		var armor_id: = str(expected_armors[role_id])
		if str(announcement.call("_get_secret_armor_id", int(role_id))) != armor_id:
			return _fail("role armor mapping %s" % role_id)
		var generated_armor: Dictionary = announcement.call("_build_secret_equipment", armor_id, true)
		if not _is_max_secret_equipment(generated_armor, armor_id, true):
			return _fail("generated armor %s" % armor_id)

	var generated_accessory: Dictionary = announcement.call("_build_secret_equipment", "cjshenj", true)
	var generated_wing: Dictionary = announcement.call("_build_secret_equipment", "xyzy", false)
	if not _is_max_secret_equipment(generated_accessory, "cjshenj", true):
		return _fail("generated accessory")
	if not _is_max_secret_equipment(generated_wing, "xyzy", false):
		return _fail("generated wing")

	var player_data_node: = root.get_node_or_null("PlayerData")
	if player_data_node == null:
		return _fail("PlayerData autoload")
	var live_player_data: Variant = player_data_node.get("player_data")
	if not (live_player_data is Dictionary):
		return _fail("PlayerData dictionary")
	var original_player_data: Dictionary = (live_player_data as Dictionary).duplicate(true)
	var test_data: Dictionary = original_player_data.duplicate(true)
	test_data["Myself"] = 1
	test_data["coin_num"] = 23
	for page_key in test_data["装备列表"]:
		test_data["装备列表"][page_key].clear()
	var old_weapon: Dictionary = announcement.call("_build_secret_equipment", "cswkxyhb", true)
	old_weapon["强化等级"] = 1
	var old_armor: Dictionary = announcement.call("_build_secret_equipment", "xyfjwk", true)
	old_armor["强化等级"] = 4
	var old_accessory: = generated_accessory.duplicate(true)
	old_accessory["强化等级"] = 2
	var old_wing: = generated_wing.duplicate(true)
	old_wing["强化等级"] = 3
	test_data["武器"] = [old_weapon]
	test_data["防具"] = [old_armor]
	test_data["饰品"] = [old_accessory]
	test_data["翅膀"] = [old_wing]
	player_data_node.set("player_data", test_data)

	announcement.call("_add_100_million_souls", false)
	var failure_reason: = ""
	if int(test_data["coin_num"]) != 100000023:
		failure_reason = "soul reward"
	elif not bool(announcement.call("_equip_one_click_divine_set", false)):
		failure_reason = "one-click equip rejected"
	elif not _is_equipped_item("武器", "cswkxyhb", true):
		failure_reason = "equipped role weapon"
	elif not _is_equipped_item("防具", "xyfjwk", true):
		failure_reason = "equipped role armor"
	elif not _is_equipped_item("饰品", "cjshenj", true):
		failure_reason = "equipped accessory"
	elif not _is_equipped_item("翅膀", "xyzy", false):
		failure_reason = "equipped wing"
	else:
		var backpack_items: Array = player_data_node.call("get_total_zb_list")
		var old_levels: = []
		for item_value in backpack_items:
			if item_value is Dictionary:
				old_levels.push_back(int((item_value as Dictionary).get("强化等级", -1)))
		old_levels.sort()
		if old_levels != [1, 2, 3, 4]:
			failure_reason = "old equipment preservation %s" % [old_levels]

	player_data_node.set("player_data", original_player_data)
	if not failure_reason.is_empty():
		return _fail(failure_reason)
	return true


func _verify_wanling_max(announcement: Node) -> bool:
	var player_data_node: = root.get_node_or_null("PlayerData")
	if player_data_node == null:
		return _fail("PlayerData autoload for wanling")
	var live_player_data: Variant = player_data_node.get("player_data")
	if not (live_player_data is Dictionary):
		return _fail("PlayerData dictionary for wanling")
	var original_player_data: Dictionary = (live_player_data as Dictionary).duplicate(true)
	var test_data: Dictionary = original_player_data.duplicate(true)
	test_data["万灵图录等级"] = {}
	player_data_node.set("player_data", test_data)
	announcement.call("_max_all_wanling_catalog", false)
	var catalog: Variant = test_data.get("万灵图录等级", {})
	var failure_reason: = ""
	if not (catalog is Dictionary):
		failure_reason = "catalog missing"
	else:
		var category_specs: = [
			["人间", [1, 24], "get_wanling_human_consume_limit"], 
			["地府", [26, 58], "get_wanling_underworld_consume_limit"], 
			["天庭", [74, 114, 134, 135, 136, 137], "get_wanling_heaven_consume_limit"], 
		]
		for spec in category_specs:
			var levels: Variant = (catalog as Dictionary).get(spec[0], {})
			if not (levels is Dictionary):
				failure_reason = "category missing %s" % spec[0]
				break
			for monster_id in spec[1]:
				var expected: = int(player_data_node.call(spec[2], int(monster_id)))
				if int((levels as Dictionary).get(str(int(monster_id)), -1)) != expected:
					failure_reason = "not maxed %s:%d" % [spec[0], int(monster_id)]
					break
			if not failure_reason.is_empty():
				break
	player_data_node.set("player_data", original_player_data)
	if not failure_reason.is_empty():
		return _fail(failure_reason)
	return true


func _verify_map_progress_clear(announcement: Node) -> bool:
	var player_data_node: = root.get_node_or_null("PlayerData")
	if player_data_node == null:
		return _fail("PlayerData autoload for map progress")
	var selector: = announcement.get_node("SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/MapProgressRow/MapSelector") as OptionButton
	var expected_map_keys: Array = announcement.call("_get_map_progress_keys")
	if selector.item_count != expected_map_keys.size():
		return _fail("map selector count %d" % selector.item_count)
	var live_player_data: Variant = player_data_node.get("player_data")
	if not (live_player_data is Dictionary):
		return _fail("PlayerData dictionary for map progress")
	var original_player_data: Dictionary = (live_player_data as Dictionary).duplicate(true)
	var test_data: Dictionary = original_player_data.duplicate(true)
	test_data["兜率宫"] = 1
	test_data["兜率宫层数"] = 5
	for floor_index in range(1, 6):
		test_data["兜率宫%d" % floor_index] = 1
	test_data["关卡评价"]["兜率宫"] = 3
	test_data["水帘洞"] = 1
	test_data["关卡评价"]["水帘洞"] = 2
	player_data_node.set("player_data", test_data)

	for item_index in range(selector.item_count):
		if selector.get_item_text(item_index) == "兜率宫":
			selector.select(item_index)
			break
	var cleared: = bool(announcement.call("_clear_selected_map_progress", false))
	var failure_reason: = ""
	if not cleared:
		failure_reason = "map progress clear rejected"
	elif int(test_data["兜率宫层数"]) != 0 or int(test_data["关卡评价"]["兜率宫"]) != 0:
		failure_reason = "special map progress remains"
	else:
		for floor_index in range(1, 6):
			if int(test_data["兜率宫%d" % floor_index]) != 0:
				failure_reason = "special map floor remains %d" % floor_index
				break
	if failure_reason.is_empty() and (int(test_data["水帘洞"]) != 1 or int(test_data["关卡评价"]["水帘洞"]) != 2):
		failure_reason = "unselected map progress changed"

	var map_5_sequence: = ["绝仙门", "紫晶门", "戮仙门", "指景宫", "陷仙门", "绝境宫", "通天教主"]
	if failure_reason.is_empty():
		for level_name in map_5_sequence:
			test_data[level_name] = 1
			test_data["关卡评价"][level_name] = 3
		for item_index in range(selector.item_count):
			if selector.get_item_text(item_index) == "指景宫":
				selector.select(item_index)
				break
		if not bool(announcement.call("_clear_selected_map_progress", false)):
			failure_reason = "map 5 progress clear rejected"
	if failure_reason.is_empty():
		for level_index in range(map_5_sequence.size()):
			var level_name: String = map_5_sequence[level_index]
			var expected_progress: = 1 if level_index < 3 else 0
			if int(test_data[level_name]) != expected_progress or int(test_data["关卡评价"][level_name]) != expected_progress * 3:
				failure_reason = "map 5 sequence reset %s" % level_name
				break
	if failure_reason.is_empty() and int(test_data["绝境宫"]) != 0:
		failure_reason = "map 5 final prerequisite remains"

	player_data_node.set("player_data", original_player_data)
	if not failure_reason.is_empty():
		return _fail(failure_reason)
	return true


func _is_equipped_item(slot_name: String, expected_id: String, divine_forge: bool) -> bool:
	var player_data_node: = root.get_node_or_null("PlayerData")
	if player_data_node == null:
		return false
	var player_data: Variant = player_data_node.get("player_data")
	if not (player_data is Dictionary):
		return false
	var equipped: Variant = (player_data as Dictionary).get(slot_name, [])
	if not (equipped is Array) or (equipped as Array).size() != 1:
		return false
	return _is_max_secret_equipment((equipped as Array)[0], expected_id, divine_forge)


func _is_max_secret_equipment(item: Dictionary, expected_id: String, divine_forge: bool) -> bool:
	if str(item.get("名字", "")) != expected_id or int(item.get("强化等级", -1)) != 30:
		return false
	var data: Variant = item.get("Data", {})
	if not (data is Dictionary):
		return false
	var equipment_data: = data as Dictionary
	if divine_forge and int(equipment_data.get("神铸阶段", 0)) != 5:
		return false
	if not divine_forge and int(equipment_data.get("神铸阶段", 0)) != 0:
		return false
	var gems: Variant = equipment_data.get("宝石", [])
	if not (gems is Array) or (gems as Array).size() != 8:
		return false
	for gem_id in gems:
		if str(gem_id) != "gjs_6":
			return false
	return true


func _verify_shop_features() -> bool:
	var global_node: = root.get_node_or_null("Global")
	if global_node == null:
		return _fail("Global autoload")
	global_node.call("set_hidden_feature_enabled", "all_shop_items", true)
	global_node.call("set_hidden_feature_enabled", "free_shop", true)
	var shop_scene: = load(SHOP_SCENE_PATH) as PackedScene
	if shop_scene == null:
		return _fail("shop scene load")
	var shop: = shop_scene.instantiate()
	root.add_child(shop)
	await process_frame
	var total_items: Array = shop.get("TotalItemList")
	if total_items.size() < 100:
		shop.queue_free()
		return _fail("shop all-items count %d" % total_items.size())
	if int(shop.call("_shop_item_price", {"price": 999})) != 0:
		shop.queue_free()
		return _fail("free shop price")
	shop.queue_free()
	global_node.call("set_hidden_feature_enabled", "all_shop_items", false)
	global_node.call("set_hidden_feature_enabled", "free_shop", false)
	await process_frame
	return true


func _fail(reason: String) -> bool:
	push_error("HIDDEN_FUNCTION_PAGE_FAIL %s" % reason)
	quit(1)
	return false
