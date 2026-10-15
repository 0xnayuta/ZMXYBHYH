extends SceneTree

const MOUNT_CATALOG: = preload("res://Script/Mount/MountCatalog.gd")
const EFFECT_ROOT: = "res://Art/Mount/Runtime/Effects"
const MOUNT_ROOT: = "res://Art/Mount/Runtime/Mounts"
const EXPECTED_VISUAL_COUNTS: = {
	"3106700": 8, "3106800": 1, "3108300": 2, 
	"3107700": 1, "3107800": 5, "3108000": 1, 
	"3108100": 2, 
	"3107100": 3, "3107200": 1, "3107400": 30, 
	"3105900": 1, "3106100": 1, "3109100": 15, 
	"3105100": 1, "3105200": 3, "3105400": 30, "3109200": 1, 
	"3104400": 7, "3109600": 2, 
	"3110800": 1, "3110900": 1, "3111000": 3, "3111200": 2, 
}
const EXPECTED_DELAYS: = {
	"3104400": [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5], 
	"3105100": [16.0 / 30.0], 
	"3105200": [25.0 / 30.0, 26.0 / 30.0, 26.0 / 30.0], 
	"3107100": [22.0 / 30.0, 22.0 / 30.0, 22.0 / 30.0], 
	"3107200": [27.0 / 30.0], 
	"3106700": [0.231, 0.665, 1.031, 1.465, 1.831, 2.265, 2.631, 3.065], 
	"3107800": [16.0 / 30.0, 26.0 / 30.0, 36.0 / 30.0, 46.0 / 30.0, 56.0 / 30.0], 
	"3111000": [14.0 / 30.0, 14.0 / 30.0, 14.0 / 30.0], 
}

var failures: Array[String] = []

func _initialize() -> void :
	call_deferred("_run")

func _run() -> void :
	root.size = Vector2i(1280, 720)
	var background: = ColorRect.new()
	background.color = Color("101820")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.z_index = -100
	root.add_child(background)
	var effect_script: = load("res://Script/Mount/MountSkillEffect.gd")
	_check(effect_script != null, "mount effect script missing")
	if effect_script == null:
		_finish()
		return
	var hero_scene: = load("res://Scene/Hero/Role_3/Role_3.tscn") as PackedScene
	_check(hero_scene != null, "role3 scene missing")
	if hero_scene == null:
		_finish()
		return
	var hero = hero_scene.instantiate()
	hero.position = Vector2(480.0, 320.0)
	hero.process_mode = Node.PROCESS_MODE_DISABLED
	root.add_child(hero)
	await process_frame
	hero.set_process(false)
	hero.set_physics_process(false)

	var checked_skills: = 0
	var checked_visuals: = 0
	for mount_id in MOUNT_CATALOG.SKILLS.keys():
		for skill_value in MOUNT_CATALOG.get_skills(str(mount_id)):
			var skill: Dictionary = skill_value if skill_value is Dictionary else {}
			var skill_id: = str(skill.get("id", ""))
			if not EXPECTED_VISUAL_COUNTS.has(skill_id):
				continue
			checked_skills += 1
			var effect = effect_script.new()
			effect.setup(hero, skill, str(mount_id))
			root.add_child(effect)
			await process_frame
			var visuals: Array = effect.get("_effect_visuals")
			var expected: = int(EXPECTED_VISUAL_COUNTS[skill_id])
			_check(visuals.size() == expected, "%s visual count %d/%d" % [skill_id, visuals.size(), expected])
			_check_visual_schedule(skill_id, visuals, effect.call("_mount_origin"))
			for visual_state in visuals:
				var visual = visual_state.get("node")
				_check(visual != null, "%s visual node missing" % skill_id)
				if visual == null:
					continue
				checked_visuals += 1
				var manifest: = "%s/%s/%s/manifest.json" % [
					str(visual_state.get("runtime_root", EFFECT_ROOT)), 
					"1003100" if str(mount_id) == "1002200" else str(mount_id), 
					str(visual.animation_name), 
				]
				_check(FileAccess.file_exists(manifest), "%s manifest missing" % manifest)
				_check(
					not (visual.get("_back_atlases") as Array).is_empty()
					or not (visual.get("_front_atlases") as Array).is_empty(), 
					"%s/%s atlas missing" % [skill_id, visual.animation_name]
				)
				_check(visual.get_animation_visual_bounds().size.length_squared() > 0.0, "%s/%s empty frames" % [skill_id, visual.animation_name])
			effect.queue_free()
			await process_frame
	_check(checked_skills == 23, "official effect skill coverage changed: %d" % checked_skills)
	_check(checked_visuals == 122, "official effect visual coverage changed: %d" % checked_visuals)
	for asset in ["effect1_1", "effect2_1", "effect2_2", "effect2_3", "mc_effect2_3", "effect4_2", "effect4_3"]:
		_check(FileAccess.file_exists("%s/1002800/%s/manifest.json" % [EFFECT_ROOT, asset]), "1002800/%s official asset missing" % asset)
	_check(FileAccess.file_exists("%s/1002800/res2/manifest.json" % MOUNT_ROOT), "1002800/res2 official overlay missing")
	await _verify_wenyu_ultimate(hero, effect_script)
	hero.set_meta("mount_claw_lightning_until", Time.get_ticks_msec() + 1000)
	var enhanced_attack = effect_script.new()
	enhanced_attack.setup(hero, {"id": "mount_normal", "power": 1.15, "kind": "claw"}, "1004700")
	root.add_child(enhanced_attack)
	await process_frame
	var enhanced_visuals: Array = enhanced_attack.get("_effect_visuals")
	_check(enhanced_visuals.size() == 1, "claw lightning normal attack effect missing")
	if not enhanced_visuals.is_empty():
		_check(str(enhanced_visuals[0].get("node").animation_name) == "attack1_4", "claw lightning effect asset mismatch")
	enhanced_attack.queue_free()
	await process_frame
	await _verify_streamed_atlas_pages()
	await _verify_shared_async_atlas()
	if DisplayServer.get_name() != "headless":
		await _capture_tiger_claw_alignment(hero, effect_script)
		await _capture_representative_effects()
		await _capture_qinglong_fullscreen(hero, effect_script)
	hero.queue_free()
	_finish(checked_skills, checked_visuals)

