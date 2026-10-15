extends BaseMagicWeapon
class_name Yx
var FollowTarget: BaseMonster
var MonsterList: Array[BaseMonster] = []
var HitTimes: int = 0
var MaxTimes: int = 0
var isBegin: bool


func _physics_process(delta: float) -> void :
	super._physics_process(delta)

	self.FB_Level = PlayerData.get_mostLevel("yx") + 1
	if PlayerData.CheckHaveWX("yx", "木"):
		MaxTimes = 6
		pass
	else:
		MaxTimes = 12
		pass


func ShowSkill() -> void :
	print("法寶使用中")
	mg_player.play("Show")
	print(Player.name)
	Global.AddBuff(Player.buff, {
			"Name": "入魔", 
			"AddTime": 10, 
			"ReduceInterval": 0.5, 
			"value": int(RoleProp.roleprop.Crit * 1.5), 
			"AttackKind": "", 
			"CanRemove": true, 
			"Buff": true, 
		})

	await get_tree().create_timer(10).timeout
	Useover()





























func Useover():
	Global.FB_CD = MaxTimes
	self.usecd = MaxTimes
	is_use = false
	skill_cd.start(MaxTimes)

func free() -> void :
	FollowTarget = null
func _on_skill_cd_timeout() -> void :
	super._on_skill_cd_timeout()
	self.visible = true
