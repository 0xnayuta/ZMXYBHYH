extends BaseMonster
var IsDrop = false
var First: bool = true
var FS: bool = false
@onready var change_timer: Timer = $ChangeTimer
@onready var special_effect: AnimatedSprite2D = $MonsterDir/SpecialEffect


func monster_64():
	self.rush_speed = 600
	self.is_boss = true
	self.my_mr_name = "五毒·泰山王"
	self.attack_in = 15
	self.level = RoleProp.baseroleprop.Level + 1
	self.SHp = 200000 + int(RoleProp.baseroleprop.Level * 14000)
	self.Hp = self.SHp
	self.def = 180 + int(RoleProp.baseroleprop.Level * 3.5)
	self.mdef = 180 + int(RoleProp.baseroleprop.Level * 3.5)
	self.crit = 5 + int(RoleProp.baseroleprop.Level * 1)
	self.miss = 5 + int(RoleProp.baseroleprop.Level * 0.5)
	self.lucky = 0 + int(RoleProp.baseroleprop.Level * 1.6)
	self.Htarget = 0
	self.Toughness = 0
	self.ar = 20 + int(RoleProp.baseroleprop.Level * 0.8)
	self.sp = 20 + int(RoleProp.baseroleprop.Level * 0.8)
	self.Critreduce = 0
	self.speed = 9
	self.mysee = 500
	self.attackRange = 335
	self.attackDesire = 60
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.objattackDic["hit1"] = {
		"power": 300 + int(RoleProp.baseroleprop.Level * 8.5),
		"hurtBack": [-7, -9],
		"attackKind": "physics",
		"HitProtect": 4
	}
	self.objattackDic["hit1_1"] = {
		"power": 200 + int(RoleProp.baseroleprop.Level * 8),
		"hurtBack": [-15, -20],
		"attackKind": "magic",
		"HitProtect": 4
	}
	self.objattackDic["hit1_2"] = {
		"power": 300 + int(RoleProp.baseroleprop.Level * 8.5),
		"hurtBack": [50, -20],
		"attackKind": "magic",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 5,
			"ReduceInterval": 0,
			"value": 0.2,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.objattackDic["xlyj"] = {
		"power": 400 + int(RoleProp.baseroleprop.Level * 8.5),
		"hurtBack": [-8, 0],
		"attackKind": "physics",
		"HitProtect": 25,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": randi_range(1, 5),
			"ReduceInterval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true,
			"CanAdd": false,
		}
	}
	self.objattackDic["yscs"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic", "HitProtect": 4}
	self.objattackDic["tsyd"] = {
		"power": 500 + int(RoleProp.baseroleprop.Level * 9),
		"hurtBack": [-3, 0],
		"attackKind": "physics",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 3,
			"ReduceInterval": 0.5,
			"value": 300 + int(RoleProp.baseroleprop.Level * 3),
			"AttackKind": "magic",
			"CanAdd": true,
			"DeBuff": true,
		}
	}

	self.objattackDic["zhq_3"] = {
		"power": 400 + int(RoleProp.baseroleprop.Level * 8.5),
		"hurtBack": [-50, -40],
		"attackKind": "physics",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 2,
			"ReduceInterval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.objattackDic["sgq"] = {
		"power": 300 + int(RoleProp.baseroleprop.Level * 8.5),
		"hurtBack": [-4, -40],
		"attackKind": "physics",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 2,
			"ReduceInterval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}

	self.fall_pro = 0.15
	self.fall_list = [
		{"name": "czyj", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	change_timer.start(randi_range(14, 16))
	super._ready()
	monster_64()
	Skill_1_CD = 2
	Skill_2_CD = 6
	Skill_3_CD = 4
	Skill_4_CD = 8
	Skill_5_CD = 15
	Skill_6_CD = 20
	Skill_7_CD = 13


func Monster_Intelligence():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attackRange:
				have_target()
				if Skill_1_CD <= 0:
					do_hit_1()
				if Skill_2_CD <= 0:
					do_hit_2()
				if Skill_3_CD <= 0:
					do_hit_3()
				if Skill_4_CD <= 0:
					do_hit_4()
				if (
					Skill_5_CD <= 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 100
				):
					do_hit_5()
				if Skill_6_CD <= 0:
					do_hit_6()
				if (
					Skill_7_CD <= 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400
				):
					do_hit_7()
			else:
				stop_move()
				if Skill_1_CD <= 0:
					do_hit_1()
				if Skill_2_CD <= 0:
					do_hit_2()
				if Skill_3_CD <= 0:
					do_hit_3()
				if Skill_4_CD <= 0:
					do_hit_4()
				if (
					Skill_5_CD <= 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 100
				):
					do_hit_5()
				if Skill_6_CD <= 0:
					do_hit_6()
				if (
					Skill_7_CD <= 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400
				):
					do_hit_7()


func do_hit_1():
	super.to_hero()
	Skill_1_CD = randi_range(2, 5)
	hit_name = "hit1_1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	Skill_2_CD = randi_range(24, 34)
	hit_name = "xlyj"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	Skill_3_CD = randi_range(15, 20)
	hit_name = "yscs"
	velocity.x = 0
	is_attacking = true
	mr_player.play("yscs")
	await mr_player.animation_finished
	is_attacking = false
	do_hit_1()


func do_hit_4():
	super.to_hero()
	Skill_4_CD = randi_range(28, 38)
	hit_name = "xlyj"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_5():
	super.to_hero()
	Skill_5_CD = randi_range(10, 15)
	hit_name = "sgq"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_6():
	super.to_hero()
	Skill_6_CD = randi_range(30, 40)
	hit_name = "tsyd"
	velocity.x = 0
	is_attacking = true
	mr_player.play("tsyd")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_7():
	super.to_hero()
	Skill_7_CD = randi_range(10, 15)
	hit_name = "hit1_2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit5")
	await mr_player.animation_finished
	is_attacking = false
	if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 100:
		do_hit_5()
	else:
		stop_move()


func MoveSelfToPlayer():
	self.position = RoleProp.get_nearest_monster_target_position(global_position)


func call_fly_bullet():
	var fz
	if self.MonsterDirection:
		fz = Global.CallFlyBullet(
			self.bullet,
			"Monster_63Bullet",
			1,
			Vector2(position.x + 100, position.y + 40),
			1000,
			-900,
			"hit1",
			self.objattackDic["hit1"]
		)
	else:
		fz = Global.CallFlyBullet(
			self.bullet,
			"Monster_63Bullet",
			1,
			Vector2(position.x - 100, position.y + 40),
			1000,
			900,
			"hit1",
			self.objattackDic["hit1"]
		)
		fz.get_node("AnimatedSprite2D").flip_h = true
	if First:
		fz.scale = Vector2(1, 1)
	else:
		fz.scale = Vector2(1.5, 1.5)


func call_fly_bullet2():
	var fz
	if self.MonsterDirection:
		fz = Global.CallFlyBullet(
			self.bullet,
			"Monster63Bullet",
			1,
			Vector2(position.x + 100, position.y),
			300,
			-1500,
			"zhq_3",
			self.objattackDic["zhq_3"]
		)
	else:
		fz = Global.CallFlyBullet(
			self.bullet,
			"Monster63Bullet",
			1,
			Vector2(position.x - 100, position.y),
			300,
			1500,
			"zhq_3",
			self.objattackDic["zhq_3"]
		)
		fz.get_node("AnimatedSprite2D").flip_h = true
	if First:
		fz.scale = Vector2(1, 1)
	else:
		fz.scale = Vector2(2, 2)


func _on_timer_timeout() -> void:
	if not FS:
		FS = true
		change_timer.start(randi_range(9, 11))
	else:
		FS = false
		change_timer.start(randi_range(22, 25))
	ChangeSelfColor()


func ChangeSelfColor():
	var TWEEN = get_tree().create_tween()

	if FS:
		TWEEN.tween_property(self, "modulate", Color("00ffff"), 1)
	else:
		TWEEN.tween_property(self, "modulate", Color("ffffff"), 1)
	pass


func _on_hurt_box_area_entered(area: Area2D) -> void:
	super._on_hurt_box_area_entered(area)
	if FS:
		if get_Player != null:
			get_Player.effect_reducehp(self.GetHurt, "real")
		self.GetHurt = 0


func ToToP():
	if _movement_command_is_blocked():
		return
	var Po = Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, -30)
	var tween = create_control_movement_tween()
	tween.tween_property(self, "position", Po, 0.4)


func ToDrop():
	if _movement_command_is_blocked():
		velocity.y = 0
		IsDrop = false
		return
	velocity.y += 800

	await mr_player.animation_finished
	is_attacking = false
	IsDrop = false


func CallBullet():
	var PositionList
	if First:
		PositionList = [Vector2(-158, 105), Vector2(158, 105), Vector2(0, 105), Vector2(-315, 105), Vector2(315, 105)]
	else:
		PositionList = [Vector2(-280, 240), Vector2(280, 240), Vector2(0, 240), Vector2(620, 240), Vector2(-620, 240)]
	for i in PositionList:
		var bb = Global.add_bullet(
			"Monster63Bullet", self.bullet, false, 1, i + self.position, "tsyd", self.objattackDic["tsyd"]
		)
		if First:
			bb.scale = Vector2(1.5, 1.5)
		else:
			bb.scale = Vector2(2.0, 2.0)


func _on_change_timer_timeout() -> void:
	pass
