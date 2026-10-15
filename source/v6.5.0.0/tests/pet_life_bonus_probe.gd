extends SceneTree

const SKILLS: = [
	["生命加成", "smjc"], ["攻击加成", "gjjc"], ["防御加成", "fyjc"], 
	["魔法庇佑", "mfby"], ["嗜血狂爆", "sxkb"], ["法术能量", "fsnl"], 
	["天生蛮力", "tsml"], ["自然守护", "zrsh"], ["生命祝福", "smzf"], 
	["魔法加成", "mfjc"]
]

class ProbePet:
	extends Node
	var SMp: = 200
	var Mp: = 200
	var SHp: = 1000
	var Hp: = 1000
	var attack_in: = 100
	var def: = 80
	var crit: = 20
	var objattackDic: = {"hit1": {"power": 100}, "hit2": {"power": 200}}

	func _rebuild_pet_attack_data() -> void :
		objattackDic["hit1"]["power"] = attack_in
		objattackDic["hit2"]["power"] = attack_in * 2

var failures: Array[String] = []


func _init() -> void :
	call_deferred("_run")


func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)


func _run() -> void :
	var runtime_script: Variant = load("res://Script/Pet/PetLifeBonusRuntime.gd")
	_check(runtime_script != null, "宠物学习技能运行脚本无法加载")
	if runtime_script != null:
		_check(int(runtime_script.scaled_bonus(1000, 1)) == 20, "1级加成公式错误")
		_check(int(runtime_script.scaled_bonus(1000, 10)) == 200, "10级加成公式错误")
		_check(int(runtime_script.active_scaled_bonus(1000, 1, 10)) == 24, "学习主动技能没有受到根骨效果加成")
		_check(float(runtime_script.learned_cooldown_seconds({"灵力": 10})) == 24.0, "学习主动技能没有受到灵力冷却加成")
		var defense_values: Dictionary = runtime_script.defense_bonuses(1000, 600, 1)
		_check(int(defense_values.get("physical", 0)) == 20 and int(defense_values.get("magic", 0)) == 12, "防御加成没有分别按宠物物防和魔防计算")
		_check(float(runtime_script.duration_seconds(1)) == 30.0, "1级持续时间错误")
		_check(float(runtime_script.duration_seconds(10)) == 120.0, "10级持续时间错误")
		_check(float(runtime_script.COOLDOWN_SECONDS) == 30.0, "冷却时间不是30秒")

	for skill in SKILLS:
		var asset_id: = str(skill[1])
		_check(ResourceLoader.exists("res://Art/Pet/skillicon/%s.png" % asset_id), "技能图标不存在：%s" % asset_id)
		_check(ResourceLoader.exists("res://Art/BackPack/AllItems/%s_skill_book.png" % asset_id), "技能书图标不存在：%s" % asset_id)
	for buff_icon in ["PetLifeBonus", "PetAttackBonus", "PetDefenseBonus", "PetManaBonus"]:
		_check(ResourceLoader.exists("res://Art/AddEffect/Buff_icon/%s.png" % buff_icon), "状态图标不存在：%s" % buff_icon)

	await _verify_learning_page()
	await _verify_pet_effects(runtime_script)
	await _verify_owner_buffs()

	if failures.is_empty():
		print("PET_LEARNED_SKILLS_PROBE_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _verify_learning_page() -> void :
	var interface_scene: PackedScene = load("res://Scene/Pet/PetInterface.tscn") as PackedScene
	var player_data: Node = root.get_node_or_null("PlayerData")
	_check(interface_scene != null and player_data != null, "学习页面依赖无法加载")
	if interface_scene == null or player_data == null:
		return
	var interface: Node = interface_scene.instantiate()
	root.add_child(interface)
	await process_frame
	var formation_button: = interface.get_node_or_null("PetAttributeShow/PetFormationButton") as Button
	var learn_button: = interface.get_node_or_null("PetAttributeShow/LearnSkillButton") as Button
	_check(formation_button != null and formation_button.text == "宠物阵法" and formation_button.is_visible_in_tree(), "宠物属性页没有显示宠物阵法按钮")
	_check(formation_button != null and formation_button.disabled, "没有选择宠物时仍然可以点击宠物阵法")
	if formation_button != null and learn_button != null:
		_check(formation_button.position.y == learn_button.position.y and formation_button.position.x + formation_button.size.x < learn_button.position.x, "宠物阵法按钮没有位于学习技能旁边")
	interface.set("current_pet_index", 0)
	interface.call("_refresh_all")
	_check(formation_button != null and not formation_button.disabled, "选择宠物后宠物阵法按钮没有恢复可点击")
	var pet: Variant = interface.call("_current_pet")
	_check(pet is Dictionary, "没有可用于学习验证的宠物")
	if pet is Dictionary:
		var stored_skills: Array = pet.get("技能", []) if pet.get("技能", []) is Array else []
		var levels: Variant = pet.get("技能等级", {})
		for skill in SKILLS:
			stored_skills.erase(str(skill[0]))
			if levels is Dictionary:
				levels.erase(str(skill[0]))
		pet["技能"] = stored_skills
		interface.call("_on_learn_skill_pressed")
		await process_frame
		var popup: Control = interface.get_node_or_null("PetSkillLearnPopup") as Control
		var window: Control = interface.get_node_or_null("PetSkillLearnPopup/Window") as Control
		var list: VBoxContainer = interface.get_node_or_null("PetSkillLearnPopup/Window/SkillScroll/SkillList") as VBoxContainer
		_check(popup != null and popup.visible, "学习按钮没有打开学习页面")
		if popup != null and window != null:
			_check(window.position + window.size * 0.5 == popup.size * 0.5, "学习页面没有居中")
		_check(list != null and list.get_child_count() == SKILLS.size() + 1, "学习页面没有枚举全部技能")
		if list != null:
			var defense_descriptions: = {}
			for row in list.get_children():
				var row_name: = row.get_node_or_null("Content/Name") as Label
				var row_description: = row.get_node_or_null("Content/Description") as Label
				if row_name != null and row_description != null and row_name.text in ["防御加成", "自然守护"]:
					defense_descriptions[row_name.text] = row_description.text
			var owner_defense_description: = str(defense_descriptions.get("防御加成", ""))
			_check(owner_defense_description.contains("技能等级×2%×宠物物防") and owner_defense_description.contains("技能等级×2%×宠物魔防"), "防御加成描述没有分别按宠物物防和宠物魔防显示公式")
			_check(str(defense_descriptions.get("自然守护", "")).contains("宠物物防") and str(defense_descriptions.get("自然守护", "")).contains("宠物魔防"), "自然守护描述没有明确显示物防和魔防")
		var missing_book_id: = "gjjc_skill_book"
		var missing_book_count: = int(player_data.call("get_item_data", missing_book_id))
		if missing_book_count > 0:
			player_data.call("remove_dj", missing_book_id, player_data.call("get_dj_page", missing_book_id), missing_book_count)
		interface.call("_learn_pet_skill", "攻击加成", missing_book_id)
		await process_frame
		var missing_tip: CanvasItem = null
		for child in interface.get_children():
			if child.get_script() != null and str(child.get_script().resource_path).ends_with("MomentText.gd"):
				missing_tip = child as CanvasItem
		_check(missing_tip != null and popup != null and missing_tip.z_index > popup.z_index, "缺少技能书提示没有显示在学习页面上方")
		for skill in SKILLS:
			var skill_name: = str(skill[0])
			var book_id: = "%s_skill_book" % str(skill[1])
			var old_count: = int(player_data.call("get_item_data", book_id))
			if old_count > 0:
				player_data.call("remove_dj", book_id, player_data.call("get_dj_page", book_id), old_count)
			player_data.call("add_dj", book_id, 1)
			var defense_before_learning: = ""
			if skill_name == "自然守护":
				interface.call("_refresh_current_pet")
				defense_before_learning = str((interface.get("pet_attribute_stat_values") as Array)[3].text)
			interface.call("_learn_pet_skill", skill_name, book_id)
			_check(pet.get("技能", []).has(skill_name), "%s没有写入宠物技能" % skill_name)
			_check(pet.get("已学习技能", []).has(skill_name), "%s没有写入永久学习技能" % skill_name)
			_check(int(pet.get("技能等级", {}).get(skill_name, 0)) == 1, "%s初始等级不是1" % skill_name)
			_check(int(player_data.call("get_item_data", book_id)) == 0, "%s没有消耗对应技能书" % skill_name)
			if skill_name == "自然守护":
				_check(str((interface.get("pet_attribute_stat_values") as Array)[3].text) != defense_before_learning, "学习自然守护后没有立即刷新宠物属性")
			interface.call("_learn_pet_skill", skill_name, book_id)
			_check(pet.get("技能", []).count(skill_name) == 1, "%s被重复学习" % skill_name)
		interface.call("_close_pet_skill_learn_popup")
		pet["技能"] = []
		interface.call("_refresh_all")
		interface.call("_on_learn_skill_pressed")
		await process_frame
		var learned_button: Button = null
		for row in list.get_children():
			var row_name: = row.get_node_or_null("Content/Name") as Label
			if row_name != null and row_name.text == "攻击加成":
				learned_button = row.get_node_or_null("Content/LearnButton") as Button
				break
		_check(learned_button != null and learned_button.disabled and learned_button.text == "已学习", "刷新页面后已学习技能没有永久保留")

		interface.call("_on_upgrade_skill_pressed")
		await process_frame
		var upgrade_list: = interface.get_node_or_null("PetSkillUpgradePopup/Window/SkillScroll/SkillList")
		var learned_upgrade_row: Node = null
		if upgrade_list != null:
			for row in upgrade_list.get_children():
				var row_name: = row.get_node_or_null("Content/Name") as Label
				if row_name != null and row_name.text == "攻击加成":
					learned_upgrade_row = row
					break
		_check(learned_upgrade_row != null, "升级技能页面没有显示已学习技能")

		var upgrade_book_id: = "gjjc_skill_book"
		var upgrade_book_count: = int(player_data.call("get_item_data", upgrade_book_id))
		if upgrade_book_count > 0:
			player_data.call("remove_dj", upgrade_book_id, player_data.call("get_dj_page", upgrade_book_id), upgrade_book_count)
		player_data.call("add_dj", upgrade_book_id, 2)
		pet["技能等级"]["攻击加成"] = 1
		var souls_before: = int(player_data.get("player_data").get("coin_num", 0))
		interface.set("pending_pet_skill_upgrade", "攻击加成")
		interface.call("_confirm_pet_skill_upgrade")
		_check(int(pet.get("技能等级", {}).get("攻击加成", 0)) == 2, "学习技能没有使用2本技能书从Lv.1升级")
		_check(int(player_data.call("get_item_data", upgrade_book_id)) == 0, "Lv.1升级没有消耗2本对应技能书")
		_check(int(player_data.get("player_data").get("coin_num", 0)) == souls_before, "学习技能升级错误消耗了灵魂")

		player_data.call("add_dj", upgrade_book_id, 2)
		interface.set("pending_pet_skill_upgrade", "攻击加成")
		interface.call("_confirm_pet_skill_upgrade")
		_check(int(pet.get("技能等级", {}).get("攻击加成", 0)) == 2, "技能书不足时学习技能仍然升级")
		_check(int(player_data.call("get_item_data", upgrade_book_id)) == 2, "技能书不足时仍然扣除了技能书")

		var guard_book_id: = "zrsh_skill_book"
		var guard_book_count: = int(player_data.call("get_item_data", guard_book_id))
		if guard_book_count > 0:
			player_data.call("remove_dj", guard_book_id, player_data.call("get_dj_page", guard_book_id), guard_book_count)
		player_data.call("add_dj", guard_book_id, 2)
		pet["技能等级"]["自然守护"] = 1
		pet["防御"] = 100
		pet["物防"] = 100
		pet["魔防"] = 100
		interface.set("pet_attribute_page", 0)
		interface.call("_refresh_current_pet")
		var stat_values: Array = interface.get("pet_attribute_stat_values")
		var defense_before: = str(stat_values[3].text)
		var magic_defense_before: = str(stat_values[5].text)
		interface.set("pending_pet_skill_upgrade", "自然守护")
		interface.call("_confirm_pet_skill_upgrade")
		_check(int(pet.get("技能等级", {}).get("自然守护", 0)) == 2, "自然守护没有使用2本技能书升级")
		_check(str(stat_values[3].text) != defense_before, "自然守护升级后没有刷新宠物防御面板")
		_check(str(stat_values[5].text) != magic_defense_before, "自然守护升级后没有刷新宠物魔防面板")

		var self_bonus_pet: = {
			"攻击": 100, 
			"生命": 1000, 
			"魔法": 200, 
			"防御": 80, 
			"魔防": 60, 
			"暴击": 20, 
			"已学习技能": ["天生蛮力", "生命祝福", "魔法庇佑", "自然守护", "嗜血狂爆"], 
			"技能等级": {"天生蛮力": 2, "生命祝福": 2, "魔法庇佑": 2, "自然守护": 2, "嗜血狂爆": 2}
		}
		_check(int(interface.call("_pet_final_stat", self_bonus_pet, "攻击", {})) == 104, "宠物属性页没有显示天生蛮力攻击加成")
		_check(int(interface.call("_pet_final_stat", self_bonus_pet, "生命", {})) == 1040, "宠物属性页没有显示生命祝福生命加成")
		_check(int(interface.call("_pet_final_stat", self_bonus_pet, "魔法", {})) == 208, "宠物属性页没有显示魔法庇佑魔法加成")
		_check(int(interface.call("_pet_final_stat", self_bonus_pet, "物防", {})) == 83, "宠物属性页没有显示自然守护防御加成")
		_check(int(interface.call("_pet_final_stat", self_bonus_pet, "魔防", {})) == 62, "宠物属性页没有显示自然守护魔防加成")
		_check(int(interface.call("_pet_final_stat", self_bonus_pet, "暴击", {})) == 21, "嗜血狂爆使用后没有计入宠物暴击面板")
		_check(str(interface.call("_pet_attribute_display_value", self_bonus_pet, "攻击", {})) == "104", "宠物属性面板没有显示天生蛮力")
		_check(str(interface.call("_pet_attribute_display_value", self_bonus_pet, "生命", {})) == "1040/1040", "宠物属性面板没有显示生命祝福")
		_check(str(interface.call("_pet_attribute_display_value", self_bonus_pet, "魔法", {})) == "208/208", "宠物属性面板没有显示魔法庇佑")
	interface.queue_free()
	await process_frame


func _verify_pet_effects(runtime_script: Variant) -> void :
	if runtime_script == null:
		return
	var pet: = ProbePet.new()
	root.add_child(pet)
	var runtime: Node = runtime_script.new()
	runtime.setup({
		"技能": ["魔法庇佑", "嗜血狂爆", "法术能量", "天生蛮力", "自然守护", "生命祝福"], 
		"技能等级": {"魔法庇佑": 1, "嗜血狂爆": 1, "法术能量": 1, "天生蛮力": 1, "自然守护": 1, "生命祝福": 1}
	})
	pet.add_child(runtime)
	await process_frame
	_check(pet.SMp == 200 and pet.Mp == 200, "常驻魔法技能被运行器重复计算")
	_check(pet.attack_in == 100, "常驻攻击技能被运行器重复计算")
	_check(pet.def == 80, "常驻防御技能被运行器重复计算")
	_check(pet.SHp == 1000 and pet.Hp == 1000, "常驻生命技能被运行器重复计算")
	_check(pet.crit == 21, "嗜血狂爆加成错误")
	_check(int(pet.objattackDic["hit1"]["power"]) == 100, "法术能量错误影响宠物普通攻击")
	_check(int(pet.objattackDic["hit2"]["power"]) == 204, "法术能量没有作用于宠物技能伤害")
	pet.queue_free()
	await process_frame
	await _verify_real_pet_self_effects(runtime_script)


func _verify_real_pet_self_effects(runtime_script: Variant) -> void :
	for scene_path in [
		"res://Scene/Pet/PetTigerSummon_1.tscn", 
		"res://Scene/Pet/PetDragonSummon_1.tscn", 
		"res://Scene/Pet/PetPhoenixSummon_1.tscn", 
		"res://Scene/Pet/PetTurtleSummon_1.tscn", 
		"res://Scene/Pet/PetRabbitSummon_1.tscn", 
		"res://Scene/Pet/PetMouseSummon_1.tscn"
	]:
		_check(load(scene_path) is PackedScene, "宠物场景无法加载：%s" % scene_path)
	var tiger_scene: = load("res://Scene/Pet/PetTigerSummon_1.tscn") as PackedScene
	_check(tiger_scene != null, "真实宠物场景无法加载")
	if tiger_scene == null:
		return
	var pet_data: = {
		"类型": "PetTiger", "阶段": 1, "等级": 1, 
		"攻击": 100, "生命上限": 1000, "生命": 1000, 
		"魔法上限": 200, "魔法": 200, "防御": 80, "魔防": 60, "暴击": 20, 
		"技能": ["虎啸", "魔法庇佑", "嗜血狂爆", "法术能量", "天生蛮力", "自然守护", "生命祝福"], 
		"已学习技能": ["魔法庇佑", "嗜血狂爆", "法术能量", "天生蛮力", "自然守护", "生命祝福"], 
		"技能等级": {"魔法庇佑": 1, "嗜血狂爆": 1, "法术能量": 1, "天生蛮力": 1, "自然守护": 1, "生命祝福": 1}
	}
	var real_pet: = tiger_scene.instantiate()
	real_pet.process_mode = Node.PROCESS_MODE_DISABLED
	real_pet.call("apply_pet_data", pet_data)
	root.add_child(real_pet)
	_check(int(real_pet.get("SHp")) == 1020, "真实宠物初始化没有计入生命祝福")
	_check(int(real_pet.get("SMp")) == 204, "真实宠物初始化没有计入魔法庇佑")
	_check(int(real_pet.get("attack_in")) == 102, "真实宠物初始化没有计入天生蛮力")
	_check(int(real_pet.get("def")) == 82, "真实宠物初始化没有计入自然守护")
	_check(int(real_pet.get("mdef")) == 61, "真实宠物魔防没有计入自然守护")
	var base_crit: = int(real_pet.get("crit"))
	var base_skill_power: = int(real_pet.get("objattackDic").get("hy", {}).get("power", 0))
	var runtime: Node = runtime_script.new()
	runtime.call("setup", pet_data)
	real_pet.add_child(runtime)
	runtime.call("_apply_pet_effects")
	_check(int(real_pet.get("SHp")) == 1020, "运行器重复计算真实宠物生命祝福")
	_check(int(real_pet.get("SMp")) == 204, "运行器重复计算真实宠物魔法庇佑")
	_check(int(real_pet.get("attack_in")) == 102, "运行器重复计算真实宠物天生蛮力")
	_check(int(real_pet.get("def")) == 82, "运行器重复计算真实宠物自然守护")
	_check(int(real_pet.get("mdef")) == 61, "运行器重复计算真实宠物自然守护魔防")
	_check(int(real_pet.get("crit")) > base_crit, "真实宠物没有获得嗜血狂爆")
	_check(int(real_pet.get("objattackDic").get("hy", {}).get("power", 0)) > base_skill_power, "真实宠物技能伤害没有获得天生蛮力和法术能量加成")
	real_pet.queue_free()
	await process_frame


func _verify_owner_buffs() -> void :
	var global_node: Node = root.get_node_or_null("Global")
	var role_prop: Node = root.get_node_or_null("RoleProp")
	var hero_scene: PackedScene = load("res://Scene/Base/BaseHero.tscn") as PackedScene
	_check(global_node != null and role_prop != null and hero_scene != null, "主人Buff验证依赖无法加载")
	if global_node == null or role_prop == null or hero_scene == null:
		return
	var hero: Node = hero_scene.instantiate()
	hero.process_mode = Node.PROCESS_MODE_DISABLED
	var icon_box: = HBoxContainer.new()
	root.add_child(icon_box)
	root.add_child(hero)
	role_prop.set("SourcePlayer", hero)
	global_node.set("buff_box", icon_box)
	await process_frame
	var buff_parent: Node = hero.get("buff") as Node
	var buffs: = {
		"PetLifeBonus": ["pet_life_bonus", 50], 
		"PetAttackBonus": ["pet_attack_bonus", 30], 
		"PetDefenseBonus": ["pet_defense_bonus", 20], 
		"PetManaBonus": ["pet_mana_bonus", 40]
	}
	for buff_name in buffs:
		var info: = {"Name": buff_name, "value": buffs[buff_name][1], "AddTime": 30.0, "ReduceInterval": 1.0, "AttackKind": "", "CanAdd": false}
		if buff_name == "PetDefenseBonus":
			info["magic_value"] = 12
		var buff: Node = global_node.call("AddBuff", buff_parent, info) as Node
		await process_frame
		buff.call("_physics_process", 0.0)
		await process_frame
		_check(int(role_prop.get(str(buffs[buff_name][0]))) == int(buffs[buff_name][1]), "%s没有应用" % buff_name)
	_check(buff_parent.get_child_count() == 4, "主人加成Buff数量错误")
	_check(icon_box.get_child_count() == 4, "主人状态栏图标数量错误")
	_check(int(role_prop.get("pet_magic_defense_bonus")) == 12, "防御加成没有独立应用主人魔防")
	var refresh_info: = {"Name": "PetAttackBonus", "value": 60, "AddTime": 40.0, "ReduceInterval": 1.0, "AttackKind": "", "CanAdd": false}
	global_node.call("AddBuff", buff_parent, refresh_info)
	await process_frame
	await process_frame
	_check(buff_parent.get_child_count() == 4, "攻击加成Buff刷新后发生叠加")
	_check(int(role_prop.get("pet_attack_bonus")) == 60, "攻击加成Buff刷新数值错误")
	hero.queue_free()
	icon_box.queue_free()
	await process_frame
	for field in ["pet_life_bonus", "pet_attack_bonus", "pet_defense_bonus", "pet_magic_defense_bonus", "pet_mana_bonus"]:
		_check(int(role_prop.get(field)) == 0, "%s在Buff移除后没有清除" % field)
