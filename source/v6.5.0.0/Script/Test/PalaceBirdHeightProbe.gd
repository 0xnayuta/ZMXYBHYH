extends "res://Script/Test/NorthMechanicsProbe.gd"

func _run() -> void :
	Global.cd_path = ""
	Global.Is_Show = true
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	RoleProp.set_physics_process(false)
	var old_data: = PlayerData.player_data.duplicate(true)
	PlayerData.player_data["头衔"] = []
	var level: = load("res://Scene/Level/Level_74.tscn").instantiate() as Game4EastLateLevel
	get_tree().root.add_child(level)
	get_tree().current_scene = level
	await get_tree().create_timer(0.8).timeout
	level.create_control.stop()
	level.set_physics_process(false)
	level.get_node("OriginalTerrain").set_physics_process(false)
	level._screen_left_wall.disabled = true
	level._screen_right_wall.disabled = true
	for unit in level.monster.get_children(): unit.queue_free()
	await get_tree().process_frame
	var hero: = level.Role_ as BaseHero
	hero.set_physics_process(false)
	hero.needProtect = false
	hero.set_meta("pet_turtle_link_unit_ref", false)
	RoleProp.roleprop.SHp = 100000000
	RoleProp.roleprop.Def = 0
	RoleProp.roleprop.Mdef = 0
	RoleProp.roleprop.Miss = 0
	for positions in [Vector2(520, 100), Vector2(220, 500)]:
		hero.position = Vector2(650, positions.x)
		RoleProp.role_pos = hero.global_position
		RoleProp.role_pos_x = hero.global_position.x
		RoleProp.role_pos_y = hero.global_position.y
		RoleProp.roleprop.Hp = 100000000
		var bird: = Global.Create_Monster(3342, level.monster, Vector2(800, positions.y)) as EastContinentMonster
		await get_tree().process_frame
		_check(bird.monster_kind == 3309 and bird.is_Fly, "浮天台琉璃鸟映射或飞行设置错误")
		_check( not bird._fixed_flight_height_ready, "琉璃鸟仍锁在出生高度")
		var started: = Time.get_ticks_msec()
		var saw_attack: = false
		while Time.get_ticks_msec() - started < 7000 and int(RoleProp.roleprop.Hp) == 100000000:
			await get_tree().physics_frame
			saw_attack = saw_attack or bird.is_attacking
		_check(saw_attack, "不同高度的琉璃鸟没有进入攻击")
		_check(int(RoleProp.roleprop.Hp) < 100000000, "琉璃鸟追近后没有命中人物")
		_check(bird.position.y > positions.y + 50 if positions.x > positions.y else bird.position.y < positions.y - 50, 
			"琉璃鸟没有按人物高度升降")
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.codex_tmp/palace_bird_height_%d.png" % int(positions.x))
		bird.queue_free()
		await get_tree().process_frame
	level.queue_free()
	await get_tree().process_frame
	PlayerData.player_data = old_data
	print("PALACE_BIRD_HEIGHT_CHECKS=", _checks, " FAILURES=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)
