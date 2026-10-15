extends Node

const LEVEL_SCENE: = preload("res://Scene/Level/Level_esbxx.tscn")
const PROBE_HP: = 1000000
const PROBE_BOSS_SPAWN: = Vector2(500, 438)

var _probe_started: = false
var _level: LevelEsbxx


func _ready() -> void :
	call_deferred("_run_probe")


func _run_probe() -> void :
	if _probe_started:
		return
	_probe_started = true
	print("CONSTELLATION_TARGET_STEP setup")
	Global.SelectedConstellationLevel = 9
	_level = LEVEL_SCENE.instantiate() as LevelEsbxx
	if _level == null:
		_fail_probe("level scene instantiate")
		return
	add_child(_level)
	for _frame in range(180):
		if _level.Role_ is BaseHero and is_instance_valid(_level.Role_):
			break
		await get_tree().process_frame
	var probe_hero: = _level.Role_ as BaseHero
	if probe_hero == null or not is_instance_valid(probe_hero):
		_fail_probe("hero setup timeout")
		return
	if _level.create_control != null:
		_level.create_control.stop()
	probe_hero.set_process(false)
	probe_hero.set_physics_process(false)
	probe_hero.velocity = Vector2.ZERO
	probe_hero.set_meta("pet_turtle_link_unit_ref", false)
	Global.get_player = probe_hero
	var hurt_area: = probe_hero.get_node_or_null("base_damagebox/HurtBox") as Area2D
	var hurt_shape: = probe_hero.get_node_or_null(
		"base_damagebox/HurtBox/HurtBox"
	) as CollisionShape2D
	if hurt_area == null or hurt_shape == null:
		_fail_probe("hero hurt area")
		return
	var hero_shape: = RectangleShape2D.new()
	hero_shape.size = Vector2(60, 120)
	hurt_shape.shape = hero_shape
	hurt_shape.disabled = false
	hurt_area.collision_layer = 896
	hurt_area.collision_mask = 4
	hurt_area.monitoring = true
	hurt_area.monitorable = true
	_prepare_role_properties(probe_hero)

	var error: = await _verify_room_attack_boundary(probe_hero)
	print("CONSTELLATION_TARGET_STEP room result=%s" % error)
	if error.is_empty():
		error = await _verify_wei_projectiles(probe_hero, hurt_shape)
		print("CONSTELLATION_TARGET_STEP wei result=%s" % error)
	if error.is_empty():
		error = await _verify_xu_invulnerability()
		print("CONSTELLATION_TARGET_STEP xu result=%s" % error)
	if error.is_empty():
		error = await _verify_tier_grounding(probe_hero)
		print("CONSTELLATION_TARGET_STEP ground result=%s" % error)
	if error.is_empty():
		error = await _capture_optional_screenshot(probe_hero)
	if not error.is_empty():
		_fail_probe(error)
		return
	print(
		"CONSTELLATION_TARGET_OK room_range=150 wei_skills=3 "
		+ "xu_invulnerable=true tiers=1,2,10 grounded=true"
	)
	get_tree().quit(0)


func _prepare_role_properties(probe_hero: BaseHero) -> void :
	RoleProp.baseroleprop["Level"] = 90
	RoleProp.baseroleprop["SHp"] = PROBE_HP
	RoleProp.roleprop["SHp"] = PROBE_HP
	RoleProp.roleprop["Hp"] = PROBE_HP
	RoleProp.roleprop["Def"] = 0
	RoleProp.roleprop["Mdef"] = 0
	RoleProp.roleprop["Miss"] = 0
	RoleProp.roleprop["CritReduce"] = 0
	RoleProp.roleprop["Toughness"] = 0
	RoleProp.roleprop["sp"] = 0
	probe_hero.needProtect = false
	probe_hero.IsDeath = false


func _verify_room_attack_boundary(probe_hero: BaseHero) -> String:
	_level.current_tier = 1
	var config: = _level.get_level_monster_config(47109)
	if int(config.get("range", 0)) != 150:
		return "room attack range %s" % config.get("range", null)
	for facing_right in [true, false]:
		await _clear_probe_bosses()
		var boss: = _spawn_probe_boss(47109, 1)
		if boss == null or int(boss.get("source_id")) != 152\
		or int(boss.attackRange) != 150:
			return "room boss config"
		var boss_drops: Array = boss.independent_fall_list
		var expected_names: = ["xwjs", "xwjh", "smzf_skill_book"]
		var expected_chances: = [0.2, 0.1, 0.05]
		if boss_drops.size() != expected_names.size():
			return "room boss drop count"
		for drop_index in range(expected_names.size()):
			if str(boss_drops[drop_index].get("name", "")) != expected_names[drop_index]\
			or not is_equal_approx(float(boss_drops[drop_index].get("chance", 0.0)), expected_chances[drop_index]):
				return "room boss drop %d" % drop_index
		boss.set_physics_process(false)
		boss.position = PROBE_BOSS_SPAWN
		probe_hero.position = Vector2(650 if facing_right else 350, 438)
		probe_hero.needProtect = false
		probe_hero.IsDeath = false
		RoleProp.roleprop["Hp"] = PROBE_HP
		boss.call("_set_facing_direction", 1.0 if facing_right else -1.0)
		boss.call("_emit_monster152_skill", 1)
		if not await _wait_for_hp_below(PROBE_HP, 90):
			return "room attack missed %s 150px boundary" % (
				"right" if facing_right else "left"
			)
	await _clear_probe_bosses()
	return ""


