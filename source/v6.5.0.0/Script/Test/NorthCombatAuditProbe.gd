extends "res://Script/Test/NorthMechanicsProbe.gd"

func _ready() -> void :
	call_deferred("_run")
	get_tree().create_timer(240.0).timeout.connect( func(): get_tree().quit(2))

func _run() -> void :
	Global.cd_path = ""
	Global.Is_Show = true
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	RoleProp.set_physics_process(false)
	var old_data: = PlayerData.player_data.duplicate(true)
	PlayerData.player_data["头衔"] = []
	var level: = await _level(80)
	level._spawn_runtime_ready = false
	for enemy in level.monster.get_children(): enemy.queue_free()
	level.Role_.set_physics_process(false)
	level.Role_.position = Vector2(500, 430)
	var bank: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(NorthOriginalData.ROOT + "monsters.json"))
	var action_count: = 0
	for id: String in bank:
		var actor: = await _boss(level, int(id))
		actor.position = Vector2(600, 400)
		actor._stationary_origin = actor.global_position
		actor._flight_height = actor.global_position.y
		var expected: = 0
		for key in ["attack1", "attack2", "attack3", "attack4", "effect1", "effect2", "effect3", "effect4", "effect5", "protectSkill"]:
			if not NorthOriginalData.skill(bank[id].get(key, "0")).is_empty(): expected += 1
		_check(actor._skill_actions.size() == expected, id + " 原版技能没有全部登记")
		for action: StringName in actor._skill_actions:
			action_count += 1
			_check(actor.mr_player.has_animation(action), id + " 技能动画不存在")
			var data: Dictionary = actor._skill_actions[action]["data"]
			var assets: = str(data["assetLink"]).split(",", false)
			if assets.is_empty(): continue
			_check(actor._source["sequences"].has(assets[0]), id + " 弹幕素材不存在 " + assets[0])
			for side in [-1, 1]:
				level.Role_.position = actor.position + Vector2(side * 300, 160)
				var root: = actor.global_position
				actor.to_hero()
				_check(actor.global_position == root, id + " 转向移动了模型根节点")
				_shots.clear()
				actor._standard_shot(action, data)
				for shot: Dictionary in _shots:
					var projectile: WutaiMinghaiProjectile = shot["projectile"]
					_check(projectile.visual_faces_right, id + " 素材原生朝向随人物改变")
					if projectile.orient_to_motion:
						_check(projectile.dir, id + " 箭头旋转前又翻转了一次")
						_check(is_equal_approx(projectile.middle.rotation, projectile.motion_velocity.angle()), id + " 可旋转弹幕朝向与速度不符")
					else:
						_check(projectile.dir == (actor._facing() > 0), id + " 横向弹幕没有随施法方向翻转")
					if int(bank[id]["classType"]) == 3487 or int(bank[id]["model"]) in [3481, 3500] and assets[0] in ["attack1", "attack1_1"]:
						var target: Vector2 = level.Role_.global_position - projectile.spawn_global_position
						_check(target.normalized().dot(projectile.motion_velocity.normalized()) > 0.999, id + " 索敌弹幕没有瞄准人物")
					projectile.queue_free()
		if actor.is_Fly:
			actor.position = Vector2(600, 250)
			actor._flight_height = 250
			actor._flight_bounds = Rect2(0, 0, 1200, 600)
			var original_canvas: = get_viewport().canvas_transform
			var shifted_canvas: = original_canvas
			shifted_canvas.origin.y -= 300
			get_viewport().canvas_transform = shifted_canvas
			actor._keep_in_view()
			_check(is_equal_approx(actor.position.y, 250), id + " 飞行模型跟随相机上下移动")
			get_viewport().canvas_transform = original_canvas
		actor.queue_free()
		await get_tree().process_frame
		_shots.clear()
	print("NORTH_ALL_ACTORS=", bank.size(), " ACTIONS=", action_count)

	var cold: = await _boss(level, 3372)
	cold.position = Vector2(600, 400)
	level.Role_.position = Vector2(800, 400)
	cold.to_hero()
	_shots.clear()
	var action: = _action(cold, "effect3")
	cold._standard_shot(action, cold._skill_actions[action]["data"])
	_check(_shots.size() == 1 and _shots[0]["motion"].x < 0, "辟寒大王屏幕右侧弹幕没有向左运动")
	cold.queue_free()
	await get_tree().process_frame
	_shots.clear()
	var flower: = await _boss(level, 3381)
	flower.cast_action(_action(flower, "effect1"))
	await get_tree().create_timer(0.9).timeout
	var petals: = _shots_for("effect1_1")
	_check(petals.size() == 6, "花隐妖没有三组两侧花弹")
	if petals.size() == 6:
		for i in range(0, 6, 2):
			_check(petals[i]["motion"].x < 0 and petals[i + 1]["motion"].x > 0, "花隐妖左右发射方向错误")
	flower.queue_free()
	await get_tree().process_frame
	_shots.clear()
	var eye: = await _boss(level, 3409)
	eye.cast_action(_action(eye, "effect3"))
	await get_tree().create_timer(2.2).timeout
	var rays: = _shots_for("effect2_1")
	_check(rays.size() == 6, "百眼魔君没有六枚金光")
	if rays.size() == 6:
		for i in range(0, 6, 2):
			_check(abs(int(rays[i]["time"]) - int(rays[i + 1]["time"])) < 40, "百眼魔君同组弹幕没有同时发射")
	eye.queue_free()
	await get_tree().process_frame
	_shots.clear()
	var spider: = await _boss(level, 3417)
	spider.position = Vector2(600, 400)
	spider.cast_action(_action(spider, "effect2"))
	spider._next_cast = Time.get_ticks_msec() + 600000
	spider.set_physics_process(true)
	await get_tree().create_timer(1.15).timeout
	_check(spider.position.y < 300 and spider.position.x < 450, "蜘蛛牵引技能被重力拉偏，没有移动到原版锚点")
	spider.queue_free()
	await get_tree().process_frame
	var dragon: = await _boss(level, 3499)
	dragon.cast_action(_action(dragon, "effect3"))
	dragon._next_cast = Time.get_ticks_msec() + 600000
	dragon.set_physics_process(true)
	await get_tree().create_timer(0.7).timeout
	var after_grab: = dragon.position
	level.Role_.position += Vector2(300, 150)
	await get_tree().create_timer(0.3).timeout
	_check(dragon.position == after_grab, "应龙抓取定位后仍持续跟随人物")
	await _dispose(level)
	var map: = load("res://Scene/Main_menu/Map_8.tscn").instantiate() as Map8
	get_tree().root.add_child(map)
	for number in range(76, 86):
		PlayerData.player_data.erase("北俱芦洲通关_%d" % number)
		PlayerData.player_data.erase(map.MAP_LEVEL_NAMES[number])
	PlayerData.player_data["云川"] = 1
	map._update_level_progression()
	_check(map.get_node("Level_76").material is ShaderMaterial, "默认没有高亮苍梧渊")
	PlayerData.player_data["北俱芦洲通关_76"] = 1
	map._update_level_progression()
	_check(map.get_node("Level_76").material == null and map.get_node("Level_77").material is ShaderMaterial, "高亮没有随通关切到寒山坡")
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.codex_tmp/north_map_highlight.png")
	map.queue_free()
	PlayerData.player_data = old_data
	print("NORTH_COMBAT_AUDIT_CHECKS=", _checks, " FAILURES=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)
