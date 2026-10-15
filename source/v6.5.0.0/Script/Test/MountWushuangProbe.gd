extends SceneTree

var failures: Array[String] = []

func _initialize() -> void :
	call_deferred("_run")

func _run() -> void :
	var player_data: = root.get_node_or_null("PlayerData")
	var role_prop: = root.get_node_or_null("RoleProp")
	_check(player_data != null and role_prop != null, "mount Wushuang autoload missing")
	if player_data == null or role_prop == null:
		_finish()
		return
	var old_data: Dictionary = player_data.player_data.duplicate(true)
	var old_ws_value: Variant = role_prop.ws_value
	var old_ws_state: Variant = role_prop.is_ws_state
	player_data.player_data["时装"] = []
	player_data.player_data["通天教主"] = 1
	player_data.call("ensure_mount_data")
	player_data.call("add_dj", "139300021", 1)
	player_data.call("unlock_mount", "1004700")
	player_data.call("set_active_mount", "1004700")
	var scene: = load("res://Scene/Hero/Role_6/Role_6.tscn") as PackedScene
	_check(scene != null, "NeZha scene missing")
	if scene != null:
		var hero = scene.instantiate()
		root.add_child(hero)
		await process_frame
		var runtime: = Node.new()
		runtime.name = "MountRuntime"
		runtime.set_script(load("res://Script/Mount/MountRuntime.gd"))
		hero.add_child(runtime)
		runtime.call("setup", hero)
		await process_frame
		await process_frame
		_check(runtime != null, "NeZha mount runtime missing")
		if runtime != null:
			runtime.call("_set_riding", true)
			runtime.call("process_mounted_control", 0.016)
			role_prop.ws_value = role_prop.max_ws_value
			role_prop.is_ws_state = false
			_check( not hero.is_using_skills, "mounted NeZha is stuck in skill state")
			_check(hero.WSSkill(), "mounted NeZha cannot activate Wushuang")
			_check(role_prop.is_ws_state, "mounted NeZha Wushuang state did not start")
		hero.queue_free()
	player_data.player_data = old_data
	role_prop.ws_value = old_ws_value
	role_prop.is_ws_state = old_ws_state
	_finish()

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _finish() -> void :
	if failures.is_empty():
		print("MOUNT_WUSHUANG_PROBE_OK")
	else:
		for failure in failures:
			push_error("MOUNT_WUSHUANG_PROBE_FAIL: %s" % failure)
	quit(0 if failures.is_empty() else 1)