func _verify_streamed_atlas_pages() -> void :
	var visual_script: = load("res://Script/Mount/MountVisual.gd")
	var visual = visual_script.new()
	root.add_child(visual)
	_check(visual.setup("1002700", "aoyiSkill_0", EFFECT_ROOT), "凛冽风暴大图动画无法加载")
	visual.set_process(false)
	for _frame in range(165):
		visual.call("_process", 1.0 / 30.0)
		var loaded_back: = 0
		var loaded_front: = 0
		for texture in visual.get("_back_atlases") as Array:
			loaded_back += 1 if texture != null else 0
		for texture in visual.get("_front_atlases") as Array:
			loaded_front += 1 if texture != null else 0
		_check(loaded_back <= 1, "凛冽风暴同时驻留了多张后层大图")
		_check(loaded_front <= 1, "凛冽风暴同时驻留了多张前层大图")
	visual.queue_free()
	await process_frame

func _verify_shared_async_atlas() -> void :
	var visual_script: = load("res://Script/Mount/MountVisual.gd")
	var first = visual_script.new()
	var second = visual_script.new()
	root.add_child(first)
	root.add_child(second)
	_check(first.setup("1003600", "effect4_1", EFFECT_ROOT, true), "异步弹幕图集首次加载失败")
	_check(second.setup("1003600", "effect4_1", EFFECT_ROOT, true), "异步弹幕图集重复加载失败")
	var first_texture: Texture2D = null
	var second_texture: Texture2D = null
	for _frame in range(120):
		await process_frame
		var first_atlases: Array = first.get("_back_atlases")
		var second_atlases: Array = second.get("_back_atlases")
		first_texture = first_atlases[0] as Texture2D if not first_atlases.is_empty() else null
		second_texture = second_atlases[0] as Texture2D if not second_atlases.is_empty() else null
		if first_texture != null and second_texture != null:
			break
	_check(first_texture != null and second_texture != null, "异步弹幕图集未在限定帧数内完成")
	_check(first_texture == second_texture, "同一技能的多个弹幕重复创建了贴图实例")
	first.queue_free()
	second.queue_free()
	await process_frame

