extends "res://Script/Test/NorthMechanicsProbe.gd"

func _feet(hero: BaseHero) -> float:
	var collider: = hero.get_node("pz") as CollisionShape2D
	return collider.global_position.y + collider.shape.get_rect().end.y * absf(collider.global_scale.y)

func _run() -> void :
	Global.cd_path = ""
	Global.Is_Show = true
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	RoleProp.set_physics_process(false)
	var old_data: = PlayerData.player_data.duplicate(true)
	PlayerData.player_data["头衔"] = []
	for role_id in range(1, 7):
		PlayerData.player_data["Myself"] = role_id
		var level: = await _level(81)
		level.set_physics_process(false)
		for actor in level.monster.get_children(): actor.queue_free()
		await get_tree().process_frame
		var hero: = level.Role_ as BaseHero
		hero.position = Vector2(4400, 390)
		hero.velocity = Vector2.ZERO
		await get_tree().create_timer(0.5).timeout
		_check(hero.is_on_floor(), "%d 正常空间参照平台不能站立" % role_id)
		var return_pos: = hero.position
		var boss: = await _boss(level, 3422)
		var terrain: = level.get_node("OriginalTerrain")
		var hp_before: = int(RoleProp.roleprop.Hp)
		for cycle in range(2):
			boss._void_hit(null, hero)
			_check(level.in_void_space and _feet(hero) < 641, "%d 传送落点压进平台" % role_id)
			_check(hero.velocity == Vector2.ZERO, "传送残留下落速度")
			await get_tree().process_frame
			for actor in level._void_units: actor.set_physics_process(false)
			await get_tree().create_timer(0.55).timeout
			_check(hero.is_on_floor() and absf(_feet(hero) - 641) < 2, "%d 空间平台未接住角色" % role_id)
			var platform_art: = terrain._backgrounds["bg31"] as Sprite2D
			_check(absf(platform_art.to_global(Vector2(0, terrain.VOID_ART_FLOOR_Y)).y - _feet(hero)) < 2, 
				"人物脚底与画面上的平台错位")
			_check(level.my_camera.zoom == Vector2.ONE, "进入空间放大了游戏画面")
			_check( not hero.IsDeath and int(RoleProp.roleprop.Hp) == hp_before, "%d 进入空间死亡或受地图伤害" % role_id)
			_check( not terrain._void_floor.get_child(0).one_way_collision and not terrain._void_floor.get_child(0).disabled, 
				"空间平台仍为单向平台或未启用")
			Input.action_press("move_right")
			await get_tree().create_timer(0.2).timeout
			Input.action_release("move_right")
			Input.action_press("down")
			await get_tree().create_timer(0.2).timeout
			Input.action_release("down")
			_check(hero.is_on_floor() and not hero.IsDeath, "空间平台走动或按S会穿落")
			if role_id == 1 and cycle == 0:
				await RenderingServer.frame_post_draw
				get_viewport().get_texture().get_image().save_png("res://.codex_tmp/north_void_landing_fixed.png")
			hero.set_physics_process(false)
			hero.position.y = 690
			terrain._physics_process(0.6)
			_check(int(RoleProp.roleprop.Hp) == hp_before, "空间仍触发正常地图659高度的伤害区域")
			for actor in level._void_units: actor.Hp = 0
			level._physics_process(0.0)
			_check( not level.in_void_space and hero.position.is_equal_approx(return_pos), "清完四只怪未返回原位置")
			_check( not hero.SXYRCannotCure and boss.visible, "返回未恢复治疗和Boss")
			await get_tree().process_frame
			_check(terrain._void_floor.get_child(0).disabled, "返回后空间平台未关闭")
			boss.set_physics_process(false)
			for actor in level._void_units: actor.queue_free()
			hero.set_physics_process(true)
			await get_tree().create_timer(0.2).timeout
			_check(hero.is_on_floor() and not hero.IsDeath, "返回正常空间穿过原平台")
		await _dispose(level)
	PlayerData.player_data = old_data
	print("NORTH_VOID_LANDING_CHECKS=", _checks, " FAILURES=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)