func _verify_wei_projectiles(
	probe_hero: BaseHero, hurt_shape: CollisionShape2D
) -> String:
	await _clear_probe_bosses()
	var boss: = _spawn_probe_boss(47110, 1)
	if boss == null or int(boss.get("source_id")) != 156:
		return "wei boss config"
	boss.set_physics_process(false)
	boss.position = PROBE_BOSS_SPAWN
	boss.call("_set_facing_direction", 1.0)
	var expected_folders: = ["skill2", "skill3", "skill1"]
	var expected_frames: = [20, 1, 1]
	var expected_lifetimes: = [20.0 / 24.0, 120.0 / 24.0, 40.0 / 24.0]
	for index in range(3):
		var bullet_parent: = boss.get_node_or_null("Bullet")
		if bullet_parent == null:
			return "wei bullet parent"
		for old_projectile in bullet_parent.get_children():
			old_projectile.queue_free()
		await get_tree().process_frame
		probe_hero.global_position = boss.global_position + Vector2(500, 0)
		probe_hero.needProtect = false
		probe_hero.IsDeath = false
		RoleProp.roleprop["Hp"] = PROBE_HP
		boss.call("_emit_monster156_skill", index + 1)
		if bullet_parent.get_child_count() != 1:
			return "wei skill%d projectile count" % (index + 1)
		var projectile: = bullet_parent.get_child(0)
		var expected_suffix: = "/156/%s" % expected_folders[index]
		if not str(projectile.get("frame_root")).ends_with(expected_suffix)\
		or int(projectile.get("frame_count")) != expected_frames[index]\
		or not is_equal_approx(
					float(projectile.get("lifetime")), expected_lifetimes[index]
				)\
				or not bool(projectile.get("poll_overlaps_on_damage_pulse")):
			return "wei skill%d visual/lifetime config" % (index + 1)
		if index == 1 and not bool(projectile.get("hold_last_frame")):
			return "wei skill2 does not hold its single frame"
		await get_tree().physics_frame
		var projectile_shape: = projectile.get_node_or_null(
			"middle/HitBox/Hit_Box"
		) as CollisionShape2D
		if projectile_shape == null:
			return "wei skill%d collision" % (index + 1)
		probe_hero.global_position += (
			projectile_shape.global_position - hurt_shape.global_position
		)
		if not await _wait_for_hp_below(PROBE_HP, 90):
			return "wei skill%d overlap caused no damage" % (index + 1)
		if int(projectile.get("_hit_count")) < 1:
			return "wei skill%d accepted no hit" % (index + 1)
		if index == 1:
			var hp_after_first: = int(RoleProp.roleprop["Hp"])
			if not await _wait_for_projectile_elapsed(projectile, 1.2):
				return "wei skill2 ended before 120 ticks"
			var stream: = projectile.get("_visual_stream") as Node
			var stream_sprite: = stream.get_child(0) as Sprite2D\
			if stream != null and stream.get_child_count() > 0 else null
			if stream_sprite == null or stream_sprite.texture == null:
				return "wei skill2 single frame became invisible"
			if int(projectile.get("_hit_count")) < 2\
			or int(RoleProp.roleprop["Hp"]) >= hp_after_first:
				return "wei skill2 persistent overlap missed its next damage pulse"
	await _clear_probe_bosses()
	return ""


func _verify_xu_invulnerability() -> String:
	await _clear_probe_bosses()
	var boss: = _spawn_probe_boss(47111, 1)
	if boss == null or int(boss.get("source_id")) != 157:
		return "xu boss config"
	boss.mr_player.play(&"wait")
	await get_tree().process_frame
	boss.set_physics_process(false)
	boss.Hp = 10000
	boss.set("_hurt_reaction_active", true)
	for property_name in [
		"is_stun", "is_Immobilize", "is_ice", "is_sleep", "is_EyeFix", "Islljy", 
	]:
		boss.set(property_name, true)
	boss.call("_monster157_start_alpha_skill")
	if not bool(boss.get("_monster157_alpha_active"))\
	or not bool(boss.call("is_control_immune")):
		return "xu alpha state is not invulnerable"
	var body_stream: = boss.get("_body_stream") as CanvasItem
	if body_stream == null or not is_equal_approx(body_stream.modulate.a, 0.5):
		return "xu alpha visual state"
	if bool(boss.get("_hurt_reaction_active")):
		return "xu alpha did not cancel old hurt state"
	for property_name in [
		"is_stun", "is_Immobilize", "is_ice", "is_sleep", "is_EyeFix", "Islljy", 
	]:
		if bool(boss.get(property_name)):
			return "xu alpha kept control flag %s" % property_name
	var damage_results: = [
		boss.call("resolve_friendly_damage", 100, "physics", null), 
		boss.call("receive_friendly_damage", 100, "physics", null), 
		boss.call("receive_reflected_damage", 100, "physics", 0), 
		boss.call("reduce_pet_hp", 100, "physics"), 
		boss.call("hd_reduce", 100), 
		boss.call("HurtReduceHp", 100, null), 
	]
	boss.call("reduce_hp", 100)
	var dummy_area: = Area2D.new()
	boss.call("_on_hurt_box_area_entered", dummy_area)
	dummy_area.free()
	boss.call("play_hit_effect")
	boss.call("state_hurt")
	for result in damage_results:
		if int(result) != 0:
			return "xu alpha damage entry returned %s" % result
	if boss.Hp != 10000 or bool(boss.get("_hurt_reaction_active")):
		return "xu alpha accepted damage or hit reaction"
	boss.set("is_stun", true)
	boss.set("is_ice", true)
	boss.call("_enforce_control_immunity_state")
	if bool(boss.get("is_stun")) or bool(boss.get("is_ice")):
		return "xu alpha accepted new control state"
	await _clear_probe_bosses()
	return ""