func _verify_wenyu_ultimate(hero, effect_script) -> void :
	var old_direction: bool = bool(hero.PlayerDir)
	hero.PlayerDir = false
	var effect = effect_script.new()
	effect.setup(hero, MOUNT_CATALOG.get_skills("1002800")[4], "1002800")
	root.add_child(effect)
	await process_frame
	var visuals: Array = effect.get("_effect_visuals")
	_check(visuals.size() == 2, "3108100 should only create the two official layers")
	var assets: Array[String] = []
	var viewport_left: Vector2 = effect.call("_screen_to_world", Vector2.ZERO)
	for index in range(visuals.size()):
		var state: Dictionary = visuals[index]
		var visual: = state.get("node") as Node2D
		assets.append(str(state.get("asset", "")))
		_check(visual != null and is_equal_approx(visual.global_position.x, viewport_left.x + 500.0), "3108100 layer %d is not viewport-left + 500" % index)
		_check(visual != null and is_equal_approx(visual.scale.x, 1.0), "3108100 layer %d incorrectly follows hero facing" % index)
	_check( not ("effect5_2" in assets), "3108100 incorrectly creates a standalone effect5_2")
	if visuals.size() == 2:
		var back_layer: = visuals[0].get("node") as Node2D
		var front_layer: = visuals[1].get("node") as Node2D
		_check(back_layer != null and not back_layer.z_as_relative and back_layer.z_index == 140, "3108100 aoyiSkill_1 layer index mismatch")
		_check(front_layer != null and not front_layer.z_as_relative and front_layer.z_index == 5, "3108100 aoyiSkill_2 layer index mismatch")
		_check(front_layer != null and is_equal_approx(front_layer.global_position.y, hero.global_position.y - 50.0), "3108100 aoyiSkill_2 Y offset mismatch")
	effect.queue_free()
	hero.PlayerDir = old_direction
	await process_frame

