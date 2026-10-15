extends Node

var _failures: Array[String] = []
var _checks: = 0
var _spawns: Dictionary = {}
var _spawned: Array[WutaiMinghaiProjectile] = []
var _boss: EastContinentMonster
var _hero: BaseHero

func _ready() -> void :
	call_deferred("_run")
	get_tree().create_timer(120.0).timeout.connect( func(): get_tree().quit(2))

func _check(condition: bool, message: String) -> void :
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("PALACE_BOSS_FAIL " + message)

func _run() -> void :
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["MonsterBloodSHow"] = false
	RoleProp.set_physics_process(false)
	PlayerData.player_data["头衔"] = []
	Global.Is_Show = true
	for number in [73, 74]:
		var level: = (load("res://Scene/Level/Level_%d.tscn" % number) as PackedScene).instantiate() as Game4EastLateLevel
		add_child(level)
		await get_tree().create_timer(0.5).timeout
		level.create_control.stop()
		level.set_physics_process(false)
		for mob in level.monster.get_children():
			mob.queue_free()
		var hero = level.Role_
		hero.SXYRCannotCure = true
		hero.set_meta("pet_turtle_link_unit_ref", false)
		hero.needProtect = false
		RoleProp.roleprop.SHp = 100000000
		RoleProp.roleprop.Hp = 100000000
		level._screen_left_wall.disabled = true
		level._screen_right_wall.disabled = true
		if number == 73:
			hero.position = Vector2(70, 360)
			hero.velocity = Vector2.ZERO
			await get_tree().create_timer(0.75).timeout
			var lowest: float = hero.position.y
			Input.action_press("move_right")
			await get_tree().create_timer(2.5).timeout
			Input.action_release("move_right")
			_check(hero.position.x > 600, "人物不能直接走上金玉宫坡顶 x=%.1f" % hero.position.x)
			_check(hero.position.y < lowest - 90, "走路时没有沿坡升高")
			_check(hero.jump_count == 0 and not hero.IsDeath, "走坡依赖跳跃或出现死亡")
		hero.position = Vector2(4250, 440)
		hero.velocity = Vector2.ZERO
		await get_tree().create_timer(0.5).timeout
		hero.set_physics_process(false)
		level.my_camera.max_left = 3784.0
		level.my_camera.max_right = 5000.0
		level.my_camera.max_top = 0.0
		level.my_camera.max_bottom = 900.0
		level.my_camera.position_smoothing_enabled = false
		level.my_camera.reset_smoothing()
		await get_tree().process_frame
		var id: = 3323 if number == 73 else 3343
		await Global.preload_level_monster_runtime_resources([id])
		var pages: Array = MonsterAtlasSequence.manifest_data("res://Art/Monster/PalaceBoss/%d/manifest.json" % id)["pages"]
		for page: Dictionary in pages:
			_check(Global._texture_cache.has(page["path"]), "%d 实际模型图集没有在出场前加载" % id)
		var spawn_start: = Time.get_ticks_usec()
		var boss: = (load("res://Scene/Monster/Monster_%d.tscn" % id) as PackedScene).instantiate() as EastContinentMonster
		boss.position = Vector2(4680, 220)
		level.monster.add_child(boss)
		var spawn_ms: = (Time.get_ticks_usec() - spawn_start) / 1000.0
		print("PALACE_BOSS_SPAWN id=%d ready_ms=%.2f pages=%d" % [id, spawn_ms, pages.size()])
		_check(spawn_ms < 150.0, "%d 出场仍然长时间阻塞 %.2fms" % [id, spawn_ms])
		_boss = boss
		_hero = hero
		boss.get_node("change_state").stop()
		await get_tree().create_timer(0.3).timeout
		boss._ready_to_fight = true


		boss.mysee = -1
		boss.skill_projectile_spawned.connect(_on_spawn)
		_check(boss.mr_ani.sprite_frames.get_frame_count(&"hit4") > 0, "%d 原版第四技能未接入" % id)
		if id == 3343:
			_check(boss.mr_ani.sprite_frames.get_frame_count(&"hit5") == 72, "祖巫第五技能动作错误")
			_check(boss._palace_data["geometry"]["wait"]["source_symbol"] == "mc_idle", "祖巫没有使用原版复合模型")
		_check(boss.hurt_box.shape.size.y > 140, "%d 受击框仍然是小怪尺寸" % id)
		for edge in [Vector2(-10000, -10000), Vector2(10000, 10000)]:
			boss.global_position = edge
			boss._keep_in_view()
			_check_model_visible(boss)
		boss.global_position.x = 4670
		boss._keep_in_view()
		var flight_y: float = boss.global_position.y
		var hero_y: float = hero.global_position.y
		for jump_y in [hero_y - 180.0, hero_y + 120.0, hero_y]:
			hero.global_position.y = jump_y
			boss._keep_in_view()
			_check(is_equal_approx(boss.global_position.y, flight_y), "Boss 高度仍然跟随角色跳动")
		hero.global_position.y = hero_y
		await _screenshot("palace_boss_%d_idle" % id)
		for skill in range(1, 5 if id == 3323 else 6):
			_spawns.clear()
			_spawned.clear()
			for projectile in boss.bullet.get_children():
				projectile.queue_free()
			boss._start_palace_attack(StringName("hit%d" % skill))
			if id == 3343 and skill in [2, 3, 4]:
				await get_tree().create_timer(0.35).timeout


				var side: = -1.0 if boss.MonsterDirection else 1.0
				hero.global_position = boss.global_position + Vector2(side * 300, -420 if skill == 4 else -80)
				if skill == 2:
					await get_tree().create_timer(0.55).timeout
					hero.global_position.x = boss.global_position.x - side * 300
					await get_tree().create_timer(0.05).timeout
				else:
					await get_tree().create_timer(0.6).timeout
			else:
				await get_tree().create_timer(0.95).timeout
			_check_model_visible(boss)
			await _screenshot("palace_boss_%d_skill%d" % [id, skill])
			var duration: = boss.mr_player.get_animation(StringName("hit%d" % skill)).length
			if id == 3323 and skill == 3:
				duration = 0.4 + 1.0 + 11.0 / 30.0
			await get_tree().create_timer(maxf(duration - 0.95, 0.0) + 0.2).timeout
			if id == 3323:
				if skill == 2:
					_check(_spawns.get("effect2_1", 0) == 1, "鹏风释放数量错误")
				elif skill == 3:
					_check(_spawns.get("effect3_1", 0) == 1 and not boss._3323_skill3_invincible, "食尽诸龙结束后未恢复可受击")
				elif skill == 4:
					_check(_spawns.get("effect4_1", 0) == 8, "化羽为剑不是八方向")
			else:
				if skill == 2:
					_check(_spawns.get("effect2_1", 0) == 3 and _spawns.get("effect2_2", 0) == 3, "阴阳闪电球不是各三个")
				elif skill in [3, 4]:
					_check(_spawns.get("effect%d_1" % skill, 0) == 1, "祖巫定向闪电未释放")
				elif skill == 5:
					await get_tree().create_timer(1.5).timeout
					_check(_spawns.get("effect5_1", 0) == 5 and _spawns.get("effect5_2", 0) == 5, "雷霆万钧列数或阴阳交替错误")
			_check_model_visible(boss)
			_check( not boss.is_attacking, "技能结束后 Boss 卡在攻击状态")


		var sequence: = "effect2_1" if id == 3323 else "effect4_1"
		var action: = &"hit2" if id == 3323 else &"hit4"
		var origin: Vector2 = hero.global_position + Vector2(-150, 0)
		var probe: WutaiMinghaiProjectile = boss._projectile(sequence, action, origin, Vector2.ZERO, 1.0)
		await get_tree().process_frame
		var data: Array = boss._palace_data["masks"][sequence]
		var active: = 0
		while active < data.size() and data[active].is_empty():
			active += 1
		var mask: Array = data[active]
		probe._elapsed = active / 30.0
		probe.set_physics_process(false)
		probe._sync_collision_to_visual_frame(true)
		probe.hit_box.set_deferred("monitoring", true)
		var rect: = Rect2(float(mask[0]), float(mask[1]), float(mask[2]), float(mask[3]))
		hero.global_position = origin + rect.get_center() + Vector2(0, 45)
		RoleProp.roleprop.Hp = 100000000
		RoleProp.roleprop.Mdef = 0
		hero.IsDeath = false
		await get_tree().create_timer(0.15).timeout
		_check(int(RoleProp.roleprop.Hp) < 100000000, "%d 技能原版伤害框没有命中真实角色" % id)
		level.queue_free()
		await get_tree().process_frame
	print("PALACE_BOSS_ORIGINAL_PROBE %s checks=%d failures=%d" % ["OK" if _failures.is_empty() else "FAIL", _checks, _failures.size()])
	get_tree().quit(0 if _failures.is_empty() else 1)

