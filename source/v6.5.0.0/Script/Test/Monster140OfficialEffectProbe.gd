extends SceneTree

func _init() -> void :
	call_deferred("_run")

func _run() -> void :
	var level_scene: = load("res://Scene/Level/Level_esbxx.tscn") as PackedScene
	if level_scene == null:
		push_error("MONSTER140_PROBE_FAIL missing level scene")
		quit(1)
		return
	var level: = level_scene.instantiate()
	get_root().add_child(level)
	for _i in range(8):
		await process_frame
	var boss: Node = null
	var monster_root: = level.get_node_or_null("Monster")
	if monster_root != null:
		for child in monster_root.get_children():
			if child.get("source_id") == 140:
				boss = child
				break
	if boss == null:
		push_error("MONSTER140_PROBE_FAIL boss not spawned")
		quit(1)
		return
	if not _verify_walk_facing(boss):
		return
	var hp_before_guard: = int(boss.get("Hp"))
	boss.call("_apply_official_invulnerability", 2)
	var direct_damage: = int(boss.call("resolve_friendly_damage", 1000, "physics", null))
	var pet_damage: = int(boss.call("reduce_pet_hp", 1000, "physics"))
	var reflected_damage: = int(boss.call("receive_reflected_damage", 1000, "magic", 0))
	if direct_damage != 0 or pet_damage != 0 or reflected_damage != 0 or int(boss.get("Hp")) != hp_before_guard:
		push_error("MONSTER140_PROBE_FAIL burrow damage guard")
		quit(1)
		return
	boss.set("_invulnerable_forever", false)
	var player: = boss.get_node("mr_player") as AnimationPlayer
	var expected_times: = {
		"skill1": 6.0 / 24.0, 
		"skill2": 2.0 / 24.0, 
		"skill3": 4.0 / 24.0, 
		"skill4": 2.0 / 24.0, 
	}
	for animation_name in expected_times:
		var animation: = player.get_animation(animation_name)
		var found_time: = -1.0
		for track_index in animation.get_track_count():
			if animation.track_get_type(track_index) != Animation.TYPE_METHOD:
				continue
			for key_index in animation.track_get_key_count(track_index):
				var method_value: Dictionary = animation.track_get_key_value(track_index, key_index)
				if str(method_value.get("method", "")) == "_emit_monster140_skill":
					var args: Array = method_value.get("args", [])
					var expected_skill: = 1 if animation_name == "skill1" else 2 if animation_name == "skill2" else 3 if animation_name == "skill3" else 4
					var expected_stage: = 2 if animation_name == "skill2" else 1
					if int(args[0]) == expected_skill and int(args[1]) == expected_stage:
						found_time = animation.track_get_key_time(track_index, key_index)
						break
			if found_time >= 0.0:
				break
		if absf(found_time - float(expected_times[animation_name])) > 0.0001:
			push_error("MONSTER140_PROBE_FAIL timing %s=%s" % [animation_name, found_time])
			quit(1)
			return
	boss.set("_busy", true)
	boss.call("_emit_monster140_skill", 1, 1)
	boss.call("_emit_monster140_skill", 2, 1)
	boss.call("_emit_monster140_skill", 2, 2)
	boss.call("_emit_monster140_skill", 3, 1)
	boss.call("_emit_monster140_skill", 4, 1)
	await process_frame
	var bullet_root: = boss.get_node("Bullet")
	var names: Array[String] = []
	var nonzero_velocity: = false
	var non_24fps: = false
	for effect in bullet_root.get_children():
		names.append(str(effect.get("skill_name")))
		if effect.get("motion_velocity") != Vector2.ZERO:
			nonzero_velocity = true
		if float(effect.get("frame_fps")) != 24.0:
			non_24fps = true
	var required: = [
		"Monster140Bullet1", "Monster140Bullet2_1", "Monster140Bullet2_2", 
		"Monster140Bullet3_1", "Monster140Bullet4"
	]
	names.sort()
	var allowed: = required + ["Monster140Bullet3_2", "Monster140Bullet3_3"]
	var invalid_names: Array[String] = []
	for effect_name: String in names:
		if effect_name not in allowed or names.count(effect_name) != 1:
			invalid_names.append(effect_name)
	var missing_required: = false
	for effect_name: String in required:
		if names.count(effect_name) != 1:
			missing_required = true
			break
	var spike_count: = 0
	for effect_name: String in names:
		if effect_name.begins_with("Monster140Bullet3_"):
			spike_count += 1
	if missing_required or not invalid_names.is_empty() or spike_count not in range(1, 4)\
	or nonzero_velocity or non_24fps:
		push_error("MONSTER140_PROBE_FAIL effects=%s velocity=%s fps=%s" % [names, nonzero_velocity, non_24fps])
		quit(1)
		return
	var stone: Node = null
	for effect in bullet_root.get_children():
		if effect.get("skill_name") == "Monster140Bullet1":
			stone = effect
			break
	if stone == null or not bool(stone.get("_collision_tracks_visual")):
		push_error("MONSTER140_PROBE_FAIL stone does not track visual frames")
		quit(1)
		return
	if not _verify_stone_frame(stone, 0, Vector2(74, 87), Vector2(36.95, 43.0)):
		return
	if not _verify_stone_frame(stone, 16, Vector2(73, 86), Vector2(-471.55, 151.5)):
		return
	stone.set("_elapsed", 17.0 / 24.0)
	stone.call("_sync_collision_to_visual_frame", true)
	stone.call("_update_damage_window")
	await physics_frame
	var stone_hit_box: = stone.get_node_or_null("middle/HitBox") as Area2D
	if bool(stone.get("_current_frame_has_visual")) or stone_hit_box == null or stone_hit_box.monitoring:
		push_error("MONSTER140_PROBE_FAIL transparent stone frame can damage")
		quit(1)
		return
	boss.call("_monster140_hit2_3", Vector2(400, 250))
	await process_frame
	var special: Node = null
	for effect in bullet_root.get_children():
		if effect.get("skill_name") == "Monster140Bullet2_3":
			special = effect
			break
	if special == null or float(special.get("lifetime")) != 5.0 or float(special.get("target_move_interval")) != 2.0:
		push_error("MONSTER140_PROBE_FAIL special chain")
		quit(1)
		return
	await process_frame
	if not is_instance_valid(special):
		push_error("MONSTER140_PROBE_FAIL special freed before first move")
		quit(1)
		return
	var early_tween: Tween = special.get("_target_tween")
	if early_tween == null or not early_tween.is_valid():
		push_error("MONSTER140_PROBE_FAIL target did not move on next physics tick")
		quit(1)
		return
	var global_node: = root.get_node_or_null("Global")
	var target_value: Variant = global_node.get("get_player") if global_node != null else null
	if target_value is Node2D and is_instance_valid(target_value):
		(target_value as Node2D).global_position.x += 300.0
	await create_timer(2.05, false).timeout
	if not is_instance_valid(special):
		push_error("MONSTER140_PROBE_FAIL special freed during 48-frame interval")
		quit(1)
		return
	var delayed_tween: Tween = special.get("_target_tween")
	if delayed_tween == null or not delayed_tween.is_valid():
		push_error("MONSTER140_PROBE_FAIL target did not move after 48 source frames")
		quit(1)
		return
	print("MONSTER140_PROBE_OK effects=%s special_lifetime=%s target_interval=%s" % [names, special.get("lifetime"), special.get("target_move_interval")])
	quit(0)