func _verify_tier_grounding(probe_hero: BaseHero) -> String:
	var floor_shape: = _level.get_node_or_null(
		"wall/ConstellationFloor"
	) as CollisionShape2D
	if floor_shape == null or not (floor_shape.shape is RectangleShape2D):
		return "constellation floor geometry"
	var floor_top: = floor_shape.global_position.y\
	- (floor_shape.shape as RectangleShape2D).size.y * 0.5
	for tier in [1, 2, 10]:
		await _clear_probe_bosses()
		_level.selected_level = 9
		_level.current_tier = tier
		_level.completed = false
		_level._advancing = false
		_level._spawn_current_boss()
		var boss: = _level._boss_instance
		if boss == null:
			return "tier %d boss spawn" % tier
		boss.Htarget = 10000
		boss.set_physics_process(false)
		var pz: = boss.get_node_or_null("pz") as CollisionShape2D
		if pz == null or not (pz.shape is RectangleShape2D):
			return "tier %d boss collision" % tier
		var boss_bottom: = pz.global_position.y\
		+ (pz.shape as RectangleShape2D).size.y * 0.5
		if absf(boss_bottom - floor_top) > 0.5:
			return "tier %d spawn floor delta %.3f" % [tier, boss_bottom - floor_top]
		if tier == 2:
			probe_hero.global_position = boss.global_position + Vector2(500, 0)
			boss.global_position.y -= 40.0
			boss.velocity = Vector2.ZERO
			boss.NoGrav = false
			boss.is_Fly = false
			boss.set("_busy", false)
			boss.set("_next_attack_msec", Time.get_ticks_msec() + 2000)
			var start_y: = boss.global_position.y
			boss.set_physics_process(true)
			for _frame in range(6):
				await get_tree().physics_frame
			boss.set_physics_process(false)
			if boss.global_position.y <= start_y + 0.5:
				return "tier 2 boss gravity was cleared while waiting"
	await _clear_probe_bosses()
	return ""


func _capture_optional_screenshot(probe_hero: BaseHero) -> String:
	var screenshot_path: = OS.get_environment("CONSTELLATION_SCREENSHOT_PATH")
	if screenshot_path.is_empty():
		return ""
	await _clear_probe_bosses()
	var boss: = _spawn_probe_boss(47110, 2)
	if boss == null:
		return "screenshot boss spawn"
	boss.set_physics_process(false)
	probe_hero.position = Vector2(250, 438)
	boss.position = Vector2(650, 438)
	for _frame in range(30):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: = get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		return "screenshot image empty"
	var save_error: = image.save_png(screenshot_path)
	if save_error != OK:
		return "screenshot save error %d" % save_error
	print("CONSTELLATION_TARGET_SCREENSHOT %s" % screenshot_path)
	return ""


func _spawn_probe_boss(project_id: int, tier: int) -> BaseMonster:
	_level.current_tier = tier
	var boss: = _level._spawn_constellation_unit(
		project_id, PROBE_BOSS_SPAWN
	) as BaseMonster
	if boss != null:
		boss.Htarget = 10000
		boss.crit = 0
		boss.lucky = 0
		boss.ar = 10000
		boss.sp = 10000
	return boss


func _clear_probe_bosses() -> void :
	_level._clear_constellation_units()
	_level._boss_instance = null
	await get_tree().process_frame


func _wait_for_hp_below(starting_hp: int, maximum_frames: int) -> bool:
	for _frame in range(maximum_frames):
		if int(RoleProp.roleprop.get("Hp", starting_hp)) < starting_hp:
			return true
		await get_tree().physics_frame
	return false


func _wait_for_projectile_elapsed(projectile: Node, target_elapsed: float) -> bool:
	for _frame in range(180):
		if projectile == null or not is_instance_valid(projectile)\
		or projectile.is_queued_for_deletion():
			return false
		if float(projectile.get("_elapsed")) >= target_elapsed:
			return true
		await get_tree().physics_frame
	return false


func _fail_probe(reason: String) -> void :
	push_error("CONSTELLATION_TARGET_FAIL %s" % reason)
	get_tree().quit(1)
