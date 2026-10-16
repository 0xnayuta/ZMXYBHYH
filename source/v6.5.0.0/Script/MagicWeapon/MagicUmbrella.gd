extends BaseMagicWeapon
class_name MagicUmbrella
var StabRotationList = [-5, -5, -5, -5, -5, -5, -5, -5, -5, -5, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]
var PositionList = [150, 135, 120, 105, 90, 75, 60, 45, 30, 15, 0, -15, -30, -45, -60, -75, -90, -105, -120, -135, -150]
var _hit_data := {
	"power": 0,
	"hurtBack": [5, -5],
	"attackKind": "real",
	"addeffect":
	{
		"Name": "poision",
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
	self.FB_Level = PlayerData.get_mostLevel("lsys") + 1
	needMp = 30 + self.FB_Level * 10
	_hit_data["power"] = 10 + 10 * self.FB_Level
	var add_effect: Dictionary = _hit_data["addeffect"]
	if PlayerData.CheckHaveWX("lsys", "木"):
		add_effect["value"] = int(RoleProp.roleprop.power * (0.04 + 0.04 * self.FB_Level))
	else:
		add_effect["value"] = int(RoleProp.roleprop.power * (0.04 + 0.01 * self.FB_Level))
	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func ShowSkill():
	mg_player.play("hit")
	await mg_player.animation_finished
	Useover()


func Useover():
	Global.FB_CD = 1
	is_use = false
	skill_cd.start(3)


func addBullet():
	var attack_data := get_attack_snapshot()
	for i in range(21):
		var stab = Global.addWeaponBullet_(
			$Bullet,
			Vector2(self.position.x + PositionList[i], self.position.y),
			"MagicUmbrellaBullet",
			attack_data,
			mg_action.flip_h,
			100
		)
		stab.rotation_degrees = StabRotationList[i]
		stab.scale = Vector2(2, 2)


func TweenToTop():
	var Po = self.position
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Player.position + Vector2(0, -400), 0.8)
	pass
