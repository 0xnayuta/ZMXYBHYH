extends Node

class ProbeSandMonk extends role4:
	var lightning_rounds: int = 0

	func ADDSMSRShenqiLightningRound() -> void :
		lightning_rounds += 1


func _ready() -> void :
	var old_fashion: Variant = PlayerData.player_data.get("时装", []).duplicate(true)
	var old_ws_state: bool = RoleProp.is_ws_state
	PlayerData.player_data["时装"] = [{"名字": "shenqismsrsz"}]
	RoleProp.is_ws_state = false

	var hero: = ProbeSandMonk.new()
	var timer: = Timer.new()
	add_child(timer)
	hero.smsrsz_timer = timer
	hero.objattackDic["smsr"] = {
		"power": 100, 
		"hurtBack": [0, 0], 
		"attackKind": "magic", 
	}

	_check(hero.WSSkill(), "沙僧神器无双启动失败")
	_check(RoleProp.is_ws_state, "沙僧无双状态未开启")
	_check(hero.lightning_rounds == 1, "沙僧无双首轮落雷未释放")

	RoleProp.is_ws_state = false
	PlayerData.player_data["时装"] = []
	_check(hero.WSSkill(), "未装备特殊时装时无法开启基础无双")
	_check(RoleProp.is_ws_state, "未装备特殊时装时无双状态未开启")

	PlayerData.player_data["时装"] = old_fashion
	RoleProp.is_ws_state = old_ws_state
	hero.free()
	print("SAND_MONK_WUSHUANG_PROBE_OK")
	get_tree().quit()


func _check(condition: bool, message: String) -> void :
	if condition:
		return
	push_error(message)
	get_tree().quit(1)
