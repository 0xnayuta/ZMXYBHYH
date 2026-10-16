extends BaseMagicWeapon
class_name PurpleGoldBell
var _hit_data := {"power": 0.0, "hurtBack": [5, -5], "attackKind": "physics"}


func _ready() -> void:
	objattackDic["hit1"] = _hit_data


func _physics_process(delta: float) -> void:
	self.FB_Level = PlayerData.get_most_level("zjfyd") + 1
	needMp = 50 + self.FB_Level * 15
	if PlayerData.check_have_wx("zjfyd", "木"):
		_hit_data["power"] = 5 + (FB_Level - 1) * 0.5
	else:
		_hit_data["power"] = 2.5 + (FB_Level - 1) * 0.25
	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func show_skill():
	mg_player.play("hit")
	await mg_player.animation_finished
	Useover()


func use_over():
	Global.FB_CD = 1
	is_use = false
	self.usecd = 30
	skill_cd.start(30)


func add_super_armor():
	(
		Global
		. add_buff(
			Player.buff,
			{
				"Name": "Indestructible1",
				"AddTime": objattackDic["hit1"]["power"],
				"ReduceInterval": 0,
				"value": 0,
				"AttackKind": "",
				"CanRemove": false,
			}
		)
	)


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func ShowSkill():
	return await show_skill()


## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func Useover():
	return use_over()
