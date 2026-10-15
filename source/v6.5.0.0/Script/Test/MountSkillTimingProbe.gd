extends SceneTree

const MOUNT_CATALOG: = preload("res://Script/Mount/MountCatalog.gd")

class ProbeLevel extends Node2D:
	var lj_tt: Node2D

	func _init() -> void :
		lj_tt = Node2D.new()
		lj_tt.name = "ComboHost"
		add_child(lj_tt)

var failures: Array[String] = []
var hit_times: Array[float] = []

func _initialize() -> void :
	call_deferred("_run")

func _run() -> void :
	var role_prop_node: = root.get_node_or_null("RoleProp")
	var main_set_node: = root.get_node_or_null("MainSet")
	_check(role_prop_node != null, "RoleProp Autoload missing")
	_check(main_set_node != null, "MainSet Autoload missing")
	if role_prop_node == null or main_set_node == null:
		_finish()
		return
	var role_properties: Dictionary = role_prop_node.get("roleprop")
	var base_role_properties: Dictionary = role_prop_node.get("baseroleprop")
	role_properties["power"] = 1000
	role_properties["Htarget"] = 100000
	role_properties["Crit"] = 0
	role_properties["Lucky"] = 0
	role_properties["sp"] = 100000
	base_role_properties["Level"] = 90
	main_set_node.get("set_data")["ShowDamageText"] = false

	_verify_official_table()
	var hero_scene: = load("res://Scene/Hero/Role_3/Role_3.tscn") as PackedScene
	var target_scene: = load("res://Scene/Monster/Monster_1.tscn") as PackedScene
	var effect_script: = load("res://Script/Mount/MountSkillEffect.gd")
	_check(hero_scene != null and target_scene != null and effect_script != null, "timing probe scenes/scripts missing")
	if hero_scene == null or target_scene == null or effect_script == null:
		_finish()
		return

	var level: = ProbeLevel.new()
	level.name = "MountTimingLevel"
	root.add_child(level)
	current_scene = level
	var hero = hero_scene.instantiate()
	hero.process_mode = Node.PROCESS_MODE_DISABLED
	hero.position = Vector2(240.0, 420.0)
	level.add_child(hero)
	var target = target_scene.instantiate()
	target.process_mode = Node.PROCESS_MODE_DISABLED
	target.add_to_group("monsters")
	level.add_child(target)
	await process_frame
	role_properties["power"] = 1000
	role_properties["Htarget"] = 100000
	role_properties["Crit"] = 0
	role_properties["Lucky"] = 0
	role_properties["sp"] = 100000
	base_role_properties["Level"] = 90
	_prepare_target(target)
	hero.PlayerDir = true

	_verify_body_hit_timing(effect_script, hero, target, level)
	_verify_projectile_collision_timing(effect_script, hero, target, level)
	_verify_impact_chain_timing(effect_script, hero, target, level)
	_verify_wenyu_split_projectile(effect_script, hero, target, level)
	await _verify_wenyu_star_ground_impact(effect_script, hero, level)
	_verify_repeated_projectile_hits(effect_script, hero, target, level)
	_verify_sustained_effect_timing(effect_script, hero, target, level)

	target.queue_free()
	hero.queue_free()
	await process_frame
	_finish()

func _verify_official_table() -> void :
	var expected: = {
		"3105100": [16.0 / 30.0, 2, 0.234, 2.0], 
		"3106700": [0.231, 1, 0.0, 0.434], 
		"3107100": [22.0 / 30.0, 3, 0.2, 1.1], 
		"3107200": [27.0 / 30.0, 1, 0.0, 0.5], 
		"3107300": [1.0 / 30.0, 999, 0.334, 8.0], 
		"3107400": [0.66, 12, 0.234, 10.0], 
		"3108100": [0.0, 6, 0.234, 2.467], 
		"3107800": [16.0 / 30.0, 1, 0.0, 8.0], 
		"3108000": [0.0, 50, 0.5, 5.5], 
		"3109100": [8.0 / 30.0, 3, 0.3, 1.167], 
		"3109600": [17.0 / 30.0, 999, 0.3, 10.0], 
		"3111000": [14.0 / 30.0, 8, 0.5, 4.0], 
		"3111101": [9.0 / 30.0, 10, 0.7, 0.6], 
	}
	for skill_id in expected:
		var combat: = MOUNT_CATALOG.get_official_combat(skill_id)
		var values: Array = expected[skill_id]
		_check( not combat.is_empty(), "%s official combat data missing" % skill_id)
		_check(is_equal_approx(float(combat.get("first", -1.0)), float(values[0])), "%s first hit frame mismatch" % skill_id)
		_check(int(combat.get("hits", -1)) == int(values[1]), "%s hit count mismatch" % skill_id)
		_check(is_equal_approx(float(combat.get("interval", -1.0)), float(values[2])), "%s interval mismatch" % skill_id)
		_check(is_equal_approx(float(combat.get("life", -1.0)), float(values[3])), "%s lifetime mismatch" % skill_id)

