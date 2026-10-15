extends Node

const ROLES: = ["wk", "ts", "bj", "ss", "bl", "nz"]
const CATEGORIES: = ["悟空", "唐僧", "八戒", "沙僧", "白龙", "哪吒"]
const BOOK_GROUPS: = {
	67: ["ygfjwkzzs", "ygfjtszzs", "ygfjbjzzs"], 
	68: ["ygfjsszzs", "ygfjblzzs", "ygfjnzzzs"], 
	70: ["ygwqwkzzs", "ygwqtszzs", "ygwqbjzzs"], 
	71: ["ygwqsszzs", "ygwqblzzs", "ygwqnzzzs"], 
}
var failed: = false

func _ready() -> void :
	call_deferred("_run")

func _check(condition: bool, message: String) -> void :
	if not condition:
		failed = true
		push_error("MOON_PALACE_FAIL: " + message)

func _shot(name_text: String) -> void :
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var path: = ProjectSettings.globalize_path("user://moon_palace_" + name_text + ".png")
	_check(get_viewport().get_texture().get_image().save_png(path) == OK, "截图失败")
	print("MOON_PALACE_SCREENSHOT=" + path)

func _run() -> void :
	var original: Dictionary = PlayerData.player_data.duplicate(true)
	var original_path: String = Global.cd_path
	var original_windows = Global.Windows_
	Global.cd_path = ""
	Global.Windows_ = self
	AE.ensure_loaded()
	var preview = load("res://Scene/OtherScene/LevelInfo.gd").new()
	for stage in BOOK_GROUPS:
		var level = load("res://Script/Level/Level_%d.gd" % stage).new()
		var boss_id: int = {67: 3179, 68: 3182, 70: 3223, 71: 3277}[stage]
		var config: Dictionary = level.get_level_monster_config(boss_id)
		var drops: Array = config.get("independent_drop_list", [])
		preview.TargetStagePath = "res://Scene/Level/Level_%d.tscn" % stage
		var info: Dictionary = preview._get_level_info()
		for book_id in BOOK_GROUPS[stage]:
			var found: = false
			for drop in drops:
				if drop.name == book_id:
					found = int(drop.value) == 1 and is_equal_approx(float(drop.chance), 0.1)
			_check(found, "BOSS制作书掉落错误：" + book_id)
			_check(info.LevelFall.has(book_id) and info.LevelFallProbability.get(book_id) == 10, "预览掉落错误：" + book_id)
		level.free()
	preview.free()
	for slot in ["武器", "防具", "时装", "翅膀", "头衔"]:
		PlayerData.player_data[slot] = []
	PlayerData.player_data["幻化列表"] = {"武器": "", "防具": "", "时装": "", "翅膀": "", "头衔": ""}
	PlayerData.player_data["宝珠列表"] = []
	var forge = load("res://Scene/LDL/Forge.tscn").instantiate()
	add_child(forge)
	await get_tree().process_frame
	for role_id in ROLES:
		for part in ["fj", "wq"]:
			var item_id: String = "yg" + part + role_id
			var item: Dictionary = AE.AllEquipment_[item_id]
			var base: Dictionary = AE.AllEquipment_["zq" + part + role_id]
			_check(str(item["名字"]).begins_with("月宫"), "装备名称错误")
			for key in AE.PropListName:
				if base.has(key):
					_check(typeof(item[key]) == TYPE_INT and item[key] == int(ceil(float(base[key]) * 1.25)), item_id + "基础属性错误：" + key)
			for key in base["强化属性"]:
				_check(typeof(item["强化属性"][key]) == TYPE_INT and item["强化属性"][key] == int(ceil(float(base["强化属性"][key]) * 1.25)), item_id + "强化属性错误：" + key)
			for id in [item_id, item_id + "zzs"]:
				_check(ResourceLoader.exists(AE.AllEquipment_[id]["图标"]), "缺少图标：" + id)
			var book_id: String = item_id + "zzs"
			_check(forge.ItemMaterialList[book_id] == {"yhs": 66, "tss": 66}, "制作材料错误")
			PlayerData.player_data["道具列表"] = {}
			for page_number in range(1, 21):
				PlayerData.player_data["道具列表"]["页码%d" % page_number] = []
			PlayerData.add_dj(book_id, 1)
			PlayerData.add_dj("yhs", 66)
			PlayerData.add_dj("tss", 66)
			forge.replace_book(book_id, 0, {})
			_check(forge.scw.get_item_name == item_id and forge.GetEqProp() == item, "打造产物预览错误")
			_check(forge.CheckFullMaterial(), "制作书或材料不被打造识别")
			if item_id == "ygwqnz":
				await _shot("forge")
			_check(forge.RemoveAll(), "打造材料消耗失败")
			_check(forge._get_forge_item_count(book_id) == 0 and forge._get_forge_item_count("yhs") == 0 and forge._get_forge_item_count("tss") == 0, "制作书或材料未消耗")
			_check(PlayerData.add_zb(item_id, 0, item.duplicate(true)), "装备获取失败")
			_check(PlayerData.has_acquired_equipment(item_id), "获取没有永久解锁幻化")
	forge.free()
	for index in ROLES.size():
		var role_id: String = ROLES[index]
		PlayerData.player_data["Myself"] = index + 1
		PlayerData.player_data["幻化列表"]["防具"] = "ygfj" + role_id
		PlayerData.player_data["幻化列表"]["武器"] = "ygwq" + role_id
		var page = load("res://Scene/OtherScene/Transmogrified.tscn").instantiate()
		add_child(page)
		await get_tree().process_frame
		await get_tree().physics_frame
		var clothes_glow = page.role_body.get_node_or_null("MoonPalaceClothesEffect")
		_check(clothes_glow != null and clothes_glow.visible and clothes_glow.is_playing(), "月宫防具幻化没有循环光效")
		_check(page.RoleItemList[CATEGORIES[index]].has("ygfj" + role_id) and page.RoleItemList[CATEGORIES[index]].has("ygwq" + role_id), "幻化列表缺少角色装备")
		if index < 5:
			_check(page.role_body.texture.resource_path.ends_with("Body_ygfj" + role_id + ".png"), "防具穿戴外观错误")
			_check(page.role_equipment.texture.resource_path.ends_with("Eq_ygwq" + role_id + ".png"), "武器穿戴外观错误")
		else:
			_check(page.role_body.texture.resource_path.contains("y36_body/"), "哪吒防具未使用原版月宫")
			_check(page.role_equipment.texture.resource_path.contains("y36_weapon/"), "哪吒武器未使用原版月宫")
			_check(page.role_body_front.texture.resource_path.contains("y36_body_front/"), "哪吒前景层未使用原版月宫")
		await _shot(role_id)
		page.free()
	var hero = load("res://Scene/Hero/Role_6/Role_6.tscn").instantiate()
	add_child(hero)
	hero.position = Vector2(500, 340)
	hero.set_physics_process(false)
	hero.ChangeBody("ygfjnz")
	hero.ChangeEq("ygwqnz")
	var combat_glow = hero.role_body.get_node_or_null("MoonPalaceClothesEffect")
	_check(combat_glow != null and combat_glow.visible, "月宫防具缺少战斗光效")
	_check(combat_glow.sprite_frames.get_frame_count(&"idle") == 10, "月宫光效缺少原版帧")
	hero.ChangeEq("Empty")
	_check(combat_glow.visible, "只穿月宫衣服时光效消失")
	hero.ChangeBody("Empty")
	_check( not combat_glow.visible, "脱下月宫衣服后光效残留")
	hero.ChangeBody("ygfjnz")
	hero.ChangeEq("ygwqnz")
	var official_layers: = {
		"body": NeZhaEquipmentVisuals.get_body_frames("ygfjnz"), 
		"body_front": NeZhaEquipmentVisuals.get_body_front_frames("ygfjnz"), 
		"weapon": NeZhaEquipmentVisuals.get_weapon_frames("ygwqnz"), 
	}
	for animation in [&"wait", &"run", &"hit1", &"hit2", &"hit3", &"hit4", &"jump1", &"skill5"]:
		for layer in ["body", "weapon"]:
			var frames: SpriteFrames = official_layers[layer]
			for frame_index in frames.get_frame_count(animation):
				var texture: = frames.get_frame_texture(animation, frame_index)
				_check( not texture.get_image().get_used_rect().size == Vector2i.ZERO, "哪吒月宫动作存在透明帧：%s/%s/%d" % [layer, animation, frame_index])
		hero.role_action_player.play(animation)
		hero.role_action_player.seek(0.1, true)
		hero.role_action_player.pause()
		_check(hero.role_body.texture.resource_path.contains("y36_body/"), "战斗模型防具层错误")
		_check(hero.role_body_front.texture.resource_path.contains("y36_body_front/"), "战斗模型防具前景层错误")
		_check(hero.role_equipment.texture.resource_path.contains("y36_weapon/"), "战斗模型武器层错误")
		await _shot("nz_" + str(animation))
	var weapon_image: Image = official_layers["weapon"].get_frame_texture(&"wait", 0).get_image()
	var blue_pixels: = 0
	for y in weapon_image.get_height():
		for x in weapon_image.get_width():
			var pixel: = weapon_image.get_pixel(x, y)
			if pixel.a > 0.5 and pixel.b > pixel.r * 1.3 and pixel.b > 0.3:
				blue_pixels += 1
	_check(blue_pixels > 300, "哪吒月宫武器未保留原版蓝色长枪")
	hero.free()
	PlayerData.player_data["Myself"] = 5
	PlayerData.player_data["幻化列表"]["防具"] = "ygfjbl"
	PlayerData.player_data["幻化列表"]["武器"] = "ygwqbl"
	var white_dragon = load("res://Scene/Hero/Role_5/Role_5.tscn").instantiate()
	add_child(white_dragon)
	white_dragon.position = Vector2(500, 340)
	white_dragon.set_physics_process(false)
	white_dragon.role_action_player.play(&"wait")
	white_dragon.role_action_player.seek(0.0, true)
	white_dragon.role_action_player.pause()
	await get_tree().process_frame
	var dragon_glow = white_dragon.RoleBody.get_node("MoonPalaceClothesEffect")
	_check(is_equal_approx(dragon_glow.position.y, white_dragon.RoleBody.offset.y + 109.0 - 50.95), "白龙月宫光环未对齐脚底")
	_check(dragon_glow.z_index > 0, "月宫光环未置于装备前景")
	await _shot("bl_combat_glow")
	white_dragon.free()
	PlayerData.player_data["Myself"] = 6
	PlayerData.player_data["幻化列表"]["防具"] = "ygfjnz"
	PlayerData.player_data["幻化列表"]["武器"] = "ygwqnz"
	var backpack = load("res://Scene/BackPack/BackPack.tscn").instantiate()
	add_child(backpack)
	await get_tree().process_frame
	await get_tree().physics_frame
	var backpack_glow = backpack.get_node("background/RoleBody/MoonPalaceClothesEffect")
	_check(backpack_glow.visible and backpack_glow.is_playing(), "背包月宫光效没有显示")
	await _shot("nz_backpack")
	backpack.free()
	var catalog = load("res://Scene/Main_menu/EquipmentCatalogPage.tscn").instantiate()
	add_child(catalog)
	await get_tree().process_frame
	for index in ROLES.size():
		catalog.select_category(CATEGORIES[index])
		for part in ["fj", "wq"]:
			var item_id: String = "yg" + part + ROLES[index]
			_check(catalog.displayed_ids.has(item_id), "图鉴缺少装备")
			_check(catalog.catalog.get_sources(item_id).contains("东胜神洲"), "图鉴缺少制作书掉落位置")
	catalog.select_item("ygwqnz")
	await _shot("catalog")
	catalog.free()
	PlayerData.player_data = original
	Global.cd_path = original_path
	Global.Windows_ = original_windows
	NeZhaEquipmentVisuals.clear_cached_frames()
	print("MOON_PALACE_PROBE_OK" if not failed else "MOON_PALACE_PROBE_FAILED")
	get_tree().quit(1 if failed else 0)
