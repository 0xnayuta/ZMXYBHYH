extends "res://Script/Test/NorthMechanicsProbe.gd"

func _run() -> void :
	Global.cd_path = ""
	Global.Is_Show = true
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["CurrentLevelPage"] = 8
	RoleProp.set_physics_process(false)
	var old_data: = PlayerData.player_data.duplicate(true)
	PlayerData.player_data["头衔"] = []
	var level: = await _level(76)
	level.set_physics_process(false)
	for actor in level.monster.get_children(): actor.queue_free()
	level.Role_.position = Vector2(600, 380)
	level.Role_.velocity = Vector2.ZERO
	await get_tree().create_timer(1.0).timeout
	_check(level.Role_.is_on_floor(), "苍梧渊顶部原版平台不能落地")
	_check(absf(level.Role_.position.y + 39 - 520) < 8, "顶部落点不在原版520高度")
	Input.action_press("move_right")
	await get_tree().create_timer(0.25).timeout
	Input.action_release("move_right")
	_check(level.Role_.is_on_floor(), "顶部平台行走掉落")
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.codex_tmp/north_summit_fixed.png")
	var bird: = await _boss(level, 3356)
	bird.global_position = level.Role_.global_position + Vector2(340, -220)
	bird._next_cast = 0
	bird.set_physics_process(true)
	var casts: Array[int] = []
	bird.source_skill_cast.connect( func(id): casts.append(id))
	level.Role_.needProtect = false
	var hp_before: float = RoleProp.roleprop.Hp
	await get_tree().create_timer(4.0).timeout
	_check( not casts.is_empty(), "雪鸟主动AI不能接近并攻击")
	_check(RoleProp.roleprop.Hp < hp_before, "雪鸟攻击没有造成实际伤害")
	var bird_y: = bird.position.y
	level.Role_.set_physics_process(false)
	level.Role_.position.y -= 200
	await get_tree().physics_frame
	_check(absf(bird.position.y - bird_y) < 10, "雪鸟模型瞬间跟随人物位移")
	level.Role_.position = Vector2(800, 481)
	bird.queue_free()
	var snow: = await _boss(level, 3357)
	snow.global_position = Vector2(500, 520)
	var action: = _action(snow, "effect2")
	snow.cast_action(action)
	await get_tree().create_timer(1.4).timeout
	var balls: = _shots_for("effect2_1")
	_check(balls.size() == 1, "雪人没有按40帧发出雪球")
	if not balls.is_empty():
		var ball = balls[0]["projectile"]
		_check(is_instance_valid(ball) and ball.motion_acceleration.y == 990, "雪球没有原版重力")
		var rose: = false
		var fell: = false
		var impacted: = false
		for i in range(32):
			if is_instance_valid(ball):
				rose = rose or ball.motion_velocity.y < 0
				fell = fell or ball.motion_velocity.y > 0
				impacted = impacted or ball._impacting and absf(ball.global_position.y - 520) < 2
			await get_tree().create_timer(0.05).timeout
		_check(rose and fell, "雪球不会经过顶点向下落")
		_check(impacted, "雪球落地没有切换原版爆裂效果")
		_check(_shots_for("effect2_2").size() == 1, "雪球落地爆裂没有独立伤害判定")

	var records: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(NorthOriginalData.ROOT + "monsters.json"))
	var tested: = {}
	for raw_id in records:
		var raw: Dictionary = records[raw_id]
		for key in ["attack1", "attack2", "effect1", "effect2", "effect3", "effect4", "effect5"]:
			var skill: = NorthOriginalData.skill(raw.get(key, "0"))
			if skill.get("gravity", "0") != "1" or tested.has(skill["id"]): continue
			var actor: = await _boss(level, int(raw_id))
			var attack: = _action(actor, key)
			_shots.clear()
			actor._standard_shot(attack, skill)
			for shot in _shots:
				_check(shot["projectile"].motion_acceleration.y == 990, "重力技能漏接: " + str(skill["id"]))
			tested[skill["id"]] = true
			actor.queue_free()
	print("NORTH_PHYSICS_GRAVITY_SKILLS ", tested.size())
	PlayerData.player_data = old_data
	await _dispose(level)
	print("NORTH_PHYSICS_PROBE ", _checks, " checks failures=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)
