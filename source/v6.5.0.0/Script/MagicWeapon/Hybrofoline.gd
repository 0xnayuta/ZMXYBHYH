extends BaseMagicWeapon
class_name Hybrofoline
var IsCure: bool
var _hit_data := {"power": 0, "hurtBack": [5, -5], "attackKind": "physics"}


func _ready() -> void:
	objattackDic["hit1"] = _hit_data


func _physics_process(delta: float) -> void:
	if IsCure:
		self.position = Player.position - Vector2(0, 200)
	self.FB_Level = PlayerData.get_most_level("kyl") + 1
	needMp = 50 + self.FB_Level * 5
	if PlayerData.check_have_wx("kyl", "木"):
		_hit_data["power"] = 100 + int(RoleProp.roleprop.SHp * (randf_range(0.02, 0.05)) + 0.02 * self.FB_Level)
	else:
		_hit_data["power"] = 50 + int(RoleProp.roleprop.SHp * (randf_range(0.01, 0.02)) + 0.01 * self.FB_Level)
	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func show_skill():
	mg_player.play("hit")
	await mg_player.animation_finished
	Useover()


func use_over():
	IsCure = false
	Global.FB_CD = 1
	is_use = false
	self.usecd = 15
	skill_cd.start(15)


func cure():
	if Player != null:
		Player.cure_hp(objattackDic["hit1"]["power"])


func add_super_armor():
	IsCure = true
	(
		Global
		. add_buff(
			Player.buff,
			{
				"Name": "SuperArmor",
				"AddTime": 10,
				"ReduceInterval": 0,
				"value": 0,
				"AttackKind": "",
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