func _verify_body_hit_timing(effect_script, hero, target, level: Node) -> void :
	target.Hp = 100000000
	target.position = hero.position + Vector2(100.0, 0.0)
	hit_times.clear()
	var effect = effect_script.new()
	effect.setup(hero, MOUNT_CATALOG.get_skills("1002200")[0], "1002200")
	effect.hit_landed.connect(_record_hit)
	level.add_child(effect)
	effect.set_process(false)
	var hp_before: = int(target.Hp)
	effect.call("_process", 0.35)
	_check(int(target.Hp) == hp_before, "3106900 dealt damage before official frame 11")
	effect.call("_process", 0.02)
	_check(hit_times.size() == 1 and hit_times[0] >= 11.0 / 30.0, "3106900 first hit is not frame 11")
	effect.call("_process", 0.1)
	_check(hit_times.size() == 1, "3106900 ignored 200ms hit interval")
	effect.call("_process", 0.11)
	effect.call("_process", 0.2)
	_check(hit_times.size() == 3, "3106900 did not produce exactly three official hits")
	effect.queue_free()

func _verify_projectile_collision_timing(effect_script, hero, target, level: Node) -> void :
	target.Hp = 100000000
	hit_times.clear()
	var skill: Dictionary = MOUNT_CATALOG.get_skills("1003500")[0]
	var effect = effect_script.new()
	effect.setup(hero, skill, "1003500")
	effect.hit_landed.connect(_record_hit)
	level.add_child(effect)
	effect.set_process(false)
	var states: Array = effect.get("_effect_visuals")
	_check(states.size() == 1, "3105900 projectile visual missing")
	if states.is_empty():
		effect.queue_free()
		return
	var visual: MountVisual = states[0].get("node") as MountVisual
	var start: Vector2 = visual.global_position
	var target_collision: = target.get_node("pz") as CollisionShape2D
	target.position += start + Vector2(220.0, 0.0) - target_collision.global_position
	var hp_before: = int(target.Hp)
	effect.call("_process", 0.32)
	_check(int(target.Hp) == hp_before, "3105900 dealt damage before projectile release")
	effect.call("_process", 0.03)
	_check(int(target.Hp) == hp_before, "3105900 dealt damage as soon as the distant projectile appeared")
	for _step in range(12):
		if not hit_times.is_empty():
			break
		effect.call("_process", 0.05)
	_check(hit_times.size() == 1, "3105900 projectile crossed the target without damage")
	if not hit_times.is_empty():
		_check(hit_times[0] > 10.0 / 30.0, "3105900 damage did not wait for visual collision")
	effect.queue_free()

func _verify_sustained_effect_timing(effect_script, hero, target, level: Node) -> void :
	target.Hp = 100000000
	hit_times.clear()
	var skill: Dictionary = MOUNT_CATALOG.get_skills("1002700")[4]
	var effect = effect_script.new()
	effect.setup(hero, skill, "1002700")
	effect.hit_landed.connect(_record_hit)
	level.add_child(effect)
	effect.set_process(false)
	var visual: MountVisual = (effect.get("_effect_visuals") as Array)[0].get("node") as MountVisual
	var bounds: Rect2 = visual.get_animation_visual_bounds()
	var target_collision: = target.get_node("pz") as CollisionShape2D
	target.position += visual.to_global(bounds.get_center()) - target_collision.global_position
	for _step in range(110):
		visual.call("_process", 0.05)
		effect.call("_process", 0.05)
	_check(hit_times.size() == 10, "3108000 should hit 10 visible collision pulses, got %s" % str(hit_times))
	for index in range(hit_times.size()):
		_check(
			is_equal_approx(hit_times[index], 0.6 + 0.5 * float(index)), 
			"3108000 pulse %d timing mismatch: %s" % [index, str(hit_times)]
		)
	var hits_at_end: = hit_times.size()
	effect.call("_process", 0.6)
	_check(hit_times.size() == hits_at_end, "3108000 still dealt damage after its official effect ended")
	effect.queue_free()

