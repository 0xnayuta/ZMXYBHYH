extends BaseMonster
class_name Monster20

var is_first_low_hp = false
var my_shark


func monster_20():
	self.is_boss = true
	self.my_mr_name = "鲨魔王"
	self.attack_in = 60
	self.level = 25
	self.SHp = 10000
	self.Hp = self.SHp
	self.def = 100
	self.mdef = 150
	self.crit = 15
	self.miss = 5
	self.lucky = 0
	self.Htarget = 0
	self.Toughness = 0
	self.ar = 0
	self.sp = 0
	self.Critreduce = 0
	self.speed = 8
	self.mysee = 450
	self.attackRange = 145
	self.attackDesire = 100
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.objattackDic["hit1"] = {"power": 225, "hurtBack": [-5, -9], "attackKind": "physics"}
	self.objattackDic["sxks"] = {
		"power": 245,
		"hurtBack": [-5, -15],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 5,
			"CanAdd": true,
			"DeBuff": true,
			"ReduceInterval": 0.5,
			"value": 20,
			"AttackKind": "real",
		}
	}
	self.objattackDic["sxks_2"] = {
		"power": 155,
		"hurtBack": [-7, -15],
		"attackKind": "real",
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 5,
			"DeBuff": true,
			"CanAdd": true,
			"ReduceInterval": 0.5,
			"value": 20,
			"AttackKind": "real",
		}
	}
	self.objattackDic["spzd"] = {
		"power": 400,
		"hurtBack": [-15, -15],
		"attackKind": "real",
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 3,
			"CanAdd": false,
			"DeBuff": true,
			"ReduceInterval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}

	self.fall_pro = 0.5
	self.fall_list = [{"name": "qlp", "value": 0}, {"name": "zqj", "value": 0}, {"name": "ttj", "value": 0}]

	enable_treasure_box = true
	treasure_box_item = "smwbx"

	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_20()
	Skill_1_CD = 0
	Skill_2_CD = 0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if self.Hp <= 0:
		if my_shark != null:
			my_shark.Hp = -100
			my_shark.state = my_shark.State.Death


func ai_think():
	if self.Hp <= 0:
		if my_shark != null:
			my_shark.Hp = -100
			my_shark.state = my_shark.State.Death
	if not is_first_low_hp:
		if low_hp():
			if self.MonsterDirection:
				my_shark = Global.create_monster(19, get_parent(), Vector2(self.position.x, self.position.y - 30))
			else:
				my_shark = Global.create_monster(19, get_parent(), Vector2(self.position.x, self.position.y - 30))
			is_first_low_hp = true

	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attackRange:
				have_target()
				if Skill_2_CD <= 0:
					do_hit_3()
				elif abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 550:
					if Skill_1_CD <= 0:
						do_hit_2()
			else:
				if Skill_2_CD <= 0:
					do_hit_3()
				elif Skill_1_CD <= 0:
					do_hit_2()
				else:
					if count % 90 == 0:
						if ran_num <= attackDesire:
							attack_target()
					else:
						stop_move()


func attack_target():
	have_target()
	hit_name = "hit1"
	if not is_fly:
		velocity.x = 0
	is_attacking = true
	if not low_hp():
		mr_player.play("hit1_1")
	else:
		mr_player.play("hit1_2")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_2():
	Skill_1_CD = 20
	hit_name = "sxks"
	velocity.x = 0
	is_attacking = true
	if not low_hp():
		mr_player.play("sxks_1")
	else:
		mr_player.play("sxks_2")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	Skill_2_CD = 15
	velocity.x = 0
	hit_name = "spzd"
	is_attacking = true
	if not low_hp():
		mr_player.play("spzd_1")
	else:
		mr_player.play("spzd_2")
	await mr_player.animation_finished
	is_attacking = false


func call_pp():
	var first_position = Vector2(
		RoleProp.get_nearest_monster_target_position(global_position).x,
		RoleProp.get_nearest_monster_target_position(global_position).y - 110
	)
	var par = Global.add_special_effect(
		get_parent().get_parent(), Vector2(first_position), "Monster20Bullet_1", Vector2(1, 1), false, 1
	)
	var second_position = par.position + Vector2(0, 70)
	await get_tree().create_timer(0.8, false).timeout
	Global.add_bullet(
		"Monster20Bullet_1", self.bullet, self.MonsterDirection, 1, second_position, "spzd", self.objattackDic["spzd"]
	)


func call_shark():
	var bullet_name = "Monster_20Bullet"
	var speed_val = 700
	var position_vec = Vector2(position.x, position.y - 20)
	var hit_name = "sxks_2"
	var attack_dic = objattackDic["sxks_2"]

	if MonsterDirection:
		var shark = Global.call_fly_bullet(bullet, bullet_name, 1, position_vec, 4000, speed_val, hit_name, attack_dic)
		var shark_1 = Global.call_fly_bullet(
			bullet, bullet_name, 1, position_vec, 4000, -speed_val, hit_name, attack_dic
		)

		if shark:
			var sprite = shark.get_node("AnimatedSprite2D")
			if sprite:
				sprite.flip_h = false
		if shark_1:
			var sprite = shark_1.get_node("AnimatedSprite2D")
			if sprite:
				sprite.flip_h = true
	else:
		var shark = Global.call_fly_bullet(bullet, bullet_name, 1, position_vec, 4000, -speed_val, hit_name, attack_dic)
		var shark_1 = Global.call_fly_bullet(
			bullet, bullet_name, 1, position_vec, 4000, speed_val, hit_name, attack_dic
		)

		if shark:
			var sprite = shark.get_node("AnimatedSprite2D")
			if sprite:
				sprite.flip_h = true
		if shark_1:
			var sprite = shark_1.get_node("AnimatedSprite2D")
			if sprite:
				sprite.flip_h = false


func low_hp():
	return self.Hp <= self.SHp * 0.7


func move_left():
	monster_dir.scale.x = 1
	base_damage_box.scale.x = 1
	velocity.x = -speed * 10
	if not low_hp():
		mr_player.play("walk_1")
	else:
		mr_player.play("walk_2")


func move_right():
	monster_dir.scale.x = -1
	base_damage_box.scale.x = -1
	velocity.x = speed * 10
	if not low_hp():
		mr_player.play("walk_1")
	else:
		mr_player.play("walk_2")


func stop_move():
	velocity.x = 0
	if not low_hp():
		mr_player.play("wait_1")
	else:
		mr_player.play("wait_2")
	await mr_player.animation_finished


func state_hurt():
	if get_target.HitDic["hurtBack"][0] != 0 or get_target.HitDic["hurtBack"][1] != 0:
		is_be_attacking = true
		velocity.x = 0
		if not is_quiescent:
			super.be_hit_back(self.get_target)
			if not low_hp():
				mr_player.play("hurt_1")
			else:
				mr_player.play("hurt_2")
			await mr_player.animation_finished
			is_be_attacking = false


func change_hit():
	if not low_hp():
		self.objattackDic["hit1"] = {"power": 245, "hurtBack": [-5, -9], "attackKind": "real"}
		self.objattackDic["sxks"] = {
			"power": 50,
			"hurtBack": [-5, -15],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "Bleed",
				"AddTime": 4,
				"ReduceInterval": 0.5,
				"value": 15,
				"AttackKind": "real",
			}
		}
		self.objattackDic["sxks_2"] = {
			"power": 70,
			"hurtBack": [-7, -15],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "Bleed",
				"AddTime": 4,
				"ReduceInterval": 0.5,
				"value": 15,
				"AttackKind": "real",
			}
		}
		self.objattackDic["spzd"] = {
			"power": 500,
			"hurtBack": [-15, -15],
			"attackKind": "real",
			"addeffect":
			{
				"Name": "stun",
				"AddTime": 3,
				"ReduceInterval": 0,
				"value": 0,
				"AttackKind": "",
			}
		}
	else:
		self.objattackDic["hit1"] = {"power": 105, "hurtBack": [-5, -9], "attackKind": "physics"}
		self.objattackDic["sxks"] = {
			"power": 300,
			"hurtBack": [-5, -15],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "Bleed",
				"AddTime": 4,
				"ReduceInterval": 0.5,
				"value": 10,
				"AttackKind": "real",
			}
		}
		self.objattackDic["sxks_2"] = {
			"power": 300,
			"hurtBack": [-7, -15],
			"attackKind": "real",
			"addeffect":
			{
				"Name": "Bleed",
				"AddTime": 4,
				"ReduceInterval": 0.5,
				"value": 10,
				"AttackKind": "real",
			}
		}
		self.objattackDic["spzd"] = {
			"power": 210,
			"hurtBack": [-15, -15],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "stun",
				"AddTime": 3,
				"ReduceInterval": 0,
				"value": 0,
				"AttackKind": "",
			}
		}
