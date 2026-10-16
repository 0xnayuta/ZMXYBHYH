extends SummonBaseMonster

var weapon_level: int = 1
var attribute_scale: float = 0.1

var player_power: int = 0
var damage_ratio: float = 0.3


func set_weapon_level(level: int, scale: float):
	weapon_level = level
	attribute_scale = scale
	damage_ratio = 0.3 + (float(weapon_level) / 10.0) * 0.5
	print("召唤物接收法宝等级: %d, 属性系数: %.1f%%, 伤害比例: %.1f%%" % [weapon_level, attribute_scale * 100, damage_ratio * 100])


func fetch_player_power():
	if RoleProp and RoleProp.roleprop:
		player_power = RoleProp.roleprop.power
	else:
		var hero = Global.get_player
		if hero and hero.has_method("get_power"):
			player_power = hero.get_power()
		else:
			player_power = 100
	print("获取到玩家攻击力: %d" % player_power)


func initialize_monster_properties():
	fetch_player_power()

	var base_hp = 500000
	var base_def = 400
	var base_mdef = 400
	var base_crit = 30
	var base_miss = 20
	var base_lucky = 20

	var scaled_hp = int(base_hp * attribute_scale)
	var scaled_def = int(base_def * attribute_scale)
	var scaled_mdef = int(base_mdef * attribute_scale)
	var scaled_crit = int(base_crit * attribute_scale)
	var scaled_miss = int(base_miss * attribute_scale)
	var scaled_lucky = int(base_lucky * attribute_scale)

	SHp = scaled_hp
	Hp = SHp

	self.set("rush_speed", 400)
	self.set("is_boss", true)
	self.set("my_mr_name", "遮迦越罗 (Lv.%d)" % weapon_level)
	self.set("attack_in", 90)
	self.set("level", 55)
	self.set("def", scaled_def)
	self.set("mdef", scaled_mdef)
	self.set("crit", scaled_crit)
	self.set("miss", scaled_miss)
	self.set("lucky", scaled_lucky)
	self.set("Htarget", 25)
	self.set("Toughness", 0)
	self.set("ar", 60)
	self.set("sp", 60)
	self.set("Critreduce", 0)
	self.set("behit_calmtime", 0)
	self.set("self_rhp", 0)
	self.set("add_exp", 0)
	self.set("fall_coin", 500)
	self.set("ebol", 0)

	attackRange = 160
	mysee = 99999
	speed = 12
	attackDesire = 80

	var base_damage_hit1 = 500
	var base_damage_hit2 = 1500
	var base_damage_hit3 = 650
	var base_damage_hit4 = 600
	var base_damage_hit5 = 1500
	var base_damage_hit6 = 600

	var actual_damage_hit1 = int(player_power * damage_ratio * (base_damage_hit1 / 500.0))
	var actual_damage_hit2 = int(player_power * damage_ratio * (base_damage_hit2 / 500.0))
	var actual_damage_hit3 = int(player_power * damage_ratio * (base_damage_hit3 / 500.0))
	var actual_damage_hit4 = int(player_power * damage_ratio * (base_damage_hit4 / 500.0))
	var actual_damage_hit5 = int(player_power * damage_ratio * (base_damage_hit5 / 500.0))
	var actual_damage_hit6 = int(player_power * damage_ratio * (base_damage_hit6 / 500.0))

	self.objattackDic["hit1"] = {
		"power": actual_damage_hit1,
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 0,
	}
	self.objattackDic["hit2"] = {
		"power": actual_damage_hit2,
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 0,
	}
	self.objattackDic["hit3"] = {
		"power": actual_damage_hit3,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 0,
		"addeffect":
		{
			"Name": "DefeReduce",
			"AddTime": 20,
			"ReduceInterval": 0,
			"value": 0.3,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}
	self.objattackDic["hit4"] = {
		"power": actual_damage_hit4,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 0,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 3,
			"ReduceInterval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}
	self.objattackDic["hit5"] = {
		"power": actual_damage_hit5,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 0,
	}
	self.objattackDic["hit6"] = {
		"power": actual_damage_hit6,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 0,
	}

	print(
		(
			"召唤物属性初始化完成 - HP: %d, 防御: %d/%d, 伤害比例: %.1f%%, 实际攻击力(示例): hit1=%d"
			% [scaled_hp, scaled_def, scaled_mdef, damage_ratio * 100, actual_damage_hit1]
		)
	)


func ai_think() -> void:
	if not is_instance_valid(current_target) or current_target.Hp <= 0:
		current_target = null
		stop_move()
		return

	var distance = abs(position.x - current_target.position.x)
	if distance < mysee:
		if distance > attackRange:
			if current_target.position.x > position.x:
				move_right()
			else:
				move_left()
		else:
			stop_move()

		if not is_be_attacking and not is_attacking:
			try_use_skills()
	else:
		current_target = null
		stop_move()


func setup_skills():
	var cd_multiplier = max(0.5, 1.0 - (weapon_level - 1) * 0.05)

	Skill_1_CD = 2 * cd_multiplier

	Skill_3_CD = 7 * cd_multiplier
	Skill_4_CD = 9 * cd_multiplier
	Skill_5_CD = 11 * cd_multiplier


func try_use_skills():
	if ShouldInSky:
		return

	if randi_range(0, 100) >= attackDesire:
		return

	if Skill_4_CD <= 0:
		do_hit_4()
	elif Skill_1_CD <= 0:
		do_hit_1()
	elif Skill_3_CD <= 0:
		do_hit_3()
	elif Skill_5_CD <= 0:
		do_hit_5()


func do_hit_1():
	if not current_target or not is_instance_valid(current_target):
		return

	if current_target.position.x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
		MonsterDirection = false
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1
		MonsterDirection = true

	Skill_1_CD = 2
	velocity.x = 0
	hit_name = "hit1"
	is_attacking = true
	mr_player.play("hit1")

	await mr_player.animation_finished
	is_attacking = false
	reset_attack_state()
	stop_move()


func do_hit_3():
	if not current_target or not is_instance_valid(current_target):
		return

	if current_target.position.x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
		MonsterDirection = false
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1
		MonsterDirection = true

	Skill_3_CD = 17
	velocity.x = 0
	hit_name = "hit3"
	is_attacking = true
	mr_player.play("hit3")

	await mr_player.animation_finished
	is_attacking = false
	reset_attack_state()
	stop_move()


func do_hit_4():
	if not current_target or not is_instance_valid(current_target):
		return

	if current_target.position.x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
		MonsterDirection = false
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1
		MonsterDirection = true

	Skill_4_CD = 13
	velocity.x = 0
	hit_name = "hit4"
	is_attacking = true
	mr_player.play("hit4")

	await mr_player.animation_finished
	is_attacking = false
	reset_attack_state()
	stop_move()


func do_hit_5():
	if not current_target or not is_instance_valid(current_target):
		return

	if current_target.position.x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
		MonsterDirection = false
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1
		MonsterDirection = true

	Skill_5_CD = 20
	velocity.x = 0
	hit_name = "hit5"
	is_attacking = true
	mr_player.play("hit5")

	await mr_player.animation_finished
	is_attacking = false
	reset_attack_state()
	stop_move()


func call_bullet_1():
	if not current_target or not is_instance_valid(current_target):
		return
	var Round = Global.add_bullet(
		"Monster142Bullet1", self.bullet, false, 1, position, "hit1", self.objattackDic["hit1"]
	)
	setup_bullet_collision(Round)
	var tween = create_tween()
	tween.tween_property(Round, "position", current_target.position, 0.5)


func call_bullet_3():
	var bullet_spawn_positions = [
		Vector2(-400 + position.x, 490),
		Vector2(-300 + position.x, 490),
		Vector2(-200 + position.x, 490),
		Vector2(-100 + position.x, 490),
		Vector2(position.x, 490),
		Vector2(100 + position.x, 490),
		Vector2(200 + position.x, 490),
		Vector2(300 + position.x, 490),
		Vector2(400 + position.x, 490)
	]
	for i in bullet_spawn_positions:
		var bullet = Global.add_bullet("Monster56Bullet", self.bullet, false, 1, i, "hit3", self.objattackDic["hit3"])
		setup_bullet_collision(bullet)


func call_bullet_4():
	var MaxCount: int = 10
	var target_count: int = 0
	var bullet_spawn_positions = []
	while target_count < MaxCount:
		var NewRotation = 360 / MaxCount
		NewRotation = NewRotation * target_count
		var stabPosition = Vector2(
			self.position.x + sin(float(NewRotation) * PI / 180) * 150,
			self.position.y - 15 - cos(float(NewRotation) * PI / 180) * 150
		)
		bullet_spawn_positions.push_back(stabPosition)
		target_count += 1
	if not MonsterDirection:
		bullet_spawn_positions.reverse()
	for i in bullet_spawn_positions:
		var stab = Global.add_bullet("Monster142Bullet2", self.bullet, false, 1, i, "hit4", self.objattackDic["hit4"])
		setup_bullet_collision(stab)
		await get_tree().create_timer(0.2, false).timeout


func call_bullet_5():
	var bullet_spawn_positions = [
		Vector2(-400 + position.x, 450),
		Vector2(-300 + position.x, 450),
		Vector2(-200 + position.x, 450),
		Vector2(-100 + position.x, 450),
		Vector2(position.x, 450),
		Vector2(100 + position.x, 450),
		Vector2(200 + position.x, 450),
		Vector2(300 + position.x, 450),
		Vector2(400 + position.x, 450),
		Vector2(500 + position.x, 450)
	]
	randomize()
	var CountTime = bullet_spawn_positions.size() * 0.1
	bullet_spawn_positions.shuffle()
	for i in bullet_spawn_positions:
		var Round = Global.add_bullet(
			"Monster55Bullet", self.bullet, false, 1, position, "hit5", self.objattackDic["hit5"]
		)
		setup_bullet_collision(Round)
		RoundList.push_back(Round)
		var tween = create_tween()
		tween.tween_property(Round, "position", i, 1)
		await get_tree().create_timer(0.1, false).timeout
	await get_tree().create_timer(2, false).timeout
	for i in RoundList:
		if is_instance_valid(i):
			var tween = create_tween()
			tween.tween_property(i, "position", self.position, 1)
	await get_tree().create_timer(CountTime, false).timeout
	for i in RoundList:
		if is_instance_valid(i):
			i.queue_free()
	RoundList.clear()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
