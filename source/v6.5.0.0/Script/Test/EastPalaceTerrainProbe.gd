extends Node

var _failures: Array[String] = []
var _checks: = 0

func _ready() -> void :
	call_deferred("_run")
	get_tree().create_timer(100.0).timeout.connect( func(): get_tree().quit(2))

func _check(condition: bool, message: String) -> void :
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error(message)

func _run() -> void :
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	Global.Is_Show = true
	RoleProp.set_physics_process(false)
	PlayerData.player_data["头衔"] = []
	for number in [72, 73, 74]:
		var level: = (load("res://Scene/Level/Level_%d.tscn" % number) as PackedScene).instantiate() as Game4EastLateLevel
		add_child(level)
		await get_tree().create_timer(0.5).timeout
		level.create_control.stop()
		level.set_physics_process(false)
		for mob in level.monster.get_children():
			mob.queue_free()
		var terrain: = level.get_node("OriginalTerrain")
		var hero = level.Role_
		hero.SXYRCannotCure = true
		hero.needProtect = false
		RoleProp.roleprop.SHp = 10000000
		RoleProp.roleprop.Hp = 10000000
		RoleProp.roleprop.Mdef = 0
		level._screen_left_wall.disabled = true
		level._screen_right_wall.disabled = true
		_check(level.get_node("wall/floor").disabled, "%d 平路仍然启用" % number)
		_check(level.hero.position == Vector2.ZERO and level.monster.position == Vector2.ZERO, "原版坐标被父节点偏移")
		_check(level._birth_points().size() == (21 if number == 73 else 19), "%d 出生点数量错误" % number)
		var dependency: Dictionary = level._birth_points().filter( func(p): return not p["after_all_dead"].is_empty())[0]
		_check( not level._point_dependency_satisfied(dependency), "前置敌人未消灭就开放后续批次")
		if number == 72:
			_check(terrain._hidden_platforms.size() == 14, "隐藏桥块数量错误")
			await _land(hero, Vector2(600, 350), 510.8)
			await _land(hero, Vector2(1500, 350), 511.0)
			await get_tree().physics_frame
			var hidden: Dictionary = terrain._hidden_platforms.filter( func(p): return is_equal_approx(p["rect"].position.x, 1421.0))[0]
			_check(hidden["sprite"].visible, "踩上隐藏踏板后没有显形")
			level.my_camera.max_left = 900.0
			level.my_camera.max_right = 2100.0
			level.my_camera.position_smoothing_enabled = false
			level.my_camera.reset_smoothing()
			await get_tree().create_timer(0.15).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://.codex_tmp/palace_platform_actor_layer.png")
			hero.position = Vector2(1500, 260)
			await get_tree().create_timer(0.2).timeout
			_check( not hidden["sprite"].visible, "离开踏板后没有隐藏")
			hero.position = Vector2(1310, 400)
			hero.velocity = Vector2.ZERO
			await get_tree().create_timer(0.25).timeout
			_check( not hero.is_on_floor(), "桥间缺口仍有平路碰撞")
			RoleProp.roleprop.Hp = 10000000
			hero.IsDeath = false
			await _land(hero, Vector2(1500, 350), 511.0)
			await _test_down(hero)
		elif number == 73:
			_check(terrain._hazards.size() == 4, "电桥数量错误")
			await _land(hero, Vector2(500, 250), 388.0)
			await _land(hero, Vector2(170, 300), 467.0, 15.0)
			await _land(hero, Vector2(500, 250), 388.0)
			await _test_hazard(terrain, hero)
			await _land(hero, Vector2(500, 250), 388.0)
			await _test_down(hero)
			hero.IsDeath = false
			RoleProp.roleprop.Hp = 10000000
			var point: Dictionary = level._birth_points().filter( func(p): return int(p["monster"]) == 3320)[0].duplicate(true)
			point["position"] = Vector2(70, 350)
			var state: Dictionary = level._point_states[int(point["point"])]
			_check(level._spawn_birth_point_unit(point, state), "金玉宫坡面测试小怪生成失败")
			var mob: BaseMonster = state["instances"].back()
			hero.position = Vector2(900, 400)
			hero.set_physics_process(false)
			await get_tree().create_timer(0.8).timeout
			var initial_y: = mob.position.y
			await get_tree().create_timer(3.0).timeout
			_check(mob.position.x > 480 and mob.position.y < initial_y - 50, 
				"金玉宫小怪不能直接沿坡走上去 position=%s" % mob.position)
			mob.queue_free()
			hero.set_physics_process(true)
			await _land(hero, Vector2(4050, 350), 509.0)
		else:
			_check(terrain._hazards.size() == 7, "升高平台数量错误")
			_check(level._screen_right_wall.position.y + level._screen_right_wall.shape.size.y * 0.5 > 1280.0, 
				"浮天台分段边界没有覆盖低处平台")
			var point: Dictionary = level._birth_points()[0]
			var state: Dictionary = level._point_states[int(point["point"])]
			_check(level._spawn_birth_point_unit(point, state), "浮天台无法按原版刷怪点生成怪物")
			var mob: BaseMonster = state["instances"].back()
			await get_tree().create_timer(0.8).timeout
			_check(mob.position.y > 800.0, "高地图怪物被重置到旧地面")
			_check(mob.get_collision_mask_value(21), "行走怪物未启用原版悬崖阻挡")
			var edge: = terrain.get_node("SourceObject43") as StaticBody2D
			_check(edge.collision_layer == (1 << 20) and not (edge.get_child(0) as CollisionShape2D).one_way_collision, 
				"悬崖护栏未形成敌人专用横向阻挡")
			mob.queue_free()
			for index in range(7):
				var rect: Array = terrain.source_data["objects"].filter( func(o): return int(o["id"]) == 27 + index)[0]["rect"]
				await _land(hero, Vector2(float(rect[0]) + 280, float(rect[1]) - 180), float(rect[1]))
				_check(hero.position.y > 800 or index > 2, "浮天台前半程坐标被强制重置")
			await _land(hero, Vector2(340, 850), 1098.0)
			Input.action_press("move_right")
			hero.jump()
			await get_tree().create_timer(0.45).timeout
			hero.jump()
			await get_tree().create_timer(1.2).timeout
			Input.action_release("move_right")
			print("PALACE_JUMP position=%s velocity=%s on_floor=%s" % [hero.position, hero.velocity, hero.is_on_floor()])
			_check(hero.position.x > 551 and hero.is_on_floor(), "实际二段跳无法跨越第一处台阶缺口")
			await _land(hero, Vector2(4050, 350), 516.0)
			await _test_down(hero)
		level.my_camera.max_left = maxf(0.0, hero.position.x - 600.0)
		level.my_camera.max_right = level.my_camera.max_left + 1200.0
		level.my_camera.max_top = 0.0
		level.my_camera.max_bottom = 1280.0 if number == 74 else 640.0
		level.my_camera.reset_smoothing()
		await get_tree().create_timer(0.4).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.codex_tmp/east_terrain_%d.png" % number)
		level.queue_free()
		await get_tree().process_frame
	print("EAST_PALACE_TERRAIN_PROBE %s checks=%d failures=%d" % ["OK" if _failures.is_empty() else "FAIL", _checks, _failures.size()])
	get_tree().quit(0 if _failures.is_empty() else 1)

