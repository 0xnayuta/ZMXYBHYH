extends Node

class ProbeNeZha extends NeZhaHero:
	var fashion_effect: = ""

	func ADDTtzsEffect() -> void :
		fashion_effect = "ttzs"

	func ADDNMWEffect() -> void :
		fashion_effect = "nmw"

	func ADDZLWEffect() -> void :
		fashion_effect = "zlw"

	func ADDSMSRShenqiLightningRound() -> void :
		if RoleProp.is_ws_state:
			fashion_effect = "smsr"

func _ready() -> void :
	var old_fashion: Variant = PlayerData.player_data.get("时装", []).duplicate(true)
	var old_ws_state: bool = RoleProp.is_ws_state
	var hero: = ProbeNeZha.new()
	var timer: = Timer.new()
	add_child(timer)
	hero.smsrsz_timer = timer
	for attack_name in ["ttzs", "nmw", "zlw", "smsr"]:
		hero.objattackDic[attack_name] = {
			"power": 100, 
			"hurtBack": [0, 0], 
			"attackKind": "magic", 
		}

	var cases: = {
		"youxiuttzssz": "ttzs", 
		"youxiunmwsz": "nmw", 
		"youxiuzlwsz": "zlw", 
		"shenqismsrsz": "smsr", 
	}
	for fashion_id in cases:
		RoleProp.is_ws_state = false
		hero.fashion_effect = ""
		PlayerData.player_data["时装"] = [{"名字": fashion_id}]
		_check(hero.WSSkill(), "哪吒无双启动失败：" + fashion_id)
		_check(RoleProp.is_ws_state, "哪吒无双状态未开启：" + fashion_id)
		_check(hero.fashion_effect == cases[fashion_id], "哪吒时装无双效果未触发：" + fashion_id)

	RoleProp.is_ws_state = false
	PlayerData.player_data["时装"] = []
	_check(hero.WSSkill(), "哪吒未装备时装时无双启动失败")
	_check(RoleProp.is_ws_state, "哪吒未装备时装时无双状态未开启")

	RoleProp.is_ws_state = false
	hero.is_using_skills = true
	hero.is_attacking = true
	hero.IsSuperArmor = true
	hero.get_action = hero.SKILL_DASH
	hero.velocity = Vector2(600.0, 0.0)
	_check(hero.WSSkill(), "哪吒释放技能期间无双启动失败")
	_check(RoleProp.is_ws_state, "哪吒技能期间无双状态未开启")
	_check(hero.is_using_skills, "哪吒无双错误中断了技能占用状态")
	_check(hero.is_attacking, "哪吒无双错误中断了技能攻击状态")
	_check(hero.IsSuperArmor, "哪吒无双错误清除了技能霸体状态")
	_check(hero.get_action == hero.SKILL_DASH, "哪吒无双错误清除了技能动作状态")
	_check(hero.velocity == Vector2(600.0, 0.0), "哪吒无双错误停止了技能位移")

	PlayerData.player_data["时装"] = old_fashion
	RoleProp.is_ws_state = old_ws_state
	hero.free()
	print("NEZHA_WUSHUANG_PROBE_OK")
	get_tree().quit()


func _check(condition: bool, message: String) -> void :
	if condition:
		return
	push_error(message)
	get_tree().quit(1)