func _on_spawn(sequence: String, projectile: WutaiMinghaiProjectile) -> void :
	_spawns[sequence] = int(_spawns.get(sequence, 0)) + 1
	_spawned.append(projectile)
	_check( not projectile.track_target, "原版定向技能错误变成追踪弹")
	if _boss.monster_kind != 3343:
		return
	if sequence in ["effect3_1", "effect4_1"] and not projectile.motion_velocity.is_zero_approx():
		var center: Vector2 = _boss._target_hurt_rect(_hero.global_position).get_center()
		var expected: = projectile.global_position.direction_to(center)
		_check(projectile.motion_velocity.normalized().dot(expected) > 0.999, 
			"闪电未朝发射时人物位置瞄准")
		_check(is_equal_approx(projectile.middle.rotation, projectile.motion_velocity.angle())
			and projectile.visual_faces_right == projectile.dir, "闪电画面方向与伤害方向不一致")
	elif sequence in ["effect2_1", "effect2_2"]:
		var origin: = projectile.global_position
		var fall_time: = (771.0 + sqrt(maxf(0.0, 771.0 * 771.0 + 1980.0 * (_hero.global_position.y - origin.y)))) / 990.0
		var landing_x: = origin.x + projectile.motion_velocity.x * fall_time
		_check(absf(landing_x - _hero.global_position.x) <= 126.0, 
			"阴阳闪电球仍然朝固定距离发射")
		_check_ball_heading(projectile)
		_check_ball_descent(projectile)

