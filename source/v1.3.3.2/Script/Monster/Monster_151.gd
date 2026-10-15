extends BaseMonster
class_name Monster151
var RoundSpeed: int = 230
var RoundChaseTime: float = 2.3
var RoundThrowCOUNT: int = 2
var RoundList = []
var Boss_2: Monster149
var Boss_3: Monster150

var is_Called: bool = false

func monster_57():
	self.is_Fly = true
	self.is_boss = true
	self.my_mr_name = "云霄"
	self.attack_in = 120
	self.level = 70
	self.SHp = 1200000
	self.Hp = self.SHp
	self.def = 400
	self.mdef = 400
	self.crit = 100
	self.miss = 30
	self.lucky = 90
	self.Htarget = 90
	self.Toughness = 0
	self.ar = 30
	self.sp = 30
	self.Critreduce = 0
	self.speed = 10
	self.mysee = 800
	self.attackRange = 600
	self.attackDesire = 90
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 1000
	self.fall_coin = 1000
	self.objattackDic["hit1"] = {
		"power": 350, 
		"hurtBack": [-4, -9], 
		"attackKind": "magic", 
		"addeffect": {
			"Name": "stun", 
			"AddTime": randi_range(0.5, 1), 
			"ReduceInterval": 0, 
			"value": 0, 
			"AttackKind": "", 
			"CanAdd": false, 
			"DeBuff": true, 
		}
	}
	self.objattackDic["hit2"] = {
		"power": 700, 
		"hurtBack": [-4, -150], 
		"attackKind": "magic", 









	}
	self.objattackDic["hit3"] = {
		"power": 220, 
		"hurtBack": [-4, -9], 
		"attackKind": "magic", 
		"addeffect": {
			"Name": "silent", 
			"AddTime": randi_range(0.5, 1), 
			"ReduceInterval": 0, 
			"value": 0, 
			"AttackKind": "", 
			"CanAdd": false, 
			"DeBuff": true, 
		}
	}
	self.objattackDic["hit1_2"] = {
		"power": 240, 
		"hurtBack": [-4, -9], 
		"attackKind": "magic", 
		"addeffect": {
			"Name": "poision", 
			"AddTime": randi_range(2, 3), 
			"ReduceInterval": randf_range(0.6, 1), 
			"value": randi_range(40, 60), 
			"AttackKind": "magic", 
			"CanAdd": true, 
			"DeBuff": true, 
		}
	}
	self.objattackDic["hit1_3"] = {
		"power": 260, 
		"hurtBack": [-4, -9], 
		"attackKind": "magic", 
		"addeffect": {
			"Name": "Fire", 
			"AddTime": randi_range(2, 3), 
			"ReduceInterval": randf_range(0.6, 1), 
			"value": randi_range(40, 60), 
			"AttackKind": "magic", 
			"CanAdd": true, 
			"DeBuff": true, 
		}
	}
	self.objattackDic["dmzhl"] = {
		"power": 300, 
		"hurtBack": [-8, 0], 
		"attackKind": "magic"
	}
	self.objattackDic["dmgz"] = {
		"power": 400, 
		"hurtBack": [0, -7], 
		"attackKind": "magic"
	}
	self.fall_pro = 0.25
	self.fall_list = [
		{
			"name": "poHuanHuaLianzzs", 
			"value": 1
		}, 
	]
	self.fall_stone_pro = 0
	self.fall_stone = []
func _ready() -> void :
	super._ready()
	Skill_1_CD = 0
	Skill_2_CD = 10
	Skill_3_CD = 10
	monster_57()
