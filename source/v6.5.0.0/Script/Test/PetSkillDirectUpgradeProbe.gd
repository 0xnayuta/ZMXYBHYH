extends Node

const HARNESS: = preload("res://Script/Test/PetSkillDirectUpgradeHarness.gd")

var failed: = false


func _ready() -> void :
	var original_player_data: = PlayerData.player_data.duplicate(true)
	var pet: = {
		"名称": "测试宠物", 
		"技能": ["虎啸"], 
		"技能等级": {"虎啸": 1}, 
	}
	PlayerData.player_data[PlayerData.PET_LIST_KEY] = [pet]
	PlayerData.set_soul(2000)

	var interface: = HARNESS.new()
	interface.current_pet_index = 0
	interface._on_pet_skill_upgrade_requested("虎啸")

	_check(int(pet["技能等级"]["虎啸"]) == 2, "点击升级后技能没有立即升到2级")
	_check(PlayerData.get_soul() == 1400, "升级没有恰好扣除一次600灵魂")
	_check(interface.save_count == 1, "一次点击触发了多次保存")
	_check(interface.tip_messages == ["虎啸已升级至Lv.2"], "升级成功提示异常")

	interface.free()
	PlayerData.player_data = original_player_data
	if failed:
		get_tree().quit(1)
		return
	print("PET_SKILL_DIRECT_UPGRADE_PROBE_OK")
	get_tree().quit(0)


func _check(condition: bool, message: String) -> void :
	if condition:
		return
	failed = true
	push_error("PET_SKILL_DIRECT_UPGRADE_PROBE_FAIL: %s" % message)