func _check_ball_heading(projectile: WutaiMinghaiProjectile) -> void :
	var drawn_direction: = Vector2.RIGHT.rotated(projectile.middle.global_rotation)
	_check(drawn_direction.dot(projectile.motion_velocity.normalized()) > 0.999
		and projectile.visual_faces_right == projectile.dir, 
		"蓝红电球图案亮头没有朝飞行方向")

func _check_ball_descent(projectile: WutaiMinghaiProjectile) -> void :
	await get_tree().create_timer(0.95).timeout
	if is_instance_valid(projectile) and not projectile._impacting:
		_check_ball_heading(projectile)

func _check_model_visible(boss) -> void :
	var view: Rect2 = boss.visible_battle_rect()
	var geometry: Dictionary = boss._palace_data["geometry"]["wait"]
	var origin: Array = geometry["origin"]
	var size: Array = geometry["size"]
	var min_x: = float(origin[0]) if not boss.MonsterDirection else - float(origin[0]) - float(size[0])
	var rect: = Rect2(boss.global_position + Vector2(min_x, float(origin[1])) * boss.scale, 
		Vector2(float(size[0]), float(size[1])) * boss.scale)
	_check(view.grow(2).encloses(rect), "Boss 模型飞出镜头范围 view=%s boss=%s" % [view, rect])

func _screenshot(filename: String) -> void :
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.codex_tmp/" + filename + ".png")
