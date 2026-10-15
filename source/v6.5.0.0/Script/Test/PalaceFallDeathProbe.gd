extends Node

var _failures: Array[String] = []
var _checks: = 0

func _ready() -> void :
	call_deferred("_run")

func _check(condition: bool, message: String) -> void :
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("PALACE_FALL_FAIL " + message)

func _run() -> void :


	get_tree().current_scene = null
	get_tree().create_timer(40.0).timeout.connect( func(): get_tree().quit(2))
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	RoleProp.set_physics_process(false)
	PlayerData.player_data["头衔"] = []
	Global.Is_Show = true
	var levels: = [74] if "--futiantai-only" in OS.get_cmdline_user_args() else [72, 73, 74]
	for number in levels:
		var level: = load("res://Scene/Level/Level_%d.tscn" % number).instantiate() as Game4EastLateLevel
		get_tree().root.add_child(level)
		get_tree().current_scene = level
		await get_tree().create_timer(0.5).timeout
		level.create_control.stop()
		level.set_physics_process(false)
		for mob in level.monster.get_children():
			mob.queue_free()
		var hero: BaseHero = level.Role_
		hero.SXYRCannotCure = true
		hero.needProtect = true
		hero.IsIndestructible = true
		hero.IsIndestructible1 = true
		hero.set_meta("pet_turtle_link_unit_ref", false)
		RoleProp.roleprop.SHp = 1000000
		RoleProp.roleprop.Hp = 1000000
		Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE, true)
		hero.effect_reducehp(100000000, "real")
		_check(int(RoleProp.roleprop.Hp) == 1000000, "免伤测试前提未生效")
		if number == 72:
			hero.position = Vector2(1310, 400)
		elif number == 73:
			hero.position = Vector2(500, 610)
		else:

			hero.position = Vector2(575, 1100)
		hero.velocity = Vector2(0, 240)
		var terrain: = level.get_node("OriginalTerrain")
		var seconds: = 0.0
		while not hero.IsDeath and seconds < 1.5:
			await get_tree().create_timer(0.05).timeout
			seconds += 0.05
		_check(hero.IsDeath and int(RoleProp.roleprop.Hp) == 0, "%d 掉入死亡区后没有死亡" % number)
		_check(hero.position.y > float(terrain._death_y) - 100.0, "%d 未实际落入死亡区" % number)
		_check(hero.get_action == "death", "%d 未进入正常死亡动作" % number)
		level.my_camera.max_top = 0.0
		level.my_camera.max_bottom = 900.0
		level.my_camera.max_left = maxf(0.0, hero.position.x - 600.0)
		level.my_camera.max_right = level.my_camera.max_left + 1200.0
		level.my_camera.position_smoothing_enabled = false
		level.my_camera.reset_smoothing()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.codex_tmp/palace_fall_%d.png" % number)
		seconds = 0.0
		while seconds < 8.0 and (get_tree().current_scene == null or get_tree().current_scene.scene_file_path != "res://Scene/Level/defeat.tscn"):
			await get_tree().create_timer(0.1).timeout
			seconds += 0.1
		_check(get_tree().current_scene != null and get_tree().current_scene.scene_file_path == "res://Scene/Level/defeat.tscn", 
			"%d 坠落死亡后没有进入失败场景" % number)
		Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE, false)
		if get_tree().current_scene != null:
			get_tree().current_scene.queue_free()
		get_tree().current_scene = null
		if is_instance_valid(level):
			level.queue_free()
		await get_tree().process_frame
	print("PALACE_FALL_DEATH_PROBE %s checks=%d failures=%d" % ["OK" if _failures.is_empty() else "FAIL", _checks, _failures.size()])
	get_tree().quit(0 if _failures.is_empty() else 1)