func _check_visual_schedule(skill_id: String, visuals: Array, mount_origin: Vector2) -> void :
	var has_negative_oriented_projectile: = false
	for state in visuals:
		if not bool(state.get("orient_to_velocity", false)):
			continue
		var velocity: Vector2 = state.get("velocity", Vector2.ZERO)
		var visual = state.get("node")
		_check( not velocity.is_zero_approx(), "%s oriented projectile has zero velocity" % skill_id)
		_check(visual != null and is_equal_approx(float(visual.rotation), velocity.angle()), "%s projectile visual direction mismatch" % skill_id)
		_check(visual != null and is_equal_approx(float(visual.scale.x), 1.0), "%s projectile visual was flipped after rotation" % skill_id)
		has_negative_oriented_projectile = has_negative_oriented_projectile or velocity.x < 0.0
	if EXPECTED_DELAYS.has(skill_id):
		var expected_delays: Array = EXPECTED_DELAYS[skill_id]
		_check(visuals.size() == expected_delays.size(), "%s schedule size mismatch" % skill_id)
		for index in range(mini(visuals.size(), expected_delays.size())):
			_check(
				is_equal_approx(float(visuals[index].get("delay", -1.0)), float(expected_delays[index])), 
				"%s visual %d delay mismatch" % [skill_id, index]
			)
	if skill_id == "3106700" and not visuals.is_empty():
		_check((visuals[0].get("velocity", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(0.0, 1350.0)), "3106700 fall velocity mismatch")
		var claw_node: = visuals[0].get("node") as Node2D
		_check(claw_node != null and is_equal_approx(claw_node.global_position.y, mount_origin.y - 590.0), "3106700 height is not based on the mount registration point")
		var impact_node: = visuals[1].get("node") as Node2D
		_check(impact_node != null and is_equal_approx(impact_node.global_position.y, mount_origin.y), "3106700 impact is not at ground level")
	elif skill_id == "3104400":
		for state in visuals:
			_check(is_equal_approx((state.get("velocity", Vector2.ZERO) as Vector2).length(), 300.0), "3104400 meteor speed mismatch")
	elif skill_id == "3105100" and not visuals.is_empty():
		_check((visuals[0].get("velocity", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(0.0, 400.0)), "3105100 fall velocity mismatch")
		_check(str(visuals[0].get("impact_asset", "")) == "effect1_2", "3105100 impact phase missing")
	elif skill_id == "3107800":
		for state in visuals:
			_check(is_equal_approx((state.get("velocity", Vector2.ZERO) as Vector2).length(), 200.0), "3107800 aimed projectile speed mismatch")
			_check(str(state.get("impact_asset", "")) == "effect4_2", "3107800 impact phase missing")
	elif skill_id == "3105400":
		for state in visuals:
			var velocity: Vector2 = state.get("velocity", Vector2.ZERO)
			_check(is_equal_approx(absf(velocity.x), 200.0) and is_equal_approx(velocity.y, 400.0), "3105400 frost velocity mismatch")
			_check(str(state.get("impact_asset", "")) == "effect4_2", "3105400 impact phase missing")
	elif skill_id == "3109200" and not visuals.is_empty():
		var visual: = visuals[0].get("node") as Node2D
		var viewport_size: = root.get_visible_rect().size
		var viewport_top_left: = root.get_canvas_transform().affine_inverse() * Vector2.ZERO
		var viewport_bottom_right: = root.get_canvas_transform().affine_inverse() * viewport_size
		var viewport_world_size: = viewport_bottom_right - viewport_top_left
		var expected_center: = root.get_canvas_transform().affine_inverse() * (viewport_size * 0.5)
		var expected_scale: = Vector2(absf(viewport_world_size.x) / 940.0, absf(viewport_world_size.y) / 590.0)
		_check(visual != null and visual.global_position.is_equal_approx(expected_center), "3109200 ice realm is not centered on the viewport: actual=%s expected=%s" % [visual.global_position if visual != null else Vector2.ZERO, expected_center])
		_check(visual != null and visual.scale.is_equal_approx(expected_scale), "3109200 ice realm does not cover the viewport: actual=%s expected=%s" % [visual.scale if visual != null else Vector2.ZERO, expected_scale])
	elif skill_id == "3109100":
		_check(has_negative_oriented_projectile, "3109100 negative-X projectile direction was not covered")

func _capture_tiger_claw_alignment(hero, effect_script) -> void :
	var visual_script: = load("res://Script/Mount/MountVisual.gd")
	var old_position: Vector2 = hero.position
	var old_action_visible: bool = hero.action.visible
	hero.position = Vector2(380.0, 540.0)
	hero.action.visible = false
	var tiger_skill: Dictionary = MOUNT_CATALOG.get_skills("1002200")[2]
	var locator = effect_script.new()
	locator.setup(hero, tiger_skill, "1002200")
	var mount_origin: Vector2 = locator.call("_mount_origin")
	var target_scene: = load("res://Scene/Monster/Monster_1.tscn") as PackedScene
	_check(target_scene != null, "tiger alignment screenshot target missing")
	var target = target_scene.instantiate() if target_scene != null else null
	if target != null:
		target.process_mode = Node.PROCESS_MODE_DISABLED
		target.position = Vector2(820.0, mount_origin.y)
		target.add_to_group("monsters")
		root.add_child(target)
		await process_frame
		var target_foot: Vector2 = locator.call("_target_foot", target)
		target.position += mount_origin + Vector2(440.0, 0.0) - target_foot
	locator.free()
	var mount_visual = visual_script.new()
	hero.add_child(mount_visual)
	_check(mount_visual.setup("1003100", "idle"), "tiger alignment screenshot mount missing")
	mount_visual.call("_process", 0.5)
	mount_visual.set_process(false)
	var effect = effect_script.new()
	effect.setup(hero, tiger_skill, "1002200")
	root.add_child(effect)
	await process_frame
	effect.set_process(false)
	var landing: Vector2 = effect.call("_target_foot", target) if target != null else mount_origin
	mount_visual.position = hero.to_local(mount_origin)
	for _frame in range(43):
		effect.call("_process", 1.0 / 60.0)
	for _frame in range(30):
		await process_frame
	var ground_line: = Line2D.new()
	ground_line.width = 2.0
	ground_line.default_color = Color(1.0, 0.2, 0.15, 1.0)
	ground_line.points = PackedVector2Array([Vector2(80.0, landing.y), Vector2(1200.0, landing.y)])
	ground_line.z_index = 200
	root.add_child(ground_line)
	RenderingServer.force_draw()
	await process_frame
	var image: = root.get_texture().get_image()
	_check(image != null and not image.is_empty(), "tiger claw alignment screenshot empty")
	if image != null and not image.is_empty():
		var output: = OS.get_environment("TEMP").path_join("mount_tiger_claw_alignment.png")
		_check(image.save_png(output) == OK, "tiger claw alignment screenshot save failed")
		print("MOUNT_TIGER_CLAW_SCREENSHOT=" + output)
	ground_line.queue_free()
	effect.queue_free()
	mount_visual.queue_free()
	if target != null:
		target.queue_free()
	hero.position = old_position
	hero.action.visible = old_action_visible
	await process_frame

func _capture_representative_effects() -> void :
	var visual_script: = load("res://Script/Mount/MountVisual.gd")
	var samples: = [
		["1003100", "effect3_1", Vector2(150, 180), 0.0], 
		["1003600", "effect4_1", Vector2(470, 180), deg_to_rad(28.0)], 
		["1002800", "effect2_1", Vector2(790, 180), 0.0], 
		["1002800", "effect4_3", Vector2(1110, 180), 0.0], 
		["1003500", "effect1_1", Vector2(150, 520), deg_to_rad(152.0)], 
		["1003600", "effect1_2", Vector2(470, 520), 0.0], 
		["1003900", "effect3_1", Vector2(790, 520), 0.0], 
		["1004700", "effect3_1", Vector2(1110, 520), 0.0], 
	]
	for sample in samples:
		var visual = visual_script.new()
		root.add_child(visual)
		_check(visual.setup(sample[0], sample[1], EFFECT_ROOT), "screenshot effect missing: %s/%s" % [sample[0], sample[1]])
		visual.position = sample[2]
		visual.rotation = sample[3]
		visual.scale = Vector2(0.5, 0.5)
		visual.call("_process", 0.5)
		visual.set_process(false)
	RenderingServer.force_draw()
	await process_frame
	var image: = root.get_texture().get_image()
	_check(image != null and not image.is_empty(), "official effect screenshot empty")
	if image != null and not image.is_empty():
		var output: = OS.get_environment("TEMP").path_join("mount_official_effects.png")
		_check(image.save_png(output) == OK, "official effect screenshot save failed")
		print("MOUNT_OFFICIAL_EFFECT_SCREENSHOT=" + output)

func _capture_qinglong_fullscreen(hero, effect_script) -> void :
	var effect = effect_script.new()
	effect.setup(hero, MOUNT_CATALOG.get_skills("1003600")[4], "1003600")
	root.add_child(effect)
	await process_frame
	var visuals: Array = effect.get("_effect_visuals")
	_check(visuals.size() == 1, "3109200 fullscreen capture visual missing")
	if not visuals.is_empty():
		var visual: = visuals[0].get("node") as Node2D
		if visual != null:
			for _frame in range(120):
				await process_frame
				var atlases: Array = visual.get("_back_atlases")
				if not atlases.is_empty() and atlases[0] != null:
					break
			visual.visible = true
			visual.call("_process", 0.8)
			visual.set_process(false)
			RenderingServer.force_draw()
			await process_frame
			var image: = root.get_texture().get_image()
			_check(image != null and not image.is_empty(), "3109200 fullscreen screenshot empty")
			if image != null and not image.is_empty():
				var output: = OS.get_environment("TEMP").path_join("mount_qinglong_fullscreen.png")
				_check(image.save_png(output) == OK, "3109200 fullscreen screenshot save failed")
				print("MOUNT_QINGLONG_FULLSCREEN_SCREENSHOT=" + output)
	effect.queue_free()
	await process_frame

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _finish(skills: = 0, visuals: = 0) -> void :
	if failures.is_empty():
		print("MOUNT_OFFICIAL_EFFECT_PROBE_OK skills=%d visuals=%d" % [skills, visuals])
	else:
		for failure in failures:
			push_error("MOUNT_OFFICIAL_EFFECT_PROBE_FAIL: %s" % failure)
	quit(0 if failures.is_empty() else 1)
