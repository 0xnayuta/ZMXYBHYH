extends Node

class ProbeMagicWeapon extends Node:
	var is_use: = false
	var is_canuse: = true
	var enough_mp: = true

	func EnoughMp() -> bool:
		return enough_mp


class ProbeHero extends BaseHero:
	var skill_cast_count: = 0
	var normal_move_count: = 0
	var auto_move_count: = 0
	var auto_magic_count: = 0
	var auto_sword_count: = 0

	func get_skill(_skill_name):
		skill_cast_count += 1
		Role1SkillInter["probe"] = 1.0

	func get_need_mp(_skill_name, _next_level):
		return 0

	func _get_auto_battle_target() -> Variant:
		return null

	func NorMalMove():
		normal_move_count += 1

	func _process_auto_battle_movement() -> void :
		auto_move_count += 1

	func _try_auto_battle_magic_weapon() -> bool:
		auto_magic_count += 1
		return true

	func _try_use_main_sword_array() -> bool:
		auto_sword_count += 1
		return true


func _ready() -> void :
	call_deferred("_run")


func _run() -> void :
	var setting_keys: = [
		"AutoBattleSkillOnly", 
		"AutoBattleMagicWeapon", 
		"AutoBattleSwordArray", 
		"AutoBattleWushuang", 
		"AutoBattleRetry", 
		"AutoBattleSkills", 
		"AutoBattleSkillsByRole", 
	]
	var old_settings: Dictionary = {}
	for key in setting_keys:
		old_settings[key] = MainSet.set_data.get(key)
	var old_enabled: = MainSet.is_auto_battle_enabled()
	var old_role_id: = int(PlayerData.player_data.get("Myself", 1))

	MainSet.set_data["AutoBattleSkillOnly"] = true
	MainSet.set_data["AutoBattleMagicWeapon"] = true
	MainSet.set_data["AutoBattleSwordArray"] = true
	var popup: = (load("res://Scene/AutoBattleConfig.tscn") as PackedScene).instantiate()
	add_child(popup)
	await get_tree().process_frame
	_check(popup.get_node("Panel/Content/Options/SkillOnly").button_pressed, "只释放技能选项没有回显")
	_check(popup.get_node("Panel/Content/Options/MagicWeapon").button_pressed, "自动释放法宝选项没有回显")
	_check(popup.get_node("Panel/Content/Options/SwordArray").button_pressed, "自动释放剑阵选项没有回显")
	var options: = popup.get_node("Panel/Content/Options") as GridContainer
	var option_rects: Array[Rect2] = []
	for option in options.get_children():
		var control: = option as Control
		_check(control != null and control.position.x >= 0.0 and control.position.y >= 0.0, "自动战斗选项超出布局起点")
		_check(control.position.x + control.size.x <= options.size.x + 1.0, "自动战斗选项超出布局右边界")
		_check(control.position.y + control.size.y <= options.size.y + 1.0, "自动战斗选项超出布局下边界")
		for existing_rect in option_rects:
			_check( not control.get_rect().intersects(existing_rect), "自动战斗选项发生重叠")
		option_rects.append(control.get_rect())
	popup.get_node("Panel/Content/Options/SkillOnly").button_pressed = false
	popup.get_node("Panel/Content/Options/MagicWeapon").button_pressed = false
	popup.get_node("Panel/Content/Options/SwordArray").button_pressed = false
	popup._store_option_settings()
	_check( not bool(MainSet.set_data["AutoBattleSkillOnly"]), "只释放技能选项没有保存")
	_check( not bool(MainSet.set_data["AutoBattleMagicWeapon"]), "自动释放法宝选项没有保存")
	_check( not bool(MainSet.set_data["AutoBattleSwordArray"]), "自动释放剑阵选项没有保存")
	popup.queue_free()

	var hero: = ProbeHero.new()
	PlayerData.player_data["Myself"] = 1
	MainSet.set_auto_battle_enabled(true)
	MainSet.set_data["AutoBattleWushuang"] = false
	MainSet.set_data["AutoBattleSkillsByRole"] = {"角色1": [{"id": "probe", "count": 1}]}
	hero.Role1SkillInter["probe"] = 0.0

	MainSet.set_data["AutoBattleSkillOnly"] = false
	hero._process_auto_battle(0.3)
	_check(hero.skill_cast_count == 0, "普通自动战斗在没有目标时仍释放了技能")

	MainSet.set_data["AutoBattleSkillOnly"] = true
	hero._process_auto_battle(0.3)
	_check(hero.skill_cast_count == 1, "只释放技能模式仍要求存在目标")
	MainSet.set_data["AutoBattleSkillsByRole"] = {"角色1": [{"id": "missing_skill", "count": 1}]}
	hero._process_auto_battle(0.3)
	_check(hero.skill_cast_count == 1, "错误技能ID仍进入了技能释放入口")
	MainSet.set_data["AutoBattleSkillsByRole"] = {"角色1": [{"id": "probe", "count": 1}]}
	hero.NoarmalControl()
	_check(hero.normal_move_count == 1 and hero.auto_move_count == 0, "只释放技能模式仍接管自动寻敌移动")

	MainSet.set_data["AutoBattleSkillOnly"] = false
	hero.NoarmalControl()
	_check(hero.auto_move_count == 1, "普通自动战斗没有接管寻敌移动")

	MainSet.set_data["AutoBattleSkillsByRole"] = {"角色1": []}
	MainSet.set_data["AutoBattleMagicWeapon"] = true
	MainSet.set_data["AutoBattleSwordArray"] = true
	hero._process_auto_battle(0.3)
	_check(hero.auto_magic_count == 1, "自动释放法宝选项未触发")
	_check(hero.auto_sword_count == 1, "自动释放剑阵选项未触发")

	var magic_hero: = BaseHero.new()
	var magic_weapon: = ProbeMagicWeapon.new()
	magic_hero.Mgtarget = magic_weapon
	_check(magic_hero._try_auto_battle_magic_weapon() and magic_weapon.is_use, "冷却完成的法宝没有自动进入释放状态")
	magic_weapon.is_use = false
	magic_weapon.is_canuse = false
	_check( not magic_hero._try_auto_battle_magic_weapon() and not magic_weapon.is_use, "冷却中的法宝被重复释放")
	magic_weapon.free()
	magic_hero.free()
	hero.free()

	for key in setting_keys:
		MainSet.set_data[key] = old_settings[key]
	MainSet.set_auto_battle_enabled(old_enabled)
	PlayerData.player_data["Myself"] = old_role_id
	print("AUTO_BATTLE_OPTIONS_PROBE_OK")
	get_tree().quit()


func _check(condition: bool, message: String) -> void :
	if condition:
		return
	push_error(message)
	get_tree().quit(1)