func _land(hero, position: Vector2, surface_y: float, tolerance: float = 2.0) -> void :
	hero.position = position
	hero.velocity = Vector2.ZERO
	await get_tree().create_timer(0.75).timeout
	if surface_y >= 0.0:
		var shape: = hero.get_node("pz") as CollisionShape2D
		var bottom: = shape.global_position.y + shape.shape.get_rect().end.y
		_check(hero.is_on_floor() and absf(bottom - surface_y) < tolerance, 
			"落地失败 position=%s feet=%.2f expected=%.2f" % [str(hero.position), bottom, surface_y])

func _test_down(hero) -> void :
	var start_y: float = hero.position.y
	Input.action_press("down")
	await get_tree().create_timer(0.65).timeout
	Input.action_release("down")
	_check(hero.is_on_floor() and absf(hero.position.y - start_y) < 2.0 and not hero.IsDeath, 
		"按 S 穿下地形 start=%.1f position=%s" % [start_y, hero.position])
	_check(hero.get_collision_mask_value(6), "按 S 关闭了地形碰撞")

func _test_hazard(terrain, hero) -> void :
	hero.set_physics_process(false)
	var hazard: Dictionary = terrain._hazards[0]
	var sprite: AnimatedSprite2D = hazard["sprite"]
	sprite.pause()
	var frames: Array = hazard["data"]["hits"]
	var active: = -1
	for index in range(frames.size()):
		if not frames[index].is_empty():
			active = index
			break
	_check(active >= 0, "原版伤害帧丢失")
	sprite.frame = active
	var hit: Array = frames[active]
	hero.position = hazard["origin"] + Vector2(float(hit[0]) + float(hit[2]) * 0.5, float(hit[1]) + float(hit[3]) * 0.5)
	var before: = int(RoleProp.roleprop.Hp)
	await get_tree().create_timer(0.1).timeout
	_check(int(RoleProp.roleprop.Hp) < before, "电桥有效动画帧没有造成伤害")
	before = int(RoleProp.roleprop.Hp)
	await get_tree().create_timer(0.15).timeout
	_check(int(RoleProp.roleprop.Hp) == before, "电桥忽略原版500毫秒命中间隔")
	hero.set_physics_process(true)
	sprite.play()
