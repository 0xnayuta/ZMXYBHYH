extends Node

const PLAYER_PASSIVE_SCRIPT: = preload("res://Script/Skill/bd_skill.gd")
const PET_INTERFACE_SCRIPT: = preload("res://Script/Pet/PetInterface.gd")
const PLAYER_PASSIVES: = ["热血", "魔泉", "狂暴", "永恒", "辉煌", "敏锐", "收益"]
const PET_PASSIVES: = ["热血", "魔泉", "狂暴", "永恒", "辉煌", "敏锐"]

var failed: = false


func _ready() -> void :
	var original_player_data: = PlayerData.player_data.duplicate(true)
	var player_passive: = PLAYER_PASSIVE_SCRIPT.new()
	var pet_interface: = PET_INTERFACE_SCRIPT.new()

	PlayerData.player_data["玩家等级"] = 6
	PlayerData.player_data["被动技能"] = _zero_levels(PLAYER_PASSIVES)
	PlayerData.set_soul(105000)
	var player_upgrades: = player_passive._upgrade_all_passives()
	_check(player_upgrades == 14, "人物一键升级总级数错误")
	_check(_all_levels_equal(PlayerData.player_data["被动技能"], PLAYER_PASSIVES, 2), "人物被动没有全部升到当前上限")
	_check(PlayerData.get_soul() == 0, "人物一键升级灵魂扣除错误")

	var pet: = {"等级": 6, "被动技能": _zero_levels(PET_PASSIVES)}
	PlayerData.set_soul(90000)
	var pet_upgrades: = pet_interface._upgrade_all_pet_passives(pet)
	_check(pet_upgrades == 12, "宠物一键升级总级数错误")
	_check(_all_levels_equal(pet["被动技能"], PET_PASSIVES, 2), "宠物被动没有全部升到当前上限")
	_check(PlayerData.get_soul() == 0, "宠物一键升级灵魂扣除错误")

	pet["等级"] = 9
	pet["被动技能"] = _zero_levels(PET_PASSIVES)
	PlayerData.set_soul(30000)
	pet_upgrades = pet_interface._upgrade_all_pet_passives(pet)
	_check(pet_upgrades == 6, "宠物灵魂有限时升级数量错误")
	_check(_all_levels_equal(pet["被动技能"], PET_PASSIVES, 1), "宠物一键升级没有按轮次均衡分配")

	player_passive.free()
	pet_interface.free()
	PlayerData.player_data = original_player_data
	if failed:
		get_tree().quit(1)
		return
	print("PASSIVE_ONE_KEY_UPGRADE_PROBE_OK")
	get_tree().quit(0)


func _zero_levels(skill_names: Array) -> Dictionary:
	var levels: = {}
	for skill_name in skill_names:
		levels[skill_name] = 0
	return levels


func _all_levels_equal(levels: Dictionary, skill_names: Array, expected: int) -> bool:
	for skill_name in skill_names:
		if int(levels.get(skill_name, -1)) != expected:
			return false
	return true


func _check(condition: bool, message: String) -> void :
	if condition:
		return
	failed = true
	push_error("PASSIVE_ONE_KEY_UPGRADE_PROBE_FAIL: %s" % message)
