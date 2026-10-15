extends "res://Script/Test/NorthMechanicsProbe.gd"

func _first_visual(node: Node) -> Node2D:
	for child in node.get_children():
		if child is Sprite2D or child is AnimatedSprite2D: return child
		var found: = _first_visual(child)
		if found != null: return found
	return null

func _node_count(node: Node) -> int:
	var count: = 1
	for child in node.get_children(): count += _node_count(child)
	return count

func _dispose_imported(level: Game4ImportedLevel) -> void :
	level.queue_free()
	await get_tree().create_timer(0.2).timeout

func _run() -> void :
	Global.cd_path = ""
	Global.Is_Show = true
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	RoleProp.set_physics_process(false)
	var old_data: = PlayerData.player_data.duplicate(true)
	PlayerData.player_data["头衔"] = []
	var paths: Array[String] = []
	for number in range(63, 86): paths.append("res://Scene/Level/Level_%d.tscn" % number)
	paths.append("res://Scene/Level/Level_80_hidden.tscn")
	for path in paths:
		_check_no_inherited_terrain_conflicts(path)
		var level: = load(path).instantiate() as Game4ImportedLevel
		var exit: = level.get_node("exit") as Node2D
		var exit_position: = exit.position + Vector2(-17, -23)
		exit.position = exit_position
		var terrain: = level.get_node_or_null("OriginalTerrain") as Node2D
		if level.stage_number >= 72:
			_check(terrain != null, path + " 编辑器缺少地形")
		var count: = _node_count(terrain) if terrain != null else 0
		var moving_homes: = {}
		if terrain != null:
			for record: Dictionary in terrain.get_meta("scene_bindings", {}).get("_moving", []):
				var body: = terrain.get_node(record["body"]) as Node2D
				body.position.x += 23
				moving_homes[body] = body.position
		var visual: = _first_visual(terrain if terrain != null else level.get_node("BackGround"))
		_check(visual != null, path + " 编辑器缺少背景/地形画面")
		visual.position += Vector2(7, 11)
		visual.scale *= Vector2(1.03, 0.97)
		var visual_position: = visual.position
		var visual_scale: = visual.scale
		var ground: = terrain.get_node_or_null("Ground0") as Node2D if terrain != null else null
		if ground != null: ground.position.x += 13
		var ground_position: = ground.position if ground != null else Vector2.ZERO
		var spawn: = level.spawn_position
		if level is NorthContinentLevel:
			spawn.x += 9
			level.spawn_position = spawn
		RoleProp.roleprop.Hp = 10000000
		get_tree().root.add_child(level)
		get_tree().current_scene = level
		level.create_control.stop()
		level.Role_.set_physics_process(false)
		level.Role_.needProtect = true
		level.Role_.set_meta("pet_turtle_link_unit_ref", false)
		await get_tree().create_timer(0.12).timeout
		_check(exit.position == exit_position, path + " 初始化覆盖出口位置")
		_check(visual.position == visual_position and visual.scale == visual_scale, path + " 初始化覆盖画面坐标/缩放")
		if terrain != null:
			_check(_node_count(terrain) == count, path + " 运行时重建地形节点")
			if ground != null: _check(ground.position == ground_position, path + " 覆盖平台编辑坐标")
			var moving: Variant = terrain.get("_moving")
			if moving is Array:
				for record: Dictionary in moving:
					_check(record["home_position"] == moving_homes[record["body"]], path + " 移动平台起点没有使用场景坐标")
		_check(level.Role_.position == spawn, path + " 覆盖出生位置")
		_check(level.my_camera.zoom == Vector2.ONE, path + " 放大游戏画面")
		if path.ends_with("Level_80_hidden.tscn"):
			_check(terrain._portals.is_empty(), "隐藏关继承了普通幻境阁的分支出口")
			_check(terrain._backgrounds["bg10"].texture.resource_path.contains("/huanjinggeyincang/"), "隐藏关使用了普通幻境阁背景")
			_check(level.hero.position == Vector2.ZERO and level.monster.position == Vector2.ZERO, "隐藏关角色或怪物父节点偏移")
			_check(level.hidden_original_room, "隐藏关没有启用隐藏房间数据")
		await _dispose_imported(level)

	var void_level: = load("res://Scene/Level/Level_81.tscn").instantiate() as NorthContinentLevel
	var void_terrain: = void_level.get_node("OriginalTerrain")
	var floor: = void_terrain.get_node("VoidFloor") as StaticBody2D
	floor.position += Vector2(30, -20)
	get_tree().root.add_child(void_level)
	get_tree().current_scene = void_level
	void_level.create_control.stop()
	var landing: Vector2 = void_terrain.void_landing_position(void_level.Role_)
	_check(absf(landing.x - 4430) < 0.01, "空间传送忽略编辑后的平台横坐标")
	var collider: = void_level.Role_.get_node("pz") as CollisionShape2D
	var feet: = collider.position.y + collider.shape.get_rect().end.y
	_check(absf(landing.y + feet + 6 - 621) < 0.01, "空间传送忽略编辑后的平台高度")
	await _dispose_imported(void_level)
	PlayerData.player_data = old_data
	print("CONTINENT_SCENE_AUTHORITY_CHECKS=", _checks, " FAILURES=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)



func _check_no_inherited_terrain_conflicts(path: String) -> void :
	var state: = (load(path) as PackedScene).get_state()
	var paths: = {}
	while state != null:
		for index in range(state.get_node_count()):
			var node_path: = str(state.get_node_path(index)).trim_prefix("./")
			if not (node_path == "OriginalTerrain" or node_path.begins_with("OriginalTerrain/")):
				continue

			if state.get_node_type(index) == &"": continue
			_check( not paths.has(node_path), path + " 重复定义继承地形 " + node_path)
			paths[node_path] = true
		var base_scene: = state.get_node_instance(0)
		state = base_scene.get_state() if base_scene != null else null
	if path.ends_with("Level_80_hidden.tscn"):
		_check(paths.has("OriginalTerrain"), "继承审计没有检查到隐藏关地形")
