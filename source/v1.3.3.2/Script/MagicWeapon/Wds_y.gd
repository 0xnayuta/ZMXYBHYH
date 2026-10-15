extends BaseMagicWeapon
class_name Wds_y
var FollowTarget: BaseMonster
var MonsterList: Array[BaseMonster] = []
var HitTimes: int = 0
var MaxTimes: int = 0
var isBegin: bool


func _physics_process(delta: float) -> void :
	super._physics_process(delta)

	self.FB_Level = PlayerData.get_mostLevel("wds_y") + 1
	if PlayerData.CheckHaveWX("wds_y", "木"):

		pass
	else:

		pass


func ShowSkill() -> void :
	print("法寶使用中")
	mg_player.play("Show")
	Global.AddBuff(Player.buff, {
			"Name": "入魔", 
			"AddTime": 10, 
			"ReduceInterval": 0.5, 
			"value": int(RoleProp.roleprop.Crit * 1.5), 
			"AttackKind": "magic", 
		})


	if PlayerData.CheckHaveWX("wds_y", "木"):
		await get_tree().create_timer(20).timeout
		is_use = false
		skill_cd.start(1)
	else:
		await get_tree().create_timer(10).timeout
		is_use = false
		skill_cd.start(12)


func Useover():
	FollowTarget = null
	HitTimes = 0
	isBegin = false
	is_use = false
	if PlayerData.CheckHaveWX("wds_y", "木"):
		skill_cd.start(1)
	else:
		skill_cd.start(12)
	self.visible = false


func free() -> void :
	FollowTarget = null
func _on_skill_cd_timeout() -> void :
	super._on_skill_cd_timeout()
	self.visible = true
