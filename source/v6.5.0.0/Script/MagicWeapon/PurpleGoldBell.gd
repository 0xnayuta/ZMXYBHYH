extends BaseMagicWeapon
class_name PurpleGoldBell
var _hit_data: = {
	"power": 0.0, 
	"hurtBack": [5, -5], 
	"attackKind": "physics"
}

func _ready() -> void :
	objattackDic["hit1"] = _hit_data

func _physics_process(delta: float) -> void :

	self.FB_Level = PlayerData.get_mostLevel("zjfyd") + 1
	needMp = 50 + self.FB_Level * 15
	if PlayerData.CheckHaveWX("zjfyd", "木"):
		_hit_data["power"] = 5 + (FB_Level - 1) * 0.5
	else:
		_hit_data["power"] = 2.5 + (FB_Level - 1) * 0.25
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
	self.usecd = 30
	skill_cd.start(30)

func ADDSuperArmor():

	Global.AddBuff(Player.buff, {
			"Name": "Indestructible1", 
			"AddTime": objattackDic["hit1"]["power"], 
			"ReduceInterval": 0, 
			"value": 0, 
			"AttackKind": "", 
			"CanRemove": false, 
		})
