extends Node

const PLAYER_PASSIVE_SCRIPT: = preload("res://Script/Skill/bd_skill.gd")
const PET_INTERFACE_SCRIPT: = preload("res://Script/Pet/PetInterface.gd")

var failed: = false


func _ready() -> void :
	var original_player_level: Variant = PlayerData.player_data.get("玩家等级", null)
	var player_passive: = PLAYER_PASSIVE_SCRIPT.new()
	var pet_interface: = PET_INTERFACE_SCRIPT.new()

	_check(PaSkill.get_unlocked_level(1) == 0, "1级错误解锁了被动等级")
	_check(PaSkill.get_unlocked_level(3) == 1, "3级未解锁1级被动")
	_check(PaSkill.get_unlocked_level(302) == 100, "302级被动解锁等级错误")
	_check(PaSkill.get_unlocked_level(303) == 101, "人物被动仍被限制在100级")

	PlayerData.player_data["玩家等级"] = 303
	_check(player_passive.get_current_max_level() == 101, "人物被动未按每3级解锁1级")
	_check(pet_interface._pet_passive_max_level({"等级": 303}) == 101, "宠物被动未按每3级解锁1级")

	var pet: = {"被动技能": {"热血": 137}}
	_check(int(pet_interface._pet_passive_levels(pet)["热血"]) == 137, "宠物高等级被动被存档规范化截断")
	_check(PaSkill.get_value("热血", 101) > PaSkill.get_value("热血", 100), "超过100级的被动属性未继续成长")

	if original_player_level == null:
		PlayerData.player_data.erase("玩家等级")
	else:
		PlayerData.player_data["玩家等级"] = original_player_level
	player_passive.free()
	pet_interface.free()
	if failed:
		get_tree().quit(1)
		return
	print("PASSIVE_LEVEL_CAP_PROBE_OK")
	get_tree().quit(0)


func _check(condition: bool, message: String) -> void :
	if condition:
		return
	failed = true
	push_error("PASSIVE_LEVEL_CAP_PROBE_FAIL: %s" % message)
