extends BaseMonster
var MyChild: MonsterBullet
var Count: int = 0

var y_min: float = 250
var y_max: float = 600


func monster_101():
	self.is_Fly = true
	self.is_boss = true
	self.my_mr_name = "紫睛鹏王"
	self.attack_in = 136
	self.level = 86

	self.SHp = 8640000
	self.Hp = self.SHp

	self.def = 2230
	self.mdef = 2160

	self.crit = 66

	self.miss = 72

	self.lucky = 146
	self.Htarget = 144000

	self.Toughness = 52

	self.ar = 492
	self.sp = 481

	self.Critreduce = 43

	self.speed = 34

	self.mysee = 1080

	self.attackRange = 382

	self.attackDesire = 325
	self.behit_calmtime = 0

	self.self_rhp = self.SHp * 0.000216

	self.add_exp = 0
	self.fall_coin = 0
	self.ebol = 0

	self.y_max = 600
	self.y_min = 250

	self.objattackDic["hit1"] = {
		"power": 4666,
		"hurtBack": [-4, -7],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.objattackDic["hit2"] = {
		"power": 4666,
		"hurtBack": [-2, -1],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 4,
			"ReduceInterval": 0,
			"value": 0.3,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		},
	}
	self.objattackDic["hit3"] = {
		"power": 8640,
		"hurtBack": [-6, -1],
		"attackKind": "magic",
		"HitProtect": 5,
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

	self.fall_pro = 0
	self.fall_list = []

	self.independent_fall_list = [
		{"name": "xianyjp", "value": 1, "chance": 0.05},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_101()
	Skill_1_CD = randi_range(0, 6)
	Skill_2_CD = randi_range(5, 8)
	Skill_3_CD = randi_range(8, 13)


func ai_think():
	if MyChild != null:
		Count += 1
		if Count >= 900:
			MyChild.queue_free()
	else:
		Count = 0

	var player_distance = abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x)
	if player_distance < mysee:
		has_target = true
	elif player_distance > mysee + 50:
		has_target = false

	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()

			_limit_y_position()
		else:
			var distance = abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x)

			if distance >= attackRange:
				have_target()

				if MyChild == null and Skill_1_CD <= 0:
					do_hit_1()
					Skill_1_CD = randi_range(8, 13)

				elif distance <= 200 and Skill_2_CD <= 0:
					do_hit_2()
					Skill_2_CD = randi_range(5, 8)

				elif distance <= 300 and Skill_3_CD <= 0:
					do_hit_3()
					Skill_3_CD = randi_range(0, 6)

			else:
				stop_move()

				_limit_y_position()

				if MyChild == null and Skill_1_CD <= 0:
					do_hit_1()
					Skill_1_CD = randi_range(8, 13)

				elif distance <= 200 and Skill_2_CD <= 0:
					do_hit_2()
					Skill_2_CD = randi_range(5, 8)

				elif distance <= 300 and Skill_3_CD <= 0:
					do_hit_3()
					Skill_3_CD = randi_range(0, 6)

				if count % 60 == 0:
					if randi_range(0, 100) < attackDesire:
						attack_target()


func _limit_y_position():
	if position.y > self.y_max:
		position.y = self.y_max

		if velocity.y < 0:
			velocity.y = abs(velocity.y)
	elif position.y < self.y_min:
		position.y = self.y_min

		if velocity.y > 0:
			velocity.y = -abs(velocity.y)


func do_hit_1():
	super.to_hero()
	Skill_1_CD = randi_range(8, 10)
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	Skill_2_CD = randi_range(11, 13)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	Skill_3_CD = randi_range(11, 13)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_bullet_1():
	var bullet_node
	if self.MonsterDirection:
		bullet_node = Global.add_bullet(
			"Monster147Bullet1", self.bullet, false, 1, Vector2(35, 25) + position, "hit1", self.objattackDic["hit1"]
		)
	else:
		bullet_node = Global.add_bullet(
			"Monster147Bullet1", self.bullet, false, 1, Vector2(-35, 25) + position, "hit1", self.objattackDic["hit1"]
		)
	bullet_node.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func call_bullet_2():
	var PositionList1 = [Vector2(position.x + 150, 0), Vector2(position.x + 0, 100), Vector2(position.x - 150, 0)]
	var PositionList2 = [Vector2(position.x + 300, 100), Vector2(position.x - 300, 100)]
	var PositionList3 = [Vector2(position.x + 450, 200), Vector2(position.x - 450, 200)]
	var PositionList4 = [Vector2(position.x + 600, 0), Vector2(position.x - 600, 0)]
	for i in PositionList1:
		Global.add_bullet("Monster147Bullet2", self.bullet, false, 1, i, "hit2", self.objattackDic["hit2"])
	await get_tree().create_timer(0.2, false).timeout
	for i in PositionList2:
		Global.add_bullet("Monster147Bullet2", self.bullet, false, 1, i, "hit2", self.objattackDic["hit2"])
	await get_tree().create_timer(0.2, false).timeout
	for i in PositionList3:
		Global.add_bullet("Monster147Bullet2", self.bullet, false, 1, i, "hit2", self.objattackDic["hit2"])
	await get_tree().create_timer(0.2, false).timeout
	for i in PositionList4:
		Global.add_bullet("Monster147Bullet2", self.bullet, false, 1, i, "hit2", self.objattackDic["hit2"])
	await get_tree().create_timer(0.2, false).timeout


func call_bullet_3():
	var bullet_spawn_positions = [
		{"position": Vector2(125, 50), "dir": true}, {"position": Vector2(-125, 50), "dir": false}
	]
	for i in range(1):
		for u in bullet_spawn_positions:
			Global.add_bullet(
				"Monster149Bullet2",
				self.bullet,
				u["dir"],
				1,
				u["position"] + position,
				"hit3",
				self.objattackDic["hit2"]
			)
		await get_tree().create_timer(0.5, false).timeout


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func CallBullet1():
	return call_bullet_1()


## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func CallBullet2():
	return await call_bullet_2()


## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func CallBullet3():
	return await call_bullet_3()
