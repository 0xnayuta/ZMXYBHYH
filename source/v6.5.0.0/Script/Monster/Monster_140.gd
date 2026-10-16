extends BaseMonster
var ShouldFly: bool
var Sword_: Monster117
var FireRound: Monster116
var IsCall: bool
var OnsetEatblood: bool
var RemoveBlood: bool


func monster_140():
	self.rush_speed = 400

	self.is_boss = true
	self.my_mr_name = "焰中仙"
	self.attack_in = 90
	self.level = 55
	self.SHp = 500000
	self.Hp = self.SHp
	self.def = 400
	self.mdef = 400
	self.crit = 20
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
		"power": 500,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.objattackDic["hit2"] = {
		"power": 450,
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 5,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"ReduceInterval": 0,
			"value": 0.5,
			"CanAdd": false,
			"DeBuff": true,
			"CanRemove": false,
			"AttackKind": "",
		},
	}
	self.objattackDic["hit3"] = {
		"power": 550,
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 9,
	}
	self.objattackDic["hit4"] = {
		"power": 800,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 3,
			"ReduceInterval": 1,
			"value": int(RoleProp.roleprop.SHp * 0.02),
			"CanAdd": false,
			"DeBuff": true,
			"CanRemove": false,
			"AttackKind": "magic",
		},
	}
	self.objattackDic["hit5"] = {
		"power": 800,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "DefeReduce",
			"AddTime": 10,
			"ReduceInterval": 0,
			"value": 0.3,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
			"CanAdd": false,
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "qszzs", "value": 1},
		{"name": "ytzzs", "value": 1},
		{"name": "llzzs", "value": 1},
		{"name": "rczzs", "value": 1},
		{"name": "ldzzs", "value": 1},
		{"name": "240007001zzs", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_140()
	Skill_1_CD = randi_range(3, 4)
	Skill_2_CD = 10
	Skill_3_CD = 5
	Skill_4_CD = 12
	Skill_5_CD = 15


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not IsCall:
		if Sword_ == null:
			Sword_ = Global.create_monster(117, get_parent(), self.position)
		if FireRound == null:
			FireRound = Global.create_monster(116, get_parent(), self.position)
		IsCall = true
	if Sword_ != null or FireRound != null:
		ebol = 10
	else:
		ebol = 1


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attackRange:
				have_target()
				if Skill_5_CD <= 0:
					do_hit_5()
				if Skill_1_CD <= 0:
					do_hit_1()
				if Skill_2_CD <= 0:
					do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 450:
					if Skill_4_CD <= 0:
						do_hit_4()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 500:
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
				if Skill_4_CD <= 0:
					do_hit_4()
				if Skill_5_CD <= 0:
					do_hit_5()
				if count % 90 == 0:
					if randi_range(0, 100) < attackDesire:
						attack_target()


func do_hit_1():
	super.to_hero()
	Skill_1_CD = 10
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	Skill_2_CD = 24
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	Skill_3_CD = 20
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_4():
	super.to_hero()
	Skill_4_CD = 15
	hit_name = "hit5"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit5")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_5():
	super.to_hero()
	Skill_5_CD = 14
	hit_name = "hit5"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit6")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func move_to_top_and_face_player():
	if _movement_command_is_blocked() or get_Player == null:
		return
	velocity.y = 0
	var tween = create_control_movement_tween().set_parallel(true)
	var Po = Vector2(position.x, position.y - 350)
	if position.y - 350 <= -100:
		Po = Vector2(position.x, -100)
	tween.tween_property(self, "position", Po, 0.2)
	var TargetDegrees = -position.angle_to(RoleProp.get_nearest_monster_target_position(global_position))
	tween.tween_property(self, "rotation", TargetDegrees, 0.2)
	ShouldInSky = true


func tweentotop():
	if _movement_command_is_blocked():
		return
	velocity.y = 0
	var tween = create_control_movement_tween().set_parallel(true)
	tween.tween_property(self, "position", Vector2(position.x, -100), 0.2)
	velocity.y = 0
	ShouldInSky = true


func NotMovePlayer():
	if _movement_command_is_blocked() or get_Player == null:
		velocity.x = 0
		return
	if position.x > RoleProp.get_nearest_monster_target_position(global_position).x:
		velocity.x = 2500
	else:
		velocity.x = -2500


func remove_speedx():
	velocity.x = 0


func drop():
	ShouldInSky = false


func call_bullet_1():
	var bb
	if self.MonsterDirection:
		bb = Global.add_bullet(
			"Monster140Bullet1", self.bullet, true, 2.5, Vector2(20, 0) + position, "hit1", self.objattackDic["hit1"]
		)
	else:
		bb = Global.add_bullet(
			"Monster140Bullet1", self.bullet, true, 2.5, Vector2(-20, 0) + position, "hit1", self.objattackDic["hit1"]
		)
	bb.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func call_bullet_alt2():
	var Bullet
	var dir = self.MonsterDirection
	if dir:
		Bullet = Global.add_bullet(
			"Monster140Bullet2", self.bullet, false, 0.3, Vector2(80, 0) + position, "hit2", self.objattackDic["hit2"]
		)
	else:
		Bullet = Global.add_bullet(
			"Monster140Bullet2", self.bullet, false, 0.3, Vector2(-80, 0) + position, "hit2", self.objattackDic["hit2"]
		)

	if Bullet:
		var sprite = Bullet.bullet_ani
		if sprite:
			sprite.flip_v = dir
	Bullet.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func call_bullet_3():
	for i in range(12):
		var Bullet
		var bullet_pos = Vector2(position.x + randi_range(-450, 500), -300)
		Bullet = Global.add_bullet(
			"Monster140Bullet3", self.bullet, false, 0.58, bullet_pos, "hit4", self.objattackDic["hit4"]
		)
		Bullet.look_at(RoleProp.get_nearest_monster_target_position(global_position))
		await get_tree().create_timer(0.3, false).timeout


func call_bullet_4():
	var bullet_spawn_positions = [
		Vector2(-500 + position.x, 500),
		Vector2(-400 + position.x, 500),
		Vector2(-300 + position.x, 500),
		Vector2(-200 + position.x, 500),
		Vector2(-100 + position.x, 500),
		Vector2(100 + position.x, 500),
		Vector2(200 + position.x, 500),
		Vector2(300 + position.x, 500),
		Vector2(400 + position.x, 500),
		Vector2(500 + position.x, 500)
	]
	for i in bullet_spawn_positions:
		Global.add_bullet("Monster140Bullet4", self.bullet, false, 1, i, "hit5", self.objattackDic["hit5"])


func to_sky():
	velocity.y = 0
	ShouldInSky = true
	velocity.y = 0


func check_player():
	if self.position.x > RoleProp.get_nearest_monster_target_position(global_position).x:
		if Global.get_player.PlayerDir:
			if not MonsterDirection:
				move_player_to_boss(0.5)
				(
					Global
					. add_buff(
						get_Player.buff,
						{
							"Name": "stun",
							"AddTime": 4,
							"ReduceInterval": 0,
							"value": 0,
							"AttackKind": "",
							"CanAdd": false,
							"CanRemove": false,
							"DeBuff": true,
						}
					)
				)
	else:
		if not Global.get_player.PlayerDir:
			if MonsterDirection:
				move_player_to_boss(0.5)
				(
					Global
					. add_buff(
						get_Player.buff,
						{
							"Name": "stun",
							"AddTime": 4,
							"ReduceInterval": 0,
							"value": 0,
							"AttackKind": "",
							"CanAdd": false,
							"CanRemove": false,
							"DeBuff": true,
						}
					)
				)


func reduce_hp(value: int):
	if Sword_ != null or FireRound != null:
		if value > 0:
			value *= 0.5
	super.reduce_hp(value)


func hurt_reduce_hp(value, target):
	if Sword_ != null or FireRound != null:
		if value > 0:
			value *= 0.5
	return super.HurtReduceHp(value, target)


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func call_bullet_2():
	return call_bullet_alt2()


## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func HurtReduceHp(value, target):
	return hurt_reduce_hp(value, target)