func _verify_impact_chain_timing(effect_script, hero, target, level: Node) -> void :
	target.Hp = 100000000
	hit_times.clear()
	var target_collision: = target.get_node("pz") as CollisionShape2D
	target.position += hero.global_position + Vector2(220.0, 0.0) - target_collision.global_position
	var skill: Dictionary = MOUNT_CATALOG.get_skills("1003600")[0]
	var effect = effect_script.new()
	effect.setup(hero, skill, "1003600")
	effect.hit_landed.connect(_record_hit)
	level.add_child(effect)
	effect.set_process(false)
	var projectile: MountVisual = (effect.get("_effect_visuals") as Array)[0].get("node") as MountVisual
	for _step in range(60):
		projectile.call("_process", 0.05)
		effect.call("_process", 0.05)
		if (effect.get("_effect_visuals") as Array).size() > 1:
			break
	var states: Array = effect.get("_effect_visuals")
	_check( not hit_times.is_empty(), "3105100 falling ice reached the target without damage")
	_check(states.size() == 2, "3105100 did not create effect1_2 on collision")
	if states.size() == 2:
		var impact: MountVisual = states[1].get("node") as MountVisual
		_check(str(impact.animation_name) == "effect1_2", "3105100 collision phase asset mismatch")
		for _step in range(8):
			impact.call("_process", 0.05)
			effect.call("_process", 0.05)
		_check(hit_times.size() == 2, "3105100 impact phase did not produce the official second hit: %s" % str(hit_times))
	effect.queue_free()

func _verify_repeated_projectile_hits(effect_script, hero, target, level: Node) -> void :
	var cases: = [
		["1002200", 2, 4, Vector2(120.0, 0.0), 4.0], 
		["1003900", 2, -1, Vector2(260.0, 0.0), 5.0], 
		["1002700", 3, 5, Vector2(420.0, -40.0), 5.0], 
		["1002800", 0, 3, Vector2(400.0, -30.0), 2.0], 
		["1002800", 2, 5, Vector2(80.0, -30.0), 1.5], 
	]
	for case in cases:
		target.Hp = 100000000
		hit_times.clear()
		var target_collision: = target.get_node("pz") as CollisionShape2D
		target.position += hero.global_position + case[3] - target_collision.global_position
		var skill: Dictionary = MOUNT_CATALOG.get_skills(case[0])[case[1]]
		var effect = effect_script.new()
		effect.setup(hero, skill, case[0])
		effect.hit_landed.connect(_record_hit)
		level.add_child(effect)
		effect.set_process(false)
		if str(skill.get("id", "")) == "3106700":
			var target_foot: Vector2 = effect.call("_target_foot", target)
			var claw_states: Array = effect.get("_effect_visuals")
			var impact_count: = 0
			for state in claw_states:
				if str(state.get("asset", "")) != "effect3_2":
					continue
				impact_count += 1
				var impact: = state.get("node") as MountVisual
				_check(
					impact != null and impact.global_position.is_equal_approx(target_foot), 
					"3106700 claw impact is not at the target foot"
				)
			_check(impact_count == 4, "3106700 did not create four target-foot impacts")
		var step_count: = int(ceil(float(case[4]) / 0.05))
		for _step in range(step_count):
			var states: Array = effect.get("_effect_visuals")
			for state in states:
				var visual: MountVisual = state.get("node") as MountVisual
				if visual != null and is_instance_valid(visual):
					visual.call("_process", 0.05)
			effect.call("_process", 0.05)
		if int(case[2]) >= 0:
			_check(
				hit_times.size() == int(case[2]), 
				"%s repeated projectile hits %d/%d at %s" % [str(skill.get("id", "")), hit_times.size(), int(case[2]), str(hit_times)]
			)
		else:
			_check(hit_times.size() > 0 and hit_times.size() <= 7, "%s random meteors never collided or exceeded seven: %s" % [str(skill.get("id", "")), str(hit_times)])
		if str(skill.get("id", "")) == "3106700":
			for index in range(hit_times.size()):
				_check(hit_times[index] > 0.231 + 0.8 * float(index), "3106700 claw %d damaged on spawn" % index)
		elif str(skill.get("id", "")) == "3107800":
			for index in range(hit_times.size()):
				_check(hit_times[index] > float(16 + index * 10) / 30.0, "3107800 shot %d damaged before collision" % index)
		effect.queue_free()