func Monster_Intelligence():
	ChangeProperies()
	if abs(RoleProp.role_pos_x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if Skill_1_CD <= 0:
				UseSkill()
			elif Skill_2_CD <= 0:
				UseSkill2()
			elif Skill_3_CD <= 0:
				UseSkill3()
			elif follow_Hero():
				have_target()
			elif count % attack_in == 0:
				attack_target()
			else:
				normal_state()
func NormalHit():
	super.to_hero()
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()
func UseSkill():
	super.to_hero()
	Skill_1_CD = randi_range(5, 8)
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()

func UseSkill2():
	super.to_hero()
	Skill_2_CD = randi_range(5, 8)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()

func UseSkill3():
	super.to_hero()
	if is_Called: return
	Skill_3_CD = randi_range(30, 40)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	is_Called = true
	stop_move()

func ChangeProperies():
	if Hp >= SHp * 0.8 and Hp <= SHp:
		attack_in = 180
		RoundSpeed = 230
		RoundChaseTime = 2.3
		RoundThrowCOUNT = 2
	elif Hp >= SHp * 0.6 and Hp <= SHp * 0.8:
		attack_in = 150
		RoundSpeed = 260
		RoundChaseTime = 2.6
		RoundThrowCOUNT = 3
	elif Hp >= SHp * 0.4 and Hp <= SHp * 0.6:
		attack_in = 120
		RoundSpeed = 300
		RoundChaseTime = 3
		RoundThrowCOUNT = 3
	elif Hp >= SHp * 0.2 and Hp <= SHp * 0.4:
		attack_in = 100
		RoundSpeed = 300
		RoundChaseTime = 4
		RoundThrowCOUNT = 4
	elif Hp >= 0 and Hp <= SHp * 0.2:
		attack_in = 100
		RoundSpeed = 300
		RoundChaseTime = 5
		RoundThrowCOUNT = 5
func CallRound():
	var RoundPositionList = []
	var tween = get_tree().create_tween().set_parallel(true)
	for i in range(RoundThrowCOUNT):
		var round = Global.add_Bullet("Monster57Bullet", bullet, false, 1, position, "dmzhl", self.objattackDic["dmzhl"])
		RoundList.push_back(round)
	for i in RoundList:
		if i != null:
			var pp = Vector2(get_Player.position.x + randi_range(-220, 220), 500)
			tween.tween_property(i, "position", pp, 0.35)
	RoundList.clear()
func normalBullet():
	var Bullet
	var BulletName: String
	var Hit_name: String
	var Position = Vector2(self.position.x, self.position.y + 15)
	var RndNum = randi_range(0, 100)
	if RndNum <= 100 and RndNum >= 75:
		BulletName = "Monster57Bullet"
		Hit_name = "hit1"
	elif RndNum < 75 and RndNum >= 50:
		BulletName = "Monster57Bullet2"
		Hit_name = "hit1_1"
	elif RndNum < 50 and RndNum >= 25:
		BulletName = "Monster57Bullet3"
		Hit_name = "hit1_2"
	else:
		BulletName = "Monster57Bullet4"
		Hit_name = "hit1_3"
	if MonsterDirection:
		Bullet = Global.CallChaseBullet(self.bullet, BulletName, RoundSpeed, RoundChaseTime, false, Position, Hit_name, self.objattackDic[Hit_name])
	else:
		Bullet = Global.CallChaseBullet(self.bullet, BulletName, RoundSpeed, RoundChaseTime, false, Position, Hit_name, self.objattackDic[Hit_name])
	Bullet.scale = Vector2(0.5, 0.5)
func CallMonster():
	if Boss_3 == null:
		Boss_3 = Global.Create_Monster(150, get_parent(), Vector2(100, 320)) as Monster150



func CallBullet_1():
	var bb
	if self.MonsterDirection:
		bb = Global.add_Bullet("Monster151_Bullet1", self.bullet, true, 3, Vector2(20, 0) + position, "hit1", self.objattackDic["hit1"])
	else:
		bb = Global.add_Bullet("Monster151_Bullet1", self.bullet, true, 3, Vector2(-20, 0) + position, "hit1", self.objattackDic["hit1"])
	bb.look_at(get_Player.position)


func CallBullet_2():
	var bb
	if self.MonsterDirection:
		bb = Global.add_Bullet("Monster151_Bullet2", self.bullet, true, 1, Vector2(20, 0) + position, "hit2", self.objattackDic["hit2"])
	else:
		bb = Global.add_Bullet("Monster151_Bullet2", self.bullet, true, 1, Vector2(-20, 0) + position, "hit2", self.objattackDic["hit2"])
	bb.look_at(get_Player.position)


func self_cure():
	cure_hp(100000)