func _verify_walk_facing(boss: Node) -> bool:
	var role_prop: = root.get_node_or_null("RoleProp")
	var global_node: = root.get_node_or_null("Global")
	if role_prop == null or global_node == null:
		push_error("MONSTER140_PROBE_FAIL target autoload")
		quit(1)
		return false
	var previous_target: Variant = global_node.get("get_player")
	var target: = Node2D.new()
	root.add_child(target)
	global_node.set("get_player", target)
	boss.set("_busy", false)
	boss.set("_monster140_body_hidden", false)
	boss.set("_monster140_buried", false)
	var cooldowns: = {}
	var cooldown_until: = Time.get_ticks_msec() + 100000
	for slot in range(1, 5):
		cooldowns[slot] = cooldown_until
	boss.set("_skill_ready_msec", cooldowns)
	boss.global_position = Vector2(500, 400)

	target.global_position = Vector2(800, 400)
	role_prop.set("role_pos_x", 200)
	role_prop.set("role_pos_y", 400)
	boss.call("Monster_Intelligence")
	var stream: Variant = boss.get("_body_stream")
	var body_sprite: Variant = stream.get("_sprite") if stream is Node else null
	var damage_box: = boss.get_node_or_null("BaseDamageBox") as Node2D
	if float(boss.get("velocity").x) <= 0.0 or not bool(boss.get("_facing_right"))\
	or not body_sprite is Sprite2D or not (body_sprite as Sprite2D).flip_h\
	or damage_box == null or not is_equal_approx(damage_box.scale.x, -1.0):
		global_node.set("get_player", previous_target)
		target.free()
		push_error("MONSTER140_PROBE_FAIL right walk facing")
		quit(1)
		return false

	target.global_position = Vector2(200, 400)
	role_prop.set("role_pos_x", 800)
	boss.call("Monster_Intelligence")
	stream = boss.get("_body_stream")
	body_sprite = stream.get("_sprite") if stream is Node else null
	if float(boss.get("velocity").x) >= 0.0 or bool(boss.get("_facing_right"))\
	or not body_sprite is Sprite2D or (body_sprite as Sprite2D).flip_h\
	or damage_box == null or not is_equal_approx(damage_box.scale.x, 1.0):
		global_node.set("get_player", previous_target)
		target.free()
		push_error("MONSTER140_PROBE_FAIL left walk facing")
		quit(1)
		return false
	global_node.set("get_player", previous_target)
	target.free()
	boss.set("velocity", Vector2.ZERO)
	return true

func _verify_stone_frame(
	stone: Node, frame_index: int, expected_size: Vector2, expected_position: Vector2
) -> bool:
	stone.set("_elapsed", float(frame_index) / 24.0)
	stone.call("_sync_collision_to_visual_frame", true)
	var shape_node: = stone.get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
	if shape_node == null or not shape_node.shape is RectangleShape2D:
		push_error("MONSTER140_PROBE_FAIL stone frame %d shape" % frame_index)
		quit(1)
		return false
	var actual_size: = (shape_node.shape as RectangleShape2D).size
	if not actual_size.is_equal_approx(expected_size)\
	or not shape_node.position.is_equal_approx(expected_position):
		push_error(
			"MONSTER140_PROBE_FAIL stone frame %d size=%s position=%s" % [
				frame_index, actual_size, shape_node.position, 
			]
		)
		quit(1)
		return false
	return true
