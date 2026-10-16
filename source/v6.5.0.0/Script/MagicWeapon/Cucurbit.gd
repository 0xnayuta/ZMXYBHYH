extends BaseMagicWeapon
class_name Cucurbit
var _hit_data := {
	"power": 0,
	"hurtBack": [5, -5],
	"attackKind": "physics",
	"addeffect":
	{
		"Name": "Fire",
		"AddTime": 5,
		"ReduceInterval": 1,
		"value": 0,
		"AttackKind": "real",
		"CanAdd": true,
		"DeBuff": true
	}
}


func _ready() -> void:
	objattackDic["hit1"] = _hit_data


func _physics_process(delta: float) -> void:
	needMp = 50
	self.FB_Level = PlayerData.get_mostLevel("dshl") + 1
	var add_effect: Dictionary = _hit_data["addeffect"]
	if PlayerData.check_have_wx("dshl", "木"):
		_hit_data["power"] = 100 + int(RoleProp.roleprop.power * randf_range(0.15, 0.18)) + 70 * self.FB_Level
	else:
		_hit_data["power"] = 50 + int(RoleProp.roleprop.power * randf_range(0.09, 0.12)) + 40 * self.FB_Level
	add_effect["value"] = int(RoleProp.roleprop.power * 0.1)
	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func show_skill():
	mg_player.play("hit")
	await mg_player.animation_finished
	Useover()


func use_over():
	Global.FB_CD = 1
	self.usecd = 6
	is_use = false
	skill_cd.start(6)


func addFire():
	var attack_data := get_attack_snapshot()
	Global.addWeaponBullet_($Bullet, Vector2(self.position.x, 250), "CucurFire_2", attack_data, mg_action.flip_h, 100)
	Global.addWeaponBullet_(
		$Bullet, Vector2(self.position.x - 230, 250), "CucurFire_2", attack_data, mg_action.flip_h, 100
	)
	Global.addWeaponBullet_(
		$Bullet, Vector2(self.position.x + 230, 250), "CucurFire_2", attack_data, mg_action.flip_h, 100
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
