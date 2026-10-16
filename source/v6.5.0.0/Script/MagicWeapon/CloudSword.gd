extends BaseMagicWeapon
class_name CloudSword
var MonsterList: Array = []
var _monster_refresh_elapsed: float = 0.0
var Target: BaseMonster
var IsNoTarget: bool
var _hit_data := {
	"power": 0,
	"hurtBack": [0, -1],
	"attackKind": "magic",
	"addeffect":
	{"Name": "DefeReduce", "AddTime": 5, "ReduceInterval": 0, "value": 0.0, "AttackKind": "", "DeBuff": true}
}


func _ready() -> void:
	objattackDic["hit1"] = _hit_data


func _get_active_monster_snapshot() -> Array:
	var level: Node = Player.get_parent().get_parent() if Player != null and Player.get_parent() != null else null
	if level != null and level.has_method("has_active_monster_index") and level.has_active_monster_index():
		return level.get_active_monsters()
	if level != null and "monster" in level and level.monster != null:
		return level.monster.get_children()
	return []


func _physics_process(delta: float) -> void:
	_monster_refresh_elapsed += delta
	if _monster_refresh_elapsed >= 0.1 or MonsterList.is_empty():
		_monster_refresh_elapsed = 0.0
		MonsterList = _get_active_monster_snapshot()
	self.FB_Level = PlayerData.get_mostLevel("qyj") + 1
	needMp = 80 + self.FB_Level * 5
	var BasicHit
	BasicHit = self.FB_Level * 0.07
	var add_effect: Dictionary = _hit_data["addeffect"]
	if PlayerData.check_have_wx("qyj", "木"):
		BasicHit = self.FB_Level * 0.1
		_hit_data["power"] = 100 + int(RoleProp.roleprop.power * BasicHit)
		add_effect["value"] = 0.09 + (0.01 * FB_Level)
	else:
		BasicHit = self.FB_Level * 0.05
		_hit_data["power"] = 50 + int(RoleProp.roleprop.power * BasicHit)
		add_effect["value"] = 0.04 + (0.01 * FB_Level)
	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func ShowSkill():
	Target = GetMonster()
	if Target == null:
		UseOver2()
		return
	mg_player.play("hit")
	await mg_player.animation_finished
	Useover()


func Useover():
	self.usecd = 15
	is_use = false
	Global.FB_CD = 1
	skill_cd.start(self.usecd)


func UseOver2():
	self.usecd = 0
	is_use = false
	Global.FB_CD = 1
	RoleProp.roleprop.Mp += needMp
	skill_cd.start(0.001)


func GetMonster():
	var MaxHp = 0
	var TT: BaseMonster
	if MonsterList.size() <= 0:
		return null
	for i in MonsterList:
		if i != null:
			if not i.NoTarget:
				if i is BaseMonster:
					if not i is Monster138:
						if i.Hp >= MaxHp:
							TT = i
							MaxHp = i.Hp
	return TT


func AddSword():
	if Target != null:
		Global.addWeaponBullet_(
			$Bullet, Target.position + Vector2(0, 30), "CloudSwordBullet", get_attack_snapshot(), mg_action.flip_h, 100
		)
