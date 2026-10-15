extends SceneTree

const MOUNT_CATALOG: = preload("res://Script/Mount/MountCatalog.gd")
const MOUNT_VISUAL: = preload("res://Script/Mount/MountVisual.gd")

var failures: Array[String] = []

func _initialize() -> void :
	call_deferred("_run")

func _run() -> void :
	print("MOUNT_WENYU_STAGE=setup")
	root.size = Vector2i(1280, 720)
	var level: = Node2D.new()
	level.name = "WenyuVisualProbe"
	root.add_child(level)
	current_scene = level

	var background: = ColorRect.new()
	background.color = Color("101820")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.z_index = -100
	level.add_child(background)

	var ground_line: = Line2D.new()
	ground_line.width = 3.0
	ground_line.default_color = Color("557080")
	ground_line.points = PackedVector2Array([Vector2(60.0, 610.0), Vector2(1220.0, 610.0)])
	ground_line.z_index = -10
	level.add_child(ground_line)

	var hero_scene: = load("res://Scene/Hero/Role_3/Role_3.tscn") as PackedScene
	var target_scene: = load("res://Scene/Monster/Monster_1.tscn") as PackedScene
	var effect_script: = load("res://Script/Mount/MountSkillEffect.gd")
	_check(hero_scene != null and target_scene != null and effect_script != null, "飞鱼视觉探针场景或脚本缺失")
	if hero_scene == null or target_scene == null or effect_script == null:
		_finish()
		return

	var hero = hero_scene.instantiate()
	hero.process_mode = Node.PROCESS_MODE_DISABLED
	hero.position = Vector2(245.0, 520.0)
	hero.PlayerDir = true
	level.add_child(hero)
	var target = target_scene.instantiate()
	target.process_mode = Node.PROCESS_MODE_DISABLED
	target.add_to_group("monsters")
	level.add_child(target)
	await process_frame
	hero.action.visible = false
	target.Hp = 100000000
	target.NoTarget = false
	target.spawn_damage_protection_until_msec = 0

	var locator = effect_script.new()
	locator.setup(hero, MOUNT_CATALOG.get_skills("1002800")[0], "1002800")
	var ground: Vector2 = locator.call("_mount_origin")
	var target_foot: Vector2 = locator.call("_target_foot", target)
	target.position += Vector2(700.0, ground.y) - target_foot
	locator.free()

	var mount: = MOUNT_VISUAL.new()
	mount.name = "MountVisual"
	hero.add_child(mount)
	_check(mount.setup("1002800", "idle"), "飞鱼 idle 模型无法加载")
	mount.position = hero.to_local(ground)
	mount.call("_process", 0.45)
	mount.set_process(false)

	var water_effect = effect_script.new()
	water_effect.setup(hero, MOUNT_CATALOG.get_skills("1002800")[0], "1002800")
	level.add_child(water_effect)
	print("MOUNT_WENYU_STAGE=skill1_wait")
	await create_timer(1.15).timeout
	print("MOUNT_WENYU_STAGE=skill1_capture")
	var water_visuals: Array = water_effect.get("_effect_visuals")
	_check(water_visuals.size() == 3, "沧浪之水没有生成三个水柱")
	var expected_x: = [510.0, 700.0, 890.0]
	for index in range(mini(water_visuals.size(), expected_x.size())):
		var water_visual: = water_visuals[index].get("node") as Node2D
		_check(water_visual != null and absf(water_visual.global_position.x - expected_x[index]) <= 2.0, "水柱 %d 横向落点错误" % index)
		_check(water_visual != null and absf(_visual_bottom_y(water_visual) - (ground.y + 64.0)) <= 2.0, "水柱 %d 底部没有对齐坐骑底部" % index)
		_check(water_visual != null and is_equal_approx(water_visual.rotation, - PI / 2.0), "水柱 %d 没有竖向升起" % index)
	await _capture("mount_wenyu_skill1_three_pillars.png")
	water_effect.queue_free()
	await process_frame

	var burst_effect = effect_script.new()
	burst_effect.setup(hero, MOUNT_CATALOG.get_skills("1002800")[1], "1002800")
	level.add_child(burst_effect)
	print("MOUNT_WENYU_STAGE=skill2_wait")
	var split_ready: = false
	var last_assets: Array[String] = []
	for _step in range(120):
		await create_timer(0.05).timeout
		if not is_instance_valid(burst_effect):
			break
		var assets: = _effect_assets(burst_effect)
		if assets != last_assets:
			print("MOUNT_WENYU_SKILL2_ASSETS=" + str(assets))
			last_assets = assets
		if "effect2_2" in assets and "mc_effect2_3" in assets and assets.count("effect2_3") == 4:
			split_ready = true
			break
	_check(split_ready, "爆破魔珠命中后没有生成完整的四弹幕链路")
	if split_ready and is_instance_valid(burst_effect):
		print("MOUNT_WENYU_SKILL2_TIMING elapsed=%s visual_lifetime=%s" % [
			str(burst_effect.get("elapsed")), str(burst_effect.get("_visual_lifetime"))
		])
		for state_value in burst_effect.get("_effect_visuals") as Array:
			if state_value is Dictionary and str(state_value.get("asset", "")) == "effect2_3":
				var projectile: = state_value.get("node") as Node2D
				if projectile != null and is_instance_valid(projectile):
					print("MOUNT_WENYU_ORBITER visible=%s position=%s" % [str(projectile.visible), str(projectile.global_position)])
	print("MOUNT_WENYU_STAGE=skill2_capture")
	await _capture("mount_wenyu_skill2_split_projectiles.png")

	if is_instance_valid(burst_effect):
		burst_effect.queue_free()
	mount.queue_free()
	target.queue_free()
	hero.queue_free()
	await process_frame
	_finish()

func _effect_assets(effect: Node) -> Array[String]:
	var assets: Array[String] = []
	for state_value in effect.get("_effect_visuals") as Array:
		if state_value is Dictionary:
			assets.append(str(state_value.get("asset", "")))
	return assets

func _visual_bottom_y(visual: Node2D) -> float:
	var bounds: Rect2 = visual.call("get_current_visual_bounds")
	var bottom_y: = - INF
	for corner in [
		bounds.position, 
		Vector2(bounds.end.x, bounds.position.y), 
		bounds.end, 
		Vector2(bounds.position.x, bounds.end.y), 
	]:
		bottom_y = maxf(bottom_y, (visual.global_transform * corner).y)
	return bottom_y

func _capture(file_name: String) -> void :
	RenderingServer.force_draw()
	await process_frame
	await process_frame
	var image: = root.get_texture().get_image()
	_check(image != null and not image.is_empty(), "%s 截图为空" % file_name)
	if image != null and not image.is_empty():
		var output: = OS.get_environment("TEMP").path_join(file_name)
		_check(image.save_png(output) == OK, "%s 保存失败" % file_name)
		print("MOUNT_WENYU_SCREENSHOT=" + output)

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _finish() -> void :
	if failures.is_empty():
		print("MOUNT_WENYU_VISUAL_PROBE_OK")
	else:
		for failure in failures:
			push_error("MOUNT_WENYU_VISUAL_PROBE_FAIL: %s" % failure)
	quit(0 if failures.is_empty() else 1)
