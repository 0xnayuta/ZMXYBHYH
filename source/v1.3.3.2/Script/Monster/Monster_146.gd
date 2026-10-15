extends BaseMonster
class_name Monster146
var ShouldFly: bool
@onready var special_effect: AnimatedSprite2D = $MonsterDir / mr_ani / SpecialEffect

var IsCall: bool
var OnsetEatblood: bool
var RemoveBlood: bool
func monster_146():
	special_effect.play("Empty")
	self.rush_speed = 400

	self.is_boss = true
	self.my_mr_name = "‌花豹圣者·高友乾"
	self.attack_in = 90
	self.level = 55
	self.SHp = 550000
	self.Hp = self.SHp
	self.def = 450
	self.mdef = 450
	self.crit = 100
	self.miss = 40
	self.lucky = 50
	self.Htarget = 15
	self.Toughness = 0
	self.ar = 50
	self.sp = 50
	self.Critreduce = 0
	self.speed = 14
	self.mysee = 500
	self.attackRange = 325
	self.attackDesire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 500
	self.ebol = 0
	self.objattackDic["hit1"] = {
		"power": 800, 
		"hurtBack": [-8, -12], 
		"attackKind": "magic", 
		"HitProtect": 0, 
	}
	self.objattackDic["hit2"] = {
		"power": 2000, 
		"hurtBack": [-1, -1], 
		"attackKind": "real", 
		"HitProtect": 0, 










	}
	self.objattackDic["hit3"] = {
		"power": 950, 
		"hurtBack": [-1, -1], 
		"attackKind": "magic", 
		"HitProtect": 0, 
	}

	self.fall_pro = 0.25
	self.fall_list = [
		{
			"name": "yaoGuangShi", 
			"value": 1
		}, 
	]
	self.fall_stone_pro = 0
	self.fall_stone = []
func _ready() -> void :
	super._ready()
	monster_146()
	Skill_1_CD = randi_range(3, 4)
	Skill_2_CD = 10
	Skill_3_CD = 5


func _physics_process(delta: float) -> void :

	super._physics_process(delta)

func Monster_Intelligence():
	if abs(RoleProp.role_pos_x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.role_pos_x) >= attackRange:
				have_target()
				if Skill_1_CD <= 0:
					do_hit_1()
				if Skill_2_CD <= 0:
					do_hit_2()
				if Skill_3_CD <= 0:
					do_hit_3()
				if count % 90 == 0:
					if randi_range(0, 100) < attackDesire:
						attack_target()
			else:
				stop_move()
				if Skill_1_CD <= 0:
					do_hit_1()
				if Skill_2_CD <= 0:
					do_hit_2()
				if Skill_3_CD <= 0:
					do_hit_3()
				if count % 90 == 0:
					if randi_range(0, 100) < attackDesire:
						attack_target()
func do_hit_1():
	super.to_hero()
	Skill_1_CD = 10
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()
func do_hit_2():
	super.to_hero()
	Skill_2_CD = 24
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()
func do_hit_3():
	super.to_hero()
	Skill_3_CD = 20
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()

func MoveToTopAndFacePlayer():
	velocity.y = 0
	var tween = create_tween().set_parallel(true)
	var Po = Vector2(position.x, position.y - 350)
	if position.y - 350 <= -100:
		Po = Vector2(position.x, -100)
	tween.tween_property(self, "position", Po, 0.2)
	var TargetDegrees = - position.angle_to(get_Player.position)
	tween.tween_property(self, "rotation", TargetDegrees, 0.2)
	ShouldInSky = true
func tweentotop():
	velocity.y = 0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position", Vector2(position.x, -100), 0.2)
	velocity.y = 0
	ShouldInSky = true
func NotMovePlayer():
	if position.x > get_Player.position.x:
		velocity.x = 2500
	else:
		velocity.x = -2500
func RemoveSpeedx():
	velocity.x = 0
func Drop():
	ShouldInSky = false
func CallBullet_1():
	var bb
	if self.MonsterDirection:
		bb = Global.add_Bullet("Monster146_Bullet1", self.bullet, true, 2.5, Vector2(20, 0) + position, "hit1", self.objattackDic["hit1"])
	else:
		bb = Global.add_Bullet("Monster146_Bullet1", self.bullet, true, 2.5, Vector2(-20, 0) + position, "hit1", self.objattackDic["hit1"])
	bb.look_at(get_Player.position)
func CallBullet_2():
	var Bullet
	if self.MonsterDirection:
		Bullet = Global.add_Bullet("Monster146_Bullet2", self.bullet, false, 0.3, Vector2(80, 0) + position, "hit2", self.objattackDic["hit2"])
	else:
		Bullet = Global.add_Bullet("Monster146_Bullet2", self.bullet, false, 0.3, Vector2(-80, 0) + position, "hit2", self.objattackDic["hit2"])
		Bullet.bullet_ani.flip_v = true
	Bullet.look_at(get_Player.position)

func CallBullet_3():
	for i in range(12):
		var Bullet
		var Position = Vector2(position.x + randi_range(-450, 500), 300)
		Bullet = Global.add_Bullet("Monster146_Bullet2", self.bullet, false, 0.3, Vector2(-80, 0) + position, "hit2", self.objattackDic["hit2"])
		Bullet.look_at(get_Player.position)
		await get_tree().create_timer(0.3, false).timeout

func ToSky():
	velocity.y = 0
	ShouldInSky = true
	velocity.y = 0
func CheckPlayer():
	if self.position.x > RoleProp.role_pos_x:
		if Global.get_player.PlayerDir:
			if not MonsterDirection:
				move_playerto_boss(0.5)
				Global.AddBuff(get_Player.buff, {
						"Name": "stun", 
						"AddTime": 4, 
						"ReduceInterval": 0, 
						"value": 0, 
						"AttackKind": "", 
						"CanAdd": false, 
						"CanRemove": false, 
						"DeBuff": true, 
					})
	else:
		if not Global.get_player.PlayerDir:
			if MonsterDirection:
				move_playerto_boss(0.5)
				Global.AddBuff(get_Player.buff, {
						"Name": "stun", 
						"AddTime": 4, 
						"ReduceInterval": 0, 
						"value": 0, 
						"AttackKind": "", 
						"CanAdd": false, 
						"CanRemove": false, 
						"DeBuff": true, 
					})
func reduce_hp(value: int):

	super.reduce_hp(value)

func HurtReduceHp(value, target):

	super.HurtReduceHp(value, target)