func _verify_wenyu_split_projectile(effect_script, hero, target, level: Node) -> void :
	target.Hp = 100000000
	hit_times.clear()
	var target_collision: = target.get_node("pz") as CollisionShape2D
	target.position += hero.global_position + Vector2(330.0, -60.0) - target_collision.global_position
	var skill: Dictionary = MOUNT_CATALOG.get_skills("1002800")[1]
	var effect = effect_script.new()
	effect.setup(hero, skill, "1002800")
	effect.hit_landed.connect(_record_hit)
	level.add_child(effect)
	effect.set_process(false)
	for _step in range(90):
		var states: Array = effect.get("_effect_visuals")
		for state in states:
			var visual: MountVisual = state.get("node") as MountVisual
			if visual != null and is_instance_valid(visual):
				visual.call("_process", 0.05)
		effect.call("_process", 0.05)
	var states: Array = effect.get("_effect_visuals")
	var assets: Array[String] = []
	var state_by_asset: Dictionary = {}
	for state in states:
		var asset: = str(state.get("asset", ""))
		assets.append(asset)
		if not state_by_asset.has(asset):
			state_by_asset[asset] = state
	_check("effect2_2" in assets, "3107200 collision did not create effect2_2")
	_check("mc_effect2_3" in assets, "3107200 effect2_2 did not create the official transition")
	_check(assets.count("effect2_3") == 4, "3107200 did not create four orbiting effect2_3 projectiles: %s" % str(assets))
	var launch_state: Dictionary = state_by_asset.get("effect2_1", {})
	var burst_state: Dictionary = state_by_asset.get("effect2_2", {})
	var transition_state: Dictionary = state_by_asset.get("mc_effect2_3", {})
	_check(is_equal_approx(float(launch_state.get("finish_delay", -1.0)), 0.1), "3107200 collision split delay is not the official 100ms")
	_check(str(launch_state.get("channel", "")) != str(burst_state.get("channel", "")), "3107200 effect2_2 incorrectly shares effect2_1 hit count")
	if not burst_state.is_empty() and not transition_state.is_empty():
		var transition_delay: = float(transition_state.get("spawn_time", 0.0)) - float(burst_state.get("spawn_time", 0.0))
		_check(transition_delay + 0.0001 >= 7.0 / 30.0 and transition_delay <= 7.0 / 30.0 + 0.051, "3107200 mc_effect2_3 frame-7 timing mismatch: %f" % transition_delay)
	_check(hit_times.size() > 1 and hit_times.size() <= 14, "3107200 split projectiles did not deal bounded collision damage: %s" % str(hit_times))
	effect.queue_free()

func _verify_wenyu_star_ground_impact(effect_script, hero, level: Node) -> void :
	var floor_body: = StaticBody2D.new()
	floor_body.collision_layer = 1
	floor_body.collision_mask = 0
	floor_body.position = Vector2(0.0, 280.0)
	var floor_shape: = CollisionShape2D.new()
	var rectangle: = RectangleShape2D.new()
	rectangle.size = Vector2(4000.0, 20.0)
	floor_shape.shape = rectangle
	floor_body.add_child(floor_shape)
	level.add_child(floor_body)
	await physics_frame
	var effect = effect_script.new()
	effect.setup(hero, MOUNT_CATALOG.get_skills("1002800")[3], "1002800")
	level.add_child(effect)
	effect.set_process(false)
	for _step in range(90):
		effect.call("_process", 0.05)
		var states: Array = effect.get("_effect_visuals")
		if states.any( func(state): return str(state.get("asset", "")) == "effect4_3"):
			break
	var states: Array = effect.get("_effect_visuals")
	var impacts: Array = states.filter( func(state): return str(state.get("asset", "")) == "effect4_3")
	_check( not impacts.is_empty(), "3107400 stars did not create effect4_3 when colliding with the ground")
	if not impacts.is_empty():
		_check(float(impacts[0].get("spawn_time", 10.0)) < 10.0, "3107400 waited for the 10-second lifetime before ground impact")
	effect.queue_free()
	floor_body.queue_free()
	await process_frame

func _prepare_target(target) -> void :
	target.Hp = 100000000
	target.SHp = 100000000
	target.hd = 0
	target.miss = 0
	target.mdef = 0
	target.def = 0
	target.Critreduce = 100000
	target.Toughness = 100000
	target.spawn_damage_protection_until_msec = 0
	target.jgz_bl = 1.0
	target.zznh_bl = 1.0
	target.HurtBl = 1.0
	target.lpzzs = 0.0
	target.llrdzs = 1.0

func _record_hit(_skill_id: String, _target, hit_time: float) -> void :
	hit_times.append(hit_time)

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _finish() -> void :
	if failures.is_empty():
		print("MOUNT_SKILL_TIMING_PROBE_OK")
	else:
		for failure in failures:
			push_error("MOUNT_SKILL_TIMING_PROBE_FAIL: %s" % failure)
	quit(0 if failures.is_empty() else 1)
